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

return State
