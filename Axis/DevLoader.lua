local TOOLKIT_URL = "RAW_TOOLKIT_URL"
local VEIL_URL = "RAW_VEIL_URL"
local AXIS_URL = "RAW_AXIS_URL"

local Toolkit = loadstring(game:HttpGet(TOOLKIT_URL))()
local Veil = loadstring(game:HttpGet(VEIL_URL))()(Toolkit)
local Axis = loadstring(game:HttpGet(AXIS_URL))()(Toolkit, Veil)

return Axis:CreateWindow({
	Title = "Axis Dev",
})
