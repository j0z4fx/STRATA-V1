local TOOLKIT_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main/Toolkit/src/init.lua"
local VEIL_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main/Veil/src/init.lua"
local AXIS_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main/Axis/src/init.lua"

local Toolkit = loadstring(game:HttpGet(TOOLKIT_URL))()
local Veil = loadstring(game:HttpGet(VEIL_URL))()(Toolkit)
local Axis = loadstring(game:HttpGet(AXIS_URL))()(Toolkit, Veil)

return Axis:CreateWindow({
})
