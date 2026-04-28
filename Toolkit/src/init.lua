-- Toolkit — core infrastructure for STRATA-V1
-- No dependencies. Instantiated once; all modules share the same global instance.
-- Public namespaces: Util, Signal, Services, Connections, Instance, Tasks,
--                    State, Drag, Sound, Storage
-- All APIs degrade gracefully in environments that lack executor or Roblox APIs.

local HttpService = game:GetService("HttpService")

-- ── Util ─────────────────────────────────────────────────────────────────────
-- Stateless helpers. No dependencies; safe to use anywhere.

local Util = {}

function Util.IsCallable(value)
	return type(value) == "function"
end

function Util.Try(callback, ...)
	if not Util.IsCallable(callback) then
		return false, "Expected callback to be a function"
	end

	return pcall(callback, ...)
end

function Util.TableShallowCopy(source)
	local copy = {}
	if type(source) ~= "table" then
		return copy
	end

	for key, value in pairs(source) do
		copy[key] = value
	end

	return copy
end

function Util.TableDeepCopy(source, seen)
	if type(source) ~= "table" then
		return source
	end

	seen = seen or {}
	if seen[source] then
		return seen[source]
	end

	local copy = {}
	seen[source] = copy

	for key, value in pairs(source) do
		copy[Util.TableDeepCopy(key, seen)] = Util.TableDeepCopy(value, seen)
	end

	return copy
end

function Util.Assign(target, ...)
	target = target or {}

	for index = 1, select("#", ...) do
		local source = select(index, ...)
		if type(source) == "table" then
			for key, value in pairs(source) do
				target[key] = value
			end
		end
	end

	return target
end

function Util.ClearTable(target)
	if type(target) ~= "table" then
		return target
	end

	for key in pairs(target) do
		target[key] = nil
	end

	return target
end

function Util.RandomString(length)
	length = math.max(1, tonumber(length) or 12)

	local characters = table.create(length)
	for index = 1, length do
		characters[index] = string.char(math.random(48, 122))
	end

	return table.concat(characters)
end

-- Falls back to RandomString(16) when HttpService.GenerateGUID is unavailable.
function Util.GenerateId(prefix)
	prefix = prefix or "id"

	local success, guid = pcall(HttpService.GenerateGUID, HttpService, false)
	if success and type(guid) == "string" then
		return string.format("%s_%s", prefix, guid:gsub("%-", ""))
	end

	return string.format("%s_%s", prefix, Util.RandomString(16))
end

-- ── Services ─────────────────────────────────────────────────────────────────
-- Cached game:GetService wrapper. Strict mode turns nil returns into errors.

local Services = {}
Services.__index = Services

function Services.new(options)
	local self = setmetatable({}, Services)
	self._cache = {}
	self._strict = options and options.Strict or false

	return self
end

-- When strict=true, Get() errors on missing services instead of returning nil.
function Services:SetStrict(enabled)
	self._strict = not not enabled
end

-- Returns the service or nil (errors in strict mode).
function Services:Get(name)
	if self._cache[name] then
		return self._cache[name]
	end

	local success, service = pcall(game.GetService, game, name)
	if success then
		self._cache[name] = service
		return service
	end

	if self._strict then
		error(string.format("[Toolkit.Services] Failed to resolve service '%s'", tostring(name)))
	end

	return nil
end

-- Like Get but asserts; use for services the caller cannot function without.
function Services:Require(name)
	local service = self:Get(name)
	assert(service, string.format("[Toolkit.Services] Missing service '%s'", tostring(name)))

	return service
end

-- ── Connections ───────────────────────────────────────────────────────────────
-- Tracks RBXScriptConnections and custom Disconnect tables for bulk cleanup.

local Connections = {}
Connections.__index = Connections

local function disconnect(connection)
	if connection == nil then
		return
	end

	if typeof(connection) == "RBXScriptConnection" then
		pcall(function()
			connection:Disconnect()
		end)
		return
	end

	if type(connection) == "table" and type(connection.Disconnect) == "function" then
		pcall(function()
			connection:Disconnect()
		end)
	end
