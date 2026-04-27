local TOOLKIT_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main/Toolkit/src/init.lua"
local VEIL_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main/Veil/src/init.lua"
local AXIS_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main/Axis/src/init.lua"

local Toolkit = loadstring(game:HttpGet(TOOLKIT_URL))()
local Veil = loadstring(game:HttpGet(VEIL_URL))()(Toolkit)
local Axis = loadstring(game:HttpGet(AXIS_URL))()(Toolkit, Veil)

local window = Axis:CreateWindow({})

local homeTab = Axis:CreateTab({
	Name = "Home",
	Icon = "house",
})

Axis:CreateTab({
	Name = "Profile",
	Icon = "user-round",
})

local settingsTab = Axis:CreateTab({
	Name = "Settings",
	Icon = "settings",
	IconScale = 0.8,
	PinnedBottom = true,
})

local settingsLeft = settingsTab.Columns.leftColumn
local settingsRight = settingsTab.Columns.rightColumn

settingsLeft:SectionHeader("Utility")

settingsLeft:CreateToggle({
	Name = "Anti-AFK",
	Subtext = "Prevents idle disconnect",
	Default = false,
	Callback = function(value)
		Axis:SetAntiAFK(value)
	end,
})

settingsRight:Dropdown({
	Name = "Icon Pack",
	Items = { "Lucide", "Phosphor" },
	Default = "Phosphor",
	Callback = function(value)
		Axis:SetIconPack(value)
	end,
})

-- Demo controls on Home tab left column
local left = homeTab.Columns.leftColumn

left:CreateToggle({
	Name = "Example Toggle",
})

left:CreateToggle({
	Name = "Example Toggle",
	Subtext = "With Subtext",
})

left:Label({ Name = "Example Label" })

left:Label({
	Name = "Example Label",
	Subtext = "With Subtext",
})

left:SectionHeader("Section Header")

local colorLabel = left:Label({ Name = "Accent Color" })
colorLabel:AddColorpicker({
	Default = Color3.fromRGB(242, 168, 190),
	Callback = function(color)
		print("Color changed:", color)
	end,
})

left:Slider({
	Name = "Sensitivity",
	Min = 0,
	Max = 100,
	Default = 50,
	Step = 1,
})

left:Slider({
	Name = "Smoothing",
	Min = 0,
	Max = 1,
	Default = 0.5,
	Step = 0.05,
	Subtext = "Camera smoothing amount",
})

left:SectionHeader("Checkboxes")

left:Checkbox({
	Name = "Example Checkbox",
	Default = false,
	Callback = function(v) print("Checkbox:", v) end,
})

left:Checkbox({
	Name = "Example Checkbox",
	Subtext = "With Subtext",
	Default = true,
})

left:SectionHeader("Actions")

left:Button({
	Name = "Connect",
	Callback = function()
		print("Primary button clicked")
	end,
})

left:Button({
	Name = "Disconnect",
	Style = "secondary",
	Callback = function()
		print("Secondary button clicked")
	end,
})

local right = homeTab.Columns.rightColumn

right:SectionHeader("Input")

right:Input({
	Name = "Username",
	Placeholder = "Enter name...",
	MaxLength = 32,
	Callback = function(value)
		print("Input changed:", value)
	end,
})

right:Input({
	Name = "Port",
	Default = "25565",
	Validator = function(v)
		local n = tonumber(v)
		return n ~= nil and n >= 1 and n <= 65535
	end,
	Callback = function(value)
		print("Port:", value)
	end,
})

right:SectionHeader("Selection")

right:Dropdown({
	Name = "Render Quality",
	Items = { "Low", "Medium", "High", "Ultra" },
	Default = "High",
	Callback = function(value)
		print("Dropdown changed:", value)
	end,
})

right:Dropdown({
	Name = "Active Cheats",
	Items = { "Aimbot", "ESP", "Speedhack", "NoRecoil" },
	MultiSelect = true,
	Default = { "ESP" },
	Callback = function(values)
		print("Multi changed:", table.concat(values, ", "))
	end,
})

right:Dropdown({
	Name = "Target Player",
	Items = { "Player1", "Player2", "Player3", "Player4", "Player5", "Player6", "Player7", "Player8" },
	Default = "Player1",
	Searchable = true,
})

local middle = homeTab.Columns.middleColumn

middle:SectionHeader("Notched")

middle:NotchedSlider({
	Name = "Quality",
	Min = 1,
	Max = 5,
	Default = 3,
	Step = 1,
})

middle:SectionHeader("Range")

middle:RangeSlider({
	Name = "Distance Range",
	Min = 0,
	Max = 500,
	DefaultMin = 50,
	DefaultMax = 250,
	Step = 5,
	Subtext = "Minimum and maximum range",
})

return Axis
