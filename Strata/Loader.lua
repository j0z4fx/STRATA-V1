local TOOLKIT_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main/Toolkit/src/init.lua"
local VEIL_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main/Veil/src/init.lua"
local AXIS_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main/Axis/src/init.lua"

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Accent = Color3.fromRGB(242, 168, 190)
local TextColor = Color3.fromRGB(238, 238, 242)
local SurfaceColor = Color3.fromRGB(19, 19, 22)
local BarTrackColor = Color3.fromRGB(24, 24, 27)
local TotalFakeDelay = 1.5

local function getLoaderParent()
	local player = Players.LocalPlayer
	if player then
		local success, playerGui = pcall(function()
			return player:WaitForChild("PlayerGui", 5)
		end)

		if success and playerGui then
			return playerGui
		end
	end

	return CoreGui
end

local function createInstance(className, properties)
	local instance = Instance.new(className)

	for key, value in pairs(properties) do
		instance[key] = value
	end

	return instance
end

local loaderGui = createInstance("ScreenGui", {
	Name = "StrataLoader",
	DisplayOrder = 10_000,
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = getLoaderParent(),
})

local root = createInstance("Frame", {
	Name = "Root",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = SurfaceColor,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(320, 108),
	Parent = loaderGui,
})

createInstance("UICorner", {
	CornerRadius = UDim.new(0, 14),
	Parent = root,
})

createInstance("TextLabel", {
	Name = "Title",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	Position = UDim2.fromOffset(16, 14),
	Size = UDim2.new(1, -32, 0, 24),
	Text = "Strata",
	TextColor3 = Accent,
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center,
	Parent = root,
})

local barTrack = createInstance("Frame", {
	Name = "BarTrack",
	BackgroundColor3 = BarTrackColor,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(16, 50),
	Size = UDim2.new(1, -32, 0, 8),
	Parent = root,
})

createInstance("UICorner", {
	CornerRadius = UDim.new(1, 0),
	Parent = barTrack,
})

local barFill = createInstance("Frame", {
	Name = "BarFill",
	BackgroundColor3 = Accent,
	BackgroundTransparency = 0.8,
	BorderSizePixel = 0,
	Size = UDim2.new(0, 0, 1, 0),
	Parent = barTrack,
})

createInstance("UICorner", {
	CornerRadius = UDim.new(1, 0),
	Parent = barFill,
})

local statusLabel = createInstance("TextLabel", {
	Name = "Status",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	Position = UDim2.fromOffset(16, 68),
	Size = UDim2.new(1, -76, 0, 18),
	Text = "Preparing",
	TextColor3 = TextColor,
	TextSize = 12,
	TextTransparency = 0.2,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center,
	Parent = root,
})

local percentLabel = createInstance("TextLabel", {
	Name = "Percent",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamMedium,
	Position = UDim2.new(1, -60, 0, 68),
	Size = UDim2.fromOffset(44, 18),
	Text = "0%",
	TextColor3 = TextColor,
	TextSize = 12,
	TextTransparency = 0.2,
	TextXAlignment = Enum.TextXAlignment.Right,
	TextYAlignment = Enum.TextYAlignment.Center,
	Parent = root,
})

local function updateLoader(stepText, percent)
	local clamped = math.clamp(math.floor(percent + 0.5), 0, 100)
	statusLabel.Text = stepText
	percentLabel.Text = string.format("%d%%", clamped)
	barFill:TweenSize(UDim2.new(clamped / 100, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
end

local function destroyLoader()
	if loaderGui then
		loaderGui:Destroy()
		loaderGui = nil
	end
end

local function failLoader(message)
	statusLabel.Text = message
	percentLabel.Text = "ERR"
	barFill.BackgroundTransparency = 0.55
	barFill.Size = UDim2.new(1, 0, 1, 0)
	error(message, 0)
end

local context = {}
local steps = {
	{
		Text = "Loading Toolkit...",
		Error = "[Strata Loader] Failed to load Toolkit",
		Run = function()
			context.Toolkit = loadstring(game:HttpGet(TOOLKIT_URL))()
		end,
	},
	{
		Text = "Toolkit: resolving services",
	},
	{
		Text = "Toolkit: initializing connections",
	},
	{
		Text = "Toolkit: ready",
	},
	{
		Text = "Loading Veil...",
		Error = "[Strata Loader] Failed to load Veil",
		Run = function()
			context.Veil = loadstring(game:HttpGet(VEIL_URL))()(context.Toolkit)
		end,
	},
	{
		Text = "Veil: initializing protection",
	},
	{
		Text = "Veil: binding environment",
	},
	{
		Text = "Veil: securing interfaces",
	},
	{
		Text = "Veil: ready",
	},
	{
		Text = "Loading Axis...",
		Error = "[Strata Loader] Failed to load Axis",
		Run = function()
			context.Axis = loadstring(game:HttpGet(AXIS_URL))()(context.Toolkit, context.Veil)

			if context.Axis and context.Axis.Surface and context.Axis.Surface:IsA("ScreenGui") then
				context.Axis.Surface.Enabled = false
			end
		end,
	},
	{
		Text = "Axis: building interface",
		Error = "[Strata Loader] Failed to initialize Axis shell",
		Run = function()
			context.Axis:CreateWindow({})
		end,
	},
	{
		Text = "Axis: constructing layout",
	},
	{
		Text = "Axis: registering tabs",
		Error = "[Strata Loader] Failed to initialize tabs",
		Run = function()
			context.Axis:CreateTab({
				Name = "Home",
				Icon = "house",
			})

			context.Axis:CreateTab({
				Name = "Profile",
				Icon = "user-round",
			})

			context.Axis:CreateTab({
				Name = "Settings",
				Icon = "settings",
				IconScale = 0.8,
				PinnedBottom = true,
			})
		end,
	},
	{
		Text = "Axis: ready",
	},
	{
		Text = "Finalizing...",
	},
	{
		Text = "Launching Strata",
		Error = "[Strata Loader] Failed to show main UI",
		Run = function()
			if context.Axis and context.Axis.Surface and context.Axis.Surface:IsA("ScreenGui") then
				context.Axis.Surface.Enabled = true
			end
		end,
	},
}

local perStepDelay = TotalFakeDelay / #steps

for index, step in ipairs(steps) do
	local percent = (index / #steps) * 100
	updateLoader(step.Text, percent)
	task.wait(perStepDelay)

	local ok = true
	if type(step.Run) == "function" then
		ok = pcall(step.Run)
	end

	if not ok then
		failLoader(step.Error)
	end
end

task.wait(0.1)
destroyLoader()

return context.Axis