end

function Connections.new()
	local self = setmetatable({}, Connections)
	self._connections = {}

	return self
end

function Connections:Track(connection)
	self._connections[connection] = true
	return connection
end

function Connections:Connect(signal, callback)
	assert(signal and type(signal.Connect) == "function", "[Toolkit.Connections] Signal must support :Connect()")
	assert(type(callback) == "function", "[Toolkit.Connections] Callback must be a function")

	return self:Track(signal:Connect(callback))
end

function Connections:Cleanup()
	for connection in pairs(self._connections) do
		disconnect(connection)
		self._connections[connection] = nil
	end
end

-- ── InstanceManager ───────────────────────────────────────────────────────────
-- Wraps Instance.new with optional lifecycle tracking. Pass `_skipTrack=true`
-- in the properties table to create an instance without adding it to cleanup.

local InstanceManager = {}
InstanceManager.__index = InstanceManager

local function applyProperties(instance, properties)
	if type(properties) ~= "table" then
		return
	end

	for key, value in pairs(properties) do
		if string.sub(key, 1, 1) ~= "_" then
			instance[key] = value
		end
	end
end

function InstanceManager.new()
	local self = setmetatable({}, InstanceManager)
	self._tracked = {}

	return self
end

function InstanceManager:Track(instance)
	if instance then
		self._tracked[instance] = true
	end

	return instance
end

function InstanceManager:Create(className, properties)
	assert(type(className) == "string", "[Toolkit.Instance] className must be a string")

	local instance = Instance.new(className)
	applyProperties(instance, properties)

	if not (type(properties) == "table" and properties._skipTrack) then
		self:Track(instance)
	end

	return instance
end

function InstanceManager:Destroy(instance)
	if not instance then
		return
	end

	self._tracked[instance] = nil

	pcall(function()
		instance.Parent = nil
	end)

	pcall(function()
		instance:Destroy()
	end)
end

function InstanceManager:Cleanup()
	local tracked = Util.TableShallowCopy(self._tracked)

	for instance in pairs(tracked) do
		self:Destroy(instance)
	end
end

-- ── Tasks ─────────────────────────────────────────────────────────────────────
-- Tracked task.spawn / task.delay wrappers. Errors are caught via xpcall.
-- Threads auto-untrack on completion; call Cancel to stop early.

local Tasks = {}
Tasks.__index = Tasks

function Tasks.new()
	local self = setmetatable({}, Tasks)
	self._threads = {}

	return self
end

function Tasks:_track(thread)
	if thread ~= nil then
		self._threads[thread] = true
	end

	return thread
end

function Tasks:_untrack(thread)
	if thread ~= nil then
		self._threads[thread] = nil
	end
end

function Tasks:Spawn(callback, ...)
	assert(type(callback) == "function", "[Toolkit.Tasks] Callback must be a function")

	local args = table.pack(...)
	local thread

	thread = task.spawn(function()
		local current = thread or coroutine.running()
		xpcall(function()
			callback(table.unpack(args, 1, args.n))
		end, debug.traceback)
		self:_untrack(current)
	end)

	return self:_track(thread)
end

function Tasks:Delay(duration, callback, ...)
	assert(type(callback) == "function", "[Toolkit.Tasks] Callback must be a function")

	local args = table.pack(...)
	local thread

	thread = task.delay(duration, function()
		local current = thread or coroutine.running()
		xpcall(function()
			callback(table.unpack(args, 1, args.n))
		end, debug.traceback)
		self:_untrack(current)
	end)

	return self:_track(thread)
end

function Tasks:Cancel(thread)
	if not self._threads[thread] then
		return false
	end

	self:_untrack(thread)
	return pcall(task.cancel, thread)
end

function Tasks:Cleanup()
	for thread in pairs(self._threads) do
		pcall(task.cancel, thread)
		self._threads[thread] = nil
	end
