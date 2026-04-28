local DEV = true
local UPDATE_CHECK_ENABLED = true
local UPDATE_CHECK_INTERVAL = 5
local RAW_BASE_URL = "https://raw.githubusercontent.com/j0z4fx/STRATA-V1/main"
local CDN_BASE_URL = "https://cdn.jsdelivr.net/gh/j0z4fx/STRATA-V1@main"
local BASE_URL = DEV and RAW_BASE_URL or CDN_BASE_URL
local LOADER_URL = RAW_BASE_URL .. "/Strata/Loader.lua"
local UPDATE_VALUE_URL = RAW_BASE_URL .. "/Strata/build.txt"

local TOOLKIT_URL = BASE_URL .. "/Toolkit/src/init.lua"
local VEIL_URL = BASE_URL .. "/Veil/src/init.lua"
local AXIS_URL = BASE_URL .. "/Axis/src/init.lua"
local INSIGHT_URL = BASE_URL .. "/Insight/src/init.lua"
local LOAD_COMPLETE_SOUND = BASE_URL .. "/Axis/Sounds/LoadComplete.mp3"

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Accent = Color3.fromRGB(242, 168, 190)
local TextColor = Color3.fromRGB(238, 238, 242)
local SurfaceColor = Color3.fromRGB(19, 19, 22)
local BarTrackColor = Color3.fromRGB(24, 24, 27)
local TotalFakeDelay = 1.5
local context = {}
local GlobalEnv = (getgenv and getgenv()) or _G
local ExistingRuntime = GlobalEnv.__STRATA_RUNTIME

if type(ExistingRuntime) == "table" and type(ExistingRuntime.Cleanup) == "function" then
	pcall(ExistingRuntime.Cleanup, "restart")
end

local Runtime = {
	Id = string.format("StrataRuntime_%d_%d", os.time(), math.random(1000, 9999)),
	Stopped = false,
	Reloading = false,
	CurrentBuildValue = nil,
	Cleanup = nil,
}

GlobalEnv.__STRATA_RUNTIME = Runtime

local function Fetch(url)
	if DEV then
		return game:HttpGet(url .. "?v=" .. tostring(os.time()))
	end

	return game:HttpGet(url)
end

local function FetchFresh(url)
	return game:HttpGet(url .. "?v=" .. tostring(os.time()))
end

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
	BackgroundTransparency = 0.45,
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

local function cleanupRuntime(reason)
	if Runtime.Stopped then
		return
	end

	Runtime.Stopped = true

	if context and context.Axis and type(context.Axis.DestroyAll) == "function" then
		pcall(function()
			context.Axis:DestroyAll()
		end)
	end

	destroyLoader()

	if GlobalEnv.__STRATA_RUNTIME == Runtime and reason ~= "restart" then
		GlobalEnv.__STRATA_RUNTIME = nil
	end
end

Runtime.Cleanup = cleanupRuntime

local function failLoader(message, detail)
	local fullDetail = detail ~= nil and tostring(detail) or ""

	-- Full error to output (not truncated)
	if #fullDetail > 0 then
		warn("[Strata Loader]", message .. "\n  Detail: " .. fullDetail)
	else
		warn("[Strata Loader]", message)
	end

	-- Status bar: red fill
	barFill.BackgroundColor3 = Color3.fromRGB(200, 55, 55)
	barFill.BackgroundTransparency = 0
	barFill.Size = UDim2.new(1, 0, 1, 0)

	statusLabel.Text = message
	statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	percentLabel.Text = "ERR"
	percentLabel.TextColor3 = Color3.fromRGB(255, 100, 100)

	-- Show the compile / runtime detail in a second line
	if #fullDetail > 0 then
		root.Size = UDim2.fromOffset(320, 128)
		createInstance("TextLabel", {
			Name = "ErrorDetail",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromOffset(16, 90),
			Size = UDim2.new(1, -32, 0, 28),
			Text = fullDetail:sub(1, 220),
			TextColor3 = Color3.fromRGB(200, 80, 80),
			TextSize = 10,
			TextTransparency = 0,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Parent = root,
		})
	end

	error(message, 0)
end

local function sanitizeStorageName(value, fallback)
	local text = tostring(value or "")
	text = text:gsub("[\\/:*?\"<>|]", "")
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	text = text:gsub("%s+", " ")
	if text == "" then
		return fallback
	end
	return text
end

