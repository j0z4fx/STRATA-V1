-- Axis - UI construction module for STRATA-V1
-- Depends on: Toolkit, Veil (both passed as arguments to this factory).
-- Public: CreateWindow, CreateTab, Toast, Notify, DestroyAll,
--         CreateCrosshair, CreateCharacterViewer, CreateKeybindOverlay,
--         CreateScanner, SetAntiAFK, Get/SetTheme, Get/SetIconPack
-- Never parents directly to CoreGui/PlayerGui/gethui - all surfaces via Veil.
-- Executor compat: polyfills table.find/clear/clone and UDim2.fromOffset/Scale.

return function(Toolkit, Veil)
	assert(type(Toolkit) == "table", "[Axis] Toolkit dependency is required")
	assert(type(Veil) == "table", "[Axis] Veil dependency is required")
	assert(type(Toolkit.Drag) == "table", "[Axis] Toolkit.Drag is required")
	assert(type(Veil.GUI) == "table", "[Axis] Veil.GUI is required")
	assert(type(Veil.Instance) == "table", "[Axis] Veil.Instance is required")

	-- Polyfills for Luau-only table functions (executor compat)
	if not table.find then
		table.find = function(t, value)
			for i, v in ipairs(t) do
				if v == value then return i end
			end
			return nil
		end
	end
	if not table.clear then
		table.clear = function(t)
			for k in pairs(t) do t[k] = nil end
		end
	end
	if not table.clone then
		table.clone = function(t)
			local copy = {}
			for k, v in pairs(t) do copy[k] = v end
			return copy
		end
	end

	-- Local aliases for Roblox API shortcuts that may be missing in some executors
	local _udim2Offset = UDim2.fromOffset or function(x, y) return UDim2.new(0, x, 0, y) end
	local _udim2Scale  = UDim2.fromScale  or function(x, y) return UDim2.new(x, 0, y, 0) end
	local _v2zero = (type(_v2zero) ~= "nil" and _v2zero) or Vector2.new(0, 0)

	local Axis = {
		Version = "0.0.1",
		Windows = {},
	}

	local TextService = Veil.Services:Get("TextService")
	local RunService = Veil.Services:Get("RunService")
	local TweenService = Veil.Services:Get("TweenService")
	local UserInputService = Veil.Services:Get("UserInputService")
	local Lighting = Veil.Services:Get("Lighting")
	local AccentTransparency = 0.9
	local InactiveIconColor = Color3.fromRGB(68, 68, 78)
	local SidebarInset = 6
	local TabButtonSize = 36
	local TabCornerRadius = 7
	local TabIconInset = 4
	local TabSpacing = 8
	local SidebarWidth = 50
	local DividerInset = 4
	local BottomSectionGap = 8
	local DividerOffset = 2
	local ContentDividerWidth = 2
	local ContentDividerGrabWidth = 12
	local ContentDividerPaddingY = 12
	local ContentDividerHandleWidth = 4
	local ContentDividerHandleHeight = 28
	local MinColumnWidth = 150
	local ResizeSmoothness = 0.08
	local OverlaySpacing = 12
	local OverlayAnimationTime = 0.22
	local OverlayExitTime = 0.16
	local OverlayCollapseTime = 0.20
	local OverlayMaxStack = 3
	local OverlayCornerRadius = 12
	local OverlayAccentLineWidth = 3
	local ToastWidth = 320
	local NotificationWidth = 340
	local WindowDragSmoothness = 0.1
	local TabButtonAnimationTime = 0.16
	local TabButtonSelectedScale = 1
	local TabButtonIdleScale = 0.94
	local TabHighlightIdleScale = 0.82
	local ColumnPaddingX = 14
	local ColumnPaddingY = 14
	local ElementSpacing = 6        -- gap between controls within a section
	local SectionSpacing = 16       -- total visual gap above a section header
	local HeaderSpacing = 8         -- total visual gap below a section header
	local ColumnItemSpacing = ElementSpacing
	local LabelRowHeight = 28
	local LabelRowWithSubtextHeight = 46
	local DividerInsetX = 6
	local SectionHeaderGap = 10
	local ToggleRowHeight = 30
	local ToggleRowWithSubtextHeight = 52
	local ToggleSwitchWidth = 34
	local ToggleSwitchHeight = 20
	local ToggleDotSize = 11
	local ToggleAnimationTime = 0.22
	local ToggleHoverStrokeTransparency = 0.82
	local TogglePressAnimTime = 0.08
	local ToggleDotPressSize = 9
	local ToggleTooltipDelay = 0.8
	local TooltipOffset = Vector2.new(16, -10)
	local TooltipMaxWidth = 260
	local AccessorySpacing = 6
	local AccessoryButtonHeight = 20
	local AccessoryInsetRight = 2
	local AccessoryTextPadding = 8
	local KeypickerMinWidth = 28
	local ColorpickerButtonSize = 20
	local PickerPopupWidth = 186
	local PickerPopupHeight = 194
	local PickerPadding = 10
	local PickerMapSize = Vector2.new(122, 122)
	local PickerHueWidth = 12
	local PickerPreviewHeight = 22
	local PickerCornerRadius = 10
	local KeypickerModeMenuWidth = 86
	local DividerSnapThresholdScale = 0.02
	local SliderRowHeight = 38
	local SliderRowWithSubtextHeight = 54
	local SliderNotchedRowHeight = 46
	local SliderNotchedRowWithSubtextHeight = 62
	local SliderTrackHeight = 4
	local SliderThumbDiameter = 14
	local SliderValueWidth = 38
	local SliderLerpAlpha = 0.22
	local SliderDragLerpAlpha = 0.42
	local SliderThumbHoverDiameter = 16
	local SliderThumbDragDiameter = 17
	local SliderThumbAnimTime = 0.10
	local DropdownRowHeight = 30
	local DropdownItemHeight = 26
	local DropdownPanelPadding = 4
	local DropdownPanelWidth = 128
	local DropdownValueWidth = 128
	local DropdownCornerRadius = 8
	local DropdownItemSpacing = 2
	local DropdownMaxVisibleItems = 7
	local DropdownPanelGap = 4
	local DropdownAnimTime = 0.16
	local DropdownAnimSlide = 6
	local DropdownSearchBarHeight = 22
	local DropdownSearchBarGap = 4
	local InputRowHeight = 30
	local InputFieldWidth = 110
	local InputFocusStrokeTransparency = 0.72
	local InputAnimTime = 0.12
	local ButtonRowHeight = 40
	local ButtonCornerRadius = 8
	local ButtonAnimTime = 0.10
	local ButtonInnerInsetY = 2
	local ColumnScrollBarThickness = 4
	local BackgroundBlurSize = 18
	local COLORS = {
		Window = Color3.fromRGB(19, 19, 22),
		Titlebar = Color3.fromRGB(24, 24, 27),
		Sidebar = Color3.fromRGB(17, 17, 19),
		Stroke = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(238, 238, 242),
		Accent = Color3.fromRGB(242, 168, 190),
		ToggleOffBackground = Color3.fromRGB(36, 36, 41),
		ToggleOffDot = Color3.fromRGB(68, 68, 78),
		ToggleOnDot = Color3.fromRGB(255, 255, 255),
	}
	local THEME_KEYS = {
		"Window",
		"Titlebar",
		"Sidebar",
		"Stroke",
		"Text",
		"Accent",
		"ToggleOffBackground",
		"ToggleOffDot",
		"ToggleOnDot",
	}
	local IconTabRegistry = {}

	local function colorToHex(color)
		if typeof(color) ~= "Color3" then
			return "#000000"
		end

		return string.format("#%02X%02X%02X", math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255))
	end

	local function colorFromValue(value, fallback)
		if typeof(value) == "Color3" then
			return value
		end

		if type(value) == "string" then
			local hex = value:gsub("#", "")
			if #hex == 6 then
				local r = tonumber(hex:sub(1, 2), 16)
				local g = tonumber(hex:sub(3, 4), 16)
				local b = tonumber(hex:sub(5, 6), 16)
				if r and g and b then
					return Color3.fromRGB(r, g, b)
				end
			end
		elseif type(value) == "table" then
			local r = value.R or value.r or value[1]
			local g = value.G or value.g or value[2]
			local b = value.B or value.b or value[3]
			if type(r) == "number" and type(g) == "number" and type(b) == "number" then
				if r <= 1 and g <= 1 and b <= 1 then
					return Color3.new(r, g, b)
				end
				return Color3.fromRGB(r, g, b)
			end
		end

		return fallback
	end

	local function normalizeIconAssetData(raw)
		if type(raw) ~= "table" then
			return nil
		end
		local imageId = raw.Image or raw.image or raw.Url or raw.url
		if type(imageId) ~= "string" or imageId == "" then
			return nil
		end
		return {
			Image = imageId,
			ImageRectSize = raw.ImageRectSize or raw.imageRectSize or _v2zero,
			ImageRectOffset = raw.ImageRectOffset or raw.imageRectOffset or _v2zero,
		}
	end

	-- j0z4fx phosphor-roblox-direct uses per-icon name keys (e.g. house-line, gear-six); first arg to GetAsset is the exact key.
	-- Add Lucide -> Phosphor aliases here when a tab icon does not share the same id.
	local LUCIDE_TO_PHOSPHOR_ICON = {
		house = "house-line",
		["user-round"] = "user-circle",
		settings = "gear-six",
		search = "magnifying-glass",
		["shield-alert"] = "shield-warning",
	}
	local function getPhosphorNameCandidates(semantic)
		local key = string.lower(semantic)
		local out = {}
		local alias = LUCIDE_TO_PHOSPHOR_ICON[key]
		if alias then
			table.insert(out, alias)
		end
		table.insert(out, semantic)
		if not string.find(semantic, "%-", 1, true) then
			local suffixed = semantic .. "-line"
			if suffixed ~= semantic then
				table.insert(out, suffixed)
			end
		end
		return out
	end

	local IconProvider = {
		ActivePack = "Phosphor",
		Packs = {},
	}

	function IconProvider:LoadLucide()
		if self.Packs.Lucide then
			return self.Packs.Lucide
		end
		local success, source = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/notpoiu/lucide-roblox-direct/main/source.lua")
		if success and type(source) == "string" then
			local compiled = loadstring(source)
			if compiled then
				local ok, module = pcall(compiled)
				if ok and type(module) == "table" then
					self.Packs.Lucide = module
					return module
				end
			end
		end
		return nil
	end

	function IconProvider:LoadPhosphor()
		if self.Packs.Phosphor then
			return self.Packs.Phosphor
		end
		local success, source = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/j0z4fx/phosphor-roblox-direct/master/source.lua")
		if success and type(source) == "string" then
			local compiled = loadstring(source)
			if compiled then
				local ok, module = pcall(compiled)
				if ok and type(module) == "table" then
					self.Packs.Phosphor = module
					return module
				end
			end
		end
		return nil
	end

	function IconProvider:Get(name, options)
		if type(name) ~= "string" or name == "" then
			return nil
		end
		local opts = type(options) == "table" and options or {}
		local phosWeight = (type(opts.Weight) == "string" and opts.Weight) or (type(opts.weight) == "string" and opts.weight) or nil
		if self.ActivePack == "Lucide" then
			local pack = self:LoadLucide()
			if pack and type(pack.GetAsset) == "function" then
				local ok, asset = pcall(pack.GetAsset, name)
				if ok then
					return normalizeIconAssetData(asset)
				end
			end
			return nil
		end
		local pack = self:LoadPhosphor()
		if not (pack and type(pack.GetAsset) == "function") then
			return nil
		end
		local w = (phosWeight == "fill" or phosWeight == "regular") and phosWeight or "regular"
		for _, cname in ipairs(getPhosphorNameCandidates(name)) do
			local ok, raw = pcall(pack.GetAsset, cname, w)
			if ok then
				local n = normalizeIconAssetData(raw)
				if n then
					return n
				end
			end
		end
		-- If fill failed (some glyphs), fall back to regular for the same candidate set
		if w == "fill" then
			for _, cname in ipairs(getPhosphorNameCandidates(name)) do
				local ok, raw = pcall(pack.GetAsset, cname, "regular")
				if ok then
					local n = normalizeIconAssetData(raw)
					if n then
						return n
					end
				end
			end
		end
		return nil
	end

	function IconProvider:RenderTabIcon(tab, isSelected)
		if not tab or not tab.TabButton or not tab.TabButton.Parent then
			return
		end
		local parent = tab.TabButton
		for _, n in ipairs({ "IconVisual", "IconImage", "IconFallback" }) do
			local old = parent:FindFirstChild(n)
			if old then
				Veil.Instance:SecureDestroy(old)
			end
		end
		tab.IconVisual = nil
		local tint = (isSelected and COLORS.Accent) or InactiveIconColor
		local options = nil
		if self.ActivePack == "Phosphor" then
			options = { Weight = isSelected and "fill" or "regular" }
		end
		local data = self:Get(tab.Icon, options)
		if data then
			local im = Veil.Instance:Create("ImageLabel", {
				Name = "IconVisual",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = data.Image,
				ImageColor3 = tint,
				ImageRectSize = data.ImageRectSize,
				ImageRectOffset = data.ImageRectOffset,
				Position = _udim2Offset(tab._iconPos, tab._iconPos),
				Size = _udim2Offset(tab._iconSize, tab._iconSize),
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = 6,
				Parent = parent,
			})
			tab.IconVisual = im
			return
		end
		local textChar = (string.len(tab.Name) or 0) > 0 and string.upper(string.sub(tab.Name, 1, 1)) or "?"
		local label = Veil.Instance:Create("TextLabel", {
			Name = "IconVisual",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = _udim2Offset(0, 0),
			Size = _udim2Offset(TabButtonSize, TabButtonSize),
			Text = textChar,
			TextColor3 = tint,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 6,
			Parent = parent,
		})
		tab.IconVisual = label
	end

	function IconProvider:RefreshAllTabIcons()
		for _, tab in ipairs(IconTabRegistry) do
			if tab and tab.TabButton and tab.TabButton.Parent and tab.Window then
				local selected = tab.Window.SelectedTab
				IconProvider:RenderTabIcon(tab, selected == tab)
			end
		end
	end

	function IconProvider:SetPack(packName)
		if self.ActivePack == packName then
			return
		end
		self.ActivePack = packName
		IconProvider:RefreshAllTabIcons()
	end

	local Window = {}
	Window.__index = Window

	local STROKE_TRANSPARENCY = 0.935
	local TOAST_LOCATIONS = {
		TopCenter = {
			Surface = "Toast",
			Width = ToastWidth,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 18),
			HostSize = UDim2.new(0, 420, 1, -36),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			EnterOffset = Vector2.new(0, -24),
			ExitOffset = Vector2.new(0, -24),
		},
		BottomCenter = {
			Surface = "Toast",
			Width = ToastWidth,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -18),
			HostSize = UDim2.new(0, 420, 1, -36),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			EnterOffset = Vector2.new(0, 24),
			ExitOffset = Vector2.new(0, 24),
		},
	}
	local NOTIFICATION_LOCATIONS = {
		TopLeft = {
			Surface = "Notification",
			Width = NotificationWidth,
			AnchorPoint = Vector2.new(0, 0),
			Position = _udim2Offset(18, 18),
			HostSize = UDim2.new(0, 360, 1, -36),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			EnterOffset = Vector2.new(-28, 0),
			ExitOffset = Vector2.new(-28, 0),
			Edge = "Left",
		},
		TopRight = {
			Surface = "Notification",
			Width = NotificationWidth,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -18, 0, 18),
			HostSize = UDim2.new(0, 360, 1, -36),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			EnterOffset = Vector2.new(28, 0),
			ExitOffset = Vector2.new(28, 0),
			Edge = "Right",
		},
		BottomLeft = {
			Surface = "Notification",
			Width = NotificationWidth,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 18, 1, -18),
			HostSize = UDim2.new(0, 360, 1, -36),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			EnterOffset = Vector2.new(-28, 0),
			ExitOffset = Vector2.new(-28, 0),
			Edge = "Left",
		},
		BottomRight = {
			Surface = "Notification",
			Width = NotificationWidth,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -18, 1, -18),
			HostSize = UDim2.new(0, 360, 1, -36),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			EnterOffset = Vector2.new(28, 0),
			ExitOffset = Vector2.new(28, 0),
			Edge = "Right",
		},
	}

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

	local function createPadding(parent, top, right, bottom, left)
		return Veil.Instance:Create("UIPadding", {
			PaddingTop = UDim.new(0, top or 0),
			PaddingRight = UDim.new(0, right or 0),
			PaddingBottom = UDim.new(0, bottom or 0),
			PaddingLeft = UDim.new(0, left or 0),
			Parent = parent,
		})
	end

	local function getModeMenuHeight(modeCount)
		local rows = math.max(1, modeCount or 0)
		return rows * DropdownItemHeight
			+ math.max(0, rows - 1) * DropdownItemSpacing
			+ DropdownPanelPadding * 2
	end

	local function createBorder(parent)
		return Veil.Instance:Create("UIStroke", {
			Name = "OverlayBorder",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = COLORS.Stroke,
			Transparency = STROKE_TRANSPARENCY,
			Thickness = 1,
			Parent = parent,
		})
	end

	local function safeCallback(callback, ...)
		if not Toolkit.Util.IsCallable(callback) then
			return true
		end

		local success, result = Toolkit.Util.Try(callback, ...)
		if not success then
			warn("[Axis] Callback failed:", result)
		end

		return success, result
	end

	local function snapToStep(value, min, max, step)
		if not step or step <= 0 then
			return math.clamp(value, min, max)
		end
		local stepped = min + math.round((value - min) / step) * step
		return math.clamp(stepped, min, max)
	end

	local function formatSliderValue(value, step)
		if not step or step <= 0 then
			return string.format("%.2f", value)
		end
		if step >= 1 and step == math.floor(step) then
			return tostring(math.floor(value + 0.5))
		end
		local decimals = math.max(0, math.ceil(-math.log10(step + 1e-9)))
		return string.format("%." .. decimals .. "f", value)
	end

	local function setOverlayVisualState(card, isVisible)
		if not card then
			return
		end

		local cardBackground = isVisible and 0 or 1
		card.BackgroundTransparency = cardBackground

		for _, descendant in ipairs(card:GetDescendants()) do
			if descendant:IsA("UIStroke") then
				descendant.Transparency = isVisible and STROKE_TRANSPARENCY or 1
			elseif descendant:IsA("TextLabel") then
				local baseTextTransparency = descendant:GetAttribute("AxisBaseTextTransparency")
				if baseTextTransparency == nil then
					baseTextTransparency = descendant.TextTransparency
					descendant:SetAttribute("AxisBaseTextTransparency", baseTextTransparency)
				end
				descendant.TextTransparency = isVisible and baseTextTransparency or 1
			elseif descendant:IsA("Frame") and descendant.Name == "AccentEdge" then
				descendant.BackgroundTransparency = isVisible and 0 or 1
			end
		end
	end

	local function createStrokeLine(parent, size, position)
		return Veil.Instance:Create("Frame", {
			Name = "AxisStrokeLine",
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
			Position = _udim2Offset(0, 14),
			Size = UDim2.new(1, 0, 1, -14),
			ZIndex = 2,
			Parent = shell,
		})

		createStrokeLine(parent, UDim2.new(1, -28, 0, 1), _udim2Offset(14, 0))
		createStrokeLine(parent, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1))
		createStrokeLine(parent, UDim2.new(0, 1, 1, -14), _udim2Offset(0, 14))
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
			Position = _udim2Offset(14, 0),
			Size = UDim2.new(1, -14, 1, 0),
			ZIndex = 2,
			Parent = shell,
		})

		createStrokeLine(parent, UDim2.new(1, 0, 0, 1), _udim2Offset(0, 0))
		createStrokeLine(parent, UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0))
		createStrokeLine(parent, UDim2.new(0, 1, 1, -14), _udim2Offset(0, 0))
		createStrokeLine(parent, UDim2.new(1, -14, 0, 1), UDim2.new(0, 14, 1, -1))

		return shell
	end