end

-- ── State ─────────────────────────────────────────────────────────────────────
-- Key-value store with optional namespaced scopes. State:Scope(key) returns a
-- proxy that prefixes all operations under that key — avoids key collisions.

local State = {}
State.__index = State

local Scope = {}
Scope.__index = Scope

local function getScopeContainer(state, key)
	local container = state._store[key]
	if type(container) ~= "table" then
		container = {}
		state._store[key] = container
	end

	return container
end

function State.new(seed)
	local self = setmetatable({}, State)
	self._store = type(seed) == "table" and seed or {}

	return self
end

function State:Get(key, defaultValue)
	local value = self._store[key]
	if value == nil then
		return defaultValue
	end

	return value
end

function State:Set(key, value)
	self._store[key] = value
	return value
end

function State:Delete(key)
	local value = self._store[key]
	self._store[key] = nil
	return value
end

function State:Clear()
	for key in pairs(self._store) do
		self._store[key] = nil
	end
end

function State:Scope(scopeKey)
	return setmetatable({
		_state = self,
		_scopeKey = scopeKey,
	}, Scope)
end

function Scope:Get(key, defaultValue)
	local container = getScopeContainer(self._state, self._scopeKey)
	local value = container[key]
	if value == nil then
		return defaultValue
	end

	return value
end

function Scope:Set(key, value)
	local container = getScopeContainer(self._state, self._scopeKey)
	container[key] = value
	return value
end

function Scope:Delete(key)
	local container = getScopeContainer(self._state, self._scopeKey)
	local value = container[key]
	container[key] = nil
	return value
end

function Scope:Clear()
	self._state._store[self._scopeKey] = {}
end

-- ── Signal ────────────────────────────────────────────────────────────────────
-- Lua-side event emitter. Fire() dispatches each listener in its own task.spawn
-- thread, so slow listeners don't block later ones.

local Signal = {}
Signal.__index = Signal

local SignalConnection = {}
SignalConnection.__index = SignalConnection

function SignalConnection:Disconnect()
	if not self.Connected then
		return
	end

	self.Connected = false
	self._signal._listeners[self] = nil
end

function Signal.new()
	return setmetatable({
		_destroyed = false,
		_listeners = {},
	}, Signal)
end

function Signal:Connect(callback)
	assert(type(callback) == "function", "[Toolkit.Signal] Callback must be a function")
	assert(not self._destroyed, "[Toolkit.Signal] Cannot connect to a destroyed signal")

	local connection = setmetatable({
		Connected = true,
		Callback = callback,
		_signal = self,
	}, SignalConnection)

	self._listeners[connection] = true
	return connection
end

function Signal:Once(callback)
	local connection

	connection = self:Connect(function(...)
		connection:Disconnect()
		callback(...)
	end)

	return connection
end

function Signal:Fire(...)
	if self._destroyed then
		return
	end

	local args = table.pack(...)

	for connection in pairs(self._listeners) do
		if connection.Connected then
			task.spawn(connection.Callback, table.unpack(args, 1, args.n))
		end
	end
end

function Signal:Wait()
	local thread = coroutine.running()
	local connection

	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread, ...)
	end)

	return coroutine.yield()
end

function Signal:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	for connection in pairs(self._listeners) do
		connection:Disconnect()
	end
end

-- ── Drag ──────────────────────────────────────────────────────────────────────
-- Mouse/touch drag for GuiObjects. Mode="Smooth" lerps on RenderStepped;
-- Mode="Instant" sets position directly. ClampToParent keeps object in bounds.

local Drag = {}
Drag.__index = Drag

local DragBinding = {}
DragBinding.__index = DragBinding

local function isPointerInput(input)
	if not input then
		return false
	end

	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function disconnectAll(connections)
	for key, connection in pairs(connections) do
		disconnect(connection)
		connections[key] = nil
	end
end