local function createManagerButton(column, name, callback, style)
	return column:Button({
		Name = name,
		Style = style or "secondary",
		Callback = callback,
	})
end

local function buildStorageManager(column, options)
	local storage = context.Toolkit.Storage
	local folder = options.Folder
	local title = options.Title
	local emptyLabel = options.EmptyLabel or "None"
	local serialize = options.Serialize
	local apply = options.Apply
	local defaultName = options.DefaultName or "Default"

	storage:EnsureFolder(folder)

	local state = {
		Selected = nil,
	}

	column:SectionHeader(title)

	local nameInput = column:Input({
		Name = title .. " Name",
		Default = defaultName,
		Persist = false,
	})

	local listDropdown = column:Dropdown({
		Name = title .. " List",
		Items = { emptyLabel },
		Default = emptyLabel,
		Persist = false,
	})

	local function readList()
		local items = storage:List(folder, ".json")
		if #items == 0 then
			return { emptyLabel }
		end
		return items
	end

	local function refreshList(selectName)
		local items = readList()
		listDropdown:SetItems(items)
		local target = selectName or state.Selected
		if target and table.find(items, target) then
			listDropdown:Set(target, { Silent = true })
			state.Selected = target
		else
			listDropdown:Set(items[1], { Silent = true })
			state.Selected = items[1] ~= emptyLabel and items[1] or nil
		end
	end

	listDropdown:OnChanged(function(value)
		if value == emptyLabel then
			state.Selected = nil
			return
		end
		state.Selected = value
		nameInput:Set(value, { Silent = true })
	end)

	createManagerButton(column, "Refresh " .. title, function()
		refreshList()
		context.Axis:Toast({
			Title = title,
			Message = "List refreshed",
			Location = "BottomCenter",
			Duration = 2.4,
		})
	end, "secondary")

	createManagerButton(column, "Save " .. title, function()
		local name = sanitizeStorageName(nameInput:GetValue(), nil)
		if not name then
			context.Axis:Notify({
				Title = title,
				Message = "Enter a valid name before saving",
				Location = "TopRight",
				Duration = 3,
			})
			return
		end

		local ok = storage:WriteJson(folder .. "/" .. name .. ".json", serialize())
		if ok then
			refreshList(name)
			context.Axis:Toast({
				Title = title,
				Message = "Saved " .. name,
				Location = "BottomCenter",
			})
		end
	end)

	createManagerButton(column, "Overwrite " .. title, function()
		local name = state.Selected or sanitizeStorageName(nameInput:GetValue(), nil)
		if not name then
			context.Axis:Notify({
				Title = title,
				Message = "Select an existing entry to overwrite",
				Location = "TopRight",
				Duration = 3,
			})
			return
		end

		local ok = storage:WriteJson(folder .. "/" .. name .. ".json", serialize())
		if ok then
			refreshList(name)
			context.Axis:Toast({
				Title = title,
				Message = "Overwrote " .. name,
				Location = "BottomCenter",
			})
		end
	end)

	createManagerButton(column, "Load " .. title, function()
		local name = state.Selected
		if not name then
			context.Axis:Notify({
				Title = title,
				Message = "Select a saved entry first",
				Location = "TopRight",
				Duration = 3,
			})
			return
		end

		local payload = storage:ReadJson(folder .. "/" .. name .. ".json", nil)
		if type(payload) ~= "table" then
			context.Axis:Notify({
				Title = title,
				Message = "Failed to read " .. name,
				Location = "TopRight",
				Duration = 3,
			})
			return
		end

		apply(payload)
		nameInput:Set(name, { Silent = true })
		context.Axis:Toast({
			Title = title,
			Message = "Loaded " .. name,
			Location = "BottomCenter",
		})
	end)

	refreshList()

	return {
		NameInput = nameInput,
		ListDropdown = listDropdown,
		Refresh = refreshList,
	}
end