-- IconProvider replaces applyLucideAsset

	local function setTabButtonVisual(tab, isSelected, colors)
		local tint = isSelected and colors.Accent or InactiveIconColor
		local targetScale = isSelected and TabButtonSelectedScale or TabButtonIdleScale
		local targetHighlightScale = isSelected and 1 or TabHighlightIdleScale
		local targetTransparency = isSelected and AccentTransparency or 1

		if tab.ButtonScale then
			TweenService:Create(tab.ButtonScale, TweenInfo.new(TabButtonAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = targetScale,
			}):Play()
		end

		if tab.HighlightScale then
			TweenService:Create(tab.HighlightScale, TweenInfo.new(TabButtonAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = targetHighlightScale,
			}):Play()
		end

		TweenService:Create(tab.Highlight, TweenInfo.new(TabButtonAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = targetTransparency,
		}):Play()

		local v = tab.IconVisual
		if v and v.Visible then
			if v:IsA("ImageLabel") then
				TweenService:Create(v, TweenInfo.new(TabButtonAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageColor3 = tint,
				}):Play()
			elseif v:IsA("TextLabel") then
				TweenService:Create(v, TweenInfo.new(TabButtonAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextColor3 = tint,
				}):Play()
			end
		end
	end

	local function registerCleanup(self, connection)
		if connection then
			table.insert(self.CleanupConnections, connection)
		end

		return connection
	end

	local function createContentDivider(parent)
		local divider = Veil.Instance:Create("Frame", {
			Name = "ColumnDivider",
			BackgroundColor3 = COLORS.Stroke,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, ContentDividerGrabWidth, 1, -(ContentDividerPaddingY * 2)),
			ZIndex = 3,
			Parent = parent,
		})

		local line = Veil.Instance:Create("Frame", {
			Name = "Line",
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = COLORS.Stroke,
			BackgroundTransparency = STROKE_TRANSPARENCY,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(0, ContentDividerWidth, 1, 0),
			ZIndex = 3,
			Parent = divider,
		})

		local handle = Veil.Instance:Create("Frame", {
			Name = "Handle",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = COLORS.Stroke,
			BackgroundTransparency = STROKE_TRANSPARENCY,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = _udim2Offset(ContentDividerHandleWidth, ContentDividerHandleHeight),
			ZIndex = 4,
			Parent = divider,
		})
		createCorner(handle, ContentDividerHandleWidth)

		local hitbox = Veil.Instance:Create("TextButton", {
			Name = "Hitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = _udim2Scale(1, 1),
			Text = "",
			ZIndex = 5,
			Parent = divider,
		})

		return divider, hitbox, line, handle
	end

	local function createSnapGuide(parent)
		local guide = Veil.Instance:Create("Frame", {
			Name = "DividerSnapGuide",
			Active = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = UDim2.new(0, 10, 1, -(ContentDividerPaddingY * 2)),
			Visible = false,
			ZIndex = 3,
			Parent = parent,
		})

		local dashLayout = Veil.Instance:Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Parent = guide,
		})

		for _ = 1, 20 do
			Veil.Instance:Create("Frame", {
				Name = "Dash",
				BackgroundColor3 = COLORS.Accent,
				BackgroundTransparency = 0.45,
				BorderSizePixel = 0,
				Size = _udim2Offset(2, 8),
				ZIndex = 3,
				Parent = guide,
			})
		end

		return guide, dashLayout
	end

	local function setDividerVisualState(layout, dividerIndex, isHeld)
		local divider = layout.Dividers[dividerIndex]
		local line = layout.Lines[dividerIndex]
		local handle = layout.Handles[dividerIndex]
		local color = isHeld and COLORS.Accent or COLORS.Stroke
		local transparency = isHeld and 0.7 or STROKE_TRANSPARENCY

		divider.BackgroundTransparency = 1
		line.BackgroundColor3 = color
		line.BackgroundTransparency = transparency
		handle.BackgroundColor3 = color
		handle.BackgroundTransparency = transparency
	end

	local function setSnapGuideVisible(layout, dividerIndex, visible)
		local guide = layout.Guides and layout.Guides[dividerIndex]
		if guide then
			guide.Visible = visible == true
		end
	end

	local function ensureColumnStack(column)
		local existing = column:FindFirstChild("AxisColumnPadding")
		if existing then
			return
		end

		local padding = createPadding(column, ColumnPaddingY, ColumnPaddingX, ColumnPaddingY, ColumnPaddingX)
		padding.Name = "AxisColumnPadding"
		Veil.Instance:Create("UIListLayout", {
			Name = "AxisColumnLayout",
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, ColumnItemSpacing),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = column,
		})
	end

	local function resolveTabColumn(tab, columnName)
		local normalized = string.lower(tostring(columnName or "left"))
		if normalized == "middle" or normalized == "middlecolumn" then
			return tab.middleColumn or tab.leftColumn
		end

		if normalized == "right" or normalized == "rightcolumn" then
			return tab.rightColumn or tab.leftColumn
		end

		return tab.leftColumn
	end

	local _columnOrders = {}
	local function nextOrder(column)
		local n = (_columnOrders[column] or 0) + 1
		_columnOrders[column] = n
		return n
	end

	local function createTextRow(parent, name, height)
		return Veil.Instance:Create("Frame", {
			Name = name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = nextOrder(parent),
			Size = UDim2.new(1, 0, 0, height),
			Parent = parent,
		})
	end

	local function getViewportSize()
		local camera = workspace.CurrentCamera
		if camera then
			return camera.ViewportSize
		end

		return Vector2.new(1920, 1080)
	end

	local function isPointInside(guiObject, point)
		if not guiObject or not point then
			return false
		end

		local position = guiObject.AbsolutePosition
		local size = guiObject.AbsoluteSize

		return point.X >= position.X
			and point.X <= position.X + size.X
			and point.Y >= position.Y
			and point.Y <= position.Y + size.Y
	end

	local function getControlTextRightInset(control)
		local accessoryWidth = control.AccessoryWidth or 0
		local baseInset = 0

		if control.Type == "Toggle" then
			baseInset = ToggleSwitchWidth + 16
		end

		if accessoryWidth > 0 then
			baseInset = baseInset + accessoryWidth + AccessorySpacing
		end

		return baseInset
	end

	local function updateControlAccessoryLayout(control)
		if not control then
			return
		end

		local accessoryWidth = control.AccessoryWidth or 0

		if control.AccessoryHost then
			control.AccessoryHost.Size = _udim2Offset(accessoryWidth, control.RowHeight or AccessoryButtonHeight)
		end

		if control.Type == "Toggle" then
			local inset = getControlTextRightInset(control)
			control.LabelWrap.Size = control.HasSubtext
				and UDim2.new(1, -inset, 1, -12)
				or UDim2.new(1, -inset, 1, 0)
			if control.AccessoryHost then
				control.AccessoryHost.Position = UDim2.new(1, -(ToggleSwitchWidth + AccessorySpacing), 0.5, 0)
			end
		else
			local inset = getControlTextRightInset(control)
			local sizeOffset = inset > 0 and -inset or 0
			control.TitleLabel.Size = UDim2.new(1, sizeOffset, 0, 18)
			if control.SubtextLabel then
				control.SubtextLabel.Size = UDim2.new(1, sizeOffset, 0, 16)
			end
			if control.AccessoryHost then
				control.AccessoryHost.Position = UDim2.new(1, -AccessoryInsetRight, 0.5, 0)
			end
		end
	end

	local function ensureAccessoryHost(control)
		if control.AccessoryHost then
			return control.AccessoryHost
		end

		control.AccessoryWidth = control.AccessoryWidth or 0

		local host = Veil.Instance:Create("Frame", {
			Name = "AccessoryHost",
			AnchorPoint = Vector2.new(1, 0.5),
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = _udim2Offset(0, control.RowHeight or AccessoryButtonHeight),
			ZIndex = 6,
			Parent = control.Holder,
		})

		Veil.Instance:Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, AccessorySpacing),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Parent = host,
		})

		control.AccessoryHost = host
		updateControlAccessoryLayout(control)

		return host
	end

	local function registerAccessory(control, width)
		ensureAccessoryHost(control)

		if control.AccessoryWidth and control.AccessoryWidth > 0 then
			control.AccessoryWidth = control.AccessoryWidth + AccessorySpacing + width
		else
			control.AccessoryWidth = width
		end
		updateControlAccessoryLayout(control)
	end

	local function refreshAccessoryWidth(control)
		if not control or not control.AccessoryHost then
			return 0
		end

		local width = 0
		local count = 0

		for _, child in ipairs(control.AccessoryHost:GetChildren()) do
			if child:IsA("GuiObject") and not child:IsA("UIListLayout") then
				width = width + child.Size.X.Offset
				count = count + 1
			end
		end

		if count > 1 then
			width = width + ((count - 1) * AccessorySpacing)
		end

		control.AccessoryWidth = width
		updateControlAccessoryLayout(control)
		return width
	end

	local function assignPersistKey(tab, control, options, controlType)
		local key = options and (options.PersistKey or options.Id or options.Key)
		if type(key) == "string" and key ~= "" then
			control.PersistKey = key
			return key
		end

		tab._persistCounter = (tab._persistCounter or 0) + 1
		key = string.format("%s.%s.%d", tab.Name, controlType or control.Type or "Control", tab._persistCounter)
		control.PersistKey = key
		return key
	end

	local function registerPersistedControl(tab, control)
		tab.PersistControls = tab.PersistControls or {}
		table.insert(tab.PersistControls, control)
	end

	local function registerTabControl(tab, control)
		tab.Controls = tab.Controls or {}
		table.insert(tab.Controls, control)
		return control
	end

	local function assignAccessoryPersistKey(control, accessory, suffix)
		local base = control.PersistKey
		if type(base) ~= "string" or base == "" then
			base = assignPersistKey(control.Tab, control, { PersistKey = control.Name }, control.Type)
		end

		accessory.PersistKey = string.format("%s.%s", base, suffix)
		return accessory.PersistKey
	end

	local function normalizeKeyValue(key)
		if typeof(key) == "EnumItem" then
			if key.EnumType == Enum.KeyCode then
				return key.Name
			end

			if key.EnumType == Enum.UserInputType then
				if key == Enum.UserInputType.MouseButton1 then
					return "MB1"
				elseif key == Enum.UserInputType.MouseButton2 then
					return "MB2"
				elseif key == Enum.UserInputType.MouseButton3 then
					return "MB3"
				end
			end
		elseif type(key) == "string" then
			local normalized = key:gsub("^%s+", ""):gsub("%s+$", "")
			if normalized == "" then
				return "None"
			end
			return normalized
		end

		return "None"
	end

	local function keyMatchesInput(key, input)
		if not key or key == "None" or not input then
			return false
		end

		if key == "MB1" then
			return input.UserInputType == Enum.UserInputType.MouseButton1
		elseif key == "MB2" then
			return input.UserInputType == Enum.UserInputType.MouseButton2
		elseif key == "MB3" then
			return input.UserInputType == Enum.UserInputType.MouseButton3
		end

		return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key
	end

	local function makeAccessoryButton(parent, name, width)
		local button = Veil.Instance:Create("TextButton", {
			Name = name,
			AutoButtonColor = false,
			BackgroundColor3 = COLORS.ToggleOffBackground,
			BorderSizePixel = 0,
			Size = _udim2Offset(width, AccessoryButtonHeight),
			Text = "",
			ZIndex = 10,
			Parent = parent,
		})
		createCorner(button, 6)
		Veil.Instance:Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = COLORS.Stroke,
			Transparency = STROKE_TRANSPARENCY,
			Thickness = 1,
			Parent = button,
		})

		return button
	end

	local function applyColumnLayout(tab)
		if not tab.ColumnLayout then
			return
		end

		local layout = tab.ColumnLayout
		local boundaries = layout.CurrentBoundaries or layout.Boundaries
		local columns = layout.Columns
		local columnCount = #columns

		for index, column in ipairs(columns) do
			local startScale = index == 1 and 0 or boundaries[index - 1]
			local endScale = index == columnCount and 1 or boundaries[index]
			column.Position = UDim2.new(startScale, 0, 0, 0)
			column.Size = UDim2.new(endScale - startScale, 0, 1, 0)
		end

		for index, divider in ipairs(layout.Dividers) do
			divider.Position = UDim2.new(boundaries[index], -(ContentDividerGrabWidth / 2), 0, ContentDividerPaddingY)
			if layout.Guides and layout.Guides[index] then
				layout.Guides[index].Position = UDim2.new(boundaries[index], -5, 0, ContentDividerPaddingY)
			end
		end
	end

	local function attachDividerResize(self, tab, dividerIndex)
		local layout = tab.ColumnLayout
		local hitbox = layout.Hitboxes[dividerIndex]

		registerCleanup(self, hitbox.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			layout.ActiveDivider = dividerIndex
			setDividerVisualState(layout, dividerIndex, true)
		end))

		registerCleanup(self, UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if layout.ActiveDivider then
					setDividerVisualState(layout, layout.ActiveDivider, false)
					setSnapGuideVisible(layout, layout.ActiveDivider, false)
				end
				layout.ActiveDivider = nil
			end
		end))

		registerCleanup(self, UserInputService.InputChanged:Connect(function(input)
			if layout.ActiveDivider ~= dividerIndex then
				return
			end

			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			local contentWidth = tab.Content.AbsoluteSize.X
			if contentWidth <= 0 then
				return
			end

			local relativeX = input.Position.X - tab.Content.AbsolutePosition.X
			local nextScale = relativeX / contentWidth
			local minimumScale = math.clamp(MinColumnWidth / contentWidth, 0.08, 0.4)
			local currentTargets = layout.TargetBoundaries
			local lowerBound = dividerIndex == 1 and minimumScale or (currentTargets[dividerIndex - 1] + minimumScale)
			local upperBound = dividerIndex == #currentTargets and (1 - minimumScale) or (currentTargets[dividerIndex + 1] - minimumScale)
			local clamped = math.clamp(nextScale, lowerBound, upperBound)
			local snapTarget = layout.DefaultBoundaries[dividerIndex]
			if snapTarget and math.abs(clamped - snapTarget) <= DividerSnapThresholdScale then
				layout.TargetBoundaries[dividerIndex] = snapTarget
				setSnapGuideVisible(layout, dividerIndex, true)
			else
				layout.TargetBoundaries[dividerIndex] = clamped
				setSnapGuideVisible(layout, dividerIndex, false)
			end
		end))
	end

	local function createColumns(self, tab, parent, columnMode)
		local columns = {}

		local leftColumn = Veil.Instance:Create("ScrollingFrame", {
			Name = "leftColumn",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BottomImage = "",
			CanvasSize = _udim2Offset(0, 0),
			MidImage = "",
			ScrollBarImageColor3 = COLORS.Accent,
			ScrollBarImageTransparency = 0.78,
			ScrollBarThickness = ColumnScrollBarThickness,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			TopImage = "",
			Parent = parent,
		})
		table.insert(columns, leftColumn)

		local middleColumn
		if columnMode == "Triple" then
			middleColumn = Veil.Instance:Create("ScrollingFrame", {
				Name = "middleColumn",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				BottomImage = "",
				CanvasSize = _udim2Offset(0, 0),
				MidImage = "",
				ScrollBarImageColor3 = COLORS.Accent,
				ScrollBarImageTransparency = 0.78,
				ScrollBarThickness = ColumnScrollBarThickness,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				TopImage = "",
				Parent = parent,
			})
			table.insert(columns, middleColumn)
		end

		local rightColumn = Veil.Instance:Create("ScrollingFrame", {
			Name = "rightColumn",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BottomImage = "",
			CanvasSize = _udim2Offset(0, 0),
			MidImage = "",
			ScrollBarImageColor3 = COLORS.Accent,
			ScrollBarImageTransparency = 0.78,
			ScrollBarThickness = ColumnScrollBarThickness,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			TopImage = "",
			Parent = parent,
		})
		table.insert(columns, rightColumn)

		tab.ColumnLayout = {
			Mode = columnMode,
			Columns = columns,
			Dividers = {},
			Guides = {},
			Hitboxes = {},
			Lines = {},
			Handles = {},
			Boundaries = columnMode == "Double" and { 0.5 } or { 1 / 3, 2 / 3 },
			DefaultBoundaries = columnMode == "Double" and { 0.5 } or { 1 / 3, 2 / 3 },
			CurrentBoundaries = columnMode == "Double" and { 0.5 } or { 1 / 3, 2 / 3 },
			TargetBoundaries = columnMode == "Double" and { 0.5 } or { 1 / 3, 2 / 3 },
			ActiveDivider = nil,
		}

		for dividerIndex = 1, #tab.ColumnLayout.Boundaries do
			local divider, hitbox, line, handle = createContentDivider(parent)
			local guide = createSnapGuide(parent)
			tab.ColumnLayout.Dividers[dividerIndex] = divider
			tab.ColumnLayout.Guides[dividerIndex] = guide
			tab.ColumnLayout.Hitboxes[dividerIndex] = hitbox
			tab.ColumnLayout.Lines[dividerIndex] = line
			tab.ColumnLayout.Handles[dividerIndex] = handle
			setDividerVisualState(tab.ColumnLayout, dividerIndex, false)
			attachDividerResize(self, tab, dividerIndex)
		end

		applyColumnLayout(tab)

		return leftColumn, middleColumn, rightColumn
	end

	local function animateOverlayCard(card, targetOffset, isVisible, onComplete)
		local dur = isVisible and OverlayAnimationTime or OverlayExitTime
		local style = isVisible and Enum.EasingStyle.Quint or Enum.EasingStyle.Quad
		local ti = TweenInfo.new(dur, style, Enum.EasingDirection.Out)

		local tween = TweenService:Create(card, ti, {
			Position = _udim2Offset(targetOffset.X, targetOffset.Y),
		})
		local tweens = { tween }

		table.insert(tweens, TweenService:Create(card, ti, {
			BackgroundTransparency = isVisible and 0 or 1,
		}))

		for _, descendant in ipairs(card:GetDescendants()) do
			if descendant:IsA("UIStroke") then
				table.insert(tweens, TweenService:Create(descendant, ti, {
					Transparency = isVisible and STROKE_TRANSPARENCY or 1,
				}))
			elseif descendant:IsA("TextLabel") then
				local baseT = descendant:GetAttribute("AxisBaseTextTransparency")
				if baseT == nil then
					baseT = descendant.TextTransparency
					descendant:SetAttribute("AxisBaseTextTransparency", baseT)
				end
				table.insert(tweens, TweenService:Create(descendant, ti, {
					TextTransparency = isVisible and baseT or 1,
				}))
			elseif descendant:IsA("Frame") and descendant.Name == "AccentEdge" then
				table.insert(tweens, TweenService:Create(descendant, ti, {
					BackgroundTransparency = isVisible and 0 or 1,
				}))
			end
		end

		if onComplete then
			local conn
			conn = tween.Completed:Connect(function()
				if conn then conn:Disconnect() end
				onComplete()
			end)
		end

		for _, t in ipairs(tweens) do t:Play() end
		return tween
	end

	local function createOverlayHost(surface, name, config)
		local host = Veil.Instance:Create("Frame", {
			Name = name,
			Active = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			Interactable = false,
			AnchorPoint = config.AnchorPoint,
			Position = config.Position,
			Size = config.HostSize,
			ZIndex = 200,
			Parent = surface,
		})

		Veil.Instance:Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = config.HorizontalAlignment,
			Padding = UDim.new(0, OverlaySpacing),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = config.VerticalAlignment,
			Parent = host,
		})

		return host
	end

	local function createOverlayCard(host, width, layoutOrder, zIndex)
		local wrapper = Veil.Instance:Create("Frame", {
			Name = "OverlayWrapper",
			Active = false,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			Interactable = false,
			LayoutOrder = layoutOrder,
			Size = _udim2Offset(width, 0),
			ZIndex = zIndex,
			Parent = host,
		})

		local card = Veil.Instance:Create("Frame", {
			Name = "OverlayCard",
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			ZIndex = zIndex,
			Parent = wrapper,
		})
		createCorner(card, OverlayCornerRadius)
		createBorder(card)

		return wrapper, card
	end

	local function createOverlayTitle(parent, text, color, zIndex)
		return Veil.Instance:Create("TextLabel", {
			Name = "Title",
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Size = UDim2.new(1, 0, 0, 0),
			Text = text,
			TextColor3 = color,
			TextSize = 14,
			TextTransparency = 0,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = zIndex,
			Parent = parent,
		})
	end

	local function createOverlayMessage(parent, text, zIndex)
		return Veil.Instance:Create("TextLabel", {
			Name = "Message",
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Size = UDim2.new(1, 0, 0, 0),
			Text = text,
			TextColor3 = COLORS.Text,
			TextSize = 13,
			TextTransparency = 0.2,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = zIndex,
			Parent = parent,
		})
	end

	local function buildToastCard(card, accentColor, options, zIndex)
		local content = Veil.Instance:Create("Frame", {
			Name = "Content",
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			ZIndex = zIndex + 1,
			Parent = card,
		})
		createPadding(content, 10, 12, 10, 12)

		local layout = Veil.Instance:Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = content,
		})

		local titleText = options.Title
		local messageText = options.Message or ""

		if titleText and titleText ~= "" then
			createOverlayTitle(content, titleText, accentColor, zIndex + 2)
		end

		if messageText ~= "" or not titleText or titleText == "" then
			createOverlayMessage(content, messageText ~= "" and messageText or tostring(titleText or "Toast"), zIndex + 2)
		end

		return content, layout
	end

	local function buildNotificationCard(card, accentColor, edge, options, zIndex)
		Veil.Instance:Create("Frame", {
			Name = "AccentEdge",
			BackgroundColor3 = accentColor,
			BorderSizePixel = 0,
			Position = edge == "Right" and UDim2.new(1, -OverlayAccentLineWidth, 0, 0) or UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0, OverlayAccentLineWidth, 1, 0),
			ZIndex = zIndex + 1,
			Parent = card,
		})

		local content = Veil.Instance:Create("Frame", {
			Name = "Content",
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			ZIndex = zIndex + 1,
			Parent = card,
		})
		createPadding(content, 12, 14, 12, 14)

		local layout = Veil.Instance:Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = content,
		})

		local titleText = options.Title or "Notification"
		local messageText = options.Message or ""

		createOverlayTitle(content, titleText, COLORS.Text, zIndex + 2)
		if messageText ~= "" then
			createOverlayMessage(content, messageText, zIndex + 2)
		end

		return content, layout
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
		self.CleanupConnections = {}
		self.CursorVisible = true
		self.Visible = true
		self.BackgroundBlurEnabled = false
		self.TooltipToken = 0
		self.ActiveTooltipAnchor = nil
		self.ActiveTooltipText = nil

		self.Frame = Veil.Instance:Create("Frame", {
			Name = "Window",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = _udim2Scale(0.5, 0.5),
			Size = _udim2Offset(960, 540),
			Parent = self.Surface,
		})

		self.WindowBackground = Veil.Instance:Create("Frame", {
			Name = "WindowBackground",
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = _udim2Scale(1, 1),
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
			Position = _udim2Offset(14, 11),
			Size = _udim2Offset(titleWidth, 18),
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
			Position = _udim2Offset(14 + titleWidth + 4, 11),
			Size = _udim2Offset(chipWidth, 18),
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

		-- Search button (right side of titlebar)
		local searchBtnSize = 24
		local searchBtn = Veil.Instance:Create("TextButton", {
			Name = "SearchButton",
			AnchorPoint = Vector2.new(1, 0.5),
			AutoButtonColor = false,
			BackgroundColor3 = COLORS.Text,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = _udim2Offset(searchBtnSize, searchBtnSize),
			Text = "",
			ZIndex = 6,
			Parent = self.Titlebar,
		})
		createCorner(searchBtn, 6)

		local searchBtnIcon = Veil.Instance:Create("ImageLabel", {
			Name = "SearchIcon",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = _udim2Scale(0.5, 0.5),
			Size = _udim2Offset(14, 14),
			ScaleType = Enum.ScaleType.Fit,
			ImageColor3 = COLORS.Text,
			ImageTransparency = 0.4,
			ZIndex = 7,
			Parent = searchBtn,
		})
		self.SearchButton = searchBtn
		self.SearchButtonIcon = searchBtnIcon

		-- Apply search icon when pack loads
		task.spawn(function()
			RunService.Heartbeat:Wait()
			local data = IconProvider:Get("search")
			if data then
				searchBtnIcon.Image = data.Image
				searchBtnIcon.ImageRectSize = data.ImageRectSize
				searchBtnIcon.ImageRectOffset = data.ImageRectOffset
			else
				-- Fallback: magnifying glass unicode
				searchBtnIcon.Parent = nil
				local fallback = Veil.Instance:Create("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Font = Enum.Font.GothamMedium,
					Position = _udim2Scale(0.5, 0.5),
					Size = _udim2Offset(searchBtnSize, searchBtnSize),
					Text = "⌕",
					TextColor3 = COLORS.Text,
					TextTransparency = 0.4,
					TextSize = 16,
					ZIndex = 7,
					Parent = searchBtn,
				})
			end
		end)

		local searchHoverTI = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		searchBtn.MouseEnter:Connect(function()
			TweenService:Create(searchBtn, searchHoverTI, { BackgroundTransparency = 0.88 }):Play()
		end)
		searchBtn.MouseLeave:Connect(function()
			TweenService:Create(searchBtn, searchHoverTI, { BackgroundTransparency = 1 }):Play()
		end)
		searchBtn.MouseButton1Click:Connect(function()
			Axis:OpenSearch(self)
		end)

		self.Body = Veil.Instance:Create("Frame", {
			Name = "Body",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = _udim2Offset(0, 40),
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
			Name = "TopTabList",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = _udim2Offset(SidebarInset, SidebarInset),
			Size = UDim2.new(
				1,
				-(SidebarInset * 2),
				1,
				-((SidebarInset * 2) + TabButtonSize + BottomSectionGap + TabSpacing + 1)
			),
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

		self.SettingsDivider = Veil.Instance:Create("Frame", {
			Name = "SettingsDivider",
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = COLORS.Stroke,
			BackgroundTransparency = STROKE_TRANSPARENCY,
			BorderSizePixel = 0,
			Position = UDim2.new(0, SidebarInset + DividerInset, 1, -(SidebarInset + TabButtonSize + BottomSectionGap - DividerOffset)),
			Size = UDim2.new(1, -((SidebarInset + DividerInset) * 2), 0, 1),
			ZIndex = 4,
			Parent = self.Sidebar,
		})

		self.BottomTabHost = Veil.Instance:Create("Frame", {
			Name = "BottomTabHost",
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, SidebarInset, 1, -SidebarInset),
			Size = UDim2.new(1, -(SidebarInset * 2), 0, TabButtonSize),
			ZIndex = 4,
			Parent = self.Sidebar,
		})

		self.Content = Veil.Instance:Create("Frame", {
			Name = "Content",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = _udim2Offset(SidebarWidth, 0),
			Size = UDim2.new(1, -SidebarWidth, 1, 0),
			ZIndex = 2,
			Parent = self.Body,
		})

		self.TabContentHost = Veil.Instance:Create("Frame", {
			Name = "TabContentHost",
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = _udim2Scale(1, 1),
			ZIndex = 2,
			Parent = self.Content,
		})
		createCorner(self.TabContentHost, 14)

		self.Cursor = Veil.Instance:Create("Frame", {
			Name = "CrossCursor",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Active = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Interactable = false,
			Size = _udim2Offset(13, 13),
			ZIndex = 500,
			Parent = self.Surface,
		})

		self.SelectionHighlight = Veil.Instance:Create("Frame", {
			Name = "SelectionHighlight",
			Active = false,
			BackgroundColor3 = COLORS.Accent,
			BackgroundTransparency = 0.28,
			BorderSizePixel = 0,
			Interactable = false,
			Position = _udim2Offset(-2048, -2048),
			Size = _udim2Offset(12, 12),
			Visible = true,
			ZIndex = 520,
			Parent = self.Surface,
		})
		createCorner(self.SelectionHighlight, 4)

		self.BlurEffect = Veil.Instance:Create("BlurEffect", {
			Name = "AxisWindowBlur",
			Enabled = false,
			Size = BackgroundBlurSize,
			Parent = Lighting,
		})

		local cursorParts = {
			{ Name = "VerticalStroke", Size = _udim2Offset(3, 13), Position = UDim2.new(0.5, 0, 0.5, 0), Color = COLORS.Window, Z = 500 },
			{ Name = "HorizontalStroke", Size = _udim2Offset(13, 3), Position = UDim2.new(0.5, 0, 0.5, 0), Color = COLORS.Window, Z = 500 },
			{ Name = "VerticalFill", Size = _udim2Offset(1, 11), Position = UDim2.new(0.5, 0, 0.5, 0), Color = COLORS.Accent, Z = 501 },
			{ Name = "HorizontalFill", Size = _udim2Offset(11, 1), Position = UDim2.new(0.5, 0, 0.5, 0), Color = COLORS.Accent, Z = 501 },
		}

		for _, part in ipairs(cursorParts) do
			Veil.Instance:Create("Frame", {
				Name = part.Name,
				Active = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = part.Color,
				BorderSizePixel = 0,
				Interactable = false,
				Position = part.Position,
				Size = part.Size,
				ZIndex = part.Z,
				Parent = self.Cursor,
			})
		end

		self.DragBinding = Toolkit.Drag:AttachSmooth(self.Titlebar, self.Frame, {
			Smoothness = WindowDragSmoothness,
		})
		self.RenderBinding = RunService.RenderStepped:Connect(function()
			local mouseLocation = UserInputService:GetMouseLocation()

			if self.Cursor then
				self.Cursor.Position = _udim2Offset(mouseLocation.X, mouseLocation.Y)
				self.Cursor.Visible = self.Visible and self.CursorVisible
			end

			if self.Tooltip and self.Tooltip.Visible and self.ActiveTooltipAnchor and self.Visible then
				local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
				local tooltipWidth = self.Tooltip.AbsoluteSize.X
				local tooltipHeight = self.Tooltip.AbsoluteSize.Y
				local nextX = math.clamp(mouseLocation.X + TooltipOffset.X, 10, math.max(10, viewportSize.X - tooltipWidth - 10))
				local nextY = math.clamp(mouseLocation.Y + TooltipOffset.Y, tooltipHeight + 10, math.max(tooltipHeight + 10, viewportSize.Y - 10))
				self.Tooltip.Position = _udim2Offset(nextX, nextY)
			end

			for _, tab in ipairs(self.Tabs) do
				local layout = tab.ColumnLayout
				if layout then
					local dirty = false
					for index, targetBoundary in ipairs(layout.TargetBoundaries) do
						local currentBoundary = layout.CurrentBoundaries[index]
						local nextBoundary = currentBoundary + ((targetBoundary - currentBoundary) * ResizeSmoothness)
						if math.abs(targetBoundary - nextBoundary) < 0.0005 then
							nextBoundary = targetBoundary
						else
							dirty = true
						end
						layout.CurrentBoundaries[index] = nextBoundary
					end

					if dirty or layout.ActiveDivider then
						applyColumnLayout(tab)
					end
				end
			end
		end)
		UserInputService.MouseIconEnabled = false
		self.State:Set("Surface", self.Surface)

		return self
	end

	function Window:Destroy()
		for _, connection in ipairs(self.CleanupConnections) do
			if connection and connection.Disconnect then
				connection:Disconnect()
			end
		end

		table.clear(self.CleanupConnections)

		if self.DragBinding then
			self.DragBinding:Disconnect()
			self.DragBinding = nil
		end

		if self.RenderBinding then
			self.RenderBinding:Disconnect()
			self.RenderBinding = nil
		end

		if self.Frame then
			Veil.Instance:SecureDestroy(self.Frame)
			self.Frame = nil
		end

		if self.Cursor then
			Veil.Instance:SecureDestroy(self.Cursor)
			self.Cursor = nil
		end

		if self.Tooltip then
			Veil.Instance:SecureDestroy(self.Tooltip)
			self.Tooltip = nil
			self.TooltipLabel = nil
		end

		if self.SelectionHighlight then
			Veil.Instance:SecureDestroy(self.SelectionHighlight)
			self.SelectionHighlight = nil
		end

		if self.BlurEffect then
			Veil.Instance:SecureDestroy(self.BlurEffect)
			self.BlurEffect = nil
		end

		for _, tab in ipairs(self.Tabs) do
			if tab.ToggleControls then
				for _, toggle in ipairs(tab.ToggleControls) do
					toggle.Destroyed = true
					if toggle.ChangedSignal then
						toggle.ChangedSignal:Destroy()
					end
				end
			end

			if tab.AccessoryControls then
				for _, accessory in ipairs(tab.AccessoryControls) do
					if accessory.ChangedSignal then
						accessory.ChangedSignal:Destroy()
					end
					if accessory.TriggeredSignal then
						accessory.TriggeredSignal:Destroy()
					end
					if accessory.ModeMenu then
						Veil.Instance:SecureDestroy(accessory.ModeMenu)
						accessory.ModeMenu = nil
					end
					if accessory.Popup then
						Veil.Instance:SecureDestroy(accessory.Popup)
						accessory.Popup = nil
					end
				end
			end
		end

		UserInputService.MouseIconEnabled = true
	end

	function Window:_applySelectionHighlight(textBox)
		if not textBox or not self.SelectionHighlight then
			return
		end

		pcall(function()
			textBox.SelectionImageObject = self.SelectionHighlight
		end)
	end

	function Window:_ensureTooltip()
		if self.Tooltip then
			return self.Tooltip
		end

		self.Tooltip = Veil.Instance:Create("Frame", {
			Name = "AxisTooltip",
			Active = false,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = COLORS.Window,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Interactable = false,
			Visible = false,
			ZIndex = 250,
			Parent = self.Surface,
		})
		createCorner(self.Tooltip, 10)
		createBorder(self.Tooltip)
		createPadding(self.Tooltip, 8, 10, 8, 10)

		self.TooltipLabel = Veil.Instance:Create("TextLabel", {
			Name = "TooltipText",
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Interactable = false,
			Size = _udim2Offset(0, 0),
			Text = "",
			TextColor3 = COLORS.Text,
			TextSize = 12,
			TextTransparency = 1,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = 251,
			Parent = self.Tooltip,
		})

		return self.Tooltip
	end

	function Window:HideTooltip(anchor)
		if anchor and self.ActiveTooltipAnchor and self.ActiveTooltipAnchor ~= anchor then
			return
		end

		self.TooltipToken = self.TooltipToken + 1
		self.ActiveTooltipAnchor = nil
		self.ActiveTooltipText = nil

		if not self.Tooltip then
			return
		end

		local fadeOut = TweenService:Create(self.Tooltip, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		})
		local textFade = TweenService:Create(self.TooltipLabel, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 1,
		})

		local connection
		connection = fadeOut.Completed:Connect(function()
			if connection then
				connection:Disconnect()
			end
			if self.Tooltip then
				self.Tooltip.Visible = false
			end
		end)

		fadeOut:Play()
		textFade:Play()
	end

	function Window:ShowTooltip(anchor, text)
		if type(text) ~= "string" or text == "" then
			return
		end

		self:_ensureTooltip()
		self.ActiveTooltipAnchor = anchor
		self.ActiveTooltipText = text
		self.TooltipLabel.Text = text
		self.TooltipLabel.TextWrapped = false
		self.Tooltip.Visible = true
		self.Tooltip.BackgroundTransparency = 1
		self.TooltipLabel.TextTransparency = 1

		local singleLineSize = measureText(text, 12, Enum.Font.Gotham)
		if singleLineSize.X > TooltipMaxWidth then
			self.TooltipLabel.Size = _udim2Offset(TooltipMaxWidth, 0)
			self.TooltipLabel.AutomaticSize = Enum.AutomaticSize.Y
			self.TooltipLabel.TextWrapped = true
		else
			self.TooltipLabel.AutomaticSize = Enum.AutomaticSize.XY
			self.TooltipLabel.Size = _udim2Offset(0, 0)
		end

		TweenService:Create(self.Tooltip, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0,
		}):Play()
		TweenService:Create(self.TooltipLabel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0.12,
		}):Play()
	end

	function Window:SetVisible(visible)
		self.Visible = visible ~= false

		if self.Frame then
			self.Frame.Visible = self.Visible
		end

		if not self.Visible then
			self:HideTooltip()
			Axis:_closeActivePicker()
		end

		if self.BlurEffect then
			self.BlurEffect.Enabled = self.Visible and self.BackgroundBlurEnabled
		end

		self.CursorVisible = self.Visible
		UserInputService.MouseIconEnabled = not self.Visible
		return self.Visible
	end

	function Window:ToggleVisible()
		return self:SetVisible(not self.Visible)
	end

	function Window:SetBackgroundBlurEnabled(enabled)
		self.BackgroundBlurEnabled = enabled == true
		if self.BlurEffect then
			self.BlurEffect.Enabled = self.Visible and self.BackgroundBlurEnabled
			self.BlurEffect.Size = self.BackgroundBlurEnabled and BackgroundBlurSize or 0
		end
		return self.BackgroundBlurEnabled
	end

	function Window:SelectTab(tab)
		if not tab or self.SelectedTab == tab then
			return tab
		end

		for _, entry in ipairs(self.Tabs) do
			local isSelected = entry == tab
			entry.Content.Visible = isSelected
			if isSelected then
				self.SelectedTab = entry
			end
		end
		IconProvider:RefreshAllTabIcons()
		for _, entry in ipairs(self.Tabs) do
			setTabButtonVisual(entry, entry == self.SelectedTab, COLORS)
		end

		-- Notify tab select hooks (e.g. character viewer)
		if self._tabSelectHooks then
			for _, fn in ipairs(self._tabSelectHooks) do
				task.spawn(pcall, fn, self.SelectedTab)
			end
		end

		return self.SelectedTab
	end

	function Window:OnTabSelected(fn)
		self._tabSelectHooks = self._tabSelectHooks or {}
		table.insert(self._tabSelectHooks, fn)
	end

	function Window:CreateTab(options)
		options = options or {}

		local tab = {
			Name = options.Name or string.format("Tab %d", #self.Tabs + 1),
			Icon = options.Icon or "square",
			Order = #self.Tabs + 1,
			IconScale = type(options.IconScale) == "number" and options.IconScale or 1,
			PinnedBottom = options.PinnedBottom == true or options.Dock == "Bottom",
			Window = self,
			Controls = {},
			PersistControls = {},
			ToggleControls = {},
			AccessoryControls = {},
		}
		tab.IsSettings = options.Settings == true or string.lower(tab.Name) == "settings"
		local baseIconSize = TabButtonSize - (TabIconInset * 2)
		local iconSize = math.max(12, math.floor(baseIconSize * tab.IconScale + 0.5))
		local iconPosition = math.floor((TabButtonSize - iconSize) * 0.5 + 0.5)
		tab._iconSize = iconSize
		tab._iconPos = iconPosition

		local buttonParent = tab.PinnedBottom and self.BottomTabHost or self.TabList

		tab.TabButton = Veil.Instance:Create("TextButton", {
			Name = tab.Name .. "TabButton",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = tab.PinnedBottom and 1 or tab.Order,
			Size = _udim2Offset(TabButtonSize, TabButtonSize),
			Text = "",
			ZIndex = 5,
			Parent = buttonParent,
		})
		tab.ButtonScale = Veil.Instance:Create("UIScale", {
			Scale = TabButtonIdleScale,
			Parent = tab.TabButton,
		})

		if tab.PinnedBottom then
			tab.TabButton.AnchorPoint = Vector2.new(0.5, 0)
			tab.TabButton.Position = UDim2.new(0.5, 0, 0, 0)
		end

		tab.Highlight = Veil.Instance:Create("Frame", {
			Name = "Highlight",
			BackgroundColor3 = COLORS.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = _udim2Offset(TabButtonSize, TabButtonSize),
			ZIndex = 5,
			Parent = tab.TabButton,
		})
		tab.HighlightScale = Veil.Instance:Create("UIScale", {
			Scale = TabHighlightIdleScale,
			Parent = tab.Highlight,
		})
		createCorner(tab.Highlight, TabCornerRadius)
		tab.IconVisual = nil

		tab.Content = Veil.Instance:Create("Frame", {
			Name = tab.Name .. "Content",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = _udim2Scale(1, 1),
			Visible = false,
			ZIndex = 2,
			Parent = self.TabContentHost,
		})

		local columnMode = options.ColumnMode or (tab.IsSettings and "Triple" or "Triple")
		tab.leftColumn, tab.middleColumn, tab.rightColumn = createColumns(self, tab, tab.Content, columnMode)

		-- Column API - all methods accept an options table and return a control object.
		-- Common options across all controls:
		--   Name (string), Subtext (string), Default (initial value), Callback (fn)
		-- Control objects expose :Set(value) and :GetValue() unless noted otherwise.
		local function makeColumnApi(frame)
			return {
				Frame = frame,
				Tab = tab,
				Window = self,
				Label = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createLabel(columnApi.Tab, elementOptions)
				end,
				SubLabel = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createLabel(columnApi.Tab, elementOptions)
				end,
				Divider = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createDivider(columnApi.Tab, elementOptions)
				end,
				SectionHeader = function(columnApi, textOrOptions)
					local elementOptions = type(textOrOptions) == "table" and textOrOptions or { Text = textOrOptions }
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createSectionHeader(columnApi.Tab, elementOptions)
				end,
				CreateToggle = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createToggle(columnApi.Tab, elementOptions)
				end,
				AddToggle = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createToggle(columnApi.Tab, elementOptions)
				end,
				Slider = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createSlider(columnApi.Tab, elementOptions)
				end,
				NotchedSlider = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createNotchedSlider(columnApi.Tab, elementOptions)
				end,
				RangeSlider = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createRangeSlider(columnApi.Tab, elementOptions)
				end,
				Dropdown = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createDropdown(columnApi.Tab, elementOptions)
				end,
				Input = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createInput(columnApi.Tab, elementOptions)
				end,
				SecureInput = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createSecureInput(columnApi.Tab, elementOptions)
				end,
				Button = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createButton(columnApi.Tab, elementOptions)
				end,
				Checkbox = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createCheckbox(columnApi.Tab, elementOptions)
				end,
				Radio = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createRadio(columnApi.Tab, elementOptions)
				end,
				CurveEditor = function(columnApi, elementOptions)
					elementOptions = elementOptions or {}
					elementOptions.ColumnFrame = columnApi.Frame
					return columnApi.Window:_createCurveEditor(columnApi.Tab, elementOptions)
				end,
			}
		end

		tab.Columns = {
			leftColumn = makeColumnApi(tab.leftColumn),
			rightColumn = makeColumnApi(tab.rightColumn),
		}
		if tab.middleColumn then
			tab.Columns.middleColumn = makeColumnApi(tab.middleColumn)
		end

		function tab:CreateToggle(toggleOptions)
			return self.Window:_createToggle(self, toggleOptions)
		end
		tab.AddToggle = tab.CreateToggle
		function tab:Label(elementOptions)
			return self.Window:_createLabel(self, elementOptions)
		end
		function tab:Divider(elementOptions)
			return self.Window:_createDivider(self, elementOptions)
		end
		function tab:SectionHeader(textOrOptions)
			local elementOptions = type(textOrOptions) == "table" and textOrOptions or { Text = textOrOptions }
			return self.Window:_createSectionHeader(self, elementOptions)
		end
		function tab:Slider(elementOptions)
			return self.Window:_createSlider(self, elementOptions)
		end
		function tab:NotchedSlider(elementOptions)
			return self.Window:_createNotchedSlider(self, elementOptions)
		end
		function tab:RangeSlider(elementOptions)
			return self.Window:_createRangeSlider(self, elementOptions)
		end
		function tab:Dropdown(elementOptions)
			return self.Window:_createDropdown(self, elementOptions)
		end
		function tab:Input(elementOptions)
			return self.Window:_createInput(self, elementOptions)
		end
		function tab:SecureInput(elementOptions)
			return self.Window:_createSecureInput(self, elementOptions)
		end
		function tab:Button(elementOptions)
			return self.Window:_createButton(self, elementOptions)
		end
		function tab:Checkbox(elementOptions)
			return self.Window:_createCheckbox(self, elementOptions)
		end
		function tab:Radio(elementOptions)
			return self.Window:_createRadio(self, elementOptions)
		end
		function tab:CurveEditor(elementOptions)
			return self.Window:_createCurveEditor(self, elementOptions)
		end

		tab.TabButton.MouseButton1Click:Connect(function()
			self:SelectTab(tab)
		end)

		table.insert(IconTabRegistry, tab)
		table.insert(self.Tabs, tab)
		if not self.SelectedTab then
			self:SelectTab(tab)
		else
			IconProvider:RenderTabIcon(tab, false)
			setTabButtonVisual(tab, false, COLORS)
		end

		return tab
	end

	function Window:_createLabel(tab, options)
		options = options or {}

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local subtext = options.Subtext or options.Description or options.Desc
		local hasSubtext = type(subtext) == "string" and subtext ~= ""
		local holder = createTextRow(parentColumn, options.Name or "Label", hasSubtext and LabelRowWithSubtextHeight or LabelRowHeight)
		if type(options.Order) == "number" then holder.LayoutOrder = options.Order end

		local label = {
			Type = "Label",
			Text = options.Text or options.Name or "Label",
			Subtext = hasSubtext and subtext or nil,
			Holder = holder,
			Tab = tab,
			Window = self,
			HasSubtext = hasSubtext,
			RowHeight = hasSubtext and LabelRowWithSubtextHeight or LabelRowHeight,
			AccessoryWidth = 0,
		}
		assignPersistKey(tab, label, options, "Label")

		label.TitleLabel = Veil.Instance:Create("TextLabel", {
			Name = "Title",
			AnchorPoint = hasSubtext and Vector2.new(0, 0) or Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = hasSubtext and _udim2Offset(0, 6) or UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 18),
			Text = label.Text,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			TextTransparency = 0,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 5,
			Parent = holder,
		})

		if hasSubtext then
			label.SubtextLabel = Veil.Instance:Create("TextLabel", {
				Name = "Subtext",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = Enum.Font.Gotham,
				Position = _udim2Offset(0, 24),
				Size = UDim2.new(1, 0, 0, 16),
				Text = label.Subtext,
				TextColor3 = COLORS.Text,
				TextSize = 12,
				TextTransparency = 0.35,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 5,
				Parent = holder,
			})
		end

		function label:AddKeypicker(keypickerOptions)
			return self.Window:_createKeypicker(self, keypickerOptions)
		end

		function label:AddColorpicker(colorpickerOptions)
			return self.Window:_createColorpicker(self, colorpickerOptions)
		end

		function label:SetVisible(visible)
			self.Holder.Visible = visible ~= false
		end

		function label:RefreshTheme()
			self.TitleLabel.TextColor3 = COLORS.Text
			if self.SubtextLabel then
				self.SubtextLabel.TextColor3 = COLORS.Text
			end
		end

		registerTabControl(tab, label)
		return label
	end

	function Window:_createDivider(tab, options)
		options = options or {}

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local holder = createTextRow(parentColumn, options.Name or "Divider", 8)
		if type(options.Order) == "number" then holder.LayoutOrder = options.Order end

		local line = Veil.Instance:Create("Frame", {
			Name = "Line",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = COLORS.Stroke,
			BackgroundTransparency = STROKE_TRANSPARENCY,
			BorderSizePixel = 0,
			Position = UDim2.new(0, DividerInsetX, 0.5, 0),
			Size = UDim2.new(1, -(DividerInsetX * 2), 0, 1),
			ZIndex = 4,
			Parent = holder,
		})

		local divider = {
			Type = "Divider",
			Holder = holder,
			Line = line,
			Tab = tab,
			Window = self,
		}

		function divider:RefreshTheme()
			self.Line.BackgroundColor3 = COLORS.Stroke
		end

		registerTabControl(tab, divider)
		return divider
	end

	function Window:_createSectionHeader(tab, options)
		options = options or {}

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local leadTop = SectionSpacing - ElementSpacing
		local leadBottom = HeaderSpacing - ElementSpacing
		local holder = createTextRow(parentColumn, options.Name or "SectionHeader", leadTop + 18 + leadBottom)
		if type(options.Order) == "number" then holder.LayoutOrder = options.Order end

		local text = options.Text or options.Name or "Section"
		local textWidth = math.ceil(measureText(text, 12, Enum.Font.GothamMedium).X)
		local clampedTextWidth = math.clamp(textWidth + 10, 36, 120)
		local halfGap = math.floor((clampedTextWidth + SectionHeaderGap) * 0.5)
		local visualCenterY = leadTop + 9

		local centerLabel = Veil.Instance:Create("TextLabel", {
			Name = "Title",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.new(0.5, 0, 0, visualCenterY),
			Size = _udim2Offset(clampedTextWidth, 18),
			Text = text,
			TextColor3 = COLORS.Text,
			TextSize = 12,
			TextTransparency = 0.2,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 5,
			Parent = holder,
		})

		local leftLine = Veil.Instance:Create("Frame", {
			Name = "LeftLine",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = COLORS.Stroke,
			BackgroundTransparency = STROKE_TRANSPARENCY,
			BorderSizePixel = 0,
			Position = UDim2.new(0, DividerInsetX, 0, visualCenterY),
			Size = UDim2.new(0.5, -(DividerInsetX + halfGap), 0, 1),
			ZIndex = 4,
			Parent = holder,
		})

		local rightLine = Veil.Instance:Create("Frame", {
			Name = "RightLine",
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = COLORS.Stroke,
			BackgroundTransparency = STROKE_TRANSPARENCY,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -DividerInsetX, 0, visualCenterY),
			Size = UDim2.new(0.5, -(DividerInsetX + halfGap), 0, 1),
			ZIndex = 4,
			Parent = holder,
		})

		local header = {
			Type = "SectionHeader",
			Holder = holder,
			Label = centerLabel,
			LeftLine = leftLine,
			RightLine = rightLine,
			Tab = tab,
			Window = self,
		}

		function header:RefreshTheme()
			self.Label.TextColor3 = COLORS.Text
			self.LeftLine.BackgroundColor3 = COLORS.Stroke
			self.RightLine.BackgroundColor3 = COLORS.Stroke
		end

		registerTabControl(tab, header)
		return header
	end

	function Window:_positionPickerPopup(anchorButton, popup)
		if not anchorButton or not popup then
			return
		end

		local viewportSize = getViewportSize()
		local width = popup.AbsoluteSize.X > 0 and popup.AbsoluteSize.X or PickerPopupWidth
		local height = popup.AbsoluteSize.Y > 0 and popup.AbsoluteSize.Y or PickerPopupHeight
		local anchorPosition = anchorButton.AbsolutePosition
		local anchorSize = anchorButton.AbsoluteSize
		local nextX = anchorPosition.X + anchorSize.X - width
		local nextY = anchorPosition.Y + anchorSize.Y + 8

		nextX = math.clamp(nextX, 10, math.max(10, viewportSize.X - width - 10))
		nextY = math.clamp(nextY, 10, math.max(10, viewportSize.Y - height - 10))

		popup.Position = _udim2Offset(nextX, nextY)
	end

	-- PickerSurface-local placement: below anchor when possible, else above.
	-- Returns "below" or "above" so callers can choose the correct slide direction.
	function Window:_positionPickerPanelBelowAnchor(anchor, panel, panelWidth, panelHeight)
		if not anchor or not panel then
			return "below"
		end
		local viewportSize = getViewportSize()
		local anchorPos = anchor.AbsolutePosition
		local anchorSize = anchor.AbsoluteSize
		local surfaceOffset = Axis.PickerSurface and Axis.PickerSurface.AbsolutePosition or _v2zero
		local relX = anchorPos.X - surfaceOffset.X
		local relY = anchorPos.Y - surfaceOffset.Y
		local belowY = relY + anchorSize.Y + DropdownPanelGap
		local aboveY = relY - panelHeight - DropdownPanelGap
		local nextX = relX + anchorSize.X - panelWidth
		nextX = math.clamp(nextX, 10, math.max(10, viewportSize.X - panelWidth - 10))
		local nextY
		local direction
		if belowY + panelHeight <= viewportSize.Y - 10 then
			nextY = belowY
			direction = "below"
		elseif aboveY >= 10 then
			nextY = aboveY
			direction = "above"
		else
			nextY = math.clamp(belowY, 10, math.max(10, viewportSize.Y - panelHeight - 10))
			direction = "below"
		end
		panel.Size = _udim2Offset(panelWidth, panelHeight)
		panel.Position = _udim2Offset(nextX, nextY)
		return direction
	end

	function Window:_positionDropdownPanel(holder, panel, panelHeight)
		return self:_positionPickerPanelBelowAnchor(holder, panel, DropdownPanelWidth, panelHeight)
	end

	function Window:_createKeypicker(control, options)
		options = options or {}
		local shouldPersist = options.Persist ~= false

		local host = ensureAccessoryHost(control)
		local initialKey = normalizeKeyValue(options.Default or options.Key or "None")
		local allowedModes = {}
		for _, mode in ipairs(options.Modes or { "Always", "Hold", "Toggle" }) do
			if type(mode) == "string" and mode ~= "" then
				table.insert(allowedModes, mode)
			end
		end
		if #allowedModes == 0 then
			allowedModes = { "Always", "Hold", "Toggle" }
		end

		local requestedMode = tostring(options.Mode or "Toggle")
		local resolvedMode = table.find(allowedModes, requestedMode) and requestedMode or "Toggle"
		if not table.find(allowedModes, resolvedMode) then
			resolvedMode = allowedModes[1]
		end
		local keypicker = {
			Type = "Keypicker",
			Window = self,
			Control = control,
			Value = initialKey,
			Mode = resolvedMode,
			Modes = allowedModes,
			Disabled = options.Disabled == true,
			Callback = options.Callback or options.ActivatedCallback,
			ChangedCallback = options.ChangedCallback or options.OnChangedCallback,
			ChangedSignal = Toolkit.Signal.new(),
			TriggeredSignal = Toolkit.Signal.new(),
			Held = false,
			Toggled = false,
			Capturing = false,
		}
		if shouldPersist then
			assignAccessoryPersistKey(control, keypicker, "Keypicker")
		end

		local displayText = keypicker.Value
		local buttonWidth = math.max(KeypickerMinWidth, math.ceil(measureText(displayText, 11, Enum.Font.GothamMedium).X) + AccessoryTextPadding)
		keypicker.Button = makeAccessoryButton(host, "Keypicker", buttonWidth)
		keypicker.Button.Active = true
		keypicker.Button.LayoutOrder = #host:GetChildren()
		keypicker.ButtonLabel = Veil.Instance:Create("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Size = _udim2Scale(1, 1),
			Text = displayText,
			TextColor3 = COLORS.Text,
			TextSize = 11,
			TextTransparency = 0.12,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 11,
			Parent = keypicker.Button,
		})
		registerAccessory(control, buttonWidth)

		local pickerSurface = Axis:_ensurePickerSurface()
		keypicker.ModeMenu = Veil.Instance:Create("Frame", {
			Name = "AxisKeypickerModeMenu",
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			Size = _udim2Offset(KeypickerModeMenuWidth, getModeMenuHeight(#allowedModes)),
			Visible = false,
			ZIndex = 244,
			Parent = pickerSurface,
		})
		createCorner(keypicker.ModeMenu, DropdownCornerRadius)
		keypicker.ModeMenuBorder = createBorder(keypicker.ModeMenu)
		createPadding(keypicker.ModeMenu, DropdownPanelPadding, DropdownPanelPadding, DropdownPanelPadding, DropdownPanelPadding)

		Veil.Instance:Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, DropdownItemSpacing),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = keypicker.ModeMenu,
		})

		keypicker.ModeButtons = {}

		function keypicker:_refreshModeButtons()
			for modeName, button in pairs(self.ModeButtons) do
				local isSelected = modeName == self.Mode
				button.BackgroundColor3 = isSelected and COLORS.Accent or COLORS.ToggleOffBackground
				button.BackgroundTransparency = isSelected and 0.84 or 1
				button.TextColor3 = isSelected and COLORS.Accent or COLORS.Text
				button.TextTransparency = isSelected and 0.05 or 0.18
			end
		end

		for _, modeName in ipairs(allowedModes) do
			local modeButton = Veil.Instance:Create("TextButton", {
				Name = modeName,
				AutoButtonColor = false,
				BackgroundColor3 = COLORS.ToggleOffBackground,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, DropdownItemHeight),
				Text = modeName,
				TextColor3 = COLORS.Text,
				TextSize = 13,
				TextTransparency = 0.18,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 245,
				Parent = keypicker.ModeMenu,
			})
			createCorner(modeButton, 6)
			createPadding(modeButton, 0, 8, 0, 8)
			keypicker.ModeButtons[modeName] = modeButton
		end

		function keypicker:GetState()
			if self.Mode == "Always" then
				return true
			elseif self.Mode == "Hold" then
				return self.Held
			end

			return self.Toggled
		end

		function keypicker:_refreshButton()
			local width = math.max(KeypickerMinWidth, math.ceil(measureText(self.Capturing and "..." or self.Value, 11, Enum.Font.GothamMedium).X) + AccessoryTextPadding)
			local active = self:GetState()
			self.Button.Size = _udim2Offset(width, AccessoryButtonHeight)
			self.ButtonLabel.Text = self.Capturing and "..." or self.Value
			self.Button.BackgroundColor3 = active and COLORS.Accent or COLORS.ToggleOffBackground
			self.Button.BackgroundTransparency = self.Disabled and 0.2 or (active and 0.4 or 0)
			self.ButtonLabel.TextTransparency = self.Disabled and 0.45 or (active and 0 or 0.12)
			self.ButtonLabel.TextColor3 = self.Capturing and COLORS.Accent or (active and Color3.fromRGB(255, 255, 255) or COLORS.Text)
			self:_refreshModeButtons()
			refreshAccessoryWidth(control)
		end

		function keypicker:RefreshTheme()
			self.Button.BackgroundColor3 = self:GetState() and COLORS.Accent or COLORS.ToggleOffBackground
			self.ButtonLabel.TextColor3 = self.Capturing and COLORS.Accent or (self:GetState() and Color3.fromRGB(255, 255, 255) or COLORS.Text)
			self:_refreshModeButtons()
		end

		function keypicker:CloseModeMenu()
			if not self.ModeMenu then
				return
			end
			if self.ModeMenu:GetAttribute("AxisOpen") then
				self.ModeMenu:SetAttribute("AxisOpen", false)
				local currentPos = self.ModeMenu.Position
				local finalPos = _udim2Offset(currentPos.X.Offset, currentPos.Y.Offset - DropdownAnimSlide)
				local tweenInfo = TweenInfo.new(DropdownAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local anim = TweenService:Create(self.ModeMenu, tweenInfo, {
					BackgroundTransparency = 1,
					Position = finalPos,
				})
				if self.ModeMenuBorder then
					TweenService:Create(self.ModeMenuBorder, tweenInfo, {
						Transparency = 1,
					}):Play()
				end
				anim:Play()
				anim.Completed:Connect(function()
					if self.ModeMenu and not self.ModeMenu:GetAttribute("AxisOpen") then
						self.ModeMenu.Visible = false
						self.ModeMenu.Position = _udim2Offset(-4000, -4000)
					end
				end)
			else
				self.ModeMenu.Visible = false
				self.ModeMenu.Position = _udim2Offset(-4000, -4000)
			end
			if Axis.ActivePickerPopup == self.ModeMenu then
				Axis.ActivePickerPopup = nil
				Axis.ActivePickerClose = nil
				if Axis.PickerBackdrop then
					Axis.PickerBackdrop.Visible = false
				end
			end
		end

		function keypicker:OpenModeMenu()
			if self.Disabled or control.Disabled or not self.ModeMenu then
				return
			end

			Axis:_closeActivePicker(self.ModeMenu)
			Axis.ActivePickerPopup = self.ModeMenu
			Axis.ActivePickerClose = function()
				keypicker:CloseModeMenu()
			end
			self.ModeMenu.BackgroundTransparency = 1
			if self.ModeMenuBorder then
				self.ModeMenuBorder.Transparency = 1
			end
			self.ModeMenu.Position = _udim2Offset(-4000, -4000)
			self.ModeMenu.Visible = true
			self.ModeMenu:SetAttribute("AxisOpen", true)
			if Axis.PickerBackdrop then
				Axis.PickerBackdrop.Visible = true
			end
			task.spawn(function()
				task.wait()
				if not self.ModeMenu or not self.ModeMenu.Visible then
					return
				end
				local h = getModeMenuHeight(#self.Modes)
				self.Window:_positionPickerPanelBelowAnchor(self.Button, self.ModeMenu, KeypickerModeMenuWidth, h)
				local finalPos = self.ModeMenu.Position
				self.ModeMenu.Position = _udim2Offset(finalPos.X.Offset, finalPos.Y.Offset - DropdownAnimSlide)
				local tweenInfo = TweenInfo.new(DropdownAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(self.ModeMenu, tweenInfo, {
					BackgroundTransparency = 0,
					Position = finalPos,
				}):Play()
				if self.ModeMenuBorder then
					TweenService:Create(self.ModeMenuBorder, tweenInfo, {
						Transparency = STROKE_TRANSPARENCY,
					}):Play()
				end
			end)
		end

		function keypicker:SetMode(mode, setOptions)
			setOptions = setOptions or {}
			if not table.find(self.Modes, mode) then
				return self.Mode
			end

			local changed = mode ~= self.Mode
			self.Mode = mode
			if self.Mode == "Always" then
				self.Held = false
				self.Toggled = true
			elseif self.Mode == "Hold" then
				self.Held = false
				self.Toggled = false
			elseif self.Mode == "Toggle" then
				self.Held = false
				self.Toggled = false
			end
			self:_refreshButton()
			if changed and setOptions.Silent ~= true then
				self.TriggeredSignal:Fire(self:GetState(), self.Mode)
			end

			return self.Mode
		end

		function keypicker:GetMode()
			return self.Mode
		end

		function keypicker:SetDisabled(disabled)
			self.Disabled = disabled == true
			self.Button.Active = not self.Disabled
			if self.Disabled then
				self:CloseModeMenu()
			end
			self:_refreshButton()
		end

		function keypicker:SetKey(value, setOptions)
			setOptions = setOptions or {}
			local normalized = normalizeKeyValue(value)
			local changed = normalized ~= self.Value
			self.Value = normalized
			self.Capturing = false
			self:_refreshButton()

			if changed and setOptions.Silent ~= true then
				safeCallback(self.ChangedCallback, self.Value)
				self.ChangedSignal:Fire(self.Value)
			end

			return self.Value
		end

		function keypicker:GetKey()
			return self.Value
		end

		function keypicker:OnChanged(callback)
			local connection = self.ChangedSignal:Connect(callback)
			safeCallback(callback, self.Value)
			return connection
		end

		function keypicker:OnTriggered(callback)
			return self.TriggeredSignal:Connect(callback)
		end

		function keypicker:_activate(input)
			safeCallback(self.Callback, self:GetState(), self.Value, self.Mode, input)
			self.TriggeredSignal:Fire(self:GetState(), self.Value, self.Mode, input)
		end

		keypicker.Button.MouseButton1Click:Connect(function()
			if keypicker.Disabled or control.Disabled then
				return
			end

			keypicker.Capturing = true
			keypicker:CloseModeMenu()
			keypicker:_refreshButton()
		end)

		keypicker.Button.MouseButton2Click:Connect(function()
			if keypicker.ModeMenu:GetAttribute("AxisOpen") then
				keypicker:CloseModeMenu()
			else
				keypicker.Capturing = false
				keypicker:OpenModeMenu()
				keypicker:_refreshButton()
			end
		end)

		for modeName, modeButton in pairs(keypicker.ModeButtons) do
			modeButton.MouseButton1Click:Connect(function()
				keypicker:SetMode(modeName)
				keypicker:CloseModeMenu()
			end)
		end

		registerCleanup(self, UserInputService.InputBegan:Connect(function(input, processed)
			if processed then
				return
			end

			if keypicker.Capturing then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					if input.KeyCode == Enum.KeyCode.Unknown then
						return
					end

					if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
						keypicker:SetKey("None")
						return
					end

					keypicker:SetKey(input.KeyCode.Name)
					return
				elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
					keypicker:SetKey("MB1")
					return
				elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
					keypicker:SetKey("MB2")
					return
				elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
					keypicker:SetKey("MB3")
					return
				end

				return
			end

			if keypicker.ModeMenu and keypicker.ModeMenu:GetAttribute("AxisOpen") and input.UserInputType == Enum.UserInputType.MouseButton1 then
				local point = input.Position
				if not isPointInside(keypicker.ModeMenu, point) and not isPointInside(keypicker.Button, point) then
					keypicker:CloseModeMenu()
				end
			end

			if keypicker.Disabled or control.Disabled or UserInputService:GetFocusedTextBox() then
				return
			end

			if keyMatchesInput(keypicker.Value, input) then
				if keypicker.Mode == "Toggle" then
					keypicker.Toggled = not keypicker.Toggled
					keypicker:_refreshButton()
					keypicker:_activate(input)
				elseif keypicker.Mode == "Hold" then
					if not keypicker.Held then
						keypicker.Held = true
						keypicker:_refreshButton()
						keypicker:_activate(input)
					end
				elseif keypicker.Mode == "Always" then
					keypicker:_refreshButton()
					keypicker:_activate(input)
				end
			end
		end))

		registerCleanup(self, UserInputService.InputEnded:Connect(function(input)
			if keypicker.Disabled or control.Disabled then
				return
			end

			if keypicker.Mode == "Hold" and keyMatchesInput(keypicker.Value, input) and keypicker.Held then
				keypicker.Held = false
				keypicker:_refreshButton()
				keypicker:_activate(input)
			end
		end))

		keypicker:SetMode(keypicker.Mode, { Silent = true })
		keypicker:SetDisabled(keypicker.Disabled)
		table.insert(control.Tab.AccessoryControls, keypicker)
		control.Keypicker = keypicker
		return keypicker
	end

	function Window:_createColorpicker(control, options)
		options = options or {}
		local shouldPersist = options.Persist ~= false

		local host = ensureAccessoryHost(control)
		local initialColor = typeof(options.Default) == "Color3" and options.Default or COLORS.Accent
		local colorpicker = {
			Type = "Colorpicker",
			Window = self,
			Control = control,
			Value = initialColor,
			Alpha = tonumber(options.Alpha) or 0,
			Disabled = options.Disabled == true,
			Callback = options.Callback or options.ChangedCallback,
			ChangedSignal = Toolkit.Signal.new(),
		}
		if shouldPersist then
			assignAccessoryPersistKey(control, colorpicker, "Colorpicker")
		end

		local hue, sat, val = initialColor:ToHSV()
		colorpicker.Hue = hue
		colorpicker.Sat = sat
		colorpicker.Val = val

		colorpicker.Button = makeAccessoryButton(host, "Colorpicker", ColorpickerButtonSize)
		colorpicker.Button.Active = true
		colorpicker.Button.LayoutOrder = #host:GetChildren()
		colorpicker.ButtonSwatch = Veil.Instance:Create("Frame", {
			Name = "Swatch",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = initialColor,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -4, 1, -4),
			ZIndex = 11,
			Parent = colorpicker.Button,
		})
		createCorner(colorpicker.ButtonSwatch, 4)
		colorpicker.ButtonHitbox = Veil.Instance:Create("TextButton", {
			Name = "ColorpickerHitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = _udim2Scale(1, 1),
			Text = "",
			ZIndex = 12,
			Parent = colorpicker.Button,
		})
		registerAccessory(control, ColorpickerButtonSize)

		local pickerSurface = Axis:_ensurePickerSurface()
		colorpicker.Popup = Veil.Instance:Create("Frame", {
			Name = "AxisColorpickerPopup",
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			Size = _udim2Offset(PickerPopupWidth, PickerPopupHeight),
			Visible = false,
			ZIndex = 260,
			Parent = pickerSurface,
		})
		createCorner(colorpicker.Popup, PickerCornerRadius)
		colorpicker.PopupBorder = createBorder(colorpicker.Popup)
		createPadding(colorpicker.Popup, PickerPadding, PickerPadding, PickerPadding, PickerPadding)

		colorpicker.PopupPreview = Veil.Instance:Create("Frame", {
			Name = "Preview",
			BackgroundColor3 = initialColor,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, PickerPreviewHeight),
			ZIndex = 261,
			Parent = colorpicker.Popup,
		})
		createCorner(colorpicker.PopupPreview, 6)

		colorpicker.PopupPreviewLabel = Veil.Instance:Create("TextLabel", {
			Name = "PreviewText",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Size = _udim2Scale(1, 1),
			Text = "Color",
			TextColor3 = COLORS.Text,
			TextSize = 12,
			TextTransparency = 0.15,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 262,
			Parent = colorpicker.PopupPreview,
		})

		local pickerBodyHeight = PickerMapSize.Y
		local pickerBody = Veil.Instance:Create("Frame", {
			Name = "PickerBody",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = _udim2Offset(0, PickerPreviewHeight + 8),
			Size = UDim2.new(1, 0, 0, pickerBodyHeight),
			ZIndex = 261,
			Parent = colorpicker.Popup,
		})

		colorpicker.Map = Veil.Instance:Create("Frame", {
			Name = "SatValMap",
			Active = true,
			BackgroundColor3 = Color3.fromHSV(colorpicker.Hue, 1, 1),
			BorderSizePixel = 0,
			Size = UDim2.new(1, -PickerHueWidth - 8, 0, PickerMapSize.Y),
			ZIndex = 261,
			Parent = pickerBody,
		})
		createCorner(colorpicker.Map, 6)
		createBorder(colorpicker.Map)

		local satOverlay = Veil.Instance:Create("ImageLabel", {
			Name = "SatOverlay",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = "rbxassetid://4155801252",
			Size = _udim2Scale(1, 1),
			ZIndex = 262,
			Parent = colorpicker.Map,
		})
		createCorner(satOverlay, 6)

		colorpicker.MapHitbox = Veil.Instance:Create("TextButton", {
			Name = "MapHitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = _udim2Scale(1, 1),
			Text = "",
			ZIndex = 265,
			Parent = colorpicker.Map,
		})

		colorpicker.MapCursorOuter = Veil.Instance:Create("Frame", {
			Name = "MapCursorOuter",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			Size = _udim2Offset(8, 8),
			ZIndex = 263,
			Parent = colorpicker.Map,
		})
		createCorner(colorpicker.MapCursorOuter, 8)

		colorpicker.MapCursorInner = Veil.Instance:Create("Frame", {
			Name = "MapCursorInner",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = COLORS.Text,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = _udim2Offset(4, 4),
			ZIndex = 264,
			Parent = colorpicker.MapCursorOuter,
		})
		createCorner(colorpicker.MapCursorInner, 4)

		colorpicker.HueBar = Veil.Instance:Create("Frame", {
			Name = "HueBar",
			Active = true,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -PickerHueWidth, 0, 0),
			Size = _udim2Offset(PickerHueWidth, PickerMapSize.Y),
			ZIndex = 261,
			Parent = pickerBody,
		})
		createCorner(colorpicker.HueBar, 6)
		createBorder(colorpicker.HueBar)

		Veil.Instance:Create("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
			}),
			Parent = colorpicker.HueBar,
		})

		colorpicker.HueHitbox = Veil.Instance:Create("TextButton", {
			Name = "HueHitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = _udim2Scale(1, 1),
			Text = "",
			ZIndex = 264,
			Parent = colorpicker.HueBar,
		})

		colorpicker.HueCursor = Veil.Instance:Create("Frame", {
			Name = "HueCursor",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = COLORS.Text,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(1, 4, 0, 2),
			ZIndex = 263,
			Parent = colorpicker.HueBar,
		})
		createCorner(colorpicker.HueCursor, 2)

		colorpicker.FooterLabel = Veil.Instance:Create("TextLabel", {
			Name = "Footer",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			Position = _udim2Offset(0, PickerPreviewHeight + 8 + pickerBodyHeight + 8),
			Size = UDim2.new(1, 0, 0, 14),
			Text = "Alpha support reserved",
			TextColor3 = COLORS.Text,
			TextSize = 11,
			TextTransparency = 0.55,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 261,
			Parent = colorpicker.Popup,
		})

		function colorpicker:_refreshVisuals()
			local color = Color3.fromHSV(self.Hue, self.Sat, self.Val)
			self.Value = color
			self.ButtonSwatch.BackgroundColor3 = color
			self.PopupPreview.BackgroundColor3 = color
			self.Map.BackgroundColor3 = Color3.fromHSV(self.Hue, 1, 1)
			self.MapCursorOuter.Position = UDim2.new(self.Sat, 0, 1 - self.Val, 0)
			self.HueCursor.Position = UDim2.new(0.5, 0, self.Hue, 0)
			self.Button.BackgroundTransparency = self.Disabled and 0.2 or 0
		end

		function colorpicker:RefreshTheme()
			self.Button.BackgroundColor3 = COLORS.ToggleOffBackground
			self.Popup.BackgroundColor3 = COLORS.Window
			self.PopupPreviewLabel.TextColor3 = COLORS.Text
			self.MapCursorOuter.BackgroundColor3 = COLORS.Window
			self.MapCursorInner.BackgroundColor3 = COLORS.Text
			self.HueCursor.BackgroundColor3 = COLORS.Text
			self.FooterLabel.TextColor3 = COLORS.Text
			self:_refreshVisuals()
		end

		function colorpicker:SetDisabled(disabled)
			self.Disabled = disabled == true
			self.Button.Active = not self.Disabled
			self:_refreshVisuals()
			if self.Disabled and self.Popup.Visible then
				self.Popup.Visible = false
				Axis:_closeActivePicker()
			end
		end

		function colorpicker:SetColor(value, setOptions)
			setOptions = setOptions or {}
			if typeof(value) ~= "Color3" then
				return self.Value
			end

			local changed = self.Value ~= value
			self.Hue, self.Sat, self.Val = value:ToHSV()
			self:_refreshVisuals()

			if changed and setOptions.Silent ~= true then
				safeCallback(self.Callback, self.Value)
				self.ChangedSignal:Fire(self.Value)
			end

			return self.Value
		end

		function colorpicker:GetColor()
			return self.Value
		end

		function colorpicker:OnChanged(callback)
			local connection = self.ChangedSignal:Connect(callback)
			safeCallback(callback, self.Value)
			return connection
		end

		function colorpicker:_updateFromMap(inputPosition)
			local mapPosition = self.Map.AbsolutePosition
			local mapSize = self.Map.AbsoluteSize
			if mapSize.X <= 0 or mapSize.Y <= 0 then
				return
			end

			self.Sat = math.clamp((inputPosition.X - mapPosition.X) / mapSize.X, 0, 1)
			self.Val = 1 - math.clamp((inputPosition.Y - mapPosition.Y) / mapSize.Y, 0, 1)
			self:SetColor(Color3.fromHSV(self.Hue, self.Sat, self.Val))
		end

		function colorpicker:_updateFromHue(inputPosition)
			local huePosition = self.HueBar.AbsolutePosition
			local hueSize = self.HueBar.AbsoluteSize
			if hueSize.Y <= 0 then
				return
			end

			self.Hue = math.clamp((inputPosition.Y - huePosition.Y) / hueSize.Y, 0, 1)
			self:SetColor(Color3.fromHSV(self.Hue, self.Sat, self.Val))
		end

		local dragTarget = nil

		local function closePopup()
			if not colorpicker.Popup or not colorpicker.Popup:GetAttribute("AxisOpen") then return end
			colorpicker.Popup:SetAttribute("AxisOpen", false)
			local currentPos = colorpicker.Popup.Position
			local finalPos = _udim2Offset(currentPos.X.Offset, currentPos.Y.Offset - DropdownAnimSlide)
			local tweenInfo = TweenInfo.new(DropdownAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(colorpicker.Popup, tweenInfo, {
				BackgroundTransparency = 1,
				Position = finalPos,
			}):Play()
			if colorpicker.PopupBorder then
				TweenService:Create(colorpicker.PopupBorder, tweenInfo, {
					Transparency = 1,
				}):Play()
			end
			task.delay(DropdownAnimTime, function()
				if not colorpicker.Popup:GetAttribute("AxisOpen") then
					colorpicker.Popup.Visible = false
					colorpicker.Popup.Position = _udim2Offset(-4000, -4000)
				end
			end)
			if Axis.ActivePickerPopup == colorpicker.Popup then
				Axis.ActivePickerPopup = nil
				Axis.ActivePickerClose = nil
				if Axis.PickerBackdrop then
					Axis.PickerBackdrop.Visible = false
				end
			end
		end

		local function beginPopup()
			if colorpicker.Disabled or control.Disabled then
				return
			end

			self:HideTooltip(control)
			Axis:_closeActivePicker(colorpicker.Popup)
			Axis.ActivePickerPopup = colorpicker.Popup
			Axis.ActivePickerClose = function() closePopup() end
			colorpicker.Popup.BackgroundTransparency = 1
			if colorpicker.PopupBorder then colorpicker.PopupBorder.Transparency = 1 end
			colorpicker.Popup.Position = _udim2Offset(-4000, -4000)
			colorpicker.Popup.Visible = true
			colorpicker.Popup:SetAttribute("AxisOpen", true)
			if Axis.PickerBackdrop then
				Axis.PickerBackdrop.Visible = true
			end
			task.spawn(function()
				task.wait()
				if not colorpicker.Popup or not colorpicker.Popup.Visible then return end
				self:_positionPickerPopup(colorpicker.Button, colorpicker.Popup)
				local finalPos = colorpicker.Popup.Position
				colorpicker.Popup.Position = _udim2Offset(
					finalPos.X.Offset,
					finalPos.Y.Offset - DropdownAnimSlide
				)
				local tweenInfo = TweenInfo.new(DropdownAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(colorpicker.Popup, tweenInfo, {
					BackgroundTransparency = 0,
					Position = finalPos,
				}):Play()
				if colorpicker.PopupBorder then
					TweenService:Create(colorpicker.PopupBorder, tweenInfo, {
						Transparency = STROKE_TRANSPARENCY,
					}):Play()
				end
			end)
		end

		colorpicker.ButtonHitbox.MouseButton1Click:Connect(function()
			if colorpicker.Disabled or control.Disabled then
				return
			end

			if colorpicker.Popup.Visible then
				closePopup()
				return
			end

			beginPopup()
		end)

		colorpicker.MapHitbox.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			dragTarget = "Map"
			colorpicker:_updateFromMap(input.Position)
		end)

		colorpicker.HueHitbox.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			dragTarget = "Hue"
			colorpicker:_updateFromHue(input.Position)
		end)

		registerCleanup(self, UserInputService.InputChanged:Connect(function(input)
			if dragTarget == "Map" and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				colorpicker:_updateFromMap(input.Position)
			elseif dragTarget == "Hue" and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				colorpicker:_updateFromHue(input.Position)
			end
		end))

		registerCleanup(self, UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragTarget = nil
			end
		end))

		registerCleanup(self, UserInputService.InputBegan:Connect(function(input, processed)
			if processed or not colorpicker.Popup.Visible then
				return
			end

			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			local popupPos = colorpicker.Popup.AbsolutePosition
			local popupSize = colorpicker.Popup.AbsoluteSize
			local buttonPos = colorpicker.Button.AbsolutePosition
			local buttonSize = colorpicker.Button.AbsoluteSize
			local point = input.Position

			local insidePopup = point.X >= popupPos.X and point.X <= popupPos.X + popupSize.X
				and point.Y >= popupPos.Y and point.Y <= popupPos.Y + popupSize.Y
			local insideButton = point.X >= buttonPos.X and point.X <= buttonPos.X + buttonSize.X
				and point.Y >= buttonPos.Y and point.Y <= buttonPos.Y + buttonSize.Y

			if not insidePopup and not insideButton then
				closePopup()
			end
		end))

		colorpicker:_refreshVisuals()
		colorpicker:SetDisabled(colorpicker.Disabled)
		table.insert(control.Tab.AccessoryControls, colorpicker)
		control.Colorpicker = colorpicker
		return colorpicker
	end

	-- Toggle - on/off switch with optional tooltip accessory.
	-- options: {Name, Subtext?, Default (bool), Callback(bool)?, Persist?}
	-- Returned control: :Set(bool), :GetValue()->bool
	function Window:_createToggle(tab, options)
		options = options or {}
		local shouldPersist = options.Persist ~= false

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local subtext = options.Subtext or options.Description or options.Desc
		local hasSubtext = type(subtext) == "string" and subtext ~= ""
		local defaultValue = options.Default
		if defaultValue == nil then
			defaultValue = options.Value
		end
		local rowHeight = hasSubtext and ToggleRowWithSubtextHeight or ToggleRowHeight

		local toggle = {
			Type = "Toggle",
			Name = options.Name or options.Text or string.format("Toggle%d", #tab.ToggleControls + 1),
			Text = options.Text or options.Name or "Toggle",
			Subtext = hasSubtext and subtext or nil,
			Tooltip = not hasSubtext and options.Tooltip or nil,
			Value = defaultValue == nil and false or (not not defaultValue),
			Disabled = options.Disabled == true,
			Visible = options.Visible ~= false,
			Callback = options.Callback,
			ChangedSignal = Toolkit.Signal.new(),
			Tab = tab,
			Window = self,
			Hovering = false,
			Destroyed = false,
			HasSubtext = hasSubtext,
			RowHeight = rowHeight,
			AccessoryWidth = 0,
		}
		if shouldPersist then
			assignPersistKey(tab, toggle, options, "Toggle")
		end

		toggle.Holder = Veil.Instance:Create("Frame", {
			Name = toggle.Name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = nextOrder(parentColumn),
			Size = UDim2.new(1, 0, 0, rowHeight),
			Visible = toggle.Visible,
			Parent = parentColumn,
		})

		toggle.Button = Veil.Instance:Create("TextButton", {
			Name = "Hitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = _udim2Scale(1, 1),
			Text = "",
			ZIndex = 8,
			Parent = toggle.Holder,
		})

		toggle.LabelWrap = Veil.Instance:Create("Frame", {
			Name = "LabelWrap",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = hasSubtext and _udim2Offset(0, 6) or _udim2Offset(0, 0),
			Size = hasSubtext
				and UDim2.new(1, -(ToggleSwitchWidth + 16), 1, -12)
				or UDim2.new(1, -(ToggleSwitchWidth + 16), 1, 0),
			ZIndex = 5,
			Parent = toggle.Holder,
		})

		toggle.TitleLabel = Veil.Instance:Create("TextLabel", {
			Name = "Title",
			AnchorPoint = hasSubtext and Vector2.new(0, 0) or Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = hasSubtext and _udim2Offset(0, 0) or UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 18),
			Text = toggle.Text,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			TextTransparency = 0,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 5,
			Parent = toggle.LabelWrap,
		})

		if hasSubtext then
			toggle.SubtextLabel = Veil.Instance:Create("TextLabel", {
				Name = "Subtext",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = Enum.Font.Gotham,
				Position = _udim2Offset(0, 18),
				Size = UDim2.new(1, 0, 0, 16),
				Text = toggle.Subtext,
				TextColor3 = COLORS.Text,
				TextSize = 12,
				TextTransparency = 0.35,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 5,
				Parent = toggle.LabelWrap,
			})
		end

		toggle.Switch = Veil.Instance:Create("Frame", {
			Name = "Switch",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = COLORS.ToggleOffBackground,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -(ToggleSwitchWidth * 0.5), 0.5, 0),
			Size = _udim2Offset(ToggleSwitchWidth, ToggleSwitchHeight),
			ZIndex = 5,
			Parent = toggle.Holder,
		})
		createCorner(toggle.Switch, ToggleSwitchHeight / 2)

		toggle.SwitchDot = Veil.Instance:Create("Frame", {
			Name = "Dot",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = COLORS.ToggleOffDot,
			BorderSizePixel = 0,
			Position = _udim2Offset(2 + (ToggleDotSize * 0.5), ToggleSwitchHeight * 0.5),
			Size = _udim2Offset(ToggleDotSize, ToggleDotSize),
			ZIndex = 6,
			Parent = toggle.Switch,
		})
		createCorner(toggle.SwitchDot, ToggleDotSize / 2)

		toggle.SwitchStroke = Veil.Instance:Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = COLORS.Stroke,
			Transparency = STROKE_TRANSPARENCY,
			Thickness = 1,
			Parent = toggle.Switch,
		})

		function toggle:_applyVisualState(value, visualOptions)
			visualOptions = visualOptions or {}
			local instant = visualOptions.Instant == true
			local disabled = self.Disabled
			local dotOffX = 2 + (ToggleDotSize * 0.5)
			local dotOnX = ToggleSwitchWidth - 3 - (ToggleDotSize * 0.5) - 1
			local targetBackground = value and COLORS.Accent or COLORS.ToggleOffBackground
			local targetDotColor = value and COLORS.ToggleOnDot or COLORS.ToggleOffDot
			local targetDotPosition = _udim2Offset(value and dotOnX or dotOffX, ToggleSwitchHeight * 0.5)
			local titleTransparency = disabled and 0.45 or 0
			local subtextTransparency = disabled and 0.6 or 0.35
			local switchTransparency = disabled and 0.25 or 0
			local dotTransparency = disabled and 0.15 or 0

			if instant then
				self.Switch.BackgroundColor3 = targetBackground
				self.Switch.BackgroundTransparency = switchTransparency
				self.SwitchDot.BackgroundColor3 = targetDotColor
				self.SwitchDot.BackgroundTransparency = dotTransparency
				self.SwitchDot.Position = targetDotPosition
				self.TitleLabel.TextTransparency = titleTransparency
				if self.SubtextLabel then
					self.SubtextLabel.TextTransparency = subtextTransparency
				end
				return
			end

			TweenService:Create(self.Switch, TweenInfo.new(ToggleAnimationTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundColor3 = targetBackground,
				BackgroundTransparency = switchTransparency,
			}):Play()
			TweenService:Create(self.SwitchDot, TweenInfo.new(ToggleAnimationTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				BackgroundColor3 = targetDotColor,
				BackgroundTransparency = dotTransparency,
				Position = targetDotPosition,
			}):Play()
			TweenService:Create(self.TitleLabel, TweenInfo.new(ToggleAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = titleTransparency,
			}):Play()
			if self.SubtextLabel then
				TweenService:Create(self.SubtextLabel, TweenInfo.new(ToggleAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = subtextTransparency,
				}):Play()
			end
		end

		function toggle:Set(value, setOptions)
			setOptions = setOptions or {}
			local normalized = not not value
			local changed = normalized ~= self.Value

			if self.Disabled and changed then
				return self.Value
			end

			self.Value = normalized
			self:_applyVisualState(normalized, {
				Instant = setOptions.Instant == true,
			})

			if changed and setOptions.Silent ~= true then
				safeCallback(self.Callback, self.Value)
				self.ChangedSignal:Fire(self.Value)
			end

			return self.Value
		end

		function toggle:Toggle(setOptions)
			return self:Set(not self.Value, setOptions)
		end

		function toggle:Enable(setOptions)
			return self:Set(true, setOptions)
		end

		function toggle:Disable(setOptions)
			return self:Set(false, setOptions)
		end

		function toggle:IsEnabled()
			return self.Value
		end

		function toggle:SetDisabled(disabled)
			self.Disabled = disabled == true
			self.Button.Active = not self.Disabled
			if self.Disabled then
				self.Window:HideTooltip(self)
			end
			self:_applyVisualState(self.Value, {
				Instant = false,
			})
		end

		function toggle:SetVisible(visible)
			self.Visible = visible ~= false
			self.Holder.Visible = self.Visible
			if not self.Visible then
				self.Window:HideTooltip(self)
			end
		end

		function toggle:OnChanged(callback)
			local connection = self.ChangedSignal:Connect(callback)
			safeCallback(callback, self.Value)
			return connection
		end

		function toggle:RefreshTheme()
			self.TitleLabel.TextColor3 = COLORS.Text
			if self.SubtextLabel then
				self.SubtextLabel.TextColor3 = COLORS.Text
			end
			self.SwitchStroke.Color = COLORS.Stroke
			self:_applyVisualState(self.Value, {
				Instant = true,
			})
		end

		function toggle:AddKeypicker(keypickerOptions)
			return self.Window:_createKeypicker(self, keypickerOptions)
		end

		function toggle:AddColorpicker(colorpickerOptions)
			return self.Window:_createColorpicker(self, colorpickerOptions)
		end

		toggle.Button.MouseButton1Click:Connect(function()
			local mousePoint = UserInputService:GetMouseLocation()
			if toggle.AccessoryHost and isPointInside(toggle.AccessoryHost, mousePoint) then
				return
			end
			toggle:Toggle()
		end)

		-- Hover: brighten switch stroke
		local hoverTI = TweenInfo.new(TogglePressAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		toggle.Button.MouseEnter:Connect(function()
			toggle.Hovering = true
			if toggle.Disabled then return end
			TweenService:Create(toggle.SwitchStroke, hoverTI, {
				Transparency = ToggleHoverStrokeTransparency,
			}):Play()
		end)
		toggle.Button.MouseLeave:Connect(function()
			toggle.Hovering = false
			self:HideTooltip(toggle)
			TweenService:Create(toggle.SwitchStroke, hoverTI, {
				Transparency = STROKE_TRANSPARENCY,
			}):Play()
		end)

		-- Press: dot shrinks on down, restores on up
		local pressTI = TweenInfo.new(TogglePressAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		toggle.Button.InputBegan:Connect(function(input)
			if toggle.Disabled then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			TweenService:Create(toggle.SwitchDot, pressTI, {
				Size = _udim2Offset(ToggleDotPressSize, ToggleDotPressSize),
			}):Play()
		end)
		toggle.Button.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			TweenService:Create(toggle.SwitchDot, pressTI, {
				Size = _udim2Offset(ToggleDotSize, ToggleDotSize),
			}):Play()
		end)

		-- Tooltip (only when no subtext and tooltip string provided)
		if not hasSubtext and type(toggle.Tooltip) == "string" and toggle.Tooltip ~= "" then
			toggle.Button.MouseEnter:Connect(function()
				self.TooltipToken = self.TooltipToken + 1
				local token = self.TooltipToken
				task.delay(ToggleTooltipDelay, function()
					if toggle.Destroyed or not toggle.Hovering or toggle.Disabled then
						return
					end
					if self.TooltipToken ~= token then
						return
					end
					self:ShowTooltip(toggle, toggle.Tooltip)
				end)
			end)
		end

		toggle.Button.Active = not toggle.Disabled
		toggle:Set(toggle.Value, {
			Silent = true,
			Instant = true,
		})

		table.insert(tab.ToggleControls, toggle)
		if shouldPersist then
			registerPersistedControl(tab, toggle)
		end
		registerTabControl(tab, toggle)
		return toggle
	end

	-- ── Slider shared internals ──────────────────────────────────────────────

	local function makeThumbAnimator(thumb)
		local thumbTI = TweenInfo.new(SliderThumbAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		return function(state)
			local d = state == "drag" and SliderThumbDragDiameter
				or state == "hover" and SliderThumbHoverDiameter
				or SliderThumbDiameter
			TweenService:Create(thumb, thumbTI, {
				Size = _udim2Offset(d, d),
			}):Play()
		end
	end

	local function buildSliderTrack(holder, trackZoneTop, thumbRadius, trackInsetY)
		local trackZone = Veil.Instance:Create("Frame", {
			Name = "TrackZone",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = _udim2Offset(0, trackZoneTop),
			Size = UDim2.new(1, 0, 0, SliderThumbDiameter),
			ZIndex = 5,
			Parent = holder,
		})

		local trackBg = Veil.Instance:Create("Frame", {
			Name = "TrackBg",
			BackgroundColor3 = COLORS.ToggleOffBackground,
			BorderSizePixel = 0,
			Position = _udim2Offset(thumbRadius, trackInsetY),
			Size = UDim2.new(1, -SliderThumbDiameter, 0, SliderTrackHeight),
			ZIndex = 5,
			Parent = trackZone,
		})
		createCorner(trackBg, SliderTrackHeight / 2)

		local trackFill = Veil.Instance:Create("Frame", {
			Name = "TrackFill",
			BackgroundColor3 = COLORS.Accent,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0),
			ZIndex = 6,
			Parent = trackBg,
		})
		createCorner(trackFill, SliderTrackHeight / 2)

		local thumb = Veil.Instance:Create("Frame", {
			Name = "Thumb",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = COLORS.Accent,
			BorderSizePixel = 0,
			Position = _udim2Offset(thumbRadius, SliderThumbDiameter / 2),
			Size = _udim2Offset(SliderThumbDiameter, SliderThumbDiameter),
			ZIndex = 7,
			Parent = trackZone,
		})
		createCorner(thumb, SliderThumbDiameter / 2)

		local hitbox = Veil.Instance:Create("TextButton", {
			Name = "Hitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = _udim2Scale(1, 1),
			Text = "",
			ZIndex = 8,
			Parent = trackZone,
		})

		return trackZone, trackBg, trackFill, thumb, hitbox
	end

	local function buildSliderTextRows(holder, name, subtext, hasSubtext)
		local title = Veil.Instance:Create("TextLabel", {
			Name = "Title",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = _udim2Offset(0, 0),
			Size = UDim2.new(1, -SliderValueWidth, 0, 18),
			Text = name,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			TextTransparency = 0,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 5,
			Parent = holder,
		})

		local valueLabel = Veil.Instance:Create("TextLabel", {
			Name = "Value",
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.new(1, 0, 0, 0),
			Size = _udim2Offset(SliderValueWidth, 18),
			Text = "",
			TextColor3 = COLORS.Text,
			TextSize = 12,
			TextTransparency = 0.25,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 5,
			Parent = holder,
		})

		local subtextLabel = nil
		if hasSubtext then
			subtextLabel = Veil.Instance:Create("TextLabel", {
				Name = "Subtext",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = Enum.Font.Gotham,
				Position = _udim2Offset(0, 18),
				Size = UDim2.new(1, 0, 0, 16),
				Text = subtext,
				TextColor3 = COLORS.Text,
				TextSize = 12,
				TextTransparency = 0.35,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 5,
				Parent = holder,
			})
		end

		return title, valueLabel, subtextLabel
	end

	-- ── Dropdown ─────────────────────────────────────────────────────────────

	-- Dropdown - single or multi-select with optional search filter.
	-- options: {Name, Items (string[]), Default (string|string[]), MultiSelect?,
	--           Searchable?, Callback(value|values)?}
	-- Multi Default must be a table; Callback receives string[] when MultiSelect=true.
	function Window:_createDropdown(tab, options)
		options = options or {}
		local shouldPersist = options.Persist ~= false

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local items = options.Items or options.Options or {}
		local isMulti = options.MultiSelect == true

		local defaultValue = nil
		local defaultValues = {}
		if isMulti then
			local dv = options.Default or options.Values or options.Defaults
			if type(dv) == "table" then
				for _, v in ipairs(dv) do
					defaultValues[v] = true
				end
			end
		else
			defaultValue = options.Default or options.Value
			if defaultValue == nil and #items > 0 then
				defaultValue = items[1]
			end
		end

		local dropdown = {
			Type = "Dropdown",
			Name = options.Name or "Dropdown",
			Text = options.Name or "Dropdown",
			MultiSelect = isMulti,
			Searchable = options.Searchable == true,
			_searchQuery = "",
			Value = defaultValue,
			Values = defaultValues,
			Items = items,
			Disabled = options.Disabled == true,
			Visible = options.Visible ~= false,
			Callback = options.Callback,
			ChangedSignal = Toolkit.Signal.new(),
			Tab = tab,
			Window = self,
		}
		if shouldPersist then
			assignPersistKey(tab, dropdown, options, "Dropdown")
		end

		local function computeBadgeText()
			if dropdown.MultiSelect then
				local selected = {}
				for _, it in ipairs(dropdown.Items) do
					if dropdown.Values[it] then
						table.insert(selected, it)
					end
				end
				local n = #selected
				if n == 0 then return "None"
				elseif n == 1 then return tostring(selected[1])
				else return n .. " selected"
				end
			end
			return tostring(dropdown.Value or "")
		end

		dropdown.Holder = Veil.Instance:Create("Frame", {
			Name = dropdown.Name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = type(options.Order) == "number" and options.Order or nextOrder(parentColumn),
			Size = UDim2.new(1, 0, 0, DropdownRowHeight),
			Visible = dropdown.Visible,
			Parent = parentColumn,
		})

		dropdown.Button = Veil.Instance:Create("TextButton", {
			Name = "Hitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = _udim2Scale(1, 1),
			Text = "",
			ZIndex = 8,
			Parent = dropdown.Holder,
		})

		local rightReserved = DropdownValueWidth + 8

		dropdown.LabelWrap = Veil.Instance:Create("Frame", {
			Name = "LabelWrap",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -rightReserved, 1, 0),
			ZIndex = 5,
			Parent = dropdown.Holder,
		})

		dropdown.TitleLabel = Veil.Instance:Create("TextLabel", {
			Name = "Title",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 18),
			Text = dropdown.Text,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 5,
			Parent = dropdown.LabelWrap,
		})

		dropdown.ValueBadge = Veil.Instance:Create("Frame", {
			Name = "ValueBadge",
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = COLORS.ToggleOffBackground,
			BorderSizePixel = 0,
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = _udim2Offset(DropdownValueWidth, AccessoryButtonHeight),
			ZIndex = 5,
			Parent = dropdown.Holder,
		})
		createCorner(dropdown.ValueBadge, 6)
		Veil.Instance:Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = COLORS.Stroke,
			Transparency = STROKE_TRANSPARENCY,
			Thickness = 1,
			Parent = dropdown.ValueBadge,
		})

		dropdown.ValueLabel = Veil.Instance:Create("TextLabel", {
			Name = "Value",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Size = _udim2Scale(1, 1),
			Text = computeBadgeText(),
			TextColor3 = COLORS.Text,
			TextSize = 11,
			TextTransparency = 0.12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 6,
			Parent = dropdown.ValueBadge,
		})

		local pickerSurface = Axis:_ensurePickerSurface()

		dropdown.Panel = Veil.Instance:Create("Frame", {
			Name = "AxisDropdownPanel",
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			Size = _udim2Offset(200, 100),
			Visible = false,
			ZIndex = 244,
			Parent = pickerSurface,
		})
		createCorner(dropdown.Panel, DropdownCornerRadius)
		dropdown.PanelBorder = createBorder(dropdown.Panel)
		createPadding(dropdown.Panel, DropdownPanelPadding, DropdownPanelPadding, DropdownPanelPadding, DropdownPanelPadding)

		-- Forward declaration so the search callback and buildItems share the same upvalue
		local buildItems

		if dropdown.Searchable then
			local searchBarFrame = Veil.Instance:Create("Frame", {
				Name = "SearchBar",
				BackgroundColor3 = COLORS.ToggleOffBackground,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, DropdownSearchBarHeight),
				ZIndex = 245,
				Parent = dropdown.Panel,
			})
			createCorner(searchBarFrame, 6)
			Veil.Instance:Create("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = COLORS.Stroke,
				Transparency = STROKE_TRANSPARENCY,
				Thickness = 1,
				Parent = searchBarFrame,
			})
			dropdown.SearchBox = Veil.Instance:Create("TextBox", {
				Name = "SearchInput",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
				Font = Enum.Font.GothamMedium,
				PlaceholderColor3 = COLORS.Text,
				PlaceholderText = "Search...",
				Size = _udim2Scale(1, 1),
				Text = "",
				TextColor3 = COLORS.Text,
				TextSize = 11,
				TextTransparency = 0.12,
				TextXAlignment = Enum.TextXAlignment.Center,
				ZIndex = 246,
				Parent = searchBarFrame,
			})
			self:_applySelectionHighlight(dropdown.SearchBox)
			dropdown.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
				dropdown._searchQuery = dropdown.SearchBox.Text
				buildItems()
			end)
		end

		local itemListOffsetY = dropdown.Searchable
			and (DropdownSearchBarHeight + DropdownSearchBarGap)
			or 0

		dropdown.ItemList = Veil.Instance:Create("ScrollingFrame", {
			Name = "ItemList",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Position = _udim2Offset(0, itemListOffsetY),
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Size = UDim2.new(1, 0, 1, -itemListOffsetY),
			ZIndex = 245,
			Parent = dropdown.Panel,
		})

		Veil.Instance:Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, DropdownItemSpacing),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = dropdown.ItemList,
		})

		buildItems = function()
			for _, child in ipairs(dropdown.ItemList:GetChildren()) do
				if child:IsA("GuiButton") then
					child:Destroy()
				end
			end
			local visibleItems = dropdown.Items
			if dropdown.Searchable and dropdown._searchQuery ~= "" then
				local q = string.lower(dropdown._searchQuery)
				local filtered = {}
				for _, item in ipairs(dropdown.Items) do
					if string.find(string.lower(tostring(item)), q, 1, true) then
						table.insert(filtered, item)
					end
				end
				visibleItems = filtered
			end
			for i, item in ipairs(visibleItems) do
				local isSelected = dropdown.MultiSelect
					and (dropdown.Values[item] == true)
					or (item == dropdown.Value)
				local itemButton = Veil.Instance:Create("TextButton", {
					Name = tostring(item),
					AutoButtonColor = false,
					BackgroundColor3 = COLORS.Accent,
					BackgroundTransparency = isSelected and 0.84 or 1,
					BorderSizePixel = 0,
					Font = Enum.Font.GothamMedium,
					LayoutOrder = i,
					Size = UDim2.new(1, 0, 0, DropdownItemHeight),
					Text = tostring(item),
					TextColor3 = isSelected and COLORS.Accent or COLORS.Text,
					TextSize = 13,
					TextTransparency = isSelected and 0.05 or 0.18,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 245,
					Parent = dropdown.ItemList,
				})
				createCorner(itemButton, 6)
				createPadding(itemButton, 0, 8, 0, 8)
				itemButton.MouseButton1Click:Connect(function()
					if dropdown.MultiSelect then
						dropdown:ToggleValue(item)
					else
						dropdown:Set(item)
						dropdown:Close()
					end
				end)
			end
			local totalHeight = #visibleItems * DropdownItemHeight
				+ math.max(0, #visibleItems - 1) * DropdownItemSpacing
			dropdown.ItemList.CanvasSize = _udim2Offset(0, totalHeight)
		end

		buildItems()

		local function computePanelHeight()
			local count = math.min(#dropdown.Items, DropdownMaxVisibleItems)
			local h = count * DropdownItemHeight
				+ math.max(0, count - 1) * DropdownItemSpacing
				+ DropdownPanelPadding * 2
			if dropdown.Searchable then
				h = h + DropdownSearchBarHeight + DropdownSearchBarGap
			end
			return h
		end

		function dropdown:Open()
			if self.Disabled then return end
			Axis:_closeActivePicker(self.Panel)
			Axis.ActivePickerPopup = self.Panel
			Axis.ActivePickerClose = function() self:Close() end
			self.Panel.BackgroundTransparency = 1
			if self.PanelBorder then self.PanelBorder.Transparency = 1 end
			self.Panel.Position = _udim2Offset(-4000, -4000)
			self.Panel.Visible = true
			self.Panel:SetAttribute("AxisOpen", true)
			if Axis.PickerBackdrop then
				Axis.PickerBackdrop.Visible = true
			end
			task.spawn(function()
				task.wait()
				if not self.Panel or not self.Panel.Visible then return end
				local h = computePanelHeight()
				local direction = self.Window:_positionDropdownPanel(self.Holder, self.Panel, h)
				self._openDirection = direction
				local finalPos = self.Panel.Position
				-- Slide from opposite side: below->slide down from above; above->slide up from below
				local slideY = direction == "above" and DropdownAnimSlide or -DropdownAnimSlide
				self.Panel.Position = _udim2Offset(
					finalPos.X.Offset,
					finalPos.Y.Offset + slideY
				)
				local tweenInfo = TweenInfo.new(DropdownAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(self.Panel, tweenInfo, {
					BackgroundTransparency = 0,
					Position = finalPos,
				}):Play()
				if self.PanelBorder then
					TweenService:Create(self.PanelBorder, tweenInfo, {
						Transparency = STROKE_TRANSPARENCY,
					}):Play()
				end
			end)
		end

		function dropdown:Close()
			if self.Searchable and self.SearchBox then
				self._searchQuery = ""
				self.SearchBox.Text = ""
				buildItems()
			end
			if self.Panel and self.Panel:GetAttribute("AxisOpen") then
				self.Panel:SetAttribute("AxisOpen", false)
				local currentPos = self.Panel.Position
				-- Slide out toward origin: below->slide up; above->slide down
				local slideY = self._openDirection == "above" and DropdownAnimSlide or -DropdownAnimSlide
				local finalPos = _udim2Offset(currentPos.X.Offset, currentPos.Y.Offset + slideY)
				
				local tweenInfo = TweenInfo.new(DropdownAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local anim = TweenService:Create(self.Panel, tweenInfo, {
					BackgroundTransparency = 1,
					Position = finalPos,
				})
				
				if self.PanelBorder then
					TweenService:Create(self.PanelBorder, tweenInfo, {
						Transparency = 1,
					}):Play()
				end
				
				anim:Play()
				anim.Completed:Connect(function()
					if not self.Panel:GetAttribute("AxisOpen") then
						self.Panel.Visible = false
						self.Panel.Position = _udim2Offset(-4000, -4000)
					end
				end)
			end
			if Axis.ActivePickerPopup == self.Panel then
				Axis.ActivePickerPopup = nil
				Axis.ActivePickerClose = nil
				if Axis.PickerBackdrop then
					Axis.PickerBackdrop.Visible = false
				end
			end
		end

		function dropdown:Set(value, opts)
			opts = opts or {}
			if self.MultiSelect then
				self:SetValues(type(value) == "table" and value or {value}, opts)
				return
			end
			self.Value = value
			self.ValueLabel.Text = computeBadgeText()
			buildItems()
			if not opts.Silent and self.Callback then
				pcall(self.Callback, value)
			end
			if not opts.Silent then
				self.ChangedSignal:Fire(value)
			end
		end

		function dropdown:SetValues(tbl, opts)
			opts = opts or {}
			self.Values = {}
			if type(tbl) == "table" then
				for _, v in ipairs(tbl) do
					self.Values[v] = true
				end
			end
			self.ValueLabel.Text = computeBadgeText()
			buildItems()
			if not opts.Silent then
				local result = self:GetValue()
				if self.Callback then
					pcall(self.Callback, result)
				end
				self.ChangedSignal:Fire(result)
			end
		end

		function dropdown:ToggleValue(item)
			if self.Values[item] then
				self.Values[item] = nil
			else
				self.Values[item] = true
			end
			self.ValueLabel.Text = computeBadgeText()
			buildItems()
			local result = self:GetValue()
			if self.Callback then
				pcall(self.Callback, result)
			end
			self.ChangedSignal:Fire(result)
		end

		function dropdown:GetValue()
			if self.MultiSelect then
				local out = {}
				for _, it in ipairs(self.Items) do
					if self.Values[it] then
						table.insert(out, it)
					end
				end
				return out
			end
			return self.Value
		end

		function dropdown:OnChanged(callback)
			return self.ChangedSignal:Connect(callback)
		end

		function dropdown:SetDisabled(disabled)
			self.Disabled = disabled == true
			self.Button.Active = not self.Disabled
			self.TitleLabel.TextTransparency = self.Disabled and 0.5 or 0
			self.ValueBadge.BackgroundTransparency = self.Disabled and 0.25 or 0
			self.ValueLabel.TextTransparency = self.Disabled and 0.45 or 0.12
			if self.SearchBox then
				self.SearchBox.TextEditable = not self.Disabled
			end
			if self.Disabled then
				self:Close()
			end
		end

		function dropdown:SetVisible(visible)
			self.Visible = visible ~= false
			self.Holder.Visible = self.Visible
			if not self.Visible then
				self:Close()
			end
		end

		function dropdown:RefreshTheme()
			self.TitleLabel.TextColor3 = COLORS.Text
			self.ValueBadge.BackgroundColor3 = COLORS.ToggleOffBackground
			self.ValueLabel.TextColor3 = COLORS.Text
			self.Panel.BackgroundColor3 = COLORS.Window
			if self.PanelBorder then
				self.PanelBorder.Color = COLORS.Stroke
			end
			if self.SearchBox then
				self.SearchBox.TextColor3 = COLORS.Text
				self.SearchBox.PlaceholderColor3 = COLORS.Text
				local searchBar = self.SearchBox.Parent
				searchBar.BackgroundColor3 = COLORS.ToggleOffBackground
			end
			buildItems()
			self:SetDisabled(self.Disabled)
		end

		function dropdown:SetItems(newItems)
			self.Items = newItems or {}
			self.Values = {}
			self.ValueLabel.Text = computeBadgeText()
			buildItems()
		end

		dropdown.Button.MouseButton1Click:Connect(function()
			if dropdown.Disabled then return end
			if dropdown.Panel.Visible then
				dropdown:Close()
			else
				dropdown:Open()
			end
		end)

		registerCleanup(self, UserInputService.InputBegan:Connect(function(input, processed)
			if processed or not dropdown.Panel.Visible then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local pp = dropdown.Panel.AbsolutePosition
			local ps = dropdown.Panel.AbsoluteSize
			local hp = dropdown.Holder.AbsolutePosition
			local hs = dropdown.Holder.AbsoluteSize
			local pt = input.Position
			local inPanel = pt.X >= pp.X and pt.X <= pp.X + ps.X and pt.Y >= pp.Y and pt.Y <= pp.Y + ps.Y
			local inHolder = pt.X >= hp.X and pt.X <= hp.X + hs.X and pt.Y >= hp.Y and pt.Y <= hp.Y + hs.Y
			if not inPanel and not inHolder then
				dropdown:Close()
			end
		end))

		dropdown:SetDisabled(dropdown.Disabled)
		if shouldPersist then
			registerPersistedControl(tab, dropdown)
		end
		registerTabControl(tab, dropdown)
		return dropdown
	end

	-- ── Input / SecureInput ───────────────────────────────────────────────────
	-- Input: options: {Name, Placeholder?, Default?, MaxLength?, Validator(v)->bool?,
	--                  Callback(value)?}
	-- Validator receives the raw string; red stroke shown on false, no callback fired.
	-- SecureInput: same API but TextBox.Text is always masked as bullets (*).
	-- Real value is stored internally and passed unmasked to Callback.

	function Window:_createInput(tab, options)
		options = options or {}
		local shouldPersist = options.Persist ~= false

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local input = {
			Type = "Input",
			Name = options.Name or "Input",
			Value = tostring(options.Default or options.Value or ""),
			Placeholder = options.Placeholder or "",
			MaxLength = tonumber(options.MaxLength),
			Validator = type(options.Validator) == "function" and options.Validator or nil,
			Disabled = options.Disabled == true,
			Visible = options.Visible ~= false,
			Callback = options.Callback,
			ChangedSignal = Toolkit.Signal.new(),
			Tab = tab,
			Window = self,
		}
		if shouldPersist then
			assignPersistKey(tab, input, options, "Input")
		end

		input.Holder = Veil.Instance:Create("Frame", {
			Name = input.Name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = type(options.Order) == "number" and options.Order or nextOrder(parentColumn),
			Size = UDim2.new(1, 0, 0, InputRowHeight),
			Visible = input.Visible,
			Parent = parentColumn,
		})

		local rightReserved = InputFieldWidth + 8

		input.LabelWrap = Veil.Instance:Create("Frame", {
			Name = "LabelWrap",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -rightReserved, 1, 0),
			ZIndex = 5,
			Parent = input.Holder,
		})

		input.TitleLabel = Veil.Instance:Create("TextLabel", {
			Name = "Title",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 18),
			Text = input.Name,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5,
			Parent = input.LabelWrap,
		})

		-- Styled container
		input.FieldFrame = Veil.Instance:Create("Frame", {
			Name = "FieldFrame",
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = COLORS.ToggleOffBackground,
			BorderSizePixel = 0,
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = _udim2Offset(InputFieldWidth, AccessoryButtonHeight),
			ZIndex = 5,
			Parent = input.Holder,
		})
		createCorner(input.FieldFrame, 6)
		input.FieldStroke = Veil.Instance:Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = COLORS.Stroke,
			Transparency = STROKE_TRANSPARENCY,
			Thickness = 1,
			Parent = input.FieldFrame,
		})
		createPadding(input.FieldFrame, 0, 6, 0, 6)

		input.TextBox = Veil.Instance:Create("TextBox", {
			Name = "TextBox",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
			Font = Enum.Font.GothamMedium,
			PlaceholderColor3 = COLORS.Text,
			PlaceholderText = input.Placeholder,
			Size = _udim2Scale(1, 1),
			Text = input.Value,
			TextColor3 = COLORS.Text,
			TextSize = 11,
			TextTransparency = 0.12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 6,
			Parent = input.FieldFrame,
		})
		self:_applySelectionHighlight(input.TextBox)

		-- Focus state: brighten stroke
		local focusTI = TweenInfo.new(InputAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		input.TextBox.Focused:Connect(function()
			if input.Disabled then
				input.TextBox:ReleaseFocus()
				return
			end
			TweenService:Create(input.FieldStroke, focusTI, {
				Transparency = InputFocusStrokeTransparency,
			}):Play()
		end)

		input.TextBox.FocusLost:Connect(function(enterPressed)
			TweenService:Create(input.FieldStroke, focusTI, {
				Transparency = STROKE_TRANSPARENCY,
			}):Play()

			local raw = input.TextBox.Text

			-- MaxLength clamp
			if input.MaxLength and #raw > input.MaxLength then
				raw = string.sub(raw, 1, input.MaxLength)
				input.TextBox.Text = raw
			end

			-- Validator: revert if invalid
			if input.Validator then
				local ok, valid = pcall(input.Validator, raw)
				if not ok or not valid then
					input.TextBox.Text = input.Value
					return
				end
			end

			if raw ~= input.Value then
				input.Value = raw
				if input.Callback then
					pcall(input.Callback, raw)
				end
				input.ChangedSignal:Fire(raw)
			end
		end)

		function input:Set(value, opts)
			opts = opts or {}
			local v = tostring(value or "")
			if input.MaxLength and #v > input.MaxLength then
				v = string.sub(v, 1, input.MaxLength)
			end
			self.Value = v
			self.TextBox.Text = v
			if not opts.Silent then
				if self.Callback then pcall(self.Callback, v) end
				self.ChangedSignal:Fire(v)
			end
		end

		function input:GetValue()
			return self.Value
		end

		function input:OnChanged(callback)
			return self.ChangedSignal:Connect(callback)
		end

		function input:SetDisabled(disabled)
			self.Disabled = disabled == true
			self.TextBox.TextEditable = not self.Disabled
			self.TitleLabel.TextTransparency = self.Disabled and 0.5 or 0
			self.TextBox.TextTransparency = self.Disabled and 0.5 or 0.12
			self.FieldFrame.BackgroundTransparency = self.Disabled and 0.4 or 0
		end

		function input:SetVisible(visible)
			self.Visible = visible ~= false
			self.Holder.Visible = self.Visible
		end

		function input:RefreshTheme()
			self.TitleLabel.TextColor3 = COLORS.Text
			self.FieldFrame.BackgroundColor3 = COLORS.ToggleOffBackground
			self.TextBox.TextColor3 = COLORS.Text
			self.TextBox.PlaceholderColor3 = COLORS.Text
			self.FieldStroke.Color = COLORS.Stroke
			self:SetDisabled(self.Disabled)
		end

		input:SetDisabled(input.Disabled)
		if shouldPersist then
			registerPersistedControl(tab, input)
		end
		registerTabControl(tab, input)
		return input
	end

	-- ── Secure Input ─────────────────────────────────────────────────────────

	local BULLET = "*"

	function Window:_createSecureInput(tab, options)
		options = options or {}
		local shouldPersist = options.Persist ~= false

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local defaultVal = tostring(options.Default or options.Value or "")

		local sinput = {
			Type = "SecureInput",
			Name = options.Name or "SecureInput",
			Value = defaultVal,
			Placeholder = options.Placeholder or "",
			MaxLength = tonumber(options.MaxLength),
			Validator = type(options.Validator) == "function" and options.Validator or nil,
			Disabled = options.Disabled == true,
			Visible = options.Visible ~= false,
			Callback = options.Callback,
			ChangedSignal = Toolkit.Signal.new(),
			Tab = tab,
			Window = self,
		}
		if shouldPersist then
			assignPersistKey(tab, sinput, options, "SecureInput")
		end

		sinput.Holder = Veil.Instance:Create("Frame", {
			Name = sinput.Name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = type(options.Order) == "number" and options.Order or nextOrder(parentColumn),
			Size = UDim2.new(1, 0, 0, InputRowHeight),
			Visible = sinput.Visible,
			Parent = parentColumn,
		})

		local rightReserved = InputFieldWidth + 8

		sinput.LabelWrap = Veil.Instance:Create("Frame", {
			Name = "LabelWrap",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -rightReserved, 1, 0),
			ZIndex = 5,
			Parent = sinput.Holder,
		})

		sinput.TitleLabel = Veil.Instance:Create("TextLabel", {
			Name = "Title",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 18),
			Text = sinput.Name,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5,
			Parent = sinput.LabelWrap,
		})

		sinput.FieldFrame = Veil.Instance:Create("Frame", {
			Name = "FieldFrame",
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = COLORS.ToggleOffBackground,
			BorderSizePixel = 0,
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = _udim2Offset(InputFieldWidth, AccessoryButtonHeight),
			ZIndex = 5,
			Parent = sinput.Holder,
		})
		createCorner(sinput.FieldFrame, 6)
		sinput.FieldStroke = Veil.Instance:Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = COLORS.Stroke,
			Transparency = STROKE_TRANSPARENCY,
			Thickness = 1,
			Parent = sinput.FieldFrame,
		})
		createPadding(sinput.FieldFrame, 0, 6, 0, 6)

		-- TextBox shows only bullets; real value tracked separately
		local displayCount = utf8.len(defaultVal) or 0
		local maskText = string.rep(BULLET, displayCount)

		sinput.TextBox = Veil.Instance:Create("TextBox", {
			Name = "TextBox",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
			Font = Enum.Font.GothamMedium,
			PlaceholderColor3 = COLORS.Text,
			PlaceholderText = sinput.Placeholder,
			Size = _udim2Scale(1, 1),
			Text = maskText,
			TextColor3 = COLORS.Text,
			TextSize = 11,
			TextTransparency = 0.12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 6,
			Parent = sinput.FieldFrame,
		})
		self:_applySelectionHighlight(sinput.TextBox)

		-- Masking logic
		local isUpdating = false
		sinput.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if isUpdating then return end
			local txt = sinput.TextBox.Text
			local newCount = utf8.len(txt) or 0

			if newCount > displayCount then
				-- Extract newly typed chars (non-bullet suffix)
				local existingBytes = #string.rep(BULLET, displayCount)
				local addedRaw = txt:sub(existingBytes + 1)
				sinput.Value = sinput.Value .. addedRaw
				if sinput.MaxLength and #sinput.Value > sinput.MaxLength then
					sinput.Value = sinput.Value:sub(1, sinput.MaxLength)
				end
			elseif newCount < displayCount then
				-- Deletion: trim real value by same delta
				local delta = displayCount - newCount
				sinput.Value = sinput.Value:sub(1, math.max(0, #sinput.Value - delta))
			end

			displayCount = utf8.len(sinput.Value) or 0
			isUpdating = true
			sinput.TextBox.Text = string.rep(BULLET, displayCount)
			isUpdating = false
		end)

		local focusTI = TweenInfo.new(InputAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		sinput.TextBox.Focused:Connect(function()
			if sinput.Disabled then sinput.TextBox:ReleaseFocus() return end
			TweenService:Create(sinput.FieldStroke, focusTI, { Transparency = InputFocusStrokeTransparency }):Play()
		end)

		sinput.TextBox.FocusLost:Connect(function()
			TweenService:Create(sinput.FieldStroke, focusTI, { Transparency = STROKE_TRANSPARENCY }):Play()
			local val = sinput.Value
			if sinput.Validator then
				local ok, valid = pcall(sinput.Validator, val)
				if not ok or not valid then
					sinput.Value = ""
					displayCount = 0
					sinput.TextBox.Text = ""
					return
				end
			end
			if sinput.Callback then pcall(sinput.Callback, val) end
			sinput.ChangedSignal:Fire(val)
		end)

		function sinput:Set(value)
			self.Value = tostring(value or "")
			displayCount = utf8.len(self.Value) or 0
			self.TextBox.Text = string.rep(BULLET, displayCount)
		end

		function sinput:GetValue()
			return self.Value
		end

		function sinput:OnChanged(fn)
			return self.ChangedSignal:Connect(fn)
		end

		function sinput:SetDisabled(disabled)
			self.Disabled = disabled == true
			self.TextBox.TextEditable = not self.Disabled
			self.TitleLabel.TextTransparency = self.Disabled and 0.5 or 0
			self.TextBox.TextTransparency = self.Disabled and 0.5 or 0.12
			self.FieldFrame.BackgroundTransparency = self.Disabled and 0.4 or 0
		end

		function sinput:SetVisible(visible)
			self.Visible = visible ~= false
			self.Holder.Visible = self.Visible
		end

		function sinput:RefreshTheme()
			self.TitleLabel.TextColor3 = COLORS.Text
			self.FieldFrame.BackgroundColor3 = COLORS.ToggleOffBackground
			self.TextBox.TextColor3 = COLORS.Text
			self.TextBox.PlaceholderColor3 = COLORS.Text
			self.FieldStroke.Color = COLORS.Stroke
		end

		sinput:SetDisabled(sinput.Disabled)
		registerTabControl(tab, sinput)
		return sinput
	end

	-- ── Button ───────────────────────────────────────────────────────────────
	-- options: {Name, Style ("primary"|"secondary"), Callback()?}
	-- Primary uses accent fill; secondary uses muted background.

	function Window:_createButton(tab, options)
		options = options or {}

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local isPrimary = (options.Style or options.style or "primary") ~= "secondary"

		local btn = {
			Type = "Button",
			Name = options.Name or options.Text or "Button",
			Style = isPrimary and "primary" or "secondary",
			Disabled = options.Disabled == true,
			Visible = options.Visible ~= false,
			Callback = options.Callback,
			Tab = tab,
			Window = self,
		}

		btn.Holder = Veil.Instance:Create("Frame", {
			Name = btn.Name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = type(options.Order) == "number" and options.Order or nextOrder(parentColumn),
			Size = UDim2.new(1, 0, 0, ButtonRowHeight),
			Visible = btn.Visible,
			Parent = parentColumn,
		})

		local bgColor = isPrimary and COLORS.Accent or COLORS.ToggleOffBackground
		local bgTransp = isPrimary and 0 or 1
		local textColor = isPrimary and COLORS.Window or COLORS.Text
		local textTransp = isPrimary and 0.05 or 0.12

		btn.Inner = Veil.Instance:Create("TextButton", {
			Name = "Inner",
			AutoButtonColor = false,
			BackgroundColor3 = bgColor,
			BackgroundTransparency = bgTransp,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = _udim2Offset(0, ButtonInnerInsetY),
			Size = UDim2.new(1, 0, 1, -(ButtonInnerInsetY * 2)),
			Text = btn.Name,
			TextColor3 = textColor,
			TextSize = 13,
			TextTransparency = textTransp,
			ZIndex = 5,
			Parent = btn.Holder,
		})
		createCorner(btn.Inner, ButtonCornerRadius)

		-- Secondary gets accent stroke; primary gets subtle stroke for definition
		btn.Stroke = Veil.Instance:Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = isPrimary and COLORS.Accent or COLORS.Stroke,
			Transparency = isPrimary and 0.85 or STROKE_TRANSPARENCY,
			Thickness = 1,
			Parent = btn.Inner,
		})

		local animTI = TweenInfo.new(ButtonAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local hoverBgTransp = isPrimary and 0.12 or 0.72
		local pressBgTransp = isPrimary and 0.22 or 0.55

		btn.Inner.MouseEnter:Connect(function()
			if btn.Disabled then return end
			TweenService:Create(btn.Inner, animTI, {
				BackgroundTransparency = hoverBgTransp,
			}):Play()
		end)

		btn.Inner.MouseLeave:Connect(function()
			TweenService:Create(btn.Inner, animTI, {
				BackgroundTransparency = bgTransp,
			}):Play()
		end)

		btn.Inner.InputBegan:Connect(function(input)
			if btn.Disabled then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			TweenService:Create(btn.Inner, animTI, {
				BackgroundTransparency = pressBgTransp,
			}):Play()
		end)

		btn.Inner.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			TweenService:Create(btn.Inner, animTI, {
				BackgroundTransparency = hoverBgTransp,
			}):Play()
		end)

		btn.Inner.MouseButton1Click:Connect(function()
			if btn.Disabled then return end
			if btn.Callback then
				pcall(btn.Callback)
			end
		end)

		function btn:SetDisabled(disabled)
			self.Disabled = disabled == true
			self.Inner.Active = not self.Disabled
			self.Inner.TextTransparency = self.Disabled and 0.45 or textTransp
			self.Inner.BackgroundTransparency = self.Disabled and (isPrimary and 0.35 or 1) or bgTransp
		end

		function btn:SetVisible(visible)
			self.Visible = visible ~= false
			self.Holder.Visible = self.Visible
		end

		function btn:RefreshTheme()
			local primary = self.Style == "primary"
			self.Inner.BackgroundColor3 = primary and COLORS.Accent or COLORS.ToggleOffBackground
			self.Inner.TextColor3 = primary and COLORS.Window or COLORS.Text
			self.Stroke.Color = primary and COLORS.Accent or COLORS.Stroke
			self:SetDisabled(self.Disabled)
		end

		btn:SetDisabled(btn.Disabled)
		registerTabControl(tab, btn)
		return btn
	end

	-- ── Checkbox ─────────────────────────────────────────────────────────────
	-- Visually distinct from Toggle: square tick box, no switch. Separate control.
	-- options: {Name, Subtext?, Default (bool), Callback(bool)?}

	local CheckboxSize = 18
	local CheckboxCorner = 4
	local CheckboxAnimTime = 0.10

	function Window:_createCheckbox(tab, options)
		options = options or {}
		local shouldPersist = options.Persist ~= false

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local subtext = options.Subtext or options.Description
		local hasSubtext = type(subtext) == "string" and subtext ~= ""
		local rowHeight = hasSubtext and (ToggleRowHeight + 18) or ToggleRowHeight

		local cb = {
			Type = "Checkbox",
			Name = options.Name or "Checkbox",
			Checked = options.Default == true,
			Disabled = options.Disabled == true,
			Visible = options.Visible ~= false,
			Callback = options.Callback,
			ChangedSignal = Toolkit.Signal.new(),
			Tab = tab,
			Window = self,
		}
		if shouldPersist then
			assignPersistKey(tab, cb, options, "Checkbox")
		end

		cb.Holder = Veil.Instance:Create("Frame", {
			Name = cb.Name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = type(options.Order) == "number" and options.Order or nextOrder(parentColumn),
			Size = UDim2.new(1, 0, 0, rowHeight),
			Visible = cb.Visible,
			Parent = parentColumn,
		})

		cb.Button = Veil.Instance:Create("TextButton", {
			Name = "Hitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Text = "",
			ZIndex = 6,
			Parent = cb.Holder,
		})

		cb.TitleLabel = Veil.Instance:Create("TextLabel", {
			Name = "Title",
			AnchorPoint = hasSubtext and Vector2.new(0, 0) or Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = hasSubtext and _udim2Offset(0, 6) or UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, -(CheckboxSize + 10), 0, 18),
			Text = cb.Name,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			TextTransparency = 0,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 5,
			Parent = cb.Holder,
		})

		if hasSubtext then
			cb.SubtextLabel = Veil.Instance:Create("TextLabel", {
				Name = "Subtext",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = Enum.Font.Gotham,
				Position = _udim2Offset(0, 24),
				Size = UDim2.new(1, -(CheckboxSize + 10), 0, 16),
				Text = subtext,
				TextColor3 = COLORS.Text,
				TextSize = 12,
				TextTransparency = 0.35,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 5,
				Parent = cb.Holder,
			})
		end

		cb.Box = Veil.Instance:Create("Frame", {
			Name = "Box",
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = COLORS.Accent,
			BackgroundTransparency = cb.Checked and 0 or 1,
			BorderSizePixel = 0,
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = _udim2Offset(CheckboxSize, CheckboxSize),
			ZIndex = 5,
			Parent = cb.Holder,
		})
		createCorner(cb.Box, CheckboxCorner)

		cb.BoxStroke = Veil.Instance:Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = COLORS.Stroke,
			Transparency = cb.Checked and 0.72 or STROKE_TRANSPARENCY,
			Thickness = 1.5,
			Parent = cb.Box,
		})

		cb.Tick = Veil.Instance:Create("TextLabel", {
			Name = "Tick",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = _udim2Scale(0.5, 0.5),
			Size = _udim2Offset(CheckboxSize, CheckboxSize),
			Text = "✓",
			TextColor3 = COLORS.Window,
			TextSize = 13,
			TextTransparency = cb.Checked and 0 or 1,
			ZIndex = 6,
			Parent = cb.Box,
		})

		local animTI = TweenInfo.new(CheckboxAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local fastTI = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local function applyState(checked)
			TweenService:Create(cb.Box, animTI, { BackgroundTransparency = checked and 0 or 1 }):Play()
			TweenService:Create(cb.BoxStroke, animTI, { Transparency = checked and 0.72 or STROKE_TRANSPARENCY }):Play()
			TweenService:Create(cb.Tick, animTI, { TextTransparency = checked and 0 or 1 }):Play()
		end

		function cb:Set(value)
			self.Checked = value == true
			applyState(self.Checked)
		end

		function cb:GetValue()
			return self.Checked
		end

		function cb:OnChanged(fn)
			return self.ChangedSignal:Connect(fn)
		end

		function cb:SetVisible(visible)
			self.Holder.Visible = visible ~= false
		end

		function cb:RefreshTheme()
			self.TitleLabel.TextColor3 = COLORS.Text
			self.Box.BackgroundColor3 = COLORS.Accent
			self.BoxStroke.Color = COLORS.Stroke
			self.Tick.TextColor3 = COLORS.Window
			if self.SubtextLabel then self.SubtextLabel.TextColor3 = COLORS.Text end
		end

		cb.Button.MouseEnter:Connect(function()
			if cb.Disabled then return end
			TweenService:Create(cb.BoxStroke, fastTI, {
				Transparency = cb.Checked and 0.55 or 0.82,
			}):Play()
		end)

		cb.Button.MouseLeave:Connect(function()
			TweenService:Create(cb.BoxStroke, fastTI, {
				Transparency = cb.Checked and 0.72 or STROKE_TRANSPARENCY,
			}):Play()
		end)

		cb.Button.MouseButton1Down:Connect(function()
			if cb.Disabled then return end
			TweenService:Create(cb.Box, fastTI, {
				Size = _udim2Offset(CheckboxSize - 2, CheckboxSize - 2),
			}):Play()
		end)

		cb.Button.MouseButton1Up:Connect(function()
			TweenService:Create(cb.Box, fastTI, {
				Size = _udim2Offset(CheckboxSize, CheckboxSize),
			}):Play()
		end)

		cb.Button.MouseButton1Click:Connect(function()
			if cb.Disabled then return end
			cb.Checked = not cb.Checked
			applyState(cb.Checked)
			if cb.Callback then pcall(cb.Callback, cb.Checked) end
			cb.ChangedSignal:Fire(cb.Checked)
		end)

		registerTabControl(tab, cb)
		return cb
	end

	-- ── Radio Button ─────────────────────────────────────────────────────────

	-- ── Radio ────────────────────────────────────────────────────────────────
	-- Single-select option group. Only one item active at a time.
	-- options: {Name, Items (string[]), Default (string), Orientation ("Vertical"|"Horizontal"),
	--           Callback(value)?}
	-- Horizontal layout shares column width equally; long labels may clip.

	local RadioDotSize = 8
	local RadioCircleSize = 16
	local RadioItemHeight = 26
	local RadioAnimTime = 0.10

	function Window:_createRadio(tab, options)
		options = options or {}
		local shouldPersist = options.Persist ~= false

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local items = options.Items or {}
		local orientation = (options.Orientation or options.Direction or "Vertical"):lower()
		local isHorizontal = orientation == "horizontal"
		local defaultValue = options.Default or items[1]

		local radio = {
			Type = "Radio",
			Name = options.Name or "Radio",
			Value = defaultValue,
			Items = items,
			Orientation = orientation,
			Disabled = options.Disabled == true,
			Visible = options.Visible ~= false,
			Callback = options.Callback,
			ChangedSignal = Toolkit.Signal.new(),
			Tab = tab,
			Window = self,
			ItemButtons = {},
		}
		if shouldPersist then
			assignPersistKey(tab, radio, options, "Radio")
		end

		-- Label row at top
		local labelHeight = (options.Name and options.Name ~= "") and 22 or 0
		local itemCount = #items
		local bodyHeight
		if isHorizontal then
			bodyHeight = RadioItemHeight
		else
			bodyHeight = itemCount * RadioItemHeight
		end
		local totalHeight = labelHeight + bodyHeight

		radio.Holder = Veil.Instance:Create("Frame", {
			Name = radio.Name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = type(options.Order) == "number" and options.Order or nextOrder(parentColumn),
			Size = UDim2.new(1, 0, 0, totalHeight),
			Visible = radio.Visible,
			Parent = parentColumn,
		})

		if labelHeight > 0 then
			Veil.Instance:Create("TextLabel", {
				Name = "Label",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamMedium,
				Position = _udim2Offset(0, 0),
				Size = UDim2.new(1, 0, 0, labelHeight),
				Text = radio.Name,
				TextColor3 = COLORS.Text,
				TextSize = 14,
				TextTransparency = 0,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 5,
				Parent = radio.Holder,
			})
		end

		local body = Veil.Instance:Create("Frame", {
			Name = "Body",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = _udim2Offset(0, labelHeight),
			Size = UDim2.new(1, 0, 0, bodyHeight),
			Parent = radio.Holder,
		})

		if isHorizontal then
			Veil.Instance:Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, 12),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Parent = body,
			})
		else
			Veil.Instance:Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = body,
			})
		end

		local animTI = TweenInfo.new(RadioAnimTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local function applySelected(selectedValue)
			for _, item in ipairs(radio.ItemButtons) do
				local isSelected = item.Value == selectedValue
				TweenService:Create(item.Dot, animTI, {
					BackgroundTransparency = isSelected and 0 or 1,
				}):Play()
				TweenService:Create(item.Circle, animTI, {
					BackgroundTransparency = isSelected and 0.85 or 1,
				}):Play()
				TweenService:Create(item.CircleStroke, animTI, {
					Transparency = isSelected and 0.55 or STROKE_TRANSPARENCY,
					Color = isSelected and COLORS.Accent or COLORS.Stroke,
				}):Play()
				TweenService:Create(item.Label, animTI, {
					TextTransparency = isSelected and 0 or 0.3,
				}):Play()
			end
		end

		for i, itemValue in ipairs(items) do
			local itemStr = tostring(itemValue)

			local itemWidth
			if isHorizontal then
				local textW = math.ceil(measureText(itemStr, 13, Enum.Font.Gotham).X)
				itemWidth = RadioCircleSize + 6 + textW
			end

			local itemFrame = Veil.Instance:Create("Frame", {
				Name = "Item_" .. itemStr,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = i,
				Size = isHorizontal and UDim2.new(0, itemWidth, 1, 0) or UDim2.new(1, 0, 0, RadioItemHeight),
				Parent = body,
			})

			local circle = Veil.Instance:Create("Frame", {
				Name = "Circle",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = COLORS.Accent,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = _udim2Offset(RadioCircleSize, RadioCircleSize),
				ZIndex = 5,
				Parent = itemFrame,
			})
			createCorner(circle, RadioCircleSize / 2)

			local circleStroke = Veil.Instance:Create("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = COLORS.Stroke,
				Transparency = STROKE_TRANSPARENCY,
				Thickness = 1.5,
				Parent = circle,
			})

			local dot = Veil.Instance:Create("Frame", {
				Name = "Dot",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = COLORS.Accent,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = _udim2Scale(0.5, 0.5),
				Size = _udim2Offset(RadioDotSize, RadioDotSize),
				ZIndex = 6,
				Parent = circle,
			})
			createCorner(dot, RadioDotSize / 2)

			local lbl = Veil.Instance:Create("TextLabel", {
				Name = "Label",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = Enum.Font.Gotham,
				Position = _udim2Offset(RadioCircleSize + 6, 0),
				Size = UDim2.new(1, -(RadioCircleSize + 6), 1, 0),
				Text = itemStr,
				TextColor3 = COLORS.Text,
				TextSize = 13,
				TextTransparency = 0.3,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 5,
				Parent = itemFrame,
			})

			local btn = Veil.Instance:Create("TextButton", {
				Name = "Hitbox",
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Text = "",
				ZIndex = 7,
				Parent = itemFrame,
			})

			local itemEntry = { Value = itemValue, Dot = dot, Circle = circle, CircleStroke = circleStroke, Label = lbl }
			table.insert(radio.ItemButtons, itemEntry)

			btn.MouseButton1Click:Connect(function()
				if radio.Disabled then return end
				radio.Value = itemValue
				applySelected(itemValue)
				if radio.Callback then pcall(radio.Callback, itemValue) end
				radio.ChangedSignal:Fire(itemValue)
			end)
		end

		applySelected(radio.Value)

		function radio:Set(value)
			self.Value = value
			applySelected(value)
		end

		function radio:GetValue()
			return self.Value
		end

		function radio:OnChanged(fn)
			return self.ChangedSignal:Connect(fn)
		end

		function radio:SetVisible(visible)
			self.Holder.Visible = visible ~= false
		end

		function radio:RefreshTheme()
			for _, item in ipairs(self.ItemButtons) do
				item.Label.TextColor3 = COLORS.Text
				item.Dot.BackgroundColor3 = COLORS.Accent
				item.Circle.BackgroundColor3 = COLORS.Accent
			end
		end

		registerTabControl(tab, radio)
		return radio
	end

	-- ── Curve Editor ─────────────────────────────────────────────────────────

	local CurveCanvasHeight = 140
	local CurveSegments = 30
	local CurveLineWidth = 2
	local CurveHandleSize = 12
	local CurveHandleInner = 6

	local function bezierPoint(t, a, b, c, d)
		local mt = 1 - t
		return mt*mt*mt*a + 3*mt*mt*t*b + 3*mt*t*t*c + t*t*t*d
	end

	local function posLine(frame, x0, y0, x1, y1, h)
		local dx, dy = x1 - x0, y1 - y0
		local len = math.sqrt(dx*dx + dy*dy)
		frame.Position = _udim2Offset(x0, y0)
		frame.Size = _udim2Offset(math.max(1, len), h or CurveLineWidth)
		frame.Rotation = math.deg(math.atan2(dy, dx))
	end

	-- Bezier curve editor. Callback receives {CP1 (UDim2 0..1), CP2 (UDim2 0..1)}.
	-- Canvas is fixed size; curve always passes through (0,0) and (1,1).
	-- options: {Name, Callback(pts)?}
	function Window:_createCurveEditor(tab, options)
		options = options or {}

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local defaultCP1 = options.DefaultCP1 or Vector2.new(0.25, 0.75)
		local defaultCP2 = options.DefaultCP2 or Vector2.new(0.75, 0.25)

		local curve = {
			Type = "CurveEditor",
			Name = options.Name or "Curve",
			CP1 = defaultCP1,
			CP2 = defaultCP2,
			Callback = options.Callback,
			ChangedSignal = Toolkit.Signal.new(),
			Tab = tab,
			Window = self,
			Visible = options.Visible ~= false,
			Segments = {},
		}

		local labelHeight = 22
		local totalHeight = labelHeight + CurveCanvasHeight + 4

		curve.Holder = Veil.Instance:Create("Frame", {
			Name = curve.Name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = type(options.Order) == "number" and options.Order or nextOrder(parentColumn),
			Size = UDim2.new(1, 0, 0, totalHeight),
			Visible = curve.Visible,
			Parent = parentColumn,
		})

		Veil.Instance:Create("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = _udim2Offset(0, 0),
			Size = UDim2.new(1, 0, 0, labelHeight),
			Text = curve.Name,
			TextColor3 = COLORS.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5,
			Parent = curve.Holder,
		})

		curve.Canvas = Veil.Instance:Create("Frame", {
			Name = "Canvas",
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = _udim2Offset(0, labelHeight),
			Size = UDim2.new(1, 0, 0, CurveCanvasHeight),
			ZIndex = 5,
			Parent = curve.Holder,
		})
		createCorner(curve.Canvas, 8)
		createBorder(curve.Canvas)

		-- Subtle grid
		for i = 1, 3 do
			local f = i / 4
			for _, axis in ipairs({"H", "V"}) do
				Veil.Instance:Create("Frame", {
					BackgroundColor3 = COLORS.Stroke,
					BackgroundTransparency = 0.88,
					BorderSizePixel = 0,
					Position = axis == "H" and _udim2Scale(0, f) or _udim2Scale(f, 0),
					Size = axis == "H" and UDim2.new(1, 0, 0, 1) or UDim2.new(0, 1, 1, 0),
					ZIndex = 5,
					Parent = curve.Canvas,
				})
			end
		end

		-- Curve segments
		for i = 1, CurveSegments do
			local seg = Veil.Instance:Create("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = COLORS.Accent,
				BorderSizePixel = 0,
				Position = _udim2Offset(0, 0),
				Size = _udim2Offset(0, CurveLineWidth),
				ZIndex = 8,
				Parent = curve.Canvas,
			})
			table.insert(curve.Segments, seg)
		end

		-- Control lines
		local ctrlLine1 = Veil.Instance:Create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = COLORS.Stroke,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Size = _udim2Offset(0, 1),
			ZIndex = 7,
			Parent = curve.Canvas,
		})
		local ctrlLine2 = Veil.Instance:Create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = COLORS.Stroke,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Size = _udim2Offset(0, 1),
			ZIndex = 7,
			Parent = curve.Canvas,
		})

		-- Handles
		local function makeHandle()
			local outer = Veil.Instance:Create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = COLORS.Window,
				BorderSizePixel = 0,
				Position = _udim2Offset(0, 0),
				Size = _udim2Offset(CurveHandleSize, CurveHandleSize),
				ZIndex = 10,
				Parent = curve.Canvas,
			})
			createCorner(outer, CurveHandleSize / 2)
			Veil.Instance:Create("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = COLORS.Accent,
				Thickness = 1.5,
				Transparency = 0,
				Parent = outer,
			})
			local inner = Veil.Instance:Create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = COLORS.Accent,
				BorderSizePixel = 0,
				Position = _udim2Scale(0.5, 0.5),
				Size = _udim2Offset(CurveHandleInner, CurveHandleInner),
				ZIndex = 11,
				Parent = outer,
			})
			createCorner(inner, CurveHandleInner / 2)
			local btn = Veil.Instance:Create("TextButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = _udim2Scale(0.5, 0.5),
				Size = _udim2Offset(CurveHandleSize + 8, CurveHandleSize + 8),
				Text = "",
				ZIndex = 12,
				Parent = outer,
			})
			return outer, btn
		end

		local h1Outer, h1Btn = makeHandle()
		local h2Outer, h2Btn = makeHandle()

		local function toCanvasPx(nx, ny, cw, ch)
			return nx * cw, (1 - ny) * ch
		end

		local function redraw()
			local cw = curve.Canvas.AbsoluteSize.X
			local ch = curve.Canvas.AbsoluteSize.Y
			if cw <= 0 or ch <= 0 then return end
			local cp1, cp2 = curve.CP1, curve.CP2

			for i = 1, CurveSegments do
				local t0 = (i - 1) / CurveSegments
				local t1 = i / CurveSegments
				local bx0 = bezierPoint(t0, 0, cp1.X, cp2.X, 1)
				local by0 = bezierPoint(t0, 0, cp1.Y, cp2.Y, 1)
				local bx1 = bezierPoint(t1, 0, cp1.X, cp2.X, 1)
				local by1 = bezierPoint(t1, 0, cp1.Y, cp2.Y, 1)
				local x0, y0 = toCanvasPx(bx0, by0, cw, ch)
				local x1, y1 = toCanvasPx(bx1, by1, cw, ch)
				posLine(curve.Segments[i], x0, y0, x1, y1)
			end

			local cp1x, cp1y = toCanvasPx(cp1.X, cp1.Y, cw, ch)
			local cp2x, cp2y = toCanvasPx(cp2.X, cp2.Y, cw, ch)
			h1Outer.Position = _udim2Offset(cp1x, cp1y)
			h2Outer.Position = _udim2Offset(cp2x, cp2y)

			posLine(ctrlLine1, 0, ch, cp1x, cp1y, 1)
			posLine(ctrlLine2, cp2x, cp2y, cw, 0, 1)
		end

		curve._redraw = redraw

		local dragging = nil
		h1Btn.MouseButton1Down:Connect(function() dragging = 1 end)
		h2Btn.MouseButton1Down:Connect(function() dragging = 2 end)

		local dragConn = UserInputService.InputChanged:Connect(function(inp)
			if not dragging then return end
			if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			local absPos = curve.Canvas.AbsolutePosition
			local absSize = curve.Canvas.AbsoluteSize
			if absSize.X <= 0 then return end
			local mx = UserInputService:GetMouseLocation()
			local nx = math.clamp((mx.X - absPos.X) / absSize.X, 0, 1)
			local ny = math.clamp(1 - (mx.Y - absPos.Y) / absSize.Y, 0, 1)
			if dragging == 1 then curve.CP1 = Vector2.new(nx, ny)
			else curve.CP2 = Vector2.new(nx, ny) end
			redraw()
			local pts = { CP1 = curve.CP1, CP2 = curve.CP2 }
			if curve.Callback then pcall(curve.Callback, pts) end
			curve.ChangedSignal:Fire(pts)
		end)

		local endConn = UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = nil end
		end)

		curve.Canvas.AncestryChanged:Connect(function()
			if not curve.Canvas.Parent then
				dragConn:Disconnect()
				endConn:Disconnect()
			end
		end)

		task.spawn(function()
			task.wait(0.05)
			redraw()
		end)

		function curve:GetPoints()
			return { CP1 = self.CP1, CP2 = self.CP2 }
		end

		function curve:GetSampled(count)
			count = count or 16
			local out = {}
			for i = 0, count do
				local t = i / count
				out[i + 1] = bezierPoint(t, 0, self.CP1.Y, self.CP2.Y, 1)
			end
			return out
		end

		function curve:OnChanged(fn)
			return self.ChangedSignal:Connect(fn)
		end

		function curve:SetVisible(visible)
			self.Holder.Visible = visible ~= false
		end

		function curve:RefreshTheme()
			self.Canvas.BackgroundColor3 = COLORS.Window
			for _, seg in ipairs(self.Segments) do
				seg.BackgroundColor3 = COLORS.Accent
			end
			self._redraw()
		end

		registerTabControl(tab, curve)
		return curve
	end

	-- ── Normal Slider ────────────────────────────────────────────────────────
	-- Continuous or stepped drag slider with live value display.
	-- options: {Name, Subtext?, Min, Max, Default, Step, Callback(value)?}
	-- Step=0 allows free float; Step>0 snaps to increments.

	function Window:_createSlider(tab, options)
		options = options or {}
		local shouldPersist = options.Persist ~= false

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local subtext = options.Subtext or options.Description or options.Desc
		local hasSubtext = type(subtext) == "string" and subtext ~= ""
		local min = tonumber(options.Min) or 0
		local max = tonumber(options.Max) or 100
		if min > max then min, max = max, min end
		local step = tonumber(options.Step)
		local default = snapToStep(tonumber(options.Default) or min, min, max, step)
		local rowHeight = hasSubtext and SliderRowWithSubtextHeight or SliderRowHeight
		local thumbRadius = SliderThumbDiameter / 2
		local trackZoneTop = hasSubtext and 38 or 22
		local trackInsetY = (SliderThumbDiameter - SliderTrackHeight) / 2

		local slider = {
			Type = "Slider",
			Name = options.Name or options.Text or "Slider",
			Min = min,
			Max = max,
			Step = step,
			Value = default,
			TargetFraction = (max > min) and (default - min) / (max - min) or 0,
			VisualFraction = (max > min) and (default - min) / (max - min) or 0,
			IsDragging = false,
			Disabled = options.Disabled == true,
			Callback = options.Callback,
			ChangedSignal = Toolkit.Signal.new(),
			Tab = tab,
			Window = self,
		}
		if shouldPersist then
			assignPersistKey(tab, slider, options, "Slider")
		end

		slider.Holder = createTextRow(parentColumn, slider.Name, rowHeight)
		if type(options.Order) == "number" then slider.Holder.LayoutOrder = options.Order end

		slider.TitleLabel, slider.ValueLabel, slider.SubtextLabel =
			buildSliderTextRows(slider.Holder, slider.Name, subtext, hasSubtext)

		slider.TrackZone, slider.TrackBg, slider.TrackFill, slider.Thumb, slider.Hitbox =
			buildSliderTrack(slider.Holder, trackZoneTop, thumbRadius, trackInsetY)

		local setThumbState = makeThumbAnimator(slider.Thumb)

		function slider:_refreshTrack()
			local f = self.VisualFraction
			local trackW = self.TrackBg.AbsoluteSize.X
			self.TrackFill.Size = UDim2.new(f, 0, 1, 0)
			self.Thumb.Position = _udim2Offset(thumbRadius + f * trackW, SliderThumbDiameter / 2)

			local disabled = self.Disabled
			self.TitleLabel.TextTransparency = disabled and 0.5 or 0
			if self.SubtextLabel then
				self.SubtextLabel.TextTransparency = disabled and 0.6 or 0.35
			end
			self.ValueLabel.TextTransparency = disabled and 0.6 or (self.IsDragging and 0.05 or 0.25)
			local blockT = disabled and 0.45 or 0
			self.TrackFill.BackgroundTransparency = blockT
			self.Thumb.BackgroundTransparency = blockT
			self.TrackBg.BackgroundTransparency = disabled and 0.4 or 0
		end

		function slider:_updateFromInput(inputPosition)
			local trackPos = self.TrackBg.AbsolutePosition
			local trackW = self.TrackBg.AbsoluteSize.X
			if trackW <= 0 then return end
			local f = math.clamp((inputPosition.X - trackPos.X) / trackW, 0, 1)
			local raw = self.Min + f * (self.Max - self.Min)
			local snapped = snapToStep(raw, self.Min, self.Max, self.Step)
			local snappedF = (snapped - self.Min) / math.max(1e-9, self.Max - self.Min)
			self.TargetFraction = snappedF
			if snapped ~= self.Value then
				self.Value = snapped
				self.ValueLabel.Text = formatSliderValue(snapped, self.Step)
				safeCallback(self.Callback, snapped)
				self.ChangedSignal:Fire(snapped)
			end
		end

		function slider:Set(value, setOptions)
			setOptions = setOptions or {}
			local snapped = snapToStep(tonumber(value) or self.Min, self.Min, self.Max, self.Step)
			local changed = snapped ~= self.Value
			self.Value = snapped
			self.TargetFraction = (snapped - self.Min) / math.max(1e-9, self.Max - self.Min)
			self.ValueLabel.Text = formatSliderValue(snapped, self.Step)
			if setOptions.Instant then
				self.VisualFraction = self.TargetFraction
				self:_refreshTrack()
			end
			if changed and not setOptions.Silent then
				safeCallback(self.Callback, snapped)
				self.ChangedSignal:Fire(snapped)
			end
			return snapped
		end
		slider.SetValue = slider.Set

		function slider:GetValue()
			return self.Value
		end

		function slider:SetDisabled(disabled)
			self.Disabled = disabled == true
			self.Hitbox.Active = not self.Disabled
			self:_refreshTrack()
		end

		function slider:OnChanged(callback)
			local conn = self.ChangedSignal:Connect(callback)
			safeCallback(callback, self.Value)
			return conn
		end

		function slider:RefreshTheme()
			self.TitleLabel.TextColor3 = COLORS.Text
			if self.SubtextLabel then
				self.SubtextLabel.TextColor3 = COLORS.Text
			end
			self.ValueLabel.TextColor3 = COLORS.Text
			self.TrackBg.BackgroundColor3 = COLORS.ToggleOffBackground
			self.TrackFill.BackgroundColor3 = COLORS.Accent
			self.Thumb.BackgroundColor3 = COLORS.Accent
			self:_refreshTrack()
		end

		local dragging = false

		slider.Hitbox.MouseEnter:Connect(function()
			if slider.Disabled then return end
			slider.IsHovered = true
			if not slider.IsDragging then
				setThumbState("hover")
			end
		end)

		slider.Hitbox.MouseLeave:Connect(function()
			slider.IsHovered = false
			if not slider.IsDragging then
				setThumbState("normal")
			end
		end)

		slider.Hitbox.InputBegan:Connect(function(input)
			if slider.Disabled then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			dragging = true
			slider.IsDragging = true
			setThumbState("drag")
			slider:_updateFromInput(input.Position)
		end)

		registerCleanup(self, UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			slider:_updateFromInput(input.Position)
		end))

		registerCleanup(self, UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				slider.IsDragging = false
				setThumbState(slider.IsHovered and "hover" or "normal")
			end
		end))

		registerCleanup(self, RunService.Heartbeat:Connect(function(dt)
			if math.abs(slider.TargetFraction - slider.VisualFraction) < 0.0005 then
				if slider.VisualFraction ~= slider.TargetFraction then
					slider.VisualFraction = slider.TargetFraction
					slider:_refreshTrack()
				end
				return
			end
			local baseAlpha = slider.IsDragging and SliderDragLerpAlpha or SliderLerpAlpha
			local alpha = 1 - (1 - baseAlpha) ^ (dt * 60)
			slider.VisualFraction = slider.VisualFraction + (slider.TargetFraction - slider.VisualFraction) * alpha
			slider:_refreshTrack()
		end))

		slider:Set(default, { Instant = true, Silent = true })
		task.defer(function()
			slider.VisualFraction = slider.TargetFraction
			slider:_refreshTrack()
		end)

		if shouldPersist then
			registerPersistedControl(tab, slider)
		end
		registerTabControl(tab, slider)
		return slider
	end

	-- ── Notched Slider ───────────────────────────────────────────────────────
	-- Discrete slider showing notch marks for each step. Step must divide evenly
	-- into (Max-Min) or the last notch will not align to Max.
	-- options: {Name, Subtext?, Min, Max, Default, Step, Callback(value)?}

	function Window:_createNotchedSlider(tab, options)
		options = options or {}
		local shouldPersist = options.Persist ~= false

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local subtext = options.Subtext or options.Description or options.Desc
		local hasSubtext = type(subtext) == "string" and subtext ~= ""
		local min = tonumber(options.Min) or 0
		local max = tonumber(options.Max) or 10
		if min > max then min, max = max, min end
		local step = math.max(1e-9, tonumber(options.Step) or 1)
		local default = snapToStep(tonumber(options.Default) or min, min, max, step)
		local rowHeight = hasSubtext and SliderNotchedRowWithSubtextHeight or SliderNotchedRowHeight
		local thumbRadius = SliderThumbDiameter / 2
		local trackZoneTop = hasSubtext and 38 or 22
		local trackInsetY = (SliderThumbDiameter - SliderTrackHeight) / 2

		local slider = {
			Type = "NotchedSlider",
			Name = options.Name or options.Text or "Slider",
			Min = min,
			Max = max,
			Step = step,
			Value = default,
			TargetFraction = (max > min) and (default - min) / (max - min) or 0,
			VisualFraction = (max > min) and (default - min) / (max - min) or 0,
			IsDragging = false,
			Disabled = options.Disabled == true,
			Callback = options.Callback,
			ChangedSignal = Toolkit.Signal.new(),
			Tab = tab,
			Window = self,
		}
		if shouldPersist then
			assignPersistKey(tab, slider, options, "NotchedSlider")
		end

		slider.Holder = createTextRow(parentColumn, slider.Name, rowHeight)
		if type(options.Order) == "number" then slider.Holder.LayoutOrder = options.Order end

		slider.TitleLabel, slider.ValueLabel, slider.SubtextLabel =
			buildSliderTextRows(slider.Holder, slider.Name, subtext, hasSubtext)

		slider.TrackZone, slider.TrackBg, slider.TrackFill, slider.Thumb, slider.Hitbox =
			buildSliderTrack(slider.Holder, trackZoneTop, thumbRadius, trackInsetY)

		local setThumbState = makeThumbAnimator(slider.Thumb)

		-- Build notch marks below the track zone
		local notchCount = math.floor((max - min) / step + 0.5) + 1
		local notchZone = Veil.Instance:Create("Frame", {
			Name = "NotchZone",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = _udim2Offset(thumbRadius, trackZoneTop + SliderThumbDiameter + 2),
			Size = UDim2.new(1, -SliderThumbDiameter, 0, 4),
			ZIndex = 5,
			Parent = slider.Holder,
		})

		for i = 0, notchCount - 1 do
			local f = (max > min) and (i * step) / (max - min) or 0
			f = math.clamp(f, 0, 1)
			Veil.Instance:Create("Frame", {
				Name = "Notch" .. i,
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = COLORS.Text,
				BackgroundTransparency = 0.72,
				BorderSizePixel = 0,
				Position = UDim2.new(f, 0, 0, 0),
				Size = _udim2Offset(2, 4),
				ZIndex = 5,
				Parent = notchZone,
			})
		end

		function slider:_refreshTrack()
			local f = self.VisualFraction
			local trackW = self.TrackBg.AbsoluteSize.X
			self.TrackFill.Size = UDim2.new(f, 0, 1, 0)
			self.Thumb.Position = _udim2Offset(thumbRadius + f * trackW, SliderThumbDiameter / 2)

			local disabled = self.Disabled
			self.TitleLabel.TextTransparency = disabled and 0.5 or 0
			if self.SubtextLabel then
				self.SubtextLabel.TextTransparency = disabled and 0.6 or 0.35
			end
			self.ValueLabel.TextTransparency = disabled and 0.6 or (self.IsDragging and 0.05 or 0.25)
			local blockT = disabled and 0.45 or 0
			self.TrackFill.BackgroundTransparency = blockT
			self.Thumb.BackgroundTransparency = blockT
			self.TrackBg.BackgroundTransparency = disabled and 0.4 or 0
		end

		function slider:_updateFromInput(inputPosition)
			local trackPos = self.TrackBg.AbsolutePosition
			local trackW = self.TrackBg.AbsoluteSize.X
			if trackW <= 0 then return end
			local f = math.clamp((inputPosition.X - trackPos.X) / trackW, 0, 1)
			local raw = self.Min + f * (self.Max - self.Min)
			local snapped = snapToStep(raw, self.Min, self.Max, self.Step)
			local snappedF = (snapped - self.Min) / math.max(1e-9, self.Max - self.Min)
			self.TargetFraction = snappedF
			if snapped ~= self.Value then
				self.Value = snapped
				self.ValueLabel.Text = formatSliderValue(snapped, self.Step)
				safeCallback(self.Callback, snapped)
				self.ChangedSignal:Fire(snapped)
			end
		end

		function slider:Set(value, setOptions)
			setOptions = setOptions or {}
			local snapped = snapToStep(tonumber(value) or self.Min, self.Min, self.Max, self.Step)
			local changed = snapped ~= self.Value
			self.Value = snapped
			self.TargetFraction = (snapped - self.Min) / math.max(1e-9, self.Max - self.Min)
			self.ValueLabel.Text = formatSliderValue(snapped, self.Step)
			if setOptions.Instant then
				self.VisualFraction = self.TargetFraction
				self:_refreshTrack()
			end
			if changed and not setOptions.Silent then
				safeCallback(self.Callback, snapped)
				self.ChangedSignal:Fire(snapped)
			end
			return snapped
		end
		slider.SetValue = slider.Set

		function slider:GetValue() return self.Value end

		function slider:SetDisabled(disabled)
			self.Disabled = disabled == true
			self.Hitbox.Active = not self.Disabled
			self:_refreshTrack()
		end

		function slider:OnChanged(callback)
			local conn = self.ChangedSignal:Connect(callback)
			safeCallback(callback, self.Value)
			return conn
		end

		function slider:RefreshTheme()
			self.TitleLabel.TextColor3 = COLORS.Text
			if self.SubtextLabel then
				self.SubtextLabel.TextColor3 = COLORS.Text
			end
			self.ValueLabel.TextColor3 = COLORS.Text
			self.TrackBg.BackgroundColor3 = COLORS.ToggleOffBackground
			self.TrackFill.BackgroundColor3 = COLORS.Accent
			self.Thumb.BackgroundColor3 = COLORS.Accent
			self:_refreshTrack()
		end

		local dragging = false

		slider.Hitbox.MouseEnter:Connect(function()
			if slider.Disabled then return end
			slider.IsHovered = true
			if not slider.IsDragging then
				setThumbState("hover")
			end
		end)

		slider.Hitbox.MouseLeave:Connect(function()
			slider.IsHovered = false
			if not slider.IsDragging then
				setThumbState("normal")
			end
		end)

		slider.Hitbox.InputBegan:Connect(function(input)
			if slider.Disabled then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			dragging = true
			slider.IsDragging = true
			setThumbState("drag")
			slider:_updateFromInput(input.Position)
		end)

		registerCleanup(self, UserInputService.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
			slider:_updateFromInput(input.Position)
		end))

		registerCleanup(self, UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				slider.IsDragging = false
				setThumbState(slider.IsHovered and "hover" or "normal")
			end
		end))

		registerCleanup(self, RunService.Heartbeat:Connect(function(dt)
			if math.abs(slider.TargetFraction - slider.VisualFraction) < 0.0005 then
				if slider.VisualFraction ~= slider.TargetFraction then
					slider.VisualFraction = slider.TargetFraction
					slider:_refreshTrack()
				end
				return
			end
			local baseAlpha = slider.IsDragging and SliderDragLerpAlpha or SliderLerpAlpha
			local alpha = 1 - (1 - baseAlpha) ^ (dt * 60)
			slider.VisualFraction = slider.VisualFraction + (slider.TargetFraction - slider.VisualFraction) * alpha
			slider:_refreshTrack()
		end))

		slider:Set(default, { Instant = true, Silent = true })
		task.defer(function()
			slider.VisualFraction = slider.TargetFraction
			slider:_refreshTrack()
		end)

		if shouldPersist then
			registerPersistedControl(tab, slider)
		end
		registerTabControl(tab, slider)
		return slider
	end

	-- ── Range Slider ─────────────────────────────────────────────────────────
	-- Two-thumb slider for min/max range selection. Thumbs cannot cross each other.
	-- options: {Name, Subtext?, Min, Max, DefaultMin, DefaultMax, Step,
	--           Callback(minVal, maxVal)?}

	function Window:_createRangeSlider(tab, options)
		options = options or {}
		local shouldPersist = options.Persist ~= false

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local subtext = options.Subtext or options.Description or options.Desc
		local hasSubtext = type(subtext) == "string" and subtext ~= ""
		local min = tonumber(options.Min) or 0
		local max = tonumber(options.Max) or 100
		if min > max then min, max = max, min end
		local step = tonumber(options.Step)
		local defaultLow = snapToStep(tonumber(options.DefaultMin) or tonumber(options.Default) or min, min, max, step)
		local defaultHigh = snapToStep(tonumber(options.DefaultMax) or max, min, max, step)
		if defaultLow > defaultHigh then defaultLow, defaultHigh = defaultHigh, defaultLow end
		local rowHeight = hasSubtext and SliderRowWithSubtextHeight or SliderRowHeight
		local thumbRadius = SliderThumbDiameter / 2
		local trackZoneTop = hasSubtext and 38 or 22
		local trackInsetY = (SliderThumbDiameter - SliderTrackHeight) / 2

		local function toFrac(v) return (v - min) / math.max(1e-9, max - min) end

		local slider = {
			Type = "RangeSlider",
			Name = options.Name or options.Text or "Range",
			Min = min,
			Max = max,
			Step = step,
			LowValue = defaultLow,
			HighValue = defaultHigh,
			LowTarget = toFrac(defaultLow),
			HighTarget = toFrac(defaultHigh),
			LowVisual = toFrac(defaultLow),
			HighVisual = toFrac(defaultHigh),
			ActiveThumb = nil,
			Disabled = options.Disabled == true,
			Callback = options.Callback,
			ChangedSignal = Toolkit.Signal.new(),
			Tab = tab,
			Window = self,
		}
		if shouldPersist then
			assignPersistKey(tab, slider, options, "RangeSlider")
		end

		slider.Holder = createTextRow(parentColumn, slider.Name, rowHeight)
		if type(options.Order) == "number" then slider.Holder.LayoutOrder = options.Order end

		slider.TitleLabel, slider.ValueLabel, slider.SubtextLabel =
			buildSliderTextRows(slider.Holder, slider.Name, subtext, hasSubtext)

		-- Track zone (no single thumb from buildSliderTrack - build manually for two thumbs)
		slider.TrackZone = Veil.Instance:Create("Frame", {
			Name = "TrackZone",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = _udim2Offset(0, trackZoneTop),
			Size = UDim2.new(1, 0, 0, SliderThumbDiameter),
			ZIndex = 5,
			Parent = slider.Holder,
		})

		slider.TrackBg = Veil.Instance:Create("Frame", {
			Name = "TrackBg",
			BackgroundColor3 = COLORS.ToggleOffBackground,
			BorderSizePixel = 0,
			Position = _udim2Offset(thumbRadius, trackInsetY),
			Size = UDim2.new(1, -SliderThumbDiameter, 0, SliderTrackHeight),
			ZIndex = 5,
			Parent = slider.TrackZone,
		})
		createCorner(slider.TrackBg, SliderTrackHeight / 2)

		slider.RangeFill = Veil.Instance:Create("Frame", {
			Name = "RangeFill",
			BackgroundColor3 = COLORS.Accent,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 6,
			Parent = slider.TrackBg,
		})

		slider.LowThumb = Veil.Instance:Create("Frame", {
			Name = "LowThumb",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = COLORS.Accent,
			BorderSizePixel = 0,
			Position = _udim2Offset(thumbRadius, SliderThumbDiameter / 2),
			Size = _udim2Offset(SliderThumbDiameter, SliderThumbDiameter),
			ZIndex = 7,
			Parent = slider.TrackZone,
		})
		createCorner(slider.LowThumb, thumbRadius)

		slider.HighThumb = Veil.Instance:Create("Frame", {
			Name = "HighThumb",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = COLORS.Accent,
			BorderSizePixel = 0,
			Position = _udim2Offset(thumbRadius, SliderThumbDiameter / 2),
			Size = _udim2Offset(SliderThumbDiameter, SliderThumbDiameter),
			ZIndex = 7,
			Parent = slider.TrackZone,
		})
		createCorner(slider.HighThumb, thumbRadius)

		slider.LowHitbox = Veil.Instance:Create("TextButton", {
			Name = "LowHitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = _udim2Offset(SliderThumbDiameter + 8, SliderThumbDiameter),
			Text = "",
			ZIndex = 8,
			Parent = slider.TrackZone,
		})

		slider.HighHitbox = Veil.Instance:Create("TextButton", {
			Name = "HighHitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = _udim2Offset(SliderThumbDiameter + 8, SliderThumbDiameter),
			Text = "",
			ZIndex = 8,
			Parent = slider.TrackZone,
		})

		-- Full track hitbox for clicking the track itself
		slider.TrackHitbox = Veil.Instance:Create("TextButton", {
			Name = "TrackHitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = _udim2Scale(1, 1),
			Text = "",
			ZIndex = 6,
			Parent = slider.TrackZone,
		})

		local function formatRange(lo, hi)
			local fmtLo = formatSliderValue(lo, step)
			local fmtHi = formatSliderValue(hi, step)
			return fmtLo .. " - " .. fmtHi
		end

		function slider:_refreshTrack()
			local lo = self.LowVisual
			local hi = self.HighVisual
			local trackW = self.TrackBg.AbsoluteSize.X

			local loCenterX = thumbRadius + lo * trackW
			local hiCenterX = thumbRadius + hi * trackW

			self.LowThumb.Position = _udim2Offset(loCenterX, SliderThumbDiameter / 2)
			self.HighThumb.Position = _udim2Offset(hiCenterX, SliderThumbDiameter / 2)

			-- Thumb hitbox positions (centered on thumbs, with extra grab zone)
			self.LowHitbox.Position = _udim2Offset(loCenterX - (SliderThumbDiameter / 2 + 4), 0)
			self.HighHitbox.Position = _udim2Offset(hiCenterX - (SliderThumbDiameter / 2 + 4), 0)

			-- Range fill: from lo to hi fraction within TrackBg
			self.RangeFill.Position = UDim2.new(lo, 0, 0, 0)
			self.RangeFill.Size = UDim2.new(hi - lo, 0, 1, 0)

			local disabled = self.Disabled
			self.TitleLabel.TextTransparency = disabled and 0.5 or 0
			if self.SubtextLabel then
				self.SubtextLabel.TextTransparency = disabled and 0.6 or 0.35
			end
			self.ValueLabel.TextTransparency = disabled and 0.6 or 0.25
			local blockT = disabled and 0.45 or 0
			self.RangeFill.BackgroundTransparency = blockT
			self.LowThumb.BackgroundTransparency = blockT
			self.HighThumb.BackgroundTransparency = blockT
			self.TrackBg.BackgroundTransparency = disabled and 0.4 or 0
		end

		local function updateValue(which, inputPosition)
			local trackPos = slider.TrackBg.AbsolutePosition
			local trackW = slider.TrackBg.AbsoluteSize.X
			if trackW <= 0 then return end
			local f = math.clamp((inputPosition.X - trackPos.X) / trackW, 0, 1)
			local raw = slider.Min + f * (slider.Max - slider.Min)
			local snapped = snapToStep(raw, slider.Min, slider.Max, slider.Step)
			local snappedF = (snapped - slider.Min) / math.max(1e-9, slider.Max - slider.Min)

			if which == "low" then
				snapped = math.min(snapped, slider.HighValue)
				snappedF = math.min(snappedF, slider.HighTarget)
				if snapped ~= slider.LowValue then
					slider.LowValue = snapped
					slider.LowTarget = snappedF
					slider.ValueLabel.Text = formatRange(slider.LowValue, slider.HighValue)
					safeCallback(slider.Callback, slider.LowValue, slider.HighValue)
					slider.ChangedSignal:Fire(slider.LowValue, slider.HighValue)
				end
			else
				snapped = math.max(snapped, slider.LowValue)
				snappedF = math.max(snappedF, slider.LowTarget)
				if snapped ~= slider.HighValue then
					slider.HighValue = snapped
					slider.HighTarget = snappedF
					slider.ValueLabel.Text = formatRange(slider.LowValue, slider.HighValue)
					safeCallback(slider.Callback, slider.LowValue, slider.HighValue)
					slider.ChangedSignal:Fire(slider.LowValue, slider.HighValue)
				end
			end
		end

		function slider:Set(lowValue, highValue, setOptions)
			setOptions = setOptions or {}
			local lo = snapToStep(tonumber(lowValue) or self.Min, self.Min, self.Max, self.Step)
			local hi = snapToStep(tonumber(highValue) or self.Max, self.Min, self.Max, self.Step)
			if lo > hi then lo, hi = hi, lo end
			local changedLo = lo ~= self.LowValue
			local changedHi = hi ~= self.HighValue
			self.LowValue = lo
			self.HighValue = hi
			self.LowTarget = toFrac(lo)
			self.HighTarget = toFrac(hi)
			self.ValueLabel.Text = formatRange(lo, hi)
			if setOptions.Instant then
				self.LowVisual = self.LowTarget
				self.HighVisual = self.HighTarget
				self:_refreshTrack()
			end
			if (changedLo or changedHi) and not setOptions.Silent then
				safeCallback(self.Callback, lo, hi)
				self.ChangedSignal:Fire(lo, hi)
			end
		end
		slider.SetValue = slider.Set

		function slider:GetValue()
			return self.LowValue, self.HighValue
		end

		function slider:SetDisabled(disabled)
			self.Disabled = disabled == true
			local active = not self.Disabled
			self.LowHitbox.Active = active
			self.HighHitbox.Active = active
			self.TrackHitbox.Active = active
			self:_refreshTrack()
		end

		function slider:OnChanged(callback)
			local conn = self.ChangedSignal:Connect(callback)
			safeCallback(callback, self.LowValue, self.HighValue)
			return conn
		end

		function slider:RefreshTheme()
			self.TitleLabel.TextColor3 = COLORS.Text
			if self.SubtextLabel then
				self.SubtextLabel.TextColor3 = COLORS.Text
			end
			self.ValueLabel.TextColor3 = COLORS.Text
			self.TrackBg.BackgroundColor3 = COLORS.ToggleOffBackground
			self.RangeFill.BackgroundColor3 = COLORS.Accent
			self.LowThumb.BackgroundColor3 = COLORS.Accent
			self.HighThumb.BackgroundColor3 = COLORS.Accent
			self:_refreshTrack()
		end

		local activeThumb = nil

		local function pickThumb(inputX)
			local trackPos = slider.TrackBg.AbsolutePosition
			local trackW = slider.TrackBg.AbsoluteSize.X
			if trackW <= 0 then return "low" end
			local f = math.clamp((inputX - trackPos.X) / trackW, 0, 1)
			local dLo = math.abs(f - slider.LowTarget)
			local dHi = math.abs(f - slider.HighTarget)
			return dLo <= dHi and "low" or "high"
		end

		slider.LowHitbox.InputBegan:Connect(function(input)
			if slider.Disabled then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			activeThumb = "low"
			slider.ActiveThumb = "low"
			updateValue("low", input.Position)
		end)

		slider.HighHitbox.InputBegan:Connect(function(input)
			if slider.Disabled then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			activeThumb = "high"
			slider.ActiveThumb = "high"
			updateValue("high", input.Position)
		end)

		slider.TrackHitbox.InputBegan:Connect(function(input)
			if slider.Disabled then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			activeThumb = pickThumb(input.Position.X)
			slider.ActiveThumb = activeThumb
			updateValue(activeThumb, input.Position)
		end)

		registerCleanup(self, UserInputService.InputChanged:Connect(function(input)
			if not activeThumb then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
			updateValue(activeThumb, input.Position)
		end))

		registerCleanup(self, UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				activeThumb = nil
				slider.ActiveThumb = nil
			end
		end))

		registerCleanup(self, RunService.Heartbeat:Connect(function(dt)
			local isDragging = slider.ActiveThumb ~= nil
			local baseAlpha = isDragging and SliderDragLerpAlpha or SliderLerpAlpha
			local alpha = 1 - (1 - baseAlpha) ^ (dt * 60)
			local dirtyLo = math.abs(slider.LowTarget - slider.LowVisual) >= 0.0005
			local dirtyHi = math.abs(slider.HighTarget - slider.HighVisual) >= 0.0005

			if dirtyLo then
				slider.LowVisual = slider.LowVisual + (slider.LowTarget - slider.LowVisual) * alpha
			else
				slider.LowVisual = slider.LowTarget
			end
			if dirtyHi then
				slider.HighVisual = slider.HighVisual + (slider.HighTarget - slider.HighVisual) * alpha
			else
				slider.HighVisual = slider.HighTarget
			end
			if dirtyLo or dirtyHi then
				slider:_refreshTrack()
			end
		end))

		slider:Set(defaultLow, defaultHigh, { Instant = true, Silent = true })
		task.defer(function()
			slider.LowVisual = slider.LowTarget
			slider.HighVisual = slider.HighTarget
			slider:_refreshTrack()
		end)

		if shouldPersist then
			registerPersistedControl(tab, slider)
		end
		registerTabControl(tab, slider)
		return slider
	end

	function Window:_getPersistenceRegistry()
		local registry = {}

		for _, tab in ipairs(self.Tabs) do
			for _, control in ipairs(tab.PersistControls or {}) do
				if type(control.PersistKey) == "string" and control.PersistKey ~= "" then
					registry[control.PersistKey] = control
				end
			end

			for _, accessory in ipairs(tab.AccessoryControls or {}) do
				if type(accessory.PersistKey) == "string" and accessory.PersistKey ~= "" then
					registry[accessory.PersistKey] = accessory
				end
			end
		end

		return registry
	end

	function Window:SerializeConfig()
		local payload = {
			Version = 1,
			Controls = {},
			Window = {
				BlurEnabled = self.BackgroundBlurEnabled == true,
				IconPack = IconProvider.ActivePack,
			},
		}

		for key, control in pairs(self:_getPersistenceRegistry()) do
			if control.Type == "Toggle" then
				payload.Controls[key] = control.Value == true
			elseif control.Type == "Dropdown" then
				payload.Controls[key] = control.MultiSelect and control:GetValue() or control.Value
			elseif control.Type == "Input" then
				payload.Controls[key] = control:GetValue()
			elseif control.Type == "Slider" or control.Type == "NotchedSlider" then
				payload.Controls[key] = control:GetValue()
			elseif control.Type == "RangeSlider" then
				local low, high = control:GetValue()
				payload.Controls[key] = {
					Low = low,
					High = high,
				}
			elseif control.Type == "Keypicker" then
				payload.Controls[key] = {
					Key = control:GetKey(),
					Mode = control:GetMode(),
				}
			elseif control.Type == "Colorpicker" then
				payload.Controls[key] = {
					Color = colorToHex(control:GetColor()),
					Alpha = control.Alpha or 0,
				}
			end
		end

		return payload
	end

	function Window:ApplyConfig(payload)
		if type(payload) ~= "table" then
			return false
		end

		local controls = payload.Controls
		local registry = self:_getPersistenceRegistry()
		if type(controls) == "table" then
			for key, value in pairs(controls) do
				local control = registry[key]
				if control then
					if control.Type == "Toggle" then
						control:Set(value, { Silent = true })
					elseif control.Type == "Dropdown" then
						if control.MultiSelect then
							control:SetValues(type(value) == "table" and value or {}, { Silent = true })
						else
							control:Set(value, { Silent = true })
						end
					elseif control.Type == "Input" then
						control:Set(value, { Silent = true })
					elseif control.Type == "Slider" or control.Type == "NotchedSlider" then
						control:Set(value, { Silent = true, Instant = true })
					elseif control.Type == "RangeSlider" and type(value) == "table" then
						control:Set(value.Low, value.High, { Silent = true, Instant = true })
					elseif control.Type == "Keypicker" and type(value) == "table" then
						if value.Key ~= nil then
							control:SetKey(value.Key, { Silent = true })
						end
						if value.Mode ~= nil then
							control:SetMode(value.Mode, { Silent = true })
						end
					elseif control.Type == "Colorpicker" then
						local colorValue = type(value) == "table" and value.Color or value
						local resolved = colorFromValue(colorValue, control:GetColor())
						control:SetColor(resolved, { Silent = true })
					end
				end
			end
		end

		if type(payload.Window) == "table" then
			if payload.Window.BlurEnabled ~= nil then
				self:SetBackgroundBlurEnabled(payload.Window.BlurEnabled == true)
			end
			if type(payload.Window.IconPack) == "string" then
				Axis:SetIconPack(payload.Window.IconPack)
			end
		end

		return true
	end

	function Window:SerializeTheme()
		local theme = {}
		for _, key in ipairs(THEME_KEYS) do
			theme[key] = colorToHex(COLORS[key])
		end
		return theme
	end

	function Window:RefreshTheme()
		if self.WindowBackground then
			self.WindowBackground.BackgroundColor3 = COLORS.Window
		end
		if self.TabContentHost then
			self.TabContentHost.BackgroundColor3 = COLORS.Window
		end
		if self.TitlebarText then
			self.TitlebarText.TextColor3 = COLORS.Text
		end
		if self.StatusChip then
			self.StatusChip.BackgroundColor3 = COLORS.Accent
			self.StatusChip.TextColor3 = COLORS.Accent
		end
		if self.SelectionHighlight then
			self.SelectionHighlight.BackgroundColor3 = COLORS.Accent
		end
		if self.TitlebarShell then
			for _, descendant in ipairs(self.Titlebar:GetDescendants()) do
				if descendant:IsA("Frame") and (descendant.Name == "Shell" or descendant.Name == "BottomFill") then
					descendant.BackgroundColor3 = COLORS.Titlebar
				elseif descendant:IsA("Frame") and descendant.Name == "AxisStrokeLine" then
					descendant.BackgroundColor3 = COLORS.Stroke
				end
			end
		end
		if self.SidebarShell then
			for _, descendant in ipairs(self.Sidebar:GetDescendants()) do
				if descendant:IsA("Frame") and (descendant.Name == "Shell" or descendant.Name == "TopFill" or descendant.Name == "RightFill") then
					descendant.BackgroundColor3 = COLORS.Sidebar
				elseif descendant:IsA("Frame") and descendant.Name == "AxisStrokeLine" then
					descendant.BackgroundColor3 = COLORS.Stroke
				end
			end
		end
		if self.SettingsDivider then
			self.SettingsDivider.BackgroundColor3 = COLORS.Stroke
		end
		if self.Cursor then
			for _, descendant in ipairs(self.Cursor:GetChildren()) do
				if descendant.Name == "VerticalStroke" or descendant.Name == "HorizontalStroke" then
					descendant.BackgroundColor3 = COLORS.Window
				elseif descendant.Name == "VerticalFill" or descendant.Name == "HorizontalFill" then
					descendant.BackgroundColor3 = COLORS.Accent
				end
			end
		end

		for _, tab in ipairs(self.Tabs) do
			if tab.Highlight then
				tab.Highlight.BackgroundColor3 = COLORS.Accent
			end
			if tab.ColumnLayout then
				for _, line in ipairs(tab.ColumnLayout.Lines or {}) do
					line.BackgroundColor3 = COLORS.Stroke
				end
				for _, handle in ipairs(tab.ColumnLayout.Handles or {}) do
					handle.BackgroundColor3 = COLORS.Stroke
				end
				for _, guide in ipairs(tab.ColumnLayout.Guides or {}) do
					local dash = guide:FindFirstChild("DashList")
					if dash then
						for _, child in ipairs(dash:GetChildren()) do
							if child:IsA("Frame") then
								child.BackgroundColor3 = COLORS.Accent
							end
						end
					end
				end
			end
			for _, control in ipairs(tab.Controls or {}) do
				if type(control.RefreshTheme) == "function" then
					control:RefreshTheme()
				end
			end
			for _, accessory in ipairs(tab.AccessoryControls or {}) do
				if type(accessory.RefreshTheme) == "function" then
					accessory:RefreshTheme()
				end
			end
			setTabButtonVisual(tab, tab == self.SelectedTab, COLORS)
		end

		if self.Tooltip then
			self.Tooltip.BackgroundColor3 = COLORS.Window
		end
		if self.TooltipLabel then
			self.TooltipLabel.TextColor3 = COLORS.Text
		end
		if Axis.PickerSurface then
			for _, descendant in ipairs(Axis.PickerSurface:GetDescendants()) do
				if descendant:IsA("UIStroke") then
					descendant.Color = COLORS.Stroke
				end
			end
		end
	end

	function Window:ApplyTheme(theme)
		if type(theme) ~= "table" then
			return false
		end

		for _, key in ipairs(THEME_KEYS) do
			if theme[key] ~= nil then
				COLORS[key] = colorFromValue(theme[key], COLORS[key])
			end
		end

		self:RefreshTheme()
		return true
	end

	Axis.Surface = Veil.GUI:CreateRoot("Axis")

	function Axis:_ensurePickerSurface()
		if self.PickerSurface then
			return self.PickerSurface
		end

		self.PickerSurface = Veil.Instance:Create("Frame", {
			Name = "AxisPickers",
			Active = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			Size = _udim2Scale(1, 1),
			ZIndex = 240,
			Parent = self.Surface,
		})

		self.PickerBackdrop = Veil.Instance:Create("TextButton", {
			Name = "AxisPickerBackdrop",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = _udim2Scale(1, 1),
			Text = "",
			Visible = false,
			ZIndex = 242,
			Parent = self.PickerSurface,
		})

		self.PickerBackdrop.MouseButton1Click:Connect(function()
			if self.ActivePickerClose then
				self.ActivePickerClose()
				self.ActivePickerClose = nil
			elseif self.ActivePickerPopup then
				self.ActivePickerPopup.Visible = false
				self.ActivePickerPopup:SetAttribute("AxisOpen", false)
				self.ActivePickerPopup = nil
			end
			self.PickerBackdrop.Visible = false
		end)

		return self.PickerSurface
	end

	function Axis:_closeActivePicker(exceptPopup)
		local popup = self.ActivePickerPopup
		if not popup or popup == exceptPopup then
			return
		end

		if self.ActivePickerClose then
			self.ActivePickerClose()
			self.ActivePickerClose = nil
		else
			popup.Visible = false
			popup:SetAttribute("AxisOpen", false)
		end
		
		self.ActivePickerPopup = nil

		if self.PickerBackdrop then
			self.PickerBackdrop.Visible = false
		end
	end

	function Axis:_ensureOverlaySurfaces()
		if self.ToastSurface and self.NotificationSurface then
			return
		end

		self.ToastSurface = self.ToastSurface or Veil.GUI:CreateSurface("AxisToasts")
		self.NotificationSurface = self.NotificationSurface or Veil.GUI:CreateSurface("AxisNotifications")
		self.ToastHosts = self.ToastHosts or {}
		self.NotificationHosts = self.NotificationHosts or {}
		self.ActiveOverlays = self.ActiveOverlays or {}
		self._overlayOrder = self._overlayOrder or 0

		for location, config in pairs(TOAST_LOCATIONS) do
			if not self.ToastHosts[location] then
				self.ToastHosts[location] = createOverlayHost(self.ToastSurface, "Toast" .. location, config)
			end
		end

		for location, config in pairs(NOTIFICATION_LOCATIONS) do
			if not self.NotificationHosts[location] then
				self.NotificationHosts[location] = createOverlayHost(self.NotificationSurface, "Notification" .. location, config)
			end
		end
	end

	function Axis:_destroyOverlayEntry(entry)
		if not entry or entry.Destroyed then
			return
		end

		entry.Destroyed = true
		animateOverlayCard(entry.Card, entry.ExitOffset, false, function()
			local wrapper = entry.Wrapper
			if not wrapper then return end

			-- Freeze AutomaticSize so we can tween height to 0
			local currentHeight = wrapper.AbsoluteSize.Y
			wrapper.AutomaticSize = Enum.AutomaticSize.None
			wrapper.Size = _udim2Offset(wrapper.AbsoluteSize.X, currentHeight)

			local collapseTI = TweenInfo.new(OverlayCollapseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = TweenService:Create(wrapper, collapseTI, {
				Size = _udim2Offset(wrapper.AbsoluteSize.X, 0),
			})
			tween:Play()
			tween.Completed:Connect(function()
				if entry.Wrapper then
					Veil.Instance:SecureDestroy(entry.Wrapper)
					entry.Wrapper = nil
					entry.Card = nil
				end
			end)
		end)
	end

	function Axis:_createOverlay(kind, options)
		options = options or {}
		self:_ensureOverlaySurfaces()

		local locations = kind == "Toast" and TOAST_LOCATIONS or NOTIFICATION_LOCATIONS
		local defaultLocation = kind == "Toast" and "TopCenter" or "TopRight"
		local locationKey = locations[options.Location] and options.Location or defaultLocation
		local config = locations[locationKey]
		local host = kind == "Toast" and self.ToastHosts[locationKey] or self.NotificationHosts[locationKey]
		local accentColor = options.AccentColor or COLORS.Accent

		-- Enforce max stack: dismiss oldest in this location if at cap
		local stackCount = 0
		local oldest = nil
		for _, e in pairs(self.ActiveOverlays) do
			if e.Wrapper and e.Wrapper.Parent == host and not e.Destroyed then
				stackCount = stackCount + 1
				if oldest == nil or e.Id < oldest.Id then
					oldest = e
				end
			end
		end
		if stackCount >= OverlayMaxStack and oldest then
			self.ActiveOverlays[oldest.Id] = nil
			self:_destroyOverlayEntry(oldest)
		end

		self._overlayOrder = self._overlayOrder + 1

		local wrapper, card = createOverlayCard(host, config.Width, self._overlayOrder, 210)
		card.Position = _udim2Offset(config.EnterOffset.X, config.EnterOffset.Y)

		if kind == "Toast" then
			buildToastCard(card, accentColor, options, 210)
		else
			buildNotificationCard(card, accentColor, config.Edge, options, 210)
		end

		setOverlayVisualState(card, false)

		local entry = {
			Card = card,
			Wrapper = wrapper,
			ExitOffset = config.ExitOffset,
			Destroyed = false,
			Id = Toolkit.Util.GenerateId(kind),
		}

		self.ActiveOverlays[entry.Id] = entry

		task.spawn(function()
			RunService.Heartbeat:Wait()
			if entry.Destroyed or not entry.Card then
				return
			end

			animateOverlayCard(entry.Card, _v2zero, true)
		end)

		task.delay(math.max(0.5, tonumber(options.Duration) or (kind == "Toast" and 3.5 or 5)), function()
			if self.ActiveOverlays then
				self.ActiveOverlays[entry.Id] = nil
			end
			self:_destroyOverlayEntry(entry)
		end)

		return entry
	end

	-- Creates the main Axis window and sets it as Axis.ActiveWindow.
	-- options: {Width?, Height?, Title?, Position?}
	function Axis:CreateWindow(options)
		local window = Window.new(options)
		table.insert(self.Windows, window)
		self.ActiveWindow = window
		return window
	end

	-- Creates a tab on the active window. options.PinnedBottom=true docks it at
	-- sidebar bottom. options.ShowCharacterViewer=true enables character viewer.
	function Axis:CreateTab(options)
		assert(self.ActiveWindow, "[Axis] Create a window before creating tabs")
		return self.ActiveWindow:CreateTab(options)
	end

	-- Shows a short ephemeral toast at TopCenter/BottomCenter; auto-dismisses.
	-- options: {Title, Message, Duration?, Location?}
	function Axis:Toast(options)
		return self:_createOverlay("Toast", options)
	end

	-- Shows a corner notification; auto-dismisses after Duration seconds.
	-- options: {Title, Message, Duration?, Location?}
	function Axis:Notify(options)
		return self:_createOverlay("Notification", options)
	end

	-- Destroys all windows, overlays, pickers, and surfaces. Also stops anti-AFK
	-- and closes the search modal. Call at script exit or Axis restart.
	function Axis:DestroyAll()
		if self.ActiveOverlays then
			for id, entry in pairs(self.ActiveOverlays) do
				self.ActiveOverlays[id] = nil
				if entry and not entry.Destroyed and entry.Wrapper then
					Veil.Instance:SecureDestroy(entry.Wrapper)
				end
			end
		end

		for _, window in ipairs(self.Windows) do
			window:Destroy()
		end

		table.clear(self.Windows)

		if self.ToastSurface then
			Veil.Instance:SecureDestroy(self.ToastSurface)
			self.ToastSurface = nil
			self.ToastHosts = nil
		end

		if self.NotificationSurface then
			Veil.Instance:SecureDestroy(self.NotificationSurface)
			self.NotificationSurface = nil
			self.NotificationHosts = nil
		end

		if self.PickerSurface then
			Veil.Instance:SecureDestroy(self.PickerSurface)
			self.PickerSurface = nil
			self.PickerBackdrop = nil
		end

		self.ActiveOverlays = nil
		self._overlayOrder = nil
		self.ActivePickerPopup = nil

		self:SetAntiAFK(false)
		self:CloseSearch()
		if self._searchSurface then
			Veil.Instance:SecureDestroy(self._searchSurface)
			self._searchSurface = nil
		end
	end

	-- ── Crosshair ────────────────────────────────────────────────────────────
	-- Adds a "Crosshair" tab to sourceWindow with live-preview controls.
	-- options: {Color?, Width?, Length?, Gap?, Opacity?, DotEnabled?, Animation?}
	-- Animation: "None" | "Spin" | "Pulse"

	function Axis:CreateCrosshair(sourceWindow, options)
		options = options or {}

		-- Default state
		local state = {
			Enabled = true,
			Color = options.Color or Color3.fromRGB(255, 255, 255),
			Width = options.Width or 2,
			Length = options.Length or 8,
			Gap = options.Gap or 3,
			Opacity = options.Opacity or 1,
			DotEnabled = options.DotEnabled == true,
			DotSize = options.DotSize or 4,
			OutlineEnabled = options.OutlineEnabled == true,
			OutlineColor = options.OutlineColor or Color3.new(0, 0, 0),
			Animation = options.Animation or "None",
		}

		-- Crosshair surface (full-screen, above game UI but below Axis)
		local surface = Veil.Instance:Create("Frame", {
			Name = "CrosshairSurface",
			Active = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Interactable = false,
			Size = _udim2Scale(1, 1),
			ZIndex = 150,
			Parent = self.Surface,
		})

		-- Inner container: centered, can be rotated for spin
		local container = Veil.Instance:Create("Frame", {
			Name = "CrosshairContainer",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Interactable = false,
			Position = _udim2Scale(0.5, 0.5),
			Size = _udim2Offset(100, 100),
			ZIndex = 151,
			Parent = surface,
		})

		-- Create arm frame
		local function makeArm(name, zIndex)
			return Veil.Instance:Create("Frame", {
				Name = name,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = state.Color,
				BackgroundTransparency = 1 - state.Opacity,
				BorderSizePixel = 0,
				Interactable = false,
				ZIndex = zIndex,
				Parent = container,
			})
		end

		-- Outline arms (drawn first, behind)
		local oTop    = makeArm("OTop",    151)
		local oBottom = makeArm("OBottom", 151)
		local oLeft   = makeArm("OLeft",   151)
		local oRight  = makeArm("ORight",  151)

		-- Main arms
		local aTop    = makeArm("Top",    152)
		local aBottom = makeArm("Bottom", 152)
		local aLeft   = makeArm("Left",   152)
		local aRight  = makeArm("Right",  152)

		-- Center dot
		local dot = Veil.Instance:Create("Frame", {
			Name = "Dot",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = state.Color,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Interactable = false,
			Position = _udim2Scale(0.5, 0.5),
			Size = _udim2Offset(state.DotSize, state.DotSize),
			ZIndex = 153,
			Parent = container,
		})
		createCorner(dot, state.DotSize / 2)

		local function applyGeometry()
			local w = state.Width
			local l = state.Length
			local g = state.Gap
			local cx, cy = 50, 50  -- center of 100x100 container

			-- Top arm
			aTop.Position = _udim2Offset(cx, cy - g - l / 2)
			aTop.Size = _udim2Offset(w, l)
			-- Bottom arm
			aBottom.Position = _udim2Offset(cx, cy + g + l / 2)
			aBottom.Size = _udim2Offset(w, l)
			-- Left arm
			aLeft.Position = _udim2Offset(cx - g - l / 2, cy)
			aLeft.Size = _udim2Offset(l, w)
			-- Right arm
			aRight.Position = _udim2Offset(cx + g + l / 2, cy)
			aRight.Size = _udim2Offset(l, w)

			local outlineAlpha = state.OutlineEnabled and 0.72 or 1
			local ow = w + 2
			oTop.Position    = _udim2Offset(cx, cy - g - l / 2)
			oTop.Size        = _udim2Offset(ow, l + 2)
			oBottom.Position = _udim2Offset(cx, cy + g + l / 2)
			oBottom.Size     = _udim2Offset(ow, l + 2)
			oLeft.Position   = _udim2Offset(cx - g - l / 2, cy)
			oLeft.Size       = _udim2Offset(l + 2, ow)
			oRight.Position  = _udim2Offset(cx + g + l / 2, cy)
			oRight.Size      = _udim2Offset(l + 2, ow)

			for _, arm in ipairs({oTop, oBottom, oLeft, oRight}) do
				arm.BackgroundColor3 = state.OutlineColor
				arm.BackgroundTransparency = outlineAlpha
			end

			dot.Size = _udim2Offset(state.DotSize, state.DotSize)
			dot.BackgroundTransparency = state.DotEnabled and (1 - state.Opacity) or 1
		end

		local function applyColor()
			for _, arm in ipairs({aTop, aBottom, aLeft, aRight, dot}) do
				arm.BackgroundColor3 = state.Color
				arm.BackgroundTransparency = 1 - state.Opacity
			end
			dot.BackgroundTransparency = state.DotEnabled and (1 - state.Opacity) or 1
		end

		applyGeometry()
		applyColor()
		surface.Visible = state.Enabled

		-- Animation
		local animAngle = 0
		local pulseSize = 1
		local pulseDelta = 1
		local animConn = RunService.Heartbeat:Connect(function(dt)
			if not state.Enabled or not surface.Visible then return end
			if state.Animation == "Spin" then
				animAngle = animAngle + 30 * dt
				container.Rotation = animAngle
			elseif state.Animation == "Pulse" then
				pulseSize = pulseSize + pulseDelta * 20 * dt
				if pulseSize >= 110 then pulseDelta = -1
				elseif pulseSize <= 90 then pulseDelta = 1 end
				container.Size = _udim2Offset(pulseSize, pulseSize)
			else
				container.Rotation = 0
				container.Size = _udim2Offset(100, 100)
			end
		end)

		surface.AncestryChanged:Connect(function()
			if not surface.Parent then animConn:Disconnect() end
		end)

		-- Build config tab in source window
		if sourceWindow then
			local crosshairTab = sourceWindow:CreateTab({
				Name = "Crosshair",
				Icon = "crosshair",
			})
			local col = crosshairTab.Columns.leftColumn

			col:CreateToggle({
				Name = "Show Crosshair",
				Default = state.Enabled,
				Callback = function(v)
					state.Enabled = v
					surface.Visible = v
				end,
			})

			col:SectionHeader("Appearance")

			local colorLabel = col:Label({ Name = "Color" })
			colorLabel:AddColorpicker({
				Default = state.Color,
				Callback = function(c)
					state.Color = c
					applyColor()
				end,
			})

			col:Slider({
				Name = "Thickness",
				Min = 1, Max = 8, Default = state.Width, Step = 1,
				Callback = function(v) state.Width = v; applyGeometry() end,
			})

			col:Slider({
				Name = "Length",
				Min = 2, Max = 30, Default = state.Length, Step = 1,
				Callback = function(v) state.Length = v; applyGeometry() end,
			})

			col:Slider({
				Name = "Gap",
				Min = 0, Max = 20, Default = state.Gap, Step = 1,
				Callback = function(v) state.Gap = v; applyGeometry() end,
			})

			col:Slider({
				Name = "Opacity",
				Min = 0, Max = 1, Default = state.Opacity, Step = 0.05,
				Callback = function(v) state.Opacity = v; applyColor() end,
			})

			col:SectionHeader("Center Dot")

			col:CreateToggle({
				Name = "Dot",
				Default = state.DotEnabled,
				Callback = function(v)
					state.DotEnabled = v
					dot.BackgroundTransparency = v and (1 - state.Opacity) or 1
				end,
			})

			col:Slider({
				Name = "Dot Size",
				Min = 1, Max = 12, Default = state.DotSize, Step = 1,
				Callback = function(v)
					state.DotSize = v
					dot.Size = _udim2Offset(v, v)
					createCorner(dot, v / 2)
				end,
			})

			col:SectionHeader("Outline")

			col:CreateToggle({
				Name = "Outline",
				Default = state.OutlineEnabled,
				Callback = function(v)
					state.OutlineEnabled = v
					applyGeometry()
				end,
			})

			col:SectionHeader("Animation")

			col:Dropdown({
				Name = "Style",
				Items = { "None", "Spin", "Pulse" },
				Default = state.Animation,
				Callback = function(v)
					state.Animation = v
					if v == "None" then
						container.Rotation = 0
						container.Size = _udim2Offset(100, 100)
					end
				end,
			})
		end

		local ch = {}
		function ch:Show() state.Enabled = true; surface.Visible = true end
		function ch:Hide() state.Enabled = false; surface.Visible = false end
		function ch:Configure(cfg)
			for k, v in pairs(cfg) do state[k] = v end
			applyGeometry(); applyColor()
		end
		function ch:Destroy()
			animConn:Disconnect()
			Veil.Instance:SecureDestroy(surface)
		end
		return ch
	end

	-- ── Character Viewer ─────────────────────────────────────────────────────
	-- ViewportFrame panel showing a spinning R6 rig with local player appearance.
	-- Visibility is controlled per-tab via tab.ShowCharacterViewer=true.
	-- Panel repositions each Heartbeat to track the window's AbsolutePosition.

	local CharViewerWidth = 180
	local CharViewerGap = 12
	local CharViewerSpinSpeed = 25  -- degrees per second; adjust for visual feel

	function Axis:CreateCharacterViewer(sourceWindow, options)
		options = options or {}

		local Players = Veil.Services:Get("Players")
		local lp = Players and Players.LocalPlayer
		if not lp then return nil end

		-- Panel frame on the surface, positioned right of the window
		local panel = Veil.Instance:Create("Frame", {
			Name = "CharacterViewer",
			BackgroundColor3 = COLORS.Window,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = _udim2Offset(CharViewerWidth, 300), -- height updated per frame
			Visible = false,
			ZIndex = 5,
			Parent = self.Surface,
		})
		createCorner(panel, 14)
		createBorder(panel)

		-- ViewportFrame fills the panel
		local vf = Veil.Instance:Create("ViewportFrame", {
			Name = "Viewport",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LightColor = Color3.fromRGB(220, 220, 235),
			LightDirection = Vector3.new(-1, -2, -1),
			Position = _udim2Offset(0, 0),
			Size = _udim2Scale(1, 1),
			ZIndex = 6,
			Parent = panel,
		})

		-- WorldModel inside viewport
		local worldModel = Veil.Instance:Create("WorldModel", {
			Parent = vf,
		})

		-- Camera
		local cam = Instance.new("Camera")
		cam.CameraType = Enum.CameraType.Scriptable
		cam.FieldOfView = 50
		cam.Parent = vf
		vf.CurrentCamera = cam

		-- Build character in background
		local charModel = nil
		local spinAngle = 0

		task.spawn(function()
			local char = lp.Character
			local humanoid = char and char:FindFirstChildOfClass("Humanoid")
			if not humanoid then return end

			local ok, desc = pcall(function()
				return humanoid:GetAppliedDescription()
			end)
			if not ok or not desc then return end

			local ok2, model = pcall(function()
				return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
			end)
			if not ok2 or not model then return end

			-- Remove scripts
			for _, s in ipairs(model:GetDescendants()) do
				if s:IsA("Script") or s:IsA("LocalScript") or s:IsA("ModuleScript") then
					s:Destroy()
				end
			end

			charModel = model
			charModel.Parent = worldModel

			-- Position character at world origin, standing
			local root = charModel:FindFirstChild("HumanoidRootPart")
			if root then
				charModel:PivotTo(CFrame.new(0, 0, 0))
			end

			-- Position camera to frame the character
			local headPos = charModel:FindFirstChild("Head")
			local eyeY = headPos and (headPos.Position.Y + 0.3) or 1.8
			cam.CFrame = CFrame.new(0, eyeY - 0.3, 3.2) * CFrame.Angles(0, math.rad(180), 0)
		end)

		-- Heartbeat: spin + reposition panel
		local heartConn = RunService.Heartbeat:Connect(function(dt)
			if not panel.Parent then return end
			if not panel.Visible then return end

			-- Reposition panel next to window
			if sourceWindow and sourceWindow.Frame then
				local winPos = sourceWindow.Frame.AbsolutePosition
				local winSize = sourceWindow.Frame.AbsoluteSize
				local screenH = sourceWindow.Frame.Parent and sourceWindow.Frame.Parent.AbsoluteSize.Y or 600
				local panelH = winSize.Y
				panel.Position = _udim2Offset(winPos.X + winSize.X + CharViewerGap, winPos.Y)
				panel.Size = _udim2Offset(CharViewerWidth, panelH)
			end

			-- Spin character
			if charModel and charModel.Parent then
				spinAngle = (spinAngle + CharViewerSpinSpeed * dt) % 360
				charModel:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(spinAngle), 0))
			end
		end)

		panel.AncestryChanged:Connect(function()
			if not panel.Parent then heartConn:Disconnect() end
		end)

		-- Tab selection hook: show when ShowCharacterViewer tab is selected
		sourceWindow:OnTabSelected(function(selectedTab)
			local shouldShow = selectedTab and selectedTab.ShowCharacterViewer == true
			panel.Visible = shouldShow == true
		end)

		-- Initial visibility check
		local selTab = sourceWindow.SelectedTab
		panel.Visible = selTab and selTab.ShowCharacterViewer == true

		local viewer = {
			Panel = panel,
			Viewport = vf,
		}

		function viewer:Show() panel.Visible = true end
		function viewer:Hide() panel.Visible = false end
		function viewer:Destroy()
			heartConn:Disconnect()
			Veil.Instance:SecureDestroy(panel)
			if charModel then charModel:Destroy() end
			if cam then cam:Destroy() end
		end

		return viewer
	end

	-- ── Keybind Overlay ──────────────────────────────────────────────────────
	-- Standalone reference panel independent of the main window visibility.
	-- options: {Title?, Keybind (KeyCode), Position ("BottomRight"|etc), Binds[]}
	-- Binds entry: {Name, Key (string label), Active (bool for highlight)}

	function Axis:CreateKeybindOverlay(options)
		options = options or {}
		local binds = options.Binds or options.Keys or {}
		local toggleKey = options.Keybind or options.ToggleKey or Enum.KeyCode.RightAlt
		local positionMode = options.Position or "BottomRight"
		local visible = options.Visible ~= false

		local panelWidth = 220
		local rowHeight = 28
		local padH = 10
		local padV = 8
		local panelHeight = padV * 2 + #binds * rowHeight

		local panel = Veil.Instance:Create("Frame", {
			Name = "KeybindOverlay",
			AnchorPoint = positionMode == "BottomRight" and Vector2.new(1, 1)
				or positionMode == "BottomLeft" and Vector2.new(0, 1)
				or positionMode == "TopRight" and Vector2.new(1, 0)
				or Vector2.new(0, 0),
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			Position = positionMode == "BottomRight" and UDim2.new(1, -16, 1, -16)
				or positionMode == "BottomLeft" and UDim2.new(0, 16, 1, -16)
				or positionMode == "TopRight" and UDim2.new(1, -16, 0, 16)
				or UDim2.new(0, 16, 0, 16),
			Size = _udim2Offset(panelWidth, panelHeight),
			Visible = visible,
			ZIndex = 190,
			Parent = self.Surface,
		})
		createCorner(panel, 10)
		createBorder(panel)

		-- Header
		Veil.Instance:Create("TextLabel", {
			AnchorPoint = Vector2.new(0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = _udim2Offset(padH, padV - 2),
			Size = UDim2.new(1, -padH * 2, 0, 16),
			Text = options.Title or "Keybinds",
			TextColor3 = COLORS.Text,
			TextSize = 11,
			TextTransparency = 0.5,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 191,
			Parent = panel,
		})

		for i, bind in ipairs(binds) do
			local y = padV + (i - 1) * rowHeight + 14

			Veil.Instance:Create("TextLabel", {
				AnchorPoint = Vector2.new(0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamMedium,
				Position = _udim2Offset(padH, y),
				Size = UDim2.new(0.65, -padH, 0, rowHeight),
				Text = bind.Name or bind.Action or "Action",
				TextColor3 = bind.Active ~= false and COLORS.Accent or COLORS.Text,
				TextSize = 12,
				TextTransparency = bind.Active == false and 0.5 or 0,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 191,
				Parent = panel,
			})

			local keyBadge = Veil.Instance:Create("TextLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = COLORS.Stroke,
				BackgroundTransparency = 0.88,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamMedium,
				Position = UDim2.new(1, -padH, 0, y + rowHeight / 2),
				Size = _udim2Offset(0, 18),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = bind.Key or bind.KeyCode or "?",
				TextColor3 = COLORS.Text,
				TextSize = 10,
				TextTransparency = bind.Active == false and 0.5 or 0.2,
				TextXAlignment = Enum.TextXAlignment.Center,
				ZIndex = 191,
				Parent = panel,
			})
			createCorner(keyBadge, 4)
			createPadding(keyBadge, 0, 5, 0, 5)
		end

		-- Toggle keybind
		local overlay = {
			Panel = panel,
			Visible = visible,
			ToggleKey = toggleKey,
		}

		local conn = UserInputService.InputBegan:Connect(function(inp, processed)
			if processed then return end
			if inp.KeyCode == toggleKey then
				overlay.Visible = not overlay.Visible
				panel.Visible = overlay.Visible
			end
		end)

		panel.AncestryChanged:Connect(function()
			if not panel.Parent then conn:Disconnect() end
		end)

		function overlay:Show() self.Visible = true; panel.Visible = true end
		function overlay:Hide() self.Visible = false; panel.Visible = false end
		function overlay:Toggle() if self.Visible then self:Hide() else self:Show() end end
		function overlay:Destroy()
			conn:Disconnect()
			Veil.Instance:SecureDestroy(panel)
		end

		return overlay
	end

	-- ── Search Modal ─────────────────────────────────────────────────────────

	local SearchModalWidth = 480
	local SearchModalMaxHeight = 320
	local SearchInputHeight = 38
	local SearchItemHeight = 32

	function Axis:CloseSearch()
		if self._searchClosing then return end
		if self._searchModal then
			self._searchClosing = true
			local m = self._searchModal
			local bd = self._searchBackdrop
			local ti = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(m, ti, { Size = _udim2Offset(SearchModalWidth - 8, SearchInputHeight - 4), BackgroundTransparency = 0.5 }):Play()
			if bd then TweenService:Create(bd, ti, { BackgroundTransparency = 1 }):Play() end
			local tw = TweenService:Create(m, ti, {})
			tw:Play()
			task.delay(0.12, function()
				Veil.Instance:SecureDestroy(m)
				self._searchModal = nil
				self._searchClosing = false
				if self._searchSurface then
					self._searchSurface.Visible = false
				end
			end)
		else
			if self._searchSurface then
				self._searchSurface.Visible = false
			end
		end
	end

	function Axis:OpenSearch(sourceWindow)
		self._searchClosing = false
		if self._searchModal then
			Veil.Instance:SecureDestroy(self._searchModal)
			self._searchModal = nil
		end

		sourceWindow = sourceWindow or self.Windows[1]

		-- Ensure surface exists
		if not self._searchSurface then
			self._searchSurface = Veil.Instance:Create("Frame", {
				Name = "AxisSearch",
				Active = true,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = _udim2Scale(1, 1),
				ZIndex = 300,
				Parent = self.Surface,
			})

			self._searchBackdrop = Veil.Instance:Create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = _udim2Scale(1, 1),
				Text = "",
				ZIndex = 300,
				Parent = self._searchSurface,
			})
			self._searchBackdrop.MouseButton1Click:Connect(function()
				self:CloseSearch()
			end)
		end
		self._searchSurface.Visible = true

		-- Fade in backdrop
		TweenService:Create(self._searchBackdrop, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.5 }):Play()

		-- Build result list from source window
		local results = {}
		local matchedData = {}
		if sourceWindow then
			for _, tab in ipairs(sourceWindow.Tabs or {}) do
				table.insert(results, { label = tab.Name or "Tab", type = "Tab", ctrl = nil })
				for _, ctrl in ipairs(tab.Controls or {}) do
					if ctrl.Name and ctrl.Name ~= "" then
						table.insert(results, { label = ctrl.Name, type = ctrl.Type or "Control", ctrl = ctrl })
					end
				end
			end
		end

		-- Modal frame
		local modal = Veil.Instance:Create("Frame", {
			Name = "SearchModal",
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			Position = _udim2Scale(0.5, 0.28),
			Size = _udim2Offset(SearchModalWidth - 8, SearchInputHeight - 4),
			BackgroundTransparency = 0.3,
			AutomaticSize = Enum.AutomaticSize.None,
			ClipsDescendants = true,
			ZIndex = 302,
			Parent = self._searchSurface,
		})
		createCorner(modal, 12)
		createBorder(modal)
		self._searchModal = modal

		-- Animate open
		TweenService:Create(modal, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = _udim2Offset(SearchModalWidth, SearchInputHeight),
			BackgroundTransparency = 0,
		}):Play()

		-- Input row
		local inputRow = Veil.Instance:Create("Frame", {
			Name = "InputRow",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, SearchInputHeight),
			ZIndex = 303,
			Parent = modal,
		})

		-- Search icon
		local searchIconLabel = Veil.Instance:Create("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 14, 0.5, 0),
			Size = _udim2Offset(16, 16),
			ScaleType = Enum.ScaleType.Fit,
			ImageColor3 = COLORS.Text,
			ImageTransparency = 0.4,
			ZIndex = 304,
			Parent = inputRow,
		})
		task.spawn(function()
			RunService.Heartbeat:Wait()
			local data = IconProvider:Get("search")
			if data then
				searchIconLabel.Image = data.Image
				searchIconLabel.ImageRectSize = data.ImageRectSize
				searchIconLabel.ImageRectOffset = data.ImageRectOffset
			else
				searchIconLabel.Parent = nil
			end
		end)

		local searchBox = Veil.Instance:Create("TextBox", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
			Font = Enum.Font.GothamMedium,
			PlaceholderColor3 = COLORS.Text,
			PlaceholderText = "Start typing…",
			Position = UDim2.new(0, 36, 0.5, 0),
			Size = UDim2.new(1, -48, 0, 20),
			Text = "",
			TextColor3 = COLORS.Text,
			TextSize = 13,
			TextTransparency = 0,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 304,
			Parent = inputRow,
		})
		if sourceWindow and sourceWindow._applySelectionHighlight then
			sourceWindow:_applySelectionHighlight(searchBox)
		end

		-- Divider
		local divider = Veil.Instance:Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = COLORS.Stroke,
			BackgroundTransparency = STROKE_TRANSPARENCY,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0, SearchInputHeight),
			Size = UDim2.new(1, -16, 0, 1),
			Visible = false,
			ZIndex = 303,
			Parent = modal,
		})

		-- Results list
		local resultsList = Veil.Instance:Create("ScrollingFrame", {
			Name = "Results",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = _udim2Offset(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Position = _udim2Offset(0, SearchInputHeight + 1),
			ScrollBarImageColor3 = COLORS.Accent,
			ScrollBarThickness = 3,
			Size = UDim2.new(1, 0, 0, 0),
			Visible = false,
			ZIndex = 303,
			Parent = modal,
		})

		Veil.Instance:Create("UIListLayout", {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = resultsList,
		})
		createPadding(resultsList, 4, 6, 4, 6)

		-- Arrow key navigation
		local selectedIdx = 0
		local rowFrames = {}

		local function highlightRow(idx)
			local hoverTI = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			for j, rf in ipairs(rowFrames) do
				local target = j == idx and 0.88 or 1
				TweenService:Create(rf, hoverTI, { BackgroundTransparency = target }):Play()
			end
			selectedIdx = idx
			-- Autoscroll to keep selected row visible
			if idx > 0 and rowFrames[idx] then
				local rowTop = (idx - 1) * (SearchItemHeight + 2)
				local rowBot = rowTop + SearchItemHeight
				local visH = resultsList.AbsoluteSize.Y
				local canvasY = resultsList.CanvasPosition.Y
				if rowBot > canvasY + visH then
					resultsList.CanvasPosition = Vector2.new(0, rowBot - visH)
				elseif rowTop < canvasY then
					resultsList.CanvasPosition = Vector2.new(0, rowTop)
				end
			end
		end

		-- Inline control renderer
		local function renderInlineControl(parent, ctrl)
			if not ctrl then return false end
			local t = ctrl.Type
			if t == "Toggle" then
				local dot = Veil.Instance:Create("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = ctrl.Value and COLORS.Accent or COLORS.Stroke,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = _udim2Offset(10, 10),
					ZIndex = 306,
					Parent = parent,
				})
				createCorner(dot, 5)
				parent.MouseButton1Click:Connect(function()
					if ctrl.Set then
						ctrl:Set(not ctrl.Value)
						dot.BackgroundColor3 = ctrl.Value and COLORS.Accent or COLORS.Stroke
					end
				end)
				return true
			elseif t == "Slider" then
				Veil.Instance:Create("TextLabel", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Font = Enum.Font.GothamMedium,
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = _udim2Offset(50, 16),
					Text = tostring(ctrl.Value or ""),
					TextColor3 = COLORS.Accent,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = 306,
					Parent = parent,
				})
				return true
			elseif t == "Dropdown" then
				local val = ctrl.Value
				if type(val) == "table" then val = table.concat(val, ", ") end
				Veil.Instance:Create("TextLabel", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Font = Enum.Font.Gotham,
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = _udim2Offset(80, 16),
					Text = tostring(val or ""),
					TextColor3 = COLORS.Accent,
					TextSize = 10,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = 306,
					Parent = parent,
				})
				return true
			end
			return false
		end

		-- Filter and render results
		local function renderResults(query)
			rowFrames = {}
			matchedData = {}
			selectedIdx = 0
			for _, child in ipairs(resultsList:GetChildren()) do
				if child:IsA("Frame") or child:IsA("TextButton") then
					child:Destroy()
				end
			end

			local q = query:lower():gsub("^%s+", ""):gsub("%s+$", "")
			local matched = {}
			if q ~= "" then
				for _, r in ipairs(results) do
					if r.label:lower():find(q, 1, true) then
						table.insert(matched, r)
						if #matched >= 10 then break end
					end
				end
			end
			matchedData = matched

			local hasResults = #matched > 0
			divider.Visible = hasResults
			resultsList.Visible = hasResults

			local listH = math.min(#matched * (SearchItemHeight + 2) + 8, SearchModalMaxHeight - SearchInputHeight)
			resultsList.Size = UDim2.new(1, 0, 0, listH)
			local targetH = SearchInputHeight + (hasResults and (listH + 1) or 0)
			TweenService:Create(modal, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = _udim2Offset(SearchModalWidth, targetH)
			}):Play()

			for i, r in ipairs(matched) do
				local row = Veil.Instance:Create("TextButton", {
					AutoButtonColor = false,
					BackgroundColor3 = COLORS.Text,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = i,
					Size = UDim2.new(1, 0, 0, SearchItemHeight),
					Text = "",
					ZIndex = 304,
					Parent = resultsList,
				})
				createCorner(row, 6)
				table.insert(rowFrames, row)

				Veil.Instance:Create("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Font = Enum.Font.GothamMedium,
					Position = UDim2.new(0, 10, 0.5, 0),
					Size = UDim2.new(0.6, 0, 0, 16),
					Text = r.label,
					TextColor3 = COLORS.Text,
					TextSize = 12,
					TextTransparency = 0,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 305,
					Parent = row,
				})

				-- Inline control widget or fallback type badge
				if not renderInlineControl(row, r.ctrl) then
					local typeBadge = Veil.Instance:Create("TextLabel", {
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundColor3 = COLORS.Accent,
						BackgroundTransparency = 0.82,
						BorderSizePixel = 0,
						Font = Enum.Font.Gotham,
						Position = UDim2.new(1, -8, 0.5, 0),
						Size = _udim2Offset(0, 18),
						AutomaticSize = Enum.AutomaticSize.X,
						Text = r.type or "Control",
						TextColor3 = COLORS.Accent,
						TextSize = 10,
						TextXAlignment = Enum.TextXAlignment.Center,
						ZIndex = 305,
						Parent = row,
					})
					createCorner(typeBadge, 4)
					createPadding(typeBadge, 0, 5, 0, 5)
				end

				local hoverTI = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				row.MouseEnter:Connect(function()
					for j, rf in ipairs(rowFrames) do
						if rf == row then
							selectedIdx = j
							break
						end
					end
					highlightRow(selectedIdx)
				end)
				row.MouseLeave:Connect(function()
					TweenService:Create(row, hoverTI, { BackgroundTransparency = 1 }):Play()
				end)
				row.MouseButton1Click:Connect(function()
					if r.ctrl and r.ctrl.Set and r.ctrl.Type == "Toggle" then
						r.ctrl:Set(not r.ctrl.Value)
					else
						self:CloseSearch()
					end
				end)
			end
		end

		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			renderResults(searchBox.Text)
		end)

		-- Keyboard: ESC, arrows, enter — sink arrow/enter inputs via InputEnded guard
		local kbConn = UserInputService.InputBegan:Connect(function(inp, processed)
			if inp.KeyCode == Enum.KeyCode.Escape then
				self:CloseSearch()
				return
			end
			if inp.KeyCode == Enum.KeyCode.Down then
				if #rowFrames > 0 then highlightRow(math.min(selectedIdx + 1, #rowFrames)) end
				return
			elseif inp.KeyCode == Enum.KeyCode.Up then
				if #rowFrames > 0 then highlightRow(math.max(selectedIdx - 1, 1)) end
				return
			elseif inp.KeyCode == Enum.KeyCode.Return then
				if selectedIdx > 0 and selectedIdx <= #matchedData then
					local r = matchedData[selectedIdx]
					if r and r.ctrl and r.ctrl.Set and r.ctrl.Type == "Toggle" then
						r.ctrl:Set(not r.ctrl.Value)
						-- Refresh the dot color in the row
						local row = rowFrames[selectedIdx]
						if row then
							for _, child in ipairs(row:GetChildren()) do
								if child:IsA("Frame") and child.Name ~= "UICorner" then
									child.BackgroundColor3 = r.ctrl.Value and COLORS.Accent or COLORS.Stroke
								end
							end
						end
					else
						self:CloseSearch()
					end
				end
				return
			end
		end)

		-- Sink arrow/WASD keys so the player doesn't move
		local sinkConn = UserInputService.InputBegan:Connect(function(inp, processed)
			local kc = inp.KeyCode
			if kc == Enum.KeyCode.W or kc == Enum.KeyCode.A or kc == Enum.KeyCode.S or kc == Enum.KeyCode.D
				or kc == Enum.KeyCode.Up or kc == Enum.KeyCode.Down or kc == Enum.KeyCode.Left or kc == Enum.KeyCode.Right
				or kc == Enum.KeyCode.Space then
				-- The TextBox has focus, so these are already sunk by the focused TextBox
			end
		end)

		modal.AncestryChanged:Connect(function()
			if not modal.Parent then
				kbConn:Disconnect()
				sinkConn:Disconnect()
			end
		end)

		renderResults("")

		task.defer(function()
			if searchBox and searchBox.Parent then
				searchBox:CaptureFocus()
			end
		end)
	end

	-- Ctrl+K global keybind to open search
	UserInputService.InputBegan:Connect(function(inp, processed)
		if inp.KeyCode == Enum.KeyCode.K and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			if Axis._searchModal then
				Axis:CloseSearch()
			else
				Axis:OpenSearch()
			end
		end
	end)



	-- Adds a "Scanner" tab to sourceWindow. "Run Scan" calls Veil.Scanner:Run()
	-- and populates results with name, path, reason, Copy and Kill buttons.
	-- Scanner logic lives in Veil - Axis only presents results.
	function Axis:CreateScanner(sourceWindow)
		assert(sourceWindow, "[Axis] CreateScanner requires a window")

		local scannerTab = sourceWindow:CreateTab({ Name = "Scanner", Icon = "shield-alert", IconScale = 0.82 })
		local left = scannerTab.Columns.leftColumn
		local right = scannerTab.Columns.rightColumn

		-- Status label (updated after each scan)
		local statusLabel = left:Label({ Name = "Status", Subtext = "Press Scan to begin" })

		left:Button({
			Name = "Run Scan",
			Callback = function()
				local results, err = Veil.Scanner:Run()
				if not results then
					if statusLabel.SetSubtext then statusLabel:SetSubtext("Error: " .. tostring(err)) end
					self:Notify({ Title = "Scanner", Message = tostring(err), Type = "Error" })
					return
				end

				-- Update status
				local count = #results
				if statusLabel.SetSubtext then
					statusLabel:SetSubtext(count == 0 and "No threats detected" or count .. " item(s) flagged")
				end

				-- Clear previous result rows
				local resultFrame = right.Frame:FindFirstChild("ScanResults")
				if resultFrame then resultFrame:Destroy() end

				-- Build result container
				local rowH = 42
				local padV = 6
				local container = Veil.Instance:Create("ScrollingFrame", {
					Name = "ScanResults",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollBarThickness = 3,
					ScrollBarImageTransparency = 0.55,
					ScrollBarImageColor3 = COLORS.Stroke,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					LayoutOrder = nextOrder(right.Frame),
					Parent = right.Frame,
				})

				local listLayout = Veil.Instance:Create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4),
					Parent = container,
				})
				local listPad = Veil.Instance:Create("UIPadding", {
					PaddingTop = UDim.new(0, padV),
					PaddingBottom = UDim.new(0, padV),
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
					Parent = container,
				})
				-- silence unused warning
				local _ = listLayout
				local __ = listPad

				if count == 0 then
					Veil.Instance:Create("TextLabel", {
						Size = UDim2.new(1, 0, 0, 32),
						BackgroundTransparency = 1,
						Text = "No threats detected",
						TextColor3 = COLORS.Text,
						TextTransparency = 0.5,
						Font = Enum.Font.Gotham,
						TextSize = 12,
						LayoutOrder = 1,
						Parent = container,
					})
				else
					for i, result in ipairs(results) do
						local row = Veil.Instance:Create("Frame", {
							Size = UDim2.new(1, 0, 0, rowH),
							BackgroundColor3 = COLORS.Titlebar,
							LayoutOrder = i,
							Parent = container,
						})
						Veil.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = row })
						Veil.Instance:Create("UIStroke", {
							Color = COLORS.Stroke,
							Transparency = 0.88,
							Thickness = 1,
							Parent = row,
						})

						-- Name (top left)
						Veil.Instance:Create("TextLabel", {
							Position = UDim2.new(0, 8, 0, 4),
							Size = UDim2.new(1, -100, 0, 18),
							BackgroundTransparency = 1,
							Text = tostring(result.Name):sub(1, 36),
							TextColor3 = COLORS.Text,
							Font = Enum.Font.GothamBold,
							TextSize = 11,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextTruncate = Enum.TextTruncate.AtEnd,
							Parent = row,
						})

						-- Reason (bottom left)
						Veil.Instance:Create("TextLabel", {
							Position = UDim2.new(0, 8, 0, 22),
							Size = UDim2.new(1, -100, 0, 14),
							BackgroundTransparency = 1,
							Text = tostring(result.Reason):sub(1, 52),
							TextColor3 = COLORS.Text,
							TextTransparency = 0.4,
							Font = Enum.Font.Gotham,
							TextSize = 10,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextTruncate = Enum.TextTruncate.AtEnd,
							Parent = row,
						})

						-- Copy button
						local copyBtn = Veil.Instance:Create("TextButton", {
							Position = UDim2.new(1, -90, 0.5, -10),
							Size = UDim2.new(0, 40, 0, 20),
							BackgroundColor3 = COLORS.Window,
							Text = "Copy",
							TextColor3 = COLORS.Text,
							TextTransparency = 0.3,
							Font = Enum.Font.Gotham,
							TextSize = 10,
							Parent = row,
						})
						Veil.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = copyBtn })
						local capturedPath = result.Path
						copyBtn.MouseButton1Click:Connect(function()
							local ok = Veil.Scanner:CopyPath(capturedPath)
							if ok then
								self:Notify({ Title = "Scanner", Message = "Path copied", Duration = 2 })
							else
								self:Notify({ Title = "Scanner", Message = "Clipboard unavailable", Type = "Warning", Duration = 2 })
							end
						end)

						-- Kill button (only for Script refs)
						local killBtn = Veil.Instance:Create("TextButton", {
							Position = UDim2.new(1, -44, 0.5, -10),
							Size = UDim2.new(0, 36, 0, 20),
							BackgroundColor3 = Color3.fromRGB(80, 28, 30),
							Text = "Kill",
							TextColor3 = Color3.fromRGB(255, 120, 120),
							Font = Enum.Font.GothamBold,
							TextSize = 10,
							AutoButtonColor = false,
							Parent = row,
						})
						Veil.Instance:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = killBtn })
						local capturedRef = result.ScriptRef
						killBtn.MouseButton1Click:Connect(function()
							if capturedRef then
								Veil.Scanner:Kill(capturedRef)
								row.BackgroundColor3 = Color3.fromRGB(30, 22, 22)
								self:Notify({ Title = "Scanner", Message = "Killed: " .. tostring(result.Name), Duration = 3 })
							else
								self:Notify({ Title = "Scanner", Message = "No script ref - cannot kill closure", Type = "Warning", Duration = 2 })
							end
						end)
					end
				end
			end,
		})
	end

	-- Fires VirtualUser:CaptureController on Player.Idled to prevent idle kick.
	-- No-ops if VirtualUser service is unavailable. Cleaned up by DestroyAll.
	function Axis:SetAntiAFK(enabled)
		if enabled then
			if self._antiAFKConn then return end
			local ok, vuser = pcall(function() return Veil.Services:Get("VirtualUser") end)
			if not ok or not vuser then return end
			local players = Veil.Services:Get("Players")
			local player = players and players.LocalPlayer
			if not player then return end
			self._antiAFKConn = player.Idled:Connect(function()
				vuser:CaptureController()
				vuser:ClickButton2(Vector2.new())
			end)
		else
			if self._antiAFKConn then
				self._antiAFKConn:Disconnect()
				self._antiAFKConn = nil
			end
		end
	end

	-- Returns current theme as {Key = "#RRGGBB"} hex map for all THEME_KEYS.
	function Axis:GetTheme()
		local theme = {}
		for _, key in ipairs(THEME_KEYS) do
			theme[key] = colorToHex(COLORS[key])
		end
		return theme
	end

	-- Applies a theme table ({Key = Color3 | "#RRGGBB"}) to all live windows.
	function Axis:SetTheme(theme)
		for _, window in ipairs(self.Windows) do
			window:ApplyTheme(theme)
		end
	end

	-- Updates a single theme color key and refreshes all live windows immediately.
	-- key must be one of the values returned by GetThemeKeys().
	function Axis:SetThemeColor(key, value)
		if COLORS[key] == nil then
			return false
		end

		local resolved = colorFromValue(value, COLORS[key])
		COLORS[key] = resolved
		for _, window in ipairs(self.Windows) do
			window:RefreshTheme()
		end
		return true
	end

	-- Returns a copy of the valid theme key list (safe to iterate; doesn't expose internal).
	function Axis:GetThemeKeys()
		return table.clone(THEME_KEYS)
	end

	-- Switches icon pack and immediately re-renders all registered tab icons.
	-- packName: "Lucide" | "Phosphor"
	function Axis:SetIconPack(packName)
		IconProvider:SetPack(packName)
	end

	-- Returns the name of the currently active icon pack.
	function Axis:GetIconPack()
		return IconProvider.ActivePack
	end

	return Axis
end