function DragBinding:Disconnect()
	if not self.Connected then
		return
	end

	self.Connected = false
	disconnectAll(self._connections)
end

function Drag.new(services)
	local self = setmetatable({}, Drag)
	self._services = services

	return self
end

function Drag:Attach(handle, target, options)
	assert(handle and handle:IsA("GuiObject"), "[Toolkit.Drag] Handle must be a GuiObject")
	assert(target and target:IsA("GuiObject"), "[Toolkit.Drag] Target must be a GuiObject")

	options = options or {}

	local userInputService = self._services:Require("UserInputService")
	local runService = self._services:Require("RunService")
	local binding = setmetatable({
		Connected = true,
		_connections = {},
	}, DragBinding)

	local dragging = false
	local dragInput
	local dragStart
	local startPosition
	local targetPosition
	local smoothness = math.clamp(tonumber(options.Smoothness) or 0.15, 0.01, 1)
	local mode = tostring(options.Mode or "Instant")

	local function stopDragging()
		dragging = false
		dragInput = nil
	end

	local function updatePosition(input)
		if not dragging or input ~= dragInput then
			return
		end

		local delta = input.Position - dragStart
		local offsetX = startPosition.X.Offset + delta.X
		local offsetY = startPosition.Y.Offset + delta.Y

		if options.ClampToParent and target.Parent and target.Parent:IsA("GuiObject") then
			local parentSize = target.Parent.AbsoluteSize
			offsetX = math.clamp(offsetX, 0, parentSize.X - target.AbsoluteSize.X)
			offsetY = math.clamp(offsetY, 0, parentSize.Y - target.AbsoluteSize.Y)
		end

		targetPosition = UDim2.new(
			startPosition.X.Scale,
			offsetX,
			startPosition.Y.Scale,
			offsetY
		)

		if mode ~= "Smooth" then
			target.Position = targetPosition
		end
	end

	binding._connections.InputBegan = handle.InputBegan:Connect(function(input)
		if not isPointerInput(input) then
			return
		end

		dragging = true
		dragInput = input
		dragStart = input.Position
		startPosition = target.Position
		targetPosition = target.Position

		local inputEnded
		inputEnded = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				disconnect(inputEnded)
				stopDragging()
			end
		end)

		binding._connections.InputEnded = inputEnded
	end)

	binding._connections.InputChanged = handle.InputChanged:Connect(function(input)
		if isPointerInput(input) or input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	binding._connections.GlobalInputChanged = userInputService.InputChanged:Connect(function(input)
		updatePosition(input)
	end)

	if mode == "Smooth" then
		binding._connections.RenderStepped = runService.RenderStepped:Connect(function()
			if not dragging or not targetPosition then
				return
			end

			local current = target.Position
			target.Position = UDim2.new(
				current.X.Scale + (targetPosition.X.Scale - current.X.Scale) * smoothness,
				current.X.Offset + (targetPosition.X.Offset - current.X.Offset) * smoothness,
				current.Y.Scale + (targetPosition.Y.Scale - current.Y.Scale) * smoothness,
				current.Y.Offset + (targetPosition.Y.Offset - current.Y.Offset) * smoothness
			)
		end)
	end

	binding._connections.AncestryChanged = target.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			binding:Disconnect()
		end
	end)

	return binding
end

function Drag:AttachInstant(handle, target, options)
	options = Util.TableShallowCopy(options or {})
	options.Mode = "Instant"
	return self:Attach(handle, target, options)
end

function Drag:AttachSmooth(handle, target, options)
	options = Util.TableShallowCopy(options or {})
	options.Mode = "Smooth"
	if options.Smoothness == nil then
		options.Smoothness = 0.15
	end

	return self:Attach(handle, target, options)
end

-- ── Sound ─────────────────────────────────────────────────────────────────────
-- Resolves and plays audio from rbxassetid, local file path, or HTTP URL.
-- Resolve() tries: rbxassetid prefix → local file via getcustomasset →
--   external HTTP download → FallbackAssetId option (in that order).