local steps = {
	{
		Text = "Loading Toolkit...",
		Error = "[Strata Loader] Failed to load Toolkit",
		Run = function()
			local source = Fetch(TOOLKIT_URL)
			local compiled, compileErr = loadstring(source)
			if not compiled then
				error("Compile error: " .. tostring(compileErr), 0)
			end
			context.Toolkit = compiled()
		end,
	},
	{ Text = "Toolkit: resolving services" },
	{ Text = "Toolkit: initializing connections" },
	{ Text = "Toolkit: ready" },

	{
		Text = "Loading Veil...",
		Error = "[Strata Loader] Failed to load Veil",
		Run = function()
			local source = Fetch(VEIL_URL)
			local compiled, compileErr = loadstring(source)
			if not compiled then
				error("Compile error: " .. tostring(compileErr), 0)
			end
			local veilFactory = compiled()
			context.Veil = veilFactory(context.Toolkit)
		end,
	},
	{ Text = "Veil: initializing protection" },
	{ Text = "Veil: binding environment" },
	{ Text = "Veil: securing interfaces" },
	{ Text = "Veil: ready" },
	
	{
		Text = "Loading Axis...",
		Error = "[Strata Loader] Failed to load Axis",
		Run = function()
			local source = Fetch(AXIS_URL)
			local compiled, compileErr = loadstring(source)
			if not compiled then
				error("Compile error: " .. tostring(compileErr), 0)
			end
			local loaded = compiled()

			if type(loaded) == "function" then
				context.Axis = loaded(context.Toolkit, context.Veil)
			else
				context.Axis = loaded
			end

			if context.Axis and context.Axis.Surface and context.Axis.Surface:IsA("ScreenGui") then
				context.Axis.Surface.Enabled = false
			end
		end,
	},

	{
		Text = "Loading Insight...",
		Error = "[Strata Loader] Failed to load Insight",
		Run = function()
			local source = Fetch(INSIGHT_URL)
			local compiled, compileErr = loadstring(source)
			if not compiled then
				error("Compile error: " .. tostring(compileErr), 0)
			end
			local loaded = compiled()
			if type(loaded) == "function" then
				context.Insight = loaded(context.Toolkit, context.Veil)
			else
				context.Insight = loaded
			end
		end,
	},

	{
		Text = "Axis: building interface",
		Error = "[Strata Loader] Failed to initialize Axis shell",
		Run = function()
			context.Window = context.Axis:CreateWindow({})
		end,
	},

	{ Text = "Axis: constructing layout" },

	{
		Text = "Axis: registering tabs",
		Error = "[Strata Loader] Failed to initialize tabs",
		Run = function()
			local homeTab = context.Axis:CreateTab({
				Name = "Home",
				Icon = "house",
			})

			local left = homeTab.Columns.leftColumn
			local middle = homeTab.Columns.middleColumn
			local right = homeTab.Columns.rightColumn
			
			local toggle = left:CreateToggle({
				Text = "Example Toggle",
				Tooltip = "Example Tooltip",
				Default = false,
			})
			
			local toggleWithSubtext = left:CreateToggle({
				Text = "Example Toggle",
				Subtext = "With Subtext",
				Default = false,
			})

			left:SectionHeader("Labels")

			left:Label({
				Text = "Example Label",
			})

			left:Label({
				Text = "Example Label",
				Subtext = "With Subtext",
			})

			left:Divider()

			left:SectionHeader("Sliders")

			left:Slider({
				Name = "Example Slider",
				Min = 0,
				Max = 100,
				Default = 50,
				Step = 1,
			})

			left:Slider({
				Name = "Example Slider",
				Subtext = "With Subtext",
				Min = 0,
				Max = 1,
				Default = 0.5,
				Step = 0.05,
			})

			middle:SectionHeader("Notched Slider")

			middle:NotchedSlider({
				Name = "Example Notched Slider",
				Min = 1,
				Max = 5,
				Default = 3,
				Step = 1,
			})

			middle:SectionHeader("Range Slider")

			middle:RangeSlider({
				Name = "Example Range Slider",
				Min = 0,
				Max = 500,
				DefaultMin = 50,
				DefaultMax = 250,
				Step = 5,
				Subtext = "With Subtext",
			})

			middle:SectionHeader("Dropdowns")

			middle:Dropdown({
				Name = "Example Dropdown",
				Items = { "Option 1", "Option 2", "Option 3" },
				Default = "Option 1",
			})

			middle:Dropdown({
				Name = "Example Dropdown",
				Subtext = "With Subtext",
				Items = { "Option 1", "Option 2", "Option 3" },
				Default = "Option 1",
			})

			right:SectionHeader("Inputs")

			right:Input({
				Name = "Example Input",
				Placeholder = "Type here...",
			})

			right:Input({
				Name = "Example Input",
				Default = "With Default",
				Validator = function(value)
					return #tostring(value) <= 24
				end,
			})

			right:SectionHeader("Pickers")

			local labelWithKeypicker = right:Label({
				Text = "Example Label",
			})

			labelWithKeypicker:AddKeypicker({
				Default = "E",
			})

			toggle:AddKeypicker({
				Default = "Q",
			})

			local labelWithColorpicker = right:Label({
				Text = "Example Label",
				Subtext = "With Subtext",
			})

			labelWithColorpicker:AddColorpicker({
				Default = Color3.fromRGB(242, 168, 190),
			})

			toggleWithSubtext:AddColorpicker({
				Default = Color3.fromRGB(90, 171, 255),
			})

			right:SectionHeader("Actions")

			right:Button({
				Name = "Example Button",
				Callback = function()
					context.Axis:Toast({
						Title = "Example Toast",
						Message = "Button interaction complete",
						Location = "BottomCenter",
					})
				end,
			})

			right:Button({
				Name = "Example Button",
				Style = "secondary",
				Callback = function()
					context.Axis:Notify({
						Title = "Example Notification",
						Message = "Secondary action triggered",
						Location = "TopRight",
					})
				end,
			})

			context.Axis:CreateTab({
				Name = "Profile",
				Icon = "user-round",
				ShowCharacterViewer = true,
			})

			local settingsTab = context.Axis:CreateTab({
				Name = "Settings",
				Icon = "settings",
				IconScale = 0.8,
				PinnedBottom = true,
				ColumnMode = "Triple",
			})
			local settingsLeft = settingsTab.Columns.leftColumn
			local settingsMiddle = settingsTab.Columns.middleColumn
			local settingsRight = settingsTab.Columns.rightColumn

			settingsLeft:SectionHeader("Utility")

			settingsLeft:CreateToggle({
				Text = "Anti-AFK",
				Subtext = "Prevents idle disconnect",
				Default = false,
				PersistKey = "Settings.AntiAFK",
				Callback = function(value)
					context.Axis:SetAntiAFK(value)
				end,
			})

			if context.Insight then
				settingsLeft:CreateToggle({
					Text = "Player ESP",
					Subtext = "Show boxes and names",
					Default = false,
					PersistKey = "Settings.PlayerESP",
					Callback = function(value)
						if value then context.Insight:Enable() else context.Insight:Disable() end
					end,
				})
			end

			settingsLeft:SectionHeader("Interface")

			local visibilityLabel = settingsLeft:Label({
				Text = "Window Visibility",
				Subtext = "Show or hide the Strata window",
				PersistKey = "Settings.WindowVisibilityLabel",
			})

			visibilityLabel:AddKeypicker({
				Default = "RightShift",
				Mode = "Toggle",
				PersistKey = "Settings.WindowVisibilityKeybind",
				Callback = function()
					if context.Window then
						context.Window:ToggleVisible()
					end
				end,
			})

			settingsLeft:CreateToggle({
				Text = "Background Blur",
				Subtext = "Blur the scene behind Strata while it is visible",
				Default = false,
				PersistKey = "Settings.BackgroundBlur",
				Callback = function(value)
					if context.Window then
						context.Window:SetBackgroundBlurEnabled(value)
					end
				end,
			})

			settingsLeft:Dropdown({
				Name = "Icon Pack",
				Items = { "Lucide", "Phosphor" },
				Default = context.Axis:GetIconPack(),
				PersistKey = "Settings.IconPack",
				Callback = function(value)
					context.Axis:SetIconPack(value)
				end,
			})

			buildStorageManager(settingsMiddle, {
				Title = "Config",
				Folder = "Configs",
				DefaultName = "Default",
				PersistKeyPrefix = "Settings.ConfigManager",
				Serialize = function()
					return context.Window:SerializeConfig()
				end,
				Apply = function(payload)
					context.Window:ApplyConfig(payload)
				end,
			})

			local themePickers = {}
			local function syncThemePickers()
				local currentTheme = context.Axis:GetTheme()
				for key, picker in pairs(themePickers) do
					local hex = currentTheme[key]
					if hex then
						local color = Color3.fromRGB(
							tonumber(hex:sub(2, 3), 16),
							tonumber(hex:sub(4, 5), 16),
							tonumber(hex:sub(6, 7), 16)
						)
						picker:SetColor(color, { Silent = true })
					end
				end
			end

			local themeManager = buildStorageManager(settingsRight, {
				Title = "Theme",
				Folder = "Themes",
				DefaultName = "Rose",
				PersistKeyPrefix = "Settings.ThemeManager",
				Serialize = function()
					return context.Window:SerializeTheme()
				end,
				Apply = function(payload)
					context.Window:ApplyTheme(payload)
					syncThemePickers()
				end,
			})

			settingsRight:SectionHeader("Theme Colors")

			for _, key in ipairs(context.Axis:GetThemeKeys()) do
				local row = settingsRight:Label({
					Text = key,
					Persist = false,
				})
				themePickers[key] = row:AddColorpicker({
					Default = Color3.fromRGB(255, 255, 255),
					Persist = false,
					Callback = function(color)
						context.Axis:SetThemeColor(key, color)
					end,
				})
			end

			syncThemePickers()
			themeManager.Refresh()
		end,
	},

	{
		Text = "Axis: registering features",
		Error = "[Strata Loader] Failed to register features",
		Run = function()
			-- Crosshair system
			pcall(function()
				context.Axis:CreateCrosshair(context.Window, {
					Color = Color3.fromRGB(255, 255, 255),
					Width = 2,
					Length = 8,
					Gap = 3,
					Opacity = 1,
				})
			end)

			-- Character viewer
			pcall(function()
				context.Axis:CreateCharacterViewer(context.Window)
			end)

			-- Security scanner
			pcall(function()
				context.Axis:CreateScanner(context.Window)
			end)

			-- Keybind overlay
			pcall(function()
				context.Axis:CreateKeybindOverlay({
					Title = "Keybinds",
					Keybind = Enum.KeyCode.RightAlt,
					Position = "BottomRight",
					Binds = {},
				})
			end)
		end,
	},

	{ Text = "Axis: ready" },
	{ Text = "Finalizing..." },

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

	local ok, result = true, nil
	if type(step.Run) == "function" then
		ok, result = pcall(step.Run)
	end

	if not ok then
		failLoader(step.Error, result)
	end
end

local function readRemoteBuildValue()
	local success, response = pcall(FetchFresh, UPDATE_VALUE_URL)
	if not success or type(response) ~= "string" then
		return nil
	end

	local normalized = response:gsub("^%s+", ""):gsub("%s+$", "")
	if normalized == "" then
		return nil
	end

	return normalized
end

local function reloadLatestLoader()
	if Runtime.Reloading then
		return
	end

	Runtime.Reloading = true

	task.spawn(function()
		task.wait(0.35)
		if Runtime.Stopped then
			return
		end

		local success, source = pcall(FetchFresh, LOADER_URL)
		if not success or type(source) ~= "string" then
			Runtime.Reloading = false
			return
		end

		local compiled = loadstring(source)
		if type(compiled) ~= "function" then
			Runtime.Reloading = false
			return
		end

		cleanupRuntime("reload")
		pcall(compiled)
	end)
end

local function startUpdateWatcher()
	if not UPDATE_CHECK_ENABLED then
		return
	end

	Runtime.CurrentBuildValue = readRemoteBuildValue()

	task.spawn(function()
		while not Runtime.Stopped do
			task.wait(UPDATE_CHECK_INTERVAL)

			if Runtime.Stopped then
				break
			end

			local nextValue = readRemoteBuildValue()
			if not nextValue then
				continue
			end

			if Runtime.CurrentBuildValue == nil then
				Runtime.CurrentBuildValue = nextValue
				continue
			end

			if nextValue == Runtime.CurrentBuildValue then
				continue
			end

			Runtime.CurrentBuildValue = nextValue

			if context.Axis then
				pcall(function()
					context.Axis:Notify({
						Title = "Strata Updated",
						Message = "UI library update detected",
						Duration = 3.5,
						Location = "TopRight",
					})
				end)
			end

			if DEV then
				reloadLatestLoader()
				break
			end
		end
	end)
end

task.wait(0.1)
destroyLoader()

if context.Axis then
	pcall(function()
		context.Axis:Toast({
			Title = "Strata",
			Message = "Load complete",
			Duration = 3.5,
			Location = "BottomCenter",
		})
	end)
end

if context.Veil and context.Veil.Sound then
	pcall(function()
		context.Veil.Sound:Preload(LOAD_COMPLETE_SOUND, {
			Name = "LoadCompletePreload",
			CacheKey = "Strata.LoadComplete",
		})

		context.Veil.Sound:Play(LOAD_COMPLETE_SOUND, {
			Name = "LoadComplete",
			Volume = 0.9,
			DestroyOnEnd = true,
			CacheKey = "Strata.LoadComplete",
		})
	end)
end

startUpdateWatcher()

return context.Axis
