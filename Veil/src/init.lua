return function(Toolkit)
	assert(type(Toolkit) == "table", "[Veil] Toolkit dependency is required")
	assert(type(Toolkit.Util) == "table", "[Veil] Toolkit.Util is required")
	assert(type(Toolkit.Modules) == "table", "[Veil] Toolkit.Modules is required")

	local Util = Toolkit.Util
	local ServicesBase = Toolkit.Modules.Services
	local InstanceBase = Toolkit.Modules.Instance
	local StateBase = Toolkit.Modules.State

	local configState = StateBase.new({
		NameLength = 18,
		DisplayOrder = 2147483647,
		RootSurface = "Root",
	})

	local Config = {}

	function Config:Get(key, defaultValue)
		return configState:Get(key, defaultValue)
	end

	function Config:Set(key, value)
		return configState:Set(key, value)
	end

	function Config:Scope(scopeKey)
		return configState:Scope(scopeKey)
	end

	local ServiceIsolation = {}
	ServiceIsolation.__index = ServiceIsolation

	local function safeClone(instance)
		local cloneReference = cloneref or clonereference
		if type(cloneReference) ~= "function" then
			return instance
		end

		local success, cloned = pcall(cloneReference, instance)
		if success and cloned ~= nil then
			return cloned
		end

		return instance
	end

	function ServiceIsolation.new()
		local self = setmetatable({}, ServiceIsolation)
		self._services = ServicesBase.new({
			Strict = false,
		})

		return self
	end

	function ServiceIsolation:Get(name)
		local service = self._services:Get(name)
		if not service then
			return nil
		end

		return safeClone(service)
	end

	function ServiceIsolation:Require(name)
		local service = self:Get(name)
		assert(service, string.format("[Veil.Services] Missing service '%s'", tostring(name)))

		return service
	end

	local Protection = {}
	Protection.__index = Protection

	local function resolveProtectGui()
		if type(protectgui) == "function" then
			return protectgui
		end

		if type(protect_gui) == "function" then
			return protect_gui
		end

		if type(syn) == "table" and type(syn.protect_gui) == "function" then
			return syn.protect_gui
		end

		return nil
	end

	function Protection.new()
		return setmetatable({}, Protection)
	end

	function Protection:GetHandler()
		return resolveProtectGui()
	end

	function Protection:Apply(instance)
		local handler = self:GetHandler()
		if not handler or not instance then
			return false
		end

		return pcall(handler, instance)
	end

	local InstanceControl = {}
	InstanceControl.__index = InstanceControl

	local RETIRE_ATTRIBUTE = "VeilRetireKey"
	local NAME_ATTRIBUTE = "VeilNameKey"

	local function setAttribute(instance, key, value)
		if not instance then
			return
		end

		pcall(function()
			instance:SetAttribute(key, value)
		end)
	end

	function InstanceControl.new(config)
		local self = setmetatable({}, InstanceControl)
		self._config = config
		self._instances = InstanceBase.new()
		self._protection = nil

		return self
	end

	function InstanceControl:SetProtection(protection)
		self._protection = protection
		return protection
	end

	function InstanceControl:GenerateName(nameKey)
		local base = nameKey or "Veil"
		return string.format("%s_%s", base, Util.RandomString(self._config:Get("NameLength", 18)))
	end

	function InstanceControl:Create(className, properties)
		local props = Util.TableShallowCopy(properties or {})
		local parent = props.Parent
		local retireKey = props._retireKey
		local nameKey = props._nameKey or props.Name
		local shouldProtect = props._protect or className == "ScreenGui"

		props.Parent = nil
		props._retireKey = nil
		props._nameKey = nil
		props._protect = nil

		if props.Name == nil then
			props.Name = self:GenerateName(nameKey)
		end

		local instance = self._instances:Create(className, props)

		if shouldProtect and self._protection then
			self._protection:Apply(instance)
		end

		if retireKey then
			setAttribute(instance, RETIRE_ATTRIBUTE, retireKey)
		end

		if nameKey then
			setAttribute(instance, NAME_ATTRIBUTE, nameKey)
		end

		if parent then
			instance.Parent = parent
		end

		return instance
	end

	function InstanceControl:GetRetireKey(instance)
		local success, value = pcall(function()
			return instance:GetAttribute(RETIRE_ATTRIBUTE)
		end)

		if success then
			return value
		end

		return nil
	end

	function InstanceControl:RetireDuplicates(parent, retireKey, current)
		if not parent or not retireKey then
			return
		end

		for _, child in ipairs(parent:GetChildren()) do
			if child ~= current and self:GetRetireKey(child) == retireKey then
				pcall(function()
					if child:IsA("LayerCollector") then
						child.Enabled = false
					end
				end)

				pcall(function()
					child.Name = self:GenerateName("Retired")
				end)

				pcall(function()
					child.Parent = nil
				end)

				pcall(function()
					child:Destroy()
				end)
			end
		end
	end

	function InstanceControl:SecureDestroy(instance)
		if not instance then
			return
		end

		pcall(function()
			if instance:IsA("LayerCollector") then
				instance.Enabled = false
			end
		end)

		self._instances:Destroy(instance)
	end

	local GUI = {}
	GUI.__index = GUI

	local function safeCall(callback, ...)
		local success, result = pcall(callback, ...)
		if success then
			return result
		end

		return nil
	end

	function GUI.new(services, config, protection, instanceControl)
		local self = setmetatable({}, GUI)
		self._services = services
		self._config = config
		self._protection = protection
		self._instance = instanceControl
		self._surfaces = {}

		return self
	end

	function GUI:_getLocalPlayer()
		local players = self._services:Get("Players")
		if not players then
			return nil
		end

		return players.LocalPlayer or safeCall(function()
			return players.PlayerAdded:Wait()
		end)
	end

	function GUI:_getHiddenParent()
		local hiddenGetter = get_hidden_gui or gethui
		if type(hiddenGetter) ~= "function" then
			return nil
		end

		local parent = safeCall(hiddenGetter)
		if typeof(parent) == "Instance" then
			return parent
		end

		return nil
	end

	function GUI:_getCoreGui()
		return self._services:Get("CoreGui")
	end

	function GUI:_getPlayerGui()
		local localPlayer = self:_getLocalPlayer()
		if not localPlayer then
			return nil
		end

		return safeCall(function()
			return localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")
		end)
	end

	function GUI:ResolveParent()
		local hiddenParent = self:_getHiddenParent()
		if hiddenParent then
			return hiddenParent, "hidden"
		end

		local coreGui = self:_getCoreGui()
		if self._protection:GetHandler() and coreGui then
			return coreGui, "protected-coregui"
		end

		if coreGui then
			return coreGui, "coregui"
		end

		return self:_getPlayerGui(), "playergui"
	end

	function GUI:SafeParent(instance, options)
		if not instance then
			return nil
		end

		options = options or {}
		local retireKey = options.RetireKey or self._instance:GetRetireKey(instance)
		local parent = options.Parent

		if instance:IsA("LayerCollector") then
			pcall(function()
				instance.ResetOnSpawn = false
			end)

			pcall(function()
				instance.DisplayOrder = self._config:Get("DisplayOrder", 2147483647)
			end)
		end

		if not parent then
			parent = self:ResolveParent()
		end

		self._protection:Apply(instance)

		if parent and retireKey then
			self._instance:RetireDuplicates(parent, retireKey, instance)
		end

		if parent then
			pcall(function()
				instance.Parent = parent
			end)
		end

		return instance
	end

	function GUI:CreateRoot(name)
		local nameKey = name or self._config:Get("RootSurface", "Root")
		local retireKey = string.format("root:%s", nameKey)

		local root = self._instance:Create("ScreenGui", {
			DisplayOrder = self._config:Get("DisplayOrder", 2147483647),
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Global,
			_nameKey = nameKey,
			_retireKey = retireKey,
			_protect = true,
		})

		self:SafeParent(root, {
			RetireKey = retireKey,
		})

		self._surfaces[nameKey] = root
		return root
	end

	function GUI:CreateSurface(name)
		local surfaceKey = name or Util.GenerateId("Surface")
		local retireKey = string.format("surface:%s", surfaceKey)

		local surface = self._instance:Create("ScreenGui", {
			DisplayOrder = self._config:Get("DisplayOrder", 2147483647),
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Global,
			_nameKey = surfaceKey,
			_retireKey = retireKey,
			_protect = true,
		})

		self:SafeParent(surface, {
			RetireKey = retireKey,
		})

		self._surfaces[surfaceKey] = surface
		return surface
	end

	local Hooks = {}
	Hooks.__index = Hooks

	local function wrapHook(callback)
		if type(newcclosure) == "function" then
			local success, wrapped = pcall(newcclosure, callback)
			if success and wrapped then
				return wrapped
			end
		end

		return callback
	end

	function Hooks.new()
		return setmetatable({
			_entries = {},
		}, Hooks)
	end

	function Hooks:HookFunction(target, replacement)
		if type(hookfunction) ~= "function" then
			return nil, "hookfunction unavailable"
		end

		local success, original = pcall(hookfunction, target, wrapHook(replacement))
		if not success then
			return nil, original
		end

		table.insert(self._entries, {
			Kind = "Function",
			Target = target,
			Original = original,
		})

		return original
	end

	function Hooks:HookMetamethod(object, method, callback)
		if type(hookmetamethod) ~= "function" then
			return nil, "hookmetamethod unavailable"
		end

		local success, original = pcall(hookmetamethod, object, method, wrapHook(callback))
		if not success then
			return nil, original
		end

		table.insert(self._entries, {
			Kind = "Metamethod",
			Target = object,
			Method = method,
			Original = original,
		})

		return original
	end

	local Env = {}
	Env.__index = Env

	local function getGlobalEnvironment()
		if type(getgenv) == "function" then
			local success, environment = pcall(getgenv)
			if success and type(environment) == "table" then
				return environment
			end
		end

		if type(getfenv) == "function" then
			local success, environment = pcall(getfenv, 0)
			if success and type(environment) == "table" then
				return environment
			end
		end

		return _G
	end

	function Env.new()
		local self = setmetatable({}, Env)
		self._globals = {}

		return self
	end

	function Env:SetGlobal(key, value)
		self._globals[key] = value
		return value
	end

	function Env:BuildEnvironment(extraGlobals)
		local environment = {}
		local sharedGlobals = Util.Assign({}, self._globals, extraGlobals)
		local parentEnvironment = getGlobalEnvironment()

		return setmetatable(environment, {
			__index = function(_, key)
				local injected = sharedGlobals[key]
				if injected ~= nil then
					return injected
				end

				return parentEnvironment[key]
			end,
			__newindex = function(_, key, value)
				rawset(environment, key, value)
			end,
		})
	end

	function Env:Wrap(callback, extraGlobals)
		if type(callback) ~= "function" then
			return nil, "Expected callback to be a function"
		end

		local environment = self:BuildEnvironment(extraGlobals)

		if type(setfenv) == "function" then
			pcall(setfenv, callback, environment)
		end

		return callback, environment
	end

	function Env:Execute(source, extraGlobals)
		if type(source) ~= "string" then
			return nil, "Expected source to be a string"
		end

		if type(loadstring) ~= "function" then
			return nil, "loadstring unavailable"
		end

		local compiled, compileError = loadstring(source)
		if type(compiled) ~= "function" then
			return nil, compileError
		end

		local wrapped, environment = self:Wrap(compiled, extraGlobals)
		if not wrapped then
			return nil, environment
		end

		local success, result = pcall(wrapped)
		if not success then
			return nil, result
		end

		return result, environment
	end

	local Security = {}
	Security.__index = Security

	local function httpGet(url)
		if type(url) ~= "string" then
			return nil, "Invalid URL"
		end

		if type(game.HttpGetAsync) == "function" then
			local success, response = pcall(game.HttpGetAsync, game, url)
			if success then
				return response
			end
		end

		if type(game.HttpGet) == "function" then
			local success, response = pcall(game.HttpGet, game, url)
			if success then
				return response
			end
		end

		return nil, "HttpGet unavailable"
	end

	function Security.new(config, env)
		local self = setmetatable({}, Security)
		self._config = config
		self._env = env
		self._api = nil

		return self
	end

	function Security:SetValidator(callback)
		self._config:Set("SecurityValidator", callback)
		return callback
	end

	function Security:LoadAPI(url)
		local source, err = httpGet(url)
		if not source then
			return nil, err
		end

		local result, environment = self._env:Execute(source, {
			Security = self,
		})

		if result ~= nil then
			self._api = result
			self._config:Set("SecurityAPIUrl", url)
		end

		return result, environment
	end

	function Security:ValidateKey(key)
		local validator = self._config:Get("SecurityValidator")
		if type(validator) == "function" then
			local success, result, detail = pcall(validator, key, self._api)
			if success then
				return result, detail
			end

			return false, result
		end

		if type(self._api) == "table" then
			local apiValidator = self._api.ValidateKey or self._api.validateKey or self._api.check_key
			if type(apiValidator) == "function" then
				local success, result, detail = pcall(apiValidator, self._api, key)
				if success then
					return result, detail
				end

				return false, result
			end
		end

		return false, "No validator configured"
	end

	local Veil = {
		Toolkit = Toolkit,
		Config = Config,
	}

	Veil.Services = ServiceIsolation.new()
	Veil.Protection = Protection.new()
	Veil.Instance = InstanceControl.new(Config)
	Veil.Instance:SetProtection(Veil.Protection)
	Veil.GUI = GUI.new(Veil.Services, Config, Veil.Protection, Veil.Instance)
	Veil.Hooks = Hooks.new()
	Veil.Env = Env.new()
	Veil.Security = Security.new(Config, Veil.Env)

	Veil.Env:SetGlobal("Toolkit", Toolkit)
	Veil.Env:SetGlobal("Veil", Veil)

	function Veil.Protect(instance)
		return Veil.Protection:Apply(instance)
	end

	return Veil
end