local Sound = {}
Sound.__index = Sound

local function normalizeAssetId(source)
	if type(source) == "number" then
		return string.format("rbxassetid://%d", source)
	end

	if type(source) ~= "string" then
		return nil
	end

	if string.match(source, "^rbxassetid://%d+$") then
		return source
	end

	if string.match(source, "^%d+$") then
		return "rbxassetid://" .. source
	end

	return nil
end

local function isExternalUrl(source)
	return type(source) == "string" and string.match(source, "^https?://") ~= nil
end

local function isLikelyFilePath(source)
	if type(source) ~= "string" then
		return false
	end

	return string.match(source, "^[A-Za-z]:[\\/].+") ~= nil
		or string.match(source, "^%.[\\/]") ~= nil
		or string.match(source, "^/") ~= nil
end

local function sanitizeFileName(value)
	value = tostring(value or "sound")
	value = string.gsub(value, "[^%w%-_%.]", "_")
	if value == "" then
		return "sound"
	end

	return value
end

local function ensureCacheFolder()
	local folder = "StrataCache"
	if type(makefolder) == "function" then
		pcall(makefolder, folder)
	end

	return folder
end

local function extractFileName(path, fallbackName)
	if type(path) ~= "string" or path == "" then
		return sanitizeFileName(fallbackName or "sound")
	end

	local normalized = string.gsub(path, "\\", "/")
	local fileName = string.match(normalized, "([^/]+)$")
	return sanitizeFileName(fileName or fallbackName or "sound")
end

local function resolveCustomAssetHandler()
	if type(getcustomasset) == "function" then
		return getcustomasset
	end

	if type(getsynasset) == "function" then
		return getsynasset
	end

	return nil
end

local function resolveRequestHandler()
	if type(request) == "function" then
		return request
	end

	if type(http_request) == "function" then
		return http_request
	end

	if type(httprequest) == "function" then
		return httprequest
	end

	if type(syn) == "table" and type(syn.request) == "function" then
		return syn.request
	end

	if type(syn_request) == "function" then
		return syn_request
	end

	return nil
end

local function getHttpContent(url)
	if type(url) ~= "string" then
		return nil
	end

	local requestHandler = resolveRequestHandler()
	if type(requestHandler) == "function" then
		local success, response = pcall(requestHandler, {
			Url = url,
			Method = "GET",
		})
		if success then
			if type(response) == "table" and type(response.Body) == "string" then
				return response.Body
			end

			if type(response) == "string" then
				return response
			end
		end
	end

	if type(game.HttpGetAsync) == "function" then
		local success, result = pcall(game.HttpGetAsync, game, url)
		if success and type(result) == "string" then
			return result
		end
	end

	if type(game.HttpGet) == "function" then
		local success, result = pcall(game.HttpGet, game, url)
		if success and type(result) == "string" then
			return result
		end
	end

	return nil
end

function Sound.new(services, instanceManager)
	local self = setmetatable({}, Sound)
	self._services = services
	self._instances = instanceManager
	self._cache = {}
	self._active = {}

	return self
end

function Sound:_getCacheKey(source, options)
	local cacheKey = options and options.CacheKey
	if cacheKey ~= nil then
		return tostring(cacheKey)
	end

	return tostring(source)
end

function Sound:_getFallbackAssetId(options)
	return normalizeAssetId(options and options.FallbackAssetId)
end

function Sound:_getSoundParent(options)
	if options and options.Parent then
		return options.Parent
	end

	return self._services:Get("SoundService")
		or self._services:Get("CoreGui")
		or workspace
end

