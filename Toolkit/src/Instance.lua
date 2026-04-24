local Util = require(script.Parent.Util)

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

return InstanceManager
