local Tasks = {}
Tasks.__index = Tasks

function Tasks.new()
	local self = setmetatable({}, Tasks)
	self._threads = {}

	return self
end

function Tasks:_track(thread)
	if thread ~= nil then
		self._threads[thread] = true
	end

	return thread
end

function Tasks:_untrack(thread)
	if thread ~= nil then
		self._threads[thread] = nil
	end
end

function Tasks:Spawn(callback, ...)
	assert(type(callback) == "function", "[Toolkit.Tasks] Callback must be a function")

	local args = table.pack(...)
	local thread

	thread = task.spawn(function()
		local current = thread or coroutine.running()
		xpcall(function()
			callback(table.unpack(args, 1, args.n))
		end, debug.traceback)
		self:_untrack(current)
	end)

	return self:_track(thread)
end

function Tasks:Delay(duration, callback, ...)
	assert(type(callback) == "function", "[Toolkit.Tasks] Callback must be a function")

	local args = table.pack(...)
	local thread

	thread = task.delay(duration, function()
		local current = thread or coroutine.running()
		xpcall(function()
			callback(table.unpack(args, 1, args.n))
		end, debug.traceback)
		self:_untrack(current)
	end)

	return self:_track(thread)
end

function Tasks:Cancel(thread)
	if not self._threads[thread] then
		return false
	end

	self:_untrack(thread)
	return pcall(task.cancel, thread)
end

function Tasks:Cleanup()
	for thread in pairs(self._threads) do
		pcall(task.cancel, thread)
		self._threads[thread] = nil
	end
end

return Tasks