function Sound:_resolveLocalFile(source)
	local customAsset = resolveCustomAssetHandler()
	if type(customAsset) ~= "function" then
		return nil
	end

	if type(isfile) == "function" then
		local success, exists = pcall(isfile, source)
		if success and not exists then
			return nil
		end
	end

	for _, path in ipairs({ source, string.gsub(source, "\\", "/") }) do
		local success, asset = pcall(customAsset, path)
		if success and type(asset) == "string" then
			return asset
		end
	end

	if type(readfile) ~= "function" or type(writefile) ~= "function" then
		return nil
	end

	for _, path in ipairs({ source, string.gsub(source, "\\", "/") }) do
		local readSuccess, content = pcall(readfile, path)
		if readSuccess and type(content) == "string" and content ~= "" then
			local folder = ensureCacheFolder()
			local cachePath = string.format("%s/%s", folder, extractFileName(path, "sound.mp3"))
			local writeSuccess = pcall(writefile, cachePath, content)
			if writeSuccess then
				for _, localPath in ipairs({ cachePath, string.gsub(cachePath, "\\", "/") }) do
					local assetSuccess, asset = pcall(customAsset, localPath)
					if assetSuccess and type(asset) == "string" then
						return asset
					end
				end
			end
		end
	end

	return nil
end

function Sound:_resolveExternalFile(source, options)
	local customAsset = resolveCustomAssetHandler()
	if type(writefile) ~= "function" or type(customAsset) ~= "function" then
		return nil
	end

	local content = getHttpContent(source)
	if not content then
		return nil
	end

	local extension = options and options.Extension
	if type(extension) ~= "string" or extension == "" then
		extension = string.match(source, "%.([%w]+)$") or "mp3"
	end

	local baseName = options and options.FileName
	if type(baseName) ~= "string" or baseName == "" then
		baseName = sanitizeFileName((options and options.CacheKey) or source)
	end

	local folder = ensureCacheFolder()
	local filePath = string.format("%s/%s.%s", folder, sanitizeFileName(baseName), sanitizeFileName(extension))
	local writeSuccess = pcall(writefile, filePath, content)
	if not writeSuccess then
		return nil
	end

	for _, localPath in ipairs({ filePath, string.gsub(filePath, "\\", "/") }) do
		local assetSuccess, asset = pcall(customAsset, localPath)
		if assetSuccess and type(asset) == "string" then
			return asset
		end
	end

	return nil
end

function Sound:Resolve(source, options)
	options = Util.TableShallowCopy(options or {})
	local cacheKey = self:_getCacheKey(source, options)
	local cached = self._cache[cacheKey]
	if type(cached) == "string" then
		return cached
	end

	local resolved = normalizeAssetId(source)
	if not resolved and isLikelyFilePath(source) then
		resolved = self:_resolveLocalFile(source)
	end

	if not resolved and isExternalUrl(source) then
		resolved = self:_resolveExternalFile(source, options)
	end

	if not resolved then
		resolved = self:_getFallbackAssetId(options)
	end

	if type(resolved) == "string" then
		self._cache[cacheKey] = resolved
		return resolved
	end

	return nil
end

function Sound:_createInstance(properties, options)
	local factory = options and options.InstanceFactory
	if type(factory) == "function" then
		local success, instance = pcall(factory, properties)
		if success and instance then
			return instance
		end
	end

	return self._instances:Create("Sound", properties)
end

function Sound:_destroyInstance(sound, options)
	local destroyer = options and options.Destroyer
	if type(destroyer) == "function" then
		pcall(destroyer, sound)
		return
	end

	self._instances:Destroy(sound)
end

function Sound:_track(sound, options)
	if not sound then
		return
	end

	local entry = {
		Destroyer = function()
			self:_destroyInstance(sound, options)
		end,
	}

	self._active[sound] = entry

	if options.DestroyOnEnd and not options.Looped and sound.Ended then
		entry.EndedConnection = sound.Ended:Connect(function()
			local activeEntry = self._active[sound]
			if not activeEntry then
				return
			end

			if activeEntry.EndedConnection then
				disconnect(activeEntry.EndedConnection)
			end

			self._active[sound] = nil
			activeEntry.Destroyer()
		end)
	end

	if sound.AncestryChanged then
		entry.AncestryConnection = sound.AncestryChanged:Connect(function(_, parent)
			if parent ~= nil then
				return
			end

			local activeEntry = self._active[sound]
			if not activeEntry then
				return
			end

			if activeEntry.EndedConnection then
				disconnect(activeEntry.EndedConnection)
			end

			if activeEntry.AncestryConnection then
				disconnect(activeEntry.AncestryConnection)
			end

			self._active[sound] = nil
		end)
	end
