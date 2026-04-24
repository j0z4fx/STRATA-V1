local Dependencies = require(script.Parent.Dependencies)
local Toolkit = Dependencies.GetToolkit()

local BaseServices = Toolkit.Modules.Services

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
	self._services = BaseServices.new({
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

return ServiceIsolation
