local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Connection:Disconnect()
	if not self.Connected then
		return
	end

	self.Connected = false
	self._signal._listeners[self] = nil
end

function Signal.new()
	return setmetatable({
		_destroyed = false,
		_listeners = {},
	}, Signal)
end

function Signal:Connect(callback)
	assert(type(callback) == "function", "[Toolkit.Signal] Callback must be a function")
	assert(not self._destroyed, "[Toolkit.Signal] Cannot connect to a destroyed signal")

	local connection = setmetatable({
		Connected = true,
		Callback = callback,
		_signal = self,
	}, Connection)

	self._listeners[connection] = true
	return connection
end

function Signal:Once(callback)
	local connection

	connection = self:Connect(function(...)
		connection:Disconnect()
		callback(...)
	end)

	return connection
end

function Signal:Fire(...)
	if self._destroyed then
		return
	end

	local args = table.pack(...)

	for connection in pairs(self._listeners) do
		if connection.Connected then
			task.spawn(connection.Callback, table.unpack(args, 1, args.n))
		end
	end
end

function Signal:Wait()
	local thread = coroutine.running()
	local connection

	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread, ...)
	end)

	return coroutine.yield()
end

function Signal:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	for connection in pairs(self._listeners) do
		connection:Disconnect()
	end
end

return Signal