end

function Sound:Create(source, options)
	options = Util.TableShallowCopy(options or {})
	local soundId = self:Resolve(source, options)
	if not soundId then
		return nil
	end

	local sound = self:_createInstance({
		Name = options.Name,
		Parent = self:_getSoundParent(options),
		SoundId = soundId,
		Volume = tonumber(options.Volume) or 0.5,
		PlaybackSpeed = tonumber(options.PlaybackSpeed) or 1,
		Looped = not not options.Looped,
		TimePosition = tonumber(options.TimePosition) or 0,
	}, options)

	if not sound then
		return nil
	end

	self:_track(sound, options)
	return sound
end

function Sound:Preload(source, options)
	options = Util.TableShallowCopy(options or {})
	local soundId = self:Resolve(source, options)
	if not soundId then
		return nil
	end

	local contentProvider = self._services:Get("ContentProvider")
	if not contentProvider or type(contentProvider.PreloadAsync) ~= "function" then
		return soundId
	end

	local sound = self._instances:Create("Sound", {
		Name = options.Name or "PreloadSound",
		Parent = self:_getSoundParent(options),
		SoundId = soundId,
		Volume = 0,
		_skipTrack = true,
	})

	pcall(contentProvider.PreloadAsync, contentProvider, { sound })
	self._instances:Destroy(sound)

	return soundId
end

function Sound:Play(source, options)
	options = Util.TableShallowCopy(options or {})
	if options.DestroyOnEnd == nil then
		options.DestroyOnEnd = not options.Looped
	end

	local sound = self:Create(source, options)
	if not sound then
		return nil
	end

	local success = pcall(sound.Play, sound)
	if not success then
		local entry = self._active[sound]
		if entry then
			if entry.EndedConnection then
				disconnect(entry.EndedConnection)
			end
			if entry.AncestryConnection then
				disconnect(entry.AncestryConnection)
			end
			self._active[sound] = nil
		end
		self:_destroyInstance(sound, options)
		return nil
	end

	return sound
end

function Sound:StopAll()
	for sound, entry in pairs(self._active) do
		pcall(sound.Stop, sound)
		if entry.EndedConnection then
			disconnect(entry.EndedConnection)
		end
		if entry.AncestryConnection then
			disconnect(entry.AncestryConnection)
		end
		self._active[sound] = nil
		entry.Destroyer()
	end
end

function Sound:Cleanup()
	self:StopAll()
	Util.ClearTable(self._cache)
end

-- ── Storage ───────────────────────────────────────────────────────────────────
-- Executor filesystem wrapper. Degrades silently when readfile/writefile are
-- unavailable (e.g., Studio). rootFolder is created on disk at construction time.

local Storage = {}
Storage.__index = Storage

local function trimPath(path)
	path = tostring(path or "")
	path = string.gsub(path, "\\", "/")
	path = string.gsub(path, "/+", "/")
	path = string.gsub(path, "^/+", "")
	path = string.gsub(path, "/+$", "")
	return path
end

local function getPathStem(path)
	local normalized = trimPath(path)
	local fileName = string.match(normalized, "([^/]+)$") or normalized
	return (string.gsub(fileName, "%.[^%.]+$", ""))
end

function Storage.new(rootFolder)
	local self = setmetatable({}, Storage)
	self.RootFolder = trimPath(rootFolder ~= nil and rootFolder or "StrataData")
	self._json = HttpService
	self._supportsFiles = type(readfile) == "function"
		and type(writefile) == "function"
		and type(isfile) == "function"
	self._supportsFolders = type(isfolder) == "function"
		and type(makefolder) == "function"
	self._supportsLists = type(listfiles) == "function"
	self:EnsureFolder("")
	return self
