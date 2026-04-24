return function(Toolkit, Veil)
	assert(type(Toolkit) == "table", "[Axis] Toolkit dependency is required")
	assert(type(Veil) == "table", "[Axis] Veil dependency is required")
	assert(type(Toolkit.Drag) == "table", "[Axis] Toolkit.Drag is required")
	assert(type(Veil.GUI) == "table", "[Axis] Veil.GUI is required")
	assert(type(Veil.Instance) == "table", "[Axis] Veil.Instance is required")

	local Axis = {
		Version = "0.0.1",
		Windows = {},
	}

	local TextService = Veil.Services:Get("TextService")
	local AccentTransparency = 0.9
	local InactiveIconColor = Color3.fromRGB(68, 68, 78)
	local SidebarInset = 6
	local TabButtonSize = 36
	local TabCornerRadius = 7
	local TabIconInset = 4
	local TabSpacing = 8
	local SidebarWidth = 50
	local Lucide

	local function loadLucide()
		if Lucide ~= nil then
			return Lucide
		end

		local success, source = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/notpoiu/lucide-roblox-direct/main/source.lua")
		if not success or type(source) ~= "string" then
			Lucide = false
			return nil
		end

		local compiled, compileError = loadstring(source)
		if type(compiled) ~= "function" then
			warn("[Axis] Failed to compile lucide-roblox-direct", compileError)
			Lucide = false
			return nil
		end

		local ok, module = pcall(compiled)
		if ok and type(module) == "table" then
			Lucide = module
			return Lucide
		end

		Lucide = false
		return nil
	end

	local Window = {}
	Window.__index = Window

	local COLORS = {
		Window = Color3.fromRGB(19, 19, 22),
		Titlebar = Color3.fromRGB(24, 24, 27),
		Sidebar = Color3.fromRGB(17, 17, 19),
		Stroke = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(238, 238, 242),
		Accent = Color3.fromRGB(242, 168, 190),
	}

	local STROKE_TRANSPARENCY = 0.935

	local function measureText(text, size, font)
		if not TextService then
			return Vector2.new(#tostring(text) * size * 0.5, size)
		end

		local success, result = pcall(function()
			return TextService:GetTextSize(
				tostring(text),
				size,
				font,
				Vector2.new(math.huge, math.huge)
			)
		end)

		if success then
			return result
		end

		return Vector2.new(#tostring(text) * size * 0.5, size)
	end

	local function createCorner(parent, radius)
		return Veil.Instance:Create("UICorner", {
			CornerRadius = UDim.new(0, radius),
			Parent = parent,
		})
	end

	local function createStrokeLine(parent, size, position)
		return Veil.Instance:Create("Frame", {
			BackgroundColor3 = COLORS.Stroke,
			BackgroundTransparency = STROKE_TRANSPARENCY,
			BorderSizePixel = 0,
			Position = position,
			Size = size,
			ZIndex = 3,
			Parent = parent,
		})
	end

	local function buildTitlebarShell(parent)
		local shell = Veil.Instance:Create("Frame", {
			Name = "Shell",
			BackgroundColor3 = COLORS.Titlebar,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 2,
			Parent = parent,
		})

		createCorner(shell, 14)

		Veil.Instance:Create("Frame", {
			Name = "BottomFill",
			BackgroundColor3 = COLORS.Titlebar,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 14),
			Size = UDim2.new(1, 0, 1, -14),
			ZIndex = 2,
			Parent = shell,
		})

		createStrokeLine(parent, UDim2.new(1, -28, 0, 1), UDim2.fromOffset(14, 0))
		createStrokeLine(parent, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1))
		createStrokeLine(parent, UDim2.new(0, 1, 1, -14), UDim2.fromOffset(0, 14))
		createStrokeLine(parent, UDim2.new(0, 1, 1, -14), UDim2.new(1, -1, 0, 14))

		return shell
	end

	local function buildSidebarShell(parent)
		local shell = Veil.Instance:Create("Frame", {
			Name = "Shell",
			BackgroundColor3 = COLORS.Sidebar,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 2,
			Parent = parent,
		})

		createCorner(shell, 14)

		Veil.Instance:Create("Frame", {
			Name = "TopFill",
			BackgroundColor3 = COLORS.Sidebar,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 14),
			ZIndex = 2,
			Parent = shell,
		})

		Veil.Instance:Create("Frame", {
			Name = "RightFill",
			BackgroundColor3 = COLORS.Sidebar,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -14, 1, 0),
			ZIndex = 2,
			Parent = shell,
		})

		createStrokeLine(parent, UDim2.new(1, 0, 0, 1), UDim2.fromOffset(0, 0))
		createStrokeLine(parent, UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0))
		createStrokeLine(parent, UDim2.new(0, 1, 1, -14), UDim2.fromOffset(0, 0))
		createStrokeLine(parent, UDim2.new(1, -14, 0, 1), UDim2.new(0, 14, 1, -1))

		return shell
	end

	local function applyLucideAsset(imageLabel, iconName, tintColor)
		local lucide = loadLucide()
		if not lucide or type(lucide.GetAsset) ~= "function" then
			return false
		end

		local success, asset = pcall(lucide.GetAsset, iconName)
		if not success or type(asset) ~= "table" then
			return false
		end

		imageLabel.Image = asset.Url or ""
		imageLabel.ImageRectSize = asset.ImageRectSize or Vector2.zero
		imageLabel.ImageRectOffset = asset.ImageRectOffset or Vector2.zero
		imageLabel.ImageColor3 = tintColor
		imageLabel.Visible = true

		return true
	end

	local function setTabButtonVisual(tab, isSelected, colors)
		local tint = isSelected and colors.Accent or InactiveIconColor
		tab.Highlight.BackgroundTransparency = isSelected and AccentTransparency or 1

		if tab.IconImage.Visible then
			tab.IconImage.ImageColor3 = tint
		end

		if tab.IconFallback.Visible then
			tab.IconFallback.TextColor3 = tint
		end
	end

	local function createColumns(parent)
		local leftColumn = Veil.Instance:Create("Frame", {
			Name = "leftColumn",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1 / 3, 0, 1, 0),
			Parent = parent,
		})

		local middleColumn = Veil.Instance:Create("Frame", {
			Name = "middleColumn",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(1 / 3, 0, 0, 0),
			Size = UDim2.new(1 / 3, 0, 1, 0),
			Parent = parent,
		})

		local rightColumn = Veil.Instance:Create("Frame", {
			Name = "rightColumn",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(2 / 3, 0, 0, 0),
			Size = UDim2.new(1 / 3, 0, 1, 0),
			Parent = parent,
		})

		return leftColumn, middleColumn, rightColumn
	end

	function Window.new(options)
		options = options or {}

		local self = setmetatable({}, Window)
		self.Title = "Strata"
		self.StatusText = " Pre-Alpha "
		self.Surface = Axis.Surface
		self.Id = Toolkit.Util.GenerateId("AxisWindow")
		self.State = Toolkit.State:Scope(self.Id)
		self.Tabs = {}
		self.SelectedTab = nil

		self.Frame = Veil.Instance:Create("Frame", {
			Name = "Window",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(960, 540),
			Parent = self.Surface,
		})

		self.WindowBackground = Veil.Instance:Create("Frame", {
			Name = "WindowBackground",
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
			Parent = self.Frame,
		})

		createCorner(self.WindowBackground, 14)

		self.Titlebar = Veil.Instance:Create("Frame", {
			Name = "Titlebar",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 40),
			ZIndex = 2,
			Parent = self.WindowBackground,
		})

		self.TitlebarShell = buildTitlebarShell(self.Titlebar)

		local titleWidth = math.ceil(measureText(self.Title, 14, Enum.Font.GothamMedium).X)
		local chipTextBounds = measureText(self.StatusText, 12, Enum.Font.GothamMedium)
		local chipWidth = math.ceil(chipTextBounds.X) + 8

		self.TitlebarText = Veil.Instance:Create("TextLabel", {
			Name = "Title",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.fromOffset(14, 11),
			Size = UDim2.fromOffset(titleWidth, 18),
			Text = self.Title,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 5,
			Parent = self.Titlebar,
		})

		self.StatusChip = Veil.Instance:Create("TextLabel", {
			Name = "StatusChip",
			BackgroundColor3 = COLORS.Accent,
			BackgroundTransparency = 0.8,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(14 + titleWidth + 4, 11),
			Size = UDim2.fromOffset(chipWidth, 18),
			Font = Enum.Font.GothamMedium,
			Text = self.StatusText,
			TextColor3 = COLORS.Accent,
			TextSize = 12,
			TextTransparency = 0,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 5,
			Parent = self.Titlebar,
		})

		Veil.Instance:Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = self.StatusChip,
		})

		Veil.Instance:Create("UIPadding", {
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
			Parent = self.StatusChip,
		})

		self.Body = Veil.Instance:Create("Frame", {
			Name = "Body",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 40),
			Size = UDim2.new(1, 0, 1, -40),
			ZIndex = 2,
			Parent = self.WindowBackground,
		})

		self.Sidebar = Veil.Instance:Create("Frame", {
			Name = "Sidebar",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, SidebarWidth, 1, 0),
			ZIndex = 2,
			Parent = self.Body,
		})

		self.SidebarShell = buildSidebarShell(self.Sidebar)

		self.TabList = Veil.Instance:Create("Frame", {
			Name = "TabList",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(SidebarInset, SidebarInset),
			Size = UDim2.new(1, -(SidebarInset * 2), 1, -(SidebarInset * 2)),
			ZIndex = 4,
			Parent = self.Sidebar,
		})

		Veil.Instance:Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, TabSpacing),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = self.TabList,
		})

		self.Content = Veil.Instance:Create("Frame", {
			Name = "Content",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(SidebarWidth, 0),
			Size = UDim2.new(1, -SidebarWidth, 1, 0),
			ZIndex = 2,
			Parent = self.Body,
		})

		self.TabContentHost = Veil.Instance:Create("Frame", {
			Name = "TabContentHost",
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
			Parent = self.Content,
		})

		self.DragBinding = Toolkit.Drag:AttachSmooth(self.Titlebar, self.Frame, {
			Smoothness = 0.15,
		})
		self.State:Set("Surface", self.Surface)

		return self
	end

	function Window:Destroy()
		if self.DragBinding then
			self.DragBinding:Disconnect()
			self.DragBinding = nil
		end

		if self.Frame then
			Veil.Instance:SecureDestroy(self.Frame)
			self.Frame = nil
		end
	end

	function Window:SelectTab(tab)
		if not tab or self.SelectedTab == tab then
			return tab
		end

		for _, entry in ipairs(self.Tabs) do
			local isSelected = entry == tab
			entry.Content.Visible = isSelected
			setTabButtonVisual(entry, isSelected, COLORS)
			if isSelected then
				self.SelectedTab = entry
			end
		end

		return self.SelectedTab
	end

	function Window:CreateTab(options)
		options = options or {}

		local tab = {
			Name = options.Name or string.format("Tab %d", #self.Tabs + 1),
			Icon = options.Icon or "square",
			Order = #self.Tabs + 1,
		}

		tab.Button = Veil.Instance:Create("TextButton", {
			Name = tab.Name .. "TabButton",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = tab.Order,
			Size = UDim2.fromOffset(TabButtonSize, TabButtonSize),
			Text = "",
			ZIndex = 5,
			Parent = self.TabList,
		})

		tab.Highlight = Veil.Instance:Create("Frame", {
			Name = "Highlight",
			BackgroundColor3 = COLORS.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(TabButtonSize, TabButtonSize),
			ZIndex = 5,
			Parent = tab.Button,
		})
		createCorner(tab.Highlight, TabCornerRadius)

		tab.IconImage = Veil.Instance:Create("ImageLabel", {
			Name = "IconImage",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = "",
			ImageColor3 = InactiveIconColor,
			Position = UDim2.fromOffset(TabIconInset, TabIconInset),
			Size = UDim2.fromOffset(TabButtonSize - (TabIconInset * 2), TabButtonSize - (TabIconInset * 2)),
			ZIndex = 6,
			Visible = false,
			Parent = tab.Button,
		})

		tab.IconFallback = Veil.Instance:Create("TextLabel", {
			Name = "IconFallback",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(TabButtonSize, TabButtonSize),
			Text = string.upper(string.sub(tab.Name, 1, 1)),
			TextColor3 = InactiveIconColor,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 6,
			Visible = true,
			Parent = tab.Button,
		})

		if applyLucideAsset(tab.IconImage, tab.Icon, InactiveIconColor) then
			tab.IconFallback.Visible = false
		end

		tab.Content = Veil.Instance:Create("Frame", {
			Name = tab.Name .. "Content",
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			ZIndex = 2,
			Parent = self.TabContentHost,
		})

		tab.leftColumn, tab.middleColumn, tab.rightColumn = createColumns(tab.Content)

		tab.Button.MouseButton1Click:Connect(function()
			self:SelectTab(tab)
		end)

		table.insert(self.Tabs, tab)
		setTabButtonVisual(tab, false, COLORS)

		if not self.SelectedTab then
			self:SelectTab(tab)
		end

		return tab
	end

	Axis.Surface = Veil.GUI:CreateRoot("Axis")

	function Axis:CreateWindow(options)
		local window = Window.new(options)
		table.insert(self.Windows, window)
		self.ActiveWindow = window
		return window
	end

	function Axis:CreateTab(options)
		assert(self.ActiveWindow, "[Axis] Create a window before creating tabs")
		return self.ActiveWindow:CreateTab(options)
	end

	function Axis:DestroyAll()
		for _, window in ipairs(self.Windows) do
			window:Destroy()
		end

		table.clear(self.Windows)
	end

	return Axis
end
