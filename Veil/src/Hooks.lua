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

return Hooks
