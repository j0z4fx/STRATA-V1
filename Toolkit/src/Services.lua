local Services = {}
Services.__index = Services

function Services.new(options)
	local self = setmetatable({}, Services)
	self._cache = {}
	self._strict = options and options.Strict or false

	return self
end

function Services:SetStrict(enabled)
	self._strict = not not enabled
end

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

function Services:Require(name)
	local service = self:Get(name)
	assert(service, string.format("[Toolkit.Services] Missing service '%s'", tostring(name)))

	return service
end

return Services
