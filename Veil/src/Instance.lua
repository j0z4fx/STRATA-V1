local Dependencies = require(script.Parent.Dependencies)
local Toolkit = Dependencies.GetToolkit()

local Util = Toolkit.Util
local BaseInstance = Toolkit.Modules.Instance

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
	self._instances = BaseInstance.new()
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
	local props = Toolkit.Util.TableShallowCopy(properties or {})
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

return InstanceControl
