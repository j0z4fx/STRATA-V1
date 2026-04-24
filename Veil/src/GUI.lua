local Dependencies = require(script.Parent.Dependencies)
local Toolkit = Dependencies.GetToolkit()

local Util = Toolkit.Util

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
		if instance.ResetOnSpawn == nil or instance.ResetOnSpawn then
			pcall(function()
				instance.ResetOnSpawn = false
			end)
		end

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
	local root = self._instance:Create("ScreenGui", {
		DisplayOrder = self._config:Get("DisplayOrder", 2147483647),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		_nameKey = nameKey,
		_retireKey = string.format("root:%s", nameKey),
	})

	self:SafeParent(root, {
		RetireKey = string.format("root:%s", nameKey),
	})

	self._surfaces[nameKey] = root
	return root
end

function GUI:CreateSurface(name)
	local surfaceKey = name or Util.GenerateId("Surface")
	local surface = self._instance:Create("ScreenGui", {
		DisplayOrder = self._config:Get("DisplayOrder", 2147483647),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		_nameKey = surfaceKey,
		_retireKey = string.format("surface:%s", surfaceKey),
	})

	self:SafeParent(surface, {
		RetireKey = string.format("surface:%s", surfaceKey),
	})

	self._surfaces[surfaceKey] = surface
	return surface
end

return GUI
