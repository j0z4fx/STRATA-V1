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

	local Window = {}
	Window.__index = Window

	local COLORS = {
		Window = Color3.fromRGB(19, 19, 22),
		Titlebar = Color3.fromRGB(24, 24, 27),
		Sidebar = Color3.fromRGB(17, 17, 19),
		Stroke = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(255, 255, 255),
	}

	local STROKE_TRANSPARENCY = 0.935

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
			ZIndex = parent.ZIndex + 1,
			Parent = parent,
		})
	end

	local function buildTitlebarShell(parent)
		local shell = Veil.Instance:Create("Frame", {
			Name = "Shell",
			BackgroundColor3 = COLORS.Titlebar,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = parent,
		})

		createCorner(shell, 14)

		Veil.Instance:Create("Frame", {
			Name = "BottomFill",
			BackgroundColor3 = COLORS.Titlebar,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 14),
			Size = UDim2.new(1, 0, 1, -14),
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
			Parent = parent,
		})

		createCorner(shell, 14)

		Veil.Instance:Create("Frame", {
			Name = "TopFill",
			BackgroundColor3 = COLORS.Sidebar,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 14),
			Parent = shell,
		})

		Veil.Instance:Create("Frame", {
			Name = "RightFill",
			BackgroundColor3 = COLORS.Sidebar,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -14, 1, 0),
			Parent = shell,
		})

		createStrokeLine(parent, UDim2.new(1, 0, 0, 1), UDim2.fromOffset(0, 0))
		createStrokeLine(parent, UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0))
		createStrokeLine(parent, UDim2.new(0, 1, 1, -14), UDim2.fromOffset(0, 0))
		createStrokeLine(parent, UDim2.new(1, -14, 0, 1), UDim2.new(0, 14, 1, -1))

		return shell
	end

	function Window.new(options)
		options = options or {}

		local self = setmetatable({}, Window)
		self.Title = options.Title or "Axis"
		self.Surface = Axis.Surface
		self.Id = Toolkit.Util.GenerateId("AxisWindow")
		self.State = Toolkit.State:Scope(self.Id)

		self.Frame = Veil.Instance:Create("Frame", {
			Name = "Window",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(960, 540),
			Parent = self.Surface,
		})

		createCorner(self.Frame, 14)

		self.Titlebar = Veil.Instance:Create("Frame", {
			Name = "Titlebar",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 40),
			Parent = self.Frame,
		})

		self.TitlebarShell = buildTitlebarShell(self.Titlebar)

		self.TitlebarText = Veil.Instance:Create("TextLabel", {
			Name = "Title",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.fromOffset(14, 11),
			Size = UDim2.new(1, -28, 0, 18),
			Text = self.Title,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			Parent = self.Titlebar,
		})

		self.Body = Veil.Instance:Create("Frame", {
			Name = "Body",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 40),
			Size = UDim2.new(1, 0, 1, -40),
			Parent = self.Frame,
		})

		self.Sidebar = Veil.Instance:Create("Frame", {
			Name = "Sidebar",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 42, 1, 0),
			Parent = self.Body,
		})

		self.SidebarShell = buildSidebarShell(self.Sidebar)

		self.Content = Veil.Instance:Create("Frame", {
			Name = "Content",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(42, 0),
			Size = UDim2.new(1, -42, 1, 0),
			Parent = self.Body,
		})

		self.DragBinding = Toolkit.Drag:Attach(self.Titlebar, self.Frame)
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

	Axis.Surface = Veil.GUI:CreateRoot("Axis")

	function Axis:CreateWindow(options)
		local window = Window.new(options)
		table.insert(self.Windows, window)
		return window
	end

	function Axis:DestroyAll()
		for _, window in ipairs(self.Windows) do
			window:Destroy()
		end

		table.clear(self.Windows)
	end

	return Axis
end
