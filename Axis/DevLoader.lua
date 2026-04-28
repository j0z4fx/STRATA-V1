local TOOLKIT_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main/Toolkit/src/init.lua"
local VEIL_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main/Veil/src/init.lua"
local AXIS_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main/Axis/src/init.lua"
local INSIGHT_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main/Insight/src/init.lua"

-- safeLoad: wraps loadstring so compile errors surface with the module name
-- instead of the opaque "attempt to call a nil value" from nil().
local function safeLoad(source, name)
	local compiled, err = loadstring(source)
	if not compiled then
		error("[DevLoader] " .. name .. " compile error: " .. tostring(err), 0)
	end
	return compiled
end

local Toolkit = safeLoad(game:HttpGet(TOOLKIT_URL), "Toolkit")()
local Veil    = safeLoad(game:HttpGet(VEIL_URL),    "Veil")()(Toolkit)
local Axis    = safeLoad(game:HttpGet(AXIS_URL),    "Axis")()(Toolkit, Veil)
local Insight = safeLoad(game:HttpGet(INSIGHT_URL), "Insight")()(Toolkit, Veil)

local window = Axis:CreateWindow({})

local homeTab = Axis:CreateTab({
	Name = "Home",
	Icon = "house",
})

local profileTab = Axis:CreateTab({
	Name = "Profile",
	Icon = "user-round",
	ShowCharacterViewer = true,
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

settingsLeft:CreateToggle({
	Name = "Player ESP",
	Subtext = "Show boxes and names",
	Default = false,
	Callback = function(value)
		if value then Insight:Enable() else Insight:Disable() end
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

right:SecureInput({
	Name = "Password",
	Placeholder = "••••••••",
	Callback = function(value)
		print("Password set (length):", #value)
	end,
})

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

middle:SectionHeader("Radio — Vertical")

middle:Radio({
	Name = "Team",
	Items = { "Alpha", "Bravo", "Charlie" },
	Default = "Bravo",
	Orientation = "Vertical",
	Callback = function(v) print("Radio vertical:", v) end,
})

middle:SectionHeader("Radio — Horizontal")

middle:Radio({
	Name = "Mode",
	Items = { "Easy", "Normal", "Hard" },
	Default = "Normal",
	Orientation = "Horizontal",
	Callback = function(v) print("Radio horizontal:", v) end,
})

middle:SectionHeader("Curve Editor")

middle:CurveEditor({
	Name = "Easing Curve",
	Callback = function(pts)
		print("CP1:", pts.CP1, "CP2:", pts.CP2)
	end,
})

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

-- Crosshair system (creates its own "Crosshair" tab)
Axis:CreateCrosshair(window, {
	Color = Color3.fromRGB(255, 255, 255),
	Width = 2,
	Length = 8,
	Gap = 3,
	Opacity = 1,
})

-- Character viewer (appears beside window when Profile tab active)
Axis:CreateCharacterViewer(window)

-- Security scanner (creates its own "Scanner" tab)
Axis:CreateScanner(window)

-- Keybind overlay (toggle with RightAlt)
Axis:CreateKeybindOverlay({
	Title = "Keybinds",
	Keybind = Enum.KeyCode.RightAlt,
	Position = "BottomRight",
	Binds = {
		{ Name = "Aimbot",      Key = "[V]",         Active = true  },
		{ Name = "BHop",        Key = "[Backspace]",  Active = true  },
		{ Name = "Fly",         Key = "[G]",          Active = false },
		{ Name = "Silent Aim",  Key = "[Z]",          Active = true  },
		{ Name = "Auto Shoot",  Key = "[H]",          Active = false },
		{ Name = "Third Person",Key = "[N]",          Active = true  },
	},
})

return Axis
