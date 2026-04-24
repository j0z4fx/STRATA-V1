local Dependencies = require(script.Parent.Dependencies)
local Toolkit = Dependencies.GetToolkit()

local State = Toolkit.Modules.State
local configState = State.new({
	NameLength = 18,
	DisplayOrder = 2147483647,
	RootSurface = "Root",
	DisableAttributes = false,
})

local Config = {}

function Config:Get(key, defaultValue)
	return configState:Get(key, defaultValue)
end

function Config:Set(key, value)
	return configState:Set(key, value)
end

function Config:Scope(scopeKey)
	return configState:Scope(scopeKey)
end

return Config
