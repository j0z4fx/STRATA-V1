local Connections = {}
Connections.__index = Connections

local function disconnect(connection)
	if connection == nil then
		return
	end

	if typeof(connection) == "RBXScriptConnection" then
		pcall(function()
			connection:Disconnect()
		end)
		return
	end

	if type(connection) == "table" and type(connection.Disconnect) == "function" then
		pcall(function()
			connection:Disconnect()
		end)
	end
end

function Connections.new()
	local self = setmetatable({}, Connections)
	self._connections = {}

	return self
end

function Connections:Track(connection)
	self._connections[connection] = true
	return connection
end

function Connections:Connect(signal, callback)
	assert(signal and type(signal.Connect) == "function", "[Toolkit.Connections] Signal must support :Connect()")
	assert(type(callback) == "function", "[Toolkit.Connections] Callback must be a function")

	return self:Track(signal:Connect(callback))
end

function Connections:Cleanup()
	for connection in pairs(self._connections) do
		disconnect(connection)
		self._connections[connection] = nil
	end
end

return Connections