end

function Storage:_join(subpath)
	local child = trimPath(subpath)
	if child == "" then
		return self.RootFolder
	end
	if self.RootFolder == "" then
		return child
	end
	return self.RootFolder .. "/" .. child
end

function Storage:EnsureFolder(subpath)
	if not self._supportsFolders then
		return false
	end

	local target = self:_join(subpath)
	local current = ""
	for part in string.gmatch(target, "[^/]+") do
		current = current == "" and part or (current .. "/" .. part)
		local ok, exists = pcall(isfolder, current)
		if not ok or not exists then
			pcall(makefolder, current)
		end
	end

	return true
end

function Storage:Exists(path)
	if not self._supportsFiles then
		return false
	end

	local ok, exists = pcall(isfile, self:_join(path))
	return ok and exists == true
end

function Storage:ReadString(path, defaultValue)
	if not self._supportsFiles then
		return defaultValue
	end

	local fullPath = self:_join(path)
	local ok, content = pcall(readfile, fullPath)
	if ok and type(content) == "string" then
		return content
	end

	return defaultValue
end

function Storage:WriteString(path, content)
	if not self._supportsFiles then
		return false
	end

	local normalized = trimPath(path)
	local folder = string.match(normalized, "^(.*)/[^/]+$")
	if folder and folder ~= "" then
		self:EnsureFolder(folder)
	end

	local ok = pcall(writefile, self:_join(normalized), tostring(content or ""))
	return ok
end

function Storage:ReadJson(path, defaultValue)
	local content = self:ReadString(path, nil)
	if type(content) ~= "string" then
		return defaultValue
	end

	local ok, decoded = pcall(self._json.JSONDecode, self._json, content)
	if ok then
		return decoded
	end

	return defaultValue
end

function Storage:WriteJson(path, payload)
	local ok, encoded = pcall(self._json.JSONEncode, self._json, payload)
	if not ok then
		return false
	end

	return self:WriteString(path, encoded)
end

function Storage:Delete(path)
	if type(delfile) ~= "function" then
		return false
	end

	local fullPath = self:_join(path)
	local ok, exists = pcall(isfile, fullPath)
	if not ok or not exists then
		return false
	end

	return pcall(delfile, fullPath)
end

function Storage:List(subpath, extension)
	if not self._supportsLists then
		return {}
	end

	local folder = self:_join(subpath)
	local ok, files = pcall(listfiles, folder)
	if not ok or type(files) ~= "table" then
		return {}
	end

	local list = {}
	local wantedExtension = type(extension) == "string" and extension or nil

	for _, path in ipairs(files) do
		if type(path) == "string" then
			local normalized = trimPath(path)
			if not wantedExtension or string.sub(normalized, -#wantedExtension) == wantedExtension then
				table.insert(list, getPathStem(normalized))
			end
		end
	end

	table.sort(list)
	return list
end

local Toolkit = {
	Util = Util,
	Signal = Signal,
	Modules = {
		Services = Services,
		Connections = Connections,
		Instance = InstanceManager,
		Tasks = Tasks,
		State = State,
		Sound = Sound,
		Storage = Storage,
	},
}

Toolkit.Services = Services.new()
Toolkit.Connections = Connections.new()
Toolkit.Instance = InstanceManager.new()
Toolkit.Tasks = Tasks.new()
Toolkit.State = State.new()
Toolkit.Drag = Drag.new(Toolkit.Services)
Toolkit.Sound = Sound.new(Toolkit.Services, Toolkit.Instance)
Toolkit.Storage = Storage.new("Strata")

function Toolkit:Cleanup()
	self.Connections:Cleanup()
	self.Tasks:Cleanup()
	self.Sound:Cleanup()
	self.Instance:Cleanup()
end

return Toolkit
