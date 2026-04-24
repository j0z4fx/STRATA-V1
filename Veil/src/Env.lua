local Dependencies = require(script.Parent.Dependencies)
local Toolkit = Dependencies.GetToolkit()

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

function Env.new(config)
	local self = setmetatable({}, Env)
	self._config = config
	self._globals = {}

	return self
end

function Env:SetGlobal(key, value)
	self._globals[key] = value
	return value
end

function Env:BuildEnvironment(extraGlobals)
	local environment = {}
	local sharedGlobals = Toolkit.Util.Assign({}, self._globals, extraGlobals)
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

return Env
