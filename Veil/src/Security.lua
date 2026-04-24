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

return Security
