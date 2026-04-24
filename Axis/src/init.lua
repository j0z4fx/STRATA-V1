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
	local RunService = Veil.Services:Get("RunService")
	local TweenService = Veil.Services:Get("TweenService")
	local UserInputService = Veil.Services:Get("UserInputService")
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
	local OverlaySpacing = 10
	local OverlayAnimationTime = 0.28
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
	local ColumnItemSpacing = 10
	local LabelRowHeight = 28
	local LabelRowWithSubtextHeight = 46
	local DividerInsetX = 6
	local SectionHeaderGap = 10
	local ToggleRowHeight = 30
	local ToggleRowWithSubtextHeight = 52
	local ToggleSwitchWidth = 34
	local ToggleSwitchHeight = 20
	local ToggleDotSize = 12
	local ToggleAnimationTime = 0.22
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
	local KeypickerModeRowHeight = 22
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
		ToggleOffBackground = Color3.fromRGB(36, 36, 41),
		ToggleOffDot = Color3.fromRGB(68, 68, 78),
		ToggleOnDot = Color3.fromRGB(255, 255, 255),
	}

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
			Position = UDim2.fromOffset(18, 18),
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
		local spacing = math.max(0, rows - 1) * 2
		return (rows * KeypickerModeRowHeight) + spacing + 8
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

		if tab.IconImage.Visible then
			TweenService:Create(tab.IconImage, TweenInfo.new(TabButtonAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageColor3 = tint,
			}):Play()
		end

		if tab.IconFallback.Visible then
			TweenService:Create(tab.IconFallback, TweenInfo.new(TabButtonAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextColor3 = tint,
			}):Play()
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
			Size = UDim2.fromOffset(ContentDividerHandleWidth, ContentDividerHandleHeight),
			ZIndex = 4,
			Parent = divider,
		})
		createCorner(handle, ContentDividerHandleWidth)

		local hitbox = Veil.Instance:Create("TextButton", {
			Name = "Hitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
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
				Size = UDim2.fromOffset(2, 8),
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

	local function createTextRow(parent, name, height)
		return Veil.Instance:Create("Frame", {
			Name = name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 999,
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
			control.AccessoryHost.Size = UDim2.fromOffset(accessoryWidth, control.RowHeight or AccessoryButtonHeight)
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
			Size = UDim2.fromOffset(0, control.RowHeight or AccessoryButtonHeight),
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
			Size = UDim2.fromOffset(width, AccessoryButtonHeight),
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

		local leftColumn = Veil.Instance:Create("Frame", {
			Name = "leftColumn",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = parent,
		})
		table.insert(columns, leftColumn)

		local middleColumn
		if columnMode == "Triple" then
			middleColumn = Veil.Instance:Create("Frame", {
				Name = "middleColumn",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = parent,
			})
			table.insert(columns, middleColumn)
		end

		local rightColumn = Veil.Instance:Create("Frame", {
			Name = "rightColumn",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
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
		local tween = TweenService:Create(card, TweenInfo.new(OverlayAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(targetOffset.X, targetOffset.Y),
		})
		local tweens = {
			tween,
		}

		local cardTween = TweenService:Create(card, TweenInfo.new(OverlayAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = isVisible and 0 or 1,
		})
		table.insert(tweens, cardTween)

		for _, descendant in ipairs(card:GetDescendants()) do
			if descendant:IsA("UIStroke") then
				table.insert(tweens, TweenService:Create(descendant, TweenInfo.new(OverlayAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = isVisible and STROKE_TRANSPARENCY or 1,
				}))
			elseif descendant:IsA("TextLabel") then
				local baseTextTransparency = descendant:GetAttribute("AxisBaseTextTransparency")
				if baseTextTransparency == nil then
					baseTextTransparency = descendant.TextTransparency
					descendant:SetAttribute("AxisBaseTextTransparency", baseTextTransparency)
				end
				table.insert(tweens, TweenService:Create(descendant, TweenInfo.new(OverlayAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = isVisible and baseTextTransparency or 1,
				}))
			elseif descendant:IsA("Frame") and descendant.Name == "AccentEdge" then
				table.insert(tweens, TweenService:Create(descendant, TweenInfo.new(OverlayAnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = isVisible and 0 or 1,
				}))
			end
		end

		if onComplete then
			local connection
			connection = tween.Completed:Connect(function()
				if connection then
					connection:Disconnect()
				end
				onComplete()
			end)
		end

		for _, activeTween in ipairs(tweens) do
			activeTween:Play()
		end

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
			Size = UDim2.fromOffset(width, 0),
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
		self.TooltipToken = 0
		self.ActiveTooltipAnchor = nil
		self.ActiveTooltipText = nil

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
			Name = "TopTabList",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(SidebarInset, SidebarInset),
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
			Position = UDim2.fromOffset(SidebarWidth, 0),
			Size = UDim2.new(1, -SidebarWidth, 1, 0),
			ZIndex = 2,
			Parent = self.Body,
		})

		self.TabContentHost = Veil.Instance:Create("Frame", {
			Name = "TabContentHost",
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
			Parent = self.Content,
		})

		self.Cursor = Veil.Instance:Create("Frame", {
			Name = "CrossCursor",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Active = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Interactable = false,
			Size = UDim2.fromOffset(13, 13),
			ZIndex = 500,
			Parent = self.Surface,
		})

		local cursorParts = {
			{ Name = "VerticalStroke", Size = UDim2.fromOffset(3, 13), Position = UDim2.new(0.5, 0, 0.5, 0), Color = COLORS.Window, Z = 500 },
			{ Name = "HorizontalStroke", Size = UDim2.fromOffset(13, 3), Position = UDim2.new(0.5, 0, 0.5, 0), Color = COLORS.Window, Z = 500 },
			{ Name = "VerticalFill", Size = UDim2.fromOffset(1, 11), Position = UDim2.new(0.5, 0, 0.5, 0), Color = COLORS.Accent, Z = 501 },
			{ Name = "HorizontalFill", Size = UDim2.fromOffset(11, 1), Position = UDim2.new(0.5, 0, 0.5, 0), Color = COLORS.Accent, Z = 501 },
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
				self.Cursor.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y)
				self.Cursor.Visible = self.CursorVisible
			end

			if self.Tooltip and self.Tooltip.Visible and self.ActiveTooltipAnchor then
				local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
				local tooltipWidth = self.Tooltip.AbsoluteSize.X
				local tooltipHeight = self.Tooltip.AbsoluteSize.Y
				local nextX = math.clamp(mouseLocation.X + TooltipOffset.X, 10, math.max(10, viewportSize.X - tooltipWidth - 10))
				local nextY = math.clamp(mouseLocation.Y + TooltipOffset.Y, tooltipHeight + 10, math.max(tooltipHeight + 10, viewportSize.Y - 10))
				self.Tooltip.Position = UDim2.fromOffset(nextX, nextY)
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
			Size = UDim2.fromOffset(0, 0),
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
			self.TooltipLabel.Size = UDim2.fromOffset(TooltipMaxWidth, 0)
			self.TooltipLabel.AutomaticSize = Enum.AutomaticSize.Y
			self.TooltipLabel.TextWrapped = true
		else
			self.TooltipLabel.AutomaticSize = Enum.AutomaticSize.XY
			self.TooltipLabel.Size = UDim2.fromOffset(0, 0)
		end

		TweenService:Create(self.Tooltip, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0,
		}):Play()
		TweenService:Create(self.TooltipLabel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0.12,
		}):Play()
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
			IconScale = type(options.IconScale) == "number" and options.IconScale or 1,
			PinnedBottom = options.PinnedBottom == true or options.Dock == "Bottom",
			Window = self,
			ToggleControls = {},
			AccessoryControls = {},
		}
		tab.IsSettings = options.Settings == true or string.lower(tab.Name) == "settings"
		local baseIconSize = TabButtonSize - (TabIconInset * 2)
		local iconSize = math.max(12, math.floor(baseIconSize * tab.IconScale + 0.5))
		local iconPosition = math.floor((TabButtonSize - iconSize) * 0.5 + 0.5)

		local buttonParent = tab.PinnedBottom and self.BottomTabHost or self.TabList

		tab.Button = Veil.Instance:Create("TextButton", {
			Name = tab.Name .. "TabButton",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = tab.PinnedBottom and 1 or tab.Order,
			Size = UDim2.fromOffset(TabButtonSize, TabButtonSize),
			Text = "",
			ZIndex = 5,
			Parent = buttonParent,
		})
		tab.ButtonScale = Veil.Instance:Create("UIScale", {
			Scale = TabButtonIdleScale,
			Parent = tab.Button,
		})

		if tab.PinnedBottom then
			tab.Button.AnchorPoint = Vector2.new(0.5, 0)
			tab.Button.Position = UDim2.new(0.5, 0, 0, 0)
		end

		tab.Highlight = Veil.Instance:Create("Frame", {
			Name = "Highlight",
			BackgroundColor3 = COLORS.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(TabButtonSize, TabButtonSize),
			ZIndex = 5,
			Parent = tab.Button,
		})
		tab.HighlightScale = Veil.Instance:Create("UIScale", {
			Scale = TabHighlightIdleScale,
			Parent = tab.Highlight,
		})
		createCorner(tab.Highlight, TabCornerRadius)

		tab.IconImage = Veil.Instance:Create("ImageLabel", {
			Name = "IconImage",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = "",
			ImageColor3 = InactiveIconColor,
			Position = UDim2.fromOffset(iconPosition, iconPosition),
			Size = UDim2.fromOffset(iconSize, iconSize),
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

		tab.leftColumn, tab.middleColumn, tab.rightColumn = createColumns(self, tab, tab.Content, tab.IsSettings and "Double" or "Triple")

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

	function Window:_createLabel(tab, options)
		options = options or {}

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local subtext = options.Subtext or options.Description or options.Desc
		local hasSubtext = type(subtext) == "string" and subtext ~= ""
		local holder = createTextRow(parentColumn, options.Name or "Label", hasSubtext and LabelRowWithSubtextHeight or LabelRowHeight)
		holder.LayoutOrder = type(options.Order) == "number" and options.Order or 999

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

		label.TitleLabel = Veil.Instance:Create("TextLabel", {
			Name = "Title",
			AnchorPoint = hasSubtext and Vector2.new(0, 0) or Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = hasSubtext and UDim2.fromOffset(0, 6) or UDim2.new(0, 0, 0.5, 0),
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
				Position = UDim2.fromOffset(0, 24),
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

		return label
	end

	function Window:_createDivider(tab, options)
		options = options or {}

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local holder = createTextRow(parentColumn, options.Name or "Divider", 8)
		holder.LayoutOrder = type(options.Order) == "number" and options.Order or 999

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

		return {
			Type = "Divider",
			Holder = holder,
			Line = line,
			Tab = tab,
			Window = self,
		}
	end

	function Window:_createSectionHeader(tab, options)
		options = options or {}

		local parentColumn = options.ColumnFrame or resolveTabColumn(tab, options.Column or options.Side or "left")
		ensureColumnStack(parentColumn)

		local holder = createTextRow(parentColumn, options.Name or "SectionHeader", 18)
		holder.LayoutOrder = type(options.Order) == "number" and options.Order or 999

		local text = options.Text or options.Name or "Section"
		local textWidth = math.ceil(measureText(text, 12, Enum.Font.GothamMedium).X)
		local clampedTextWidth = math.clamp(textWidth + 10, 36, 120)
		local halfGap = math.floor((clampedTextWidth + SectionHeaderGap) * 0.5)

		local centerLabel = Veil.Instance:Create("TextLabel", {
			Name = "Title",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.fromOffset(clampedTextWidth, 18),
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
			Position = UDim2.new(0, DividerInsetX, 0.5, 0),
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
			Position = UDim2.new(1, -DividerInsetX, 0.5, 0),
			Size = UDim2.new(0.5, -(DividerInsetX + halfGap), 0, 1),
			ZIndex = 4,
			Parent = holder,
		})

		return {
			Type = "SectionHeader",
			Holder = holder,
			Label = centerLabel,
			LeftLine = leftLine,
			RightLine = rightLine,
			Tab = tab,
			Window = self,
		}
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

		popup.Position = UDim2.fromOffset(nextX, nextY)
	end

	function Window:_positionMenuPopup(anchorButton, popup, width, height)
		if not anchorButton or not popup then
			return
		end

		local viewportSize = getViewportSize()
		local resolvedWidth = width or (popup.AbsoluteSize.X > 0 and popup.AbsoluteSize.X or KeypickerModeMenuWidth)
		local resolvedHeight = height or (popup.AbsoluteSize.Y > 0 and popup.AbsoluteSize.Y or getModeMenuHeight(3))
		local anchorPosition = anchorButton.AbsolutePosition
		local anchorSize = anchorButton.AbsoluteSize
		local nextX = anchorPosition.X + anchorSize.X - resolvedWidth
		local nextY = anchorPosition.Y + anchorSize.Y + 6

		nextX = math.clamp(nextX, 10, math.max(10, viewportSize.X - resolvedWidth - 10))
		nextY = math.clamp(nextY, 10, math.max(10, viewportSize.Y - resolvedHeight - 10))

		popup.Position = UDim2.fromOffset(nextX, nextY)
	end

	function Window:_createKeypicker(control, options)
		options = options or {}

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
			Size = UDim2.fromScale(1, 1),
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
			Size = UDim2.fromOffset(KeypickerModeMenuWidth, getModeMenuHeight(#allowedModes)),
			Visible = false,
			ZIndex = 260,
			Parent = pickerSurface,
		})
		createCorner(keypicker.ModeMenu, 8)
		createBorder(keypicker.ModeMenu)
		createPadding(keypicker.ModeMenu, 4, 4, 4, 4)

		Veil.Instance:Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 2),
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
				Size = UDim2.new(1, 0, 0, KeypickerModeRowHeight),
				Text = modeName,
				TextColor3 = COLORS.Text,
				TextSize = 12,
				TextTransparency = 0.18,
				Font = Enum.Font.GothamMedium,
				ZIndex = 261,
				Parent = keypicker.ModeMenu,
			})
			createCorner(modeButton, 6)
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
			self.Button.Size = UDim2.fromOffset(width, AccessoryButtonHeight)
			self.ButtonLabel.Text = self.Capturing and "..." or self.Value
			self.Button.BackgroundColor3 = active and COLORS.Accent or COLORS.ToggleOffBackground
			self.Button.BackgroundTransparency = self.Disabled and 0.2 or (active and 0.4 or 0)
			self.ButtonLabel.TextTransparency = self.Disabled and 0.45 or (active and 0 or 0.12)
			self.ButtonLabel.TextColor3 = self.Capturing and COLORS.Accent or (active and Color3.fromRGB(255, 255, 255) or COLORS.Text)
			self:_refreshModeButtons()
			refreshAccessoryWidth(control)
		end

		function keypicker:CloseModeMenu()
			if self.ModeMenu then
				self.ModeMenu.Visible = false
			end
			if Axis.ActiveModeMenu == self.ModeMenu then
				Axis.ActiveModeMenu = nil
			end
			if not Axis.ActivePickerPopup and Axis.PickerBackdrop then
				Axis.PickerBackdrop.Visible = false
			end
		end

		function keypicker:OpenModeMenu()
			if self.Disabled or control.Disabled or not self.ModeMenu then
				return
			end

			Axis:_closeActivePicker()
			Axis.ActiveModeMenu = self.ModeMenu
			self.ModeMenu.Visible = true
			if Axis.PickerBackdrop then
				Axis.PickerBackdrop.Visible = true
			end
			self.Window:_positionMenuPopup(self.Button, self.ModeMenu, KeypickerModeMenuWidth, getModeMenuHeight(#self.Modes))
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
			if keypicker.ModeMenu.Visible then
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

			if keypicker.ModeMenu and keypicker.ModeMenu.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
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

		local hue, sat, val = Color3.toHSV(initialColor)
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
			Size = UDim2.fromScale(1, 1),
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
			Size = UDim2.fromOffset(PickerPopupWidth, PickerPopupHeight),
			Visible = false,
			ZIndex = 260,
			Parent = pickerSurface,
		})
		createCorner(colorpicker.Popup, PickerCornerRadius)
		createBorder(colorpicker.Popup)
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
			Size = UDim2.fromScale(1, 1),
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
			Position = UDim2.fromOffset(0, PickerPreviewHeight + 8),
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
			Size = UDim2.fromScale(1, 1),
			ZIndex = 262,
			Parent = colorpicker.Map,
		})
		createCorner(satOverlay, 6)

		colorpicker.MapHitbox = Veil.Instance:Create("TextButton", {
			Name = "MapHitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			ZIndex = 265,
			Parent = colorpicker.Map,
		})

		colorpicker.MapCursorOuter = Veil.Instance:Create("Frame", {
			Name = "MapCursorOuter",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = COLORS.Window,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(8, 8),
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
			Size = UDim2.fromOffset(4, 4),
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
			Size = UDim2.fromOffset(PickerHueWidth, PickerMapSize.Y),
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
			Size = UDim2.fromScale(1, 1),
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
			Position = UDim2.fromOffset(0, PickerPreviewHeight + 8 + pickerBodyHeight + 8),
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
			self.Hue, self.Sat, self.Val = Color3.toHSV(value)
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

		local function beginPopup()
			if colorpicker.Disabled or control.Disabled then
				return
			end

			self:HideTooltip(control)
			Axis:_closeActivePicker(colorpicker.Popup)
			Axis.ActivePickerPopup = colorpicker.Popup
			colorpicker.Popup.Visible = true
			colorpicker.Popup:SetAttribute("AxisOpen", true)
			if Axis.PickerBackdrop then
				Axis.PickerBackdrop.Visible = true
			end
			self:_positionPickerPopup(colorpicker.Button, colorpicker.Popup)
			task.defer(function()
				if colorpicker.Popup and colorpicker.Popup.Visible then
					self:_positionPickerPopup(colorpicker.Button, colorpicker.Popup)
				end
			end)
		end

		colorpicker.ButtonHitbox.MouseButton1Click:Connect(function()
			if colorpicker.Disabled or control.Disabled then
				return
			end

			if colorpicker.Popup.Visible then
				colorpicker.Popup.Visible = false
				Axis:_closeActivePicker()
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
				colorpicker.Popup.Visible = false
				Axis:_closeActivePicker()
			end
		end))

		colorpicker:_refreshVisuals()
		colorpicker:SetDisabled(colorpicker.Disabled)
		table.insert(control.Tab.AccessoryControls, colorpicker)
		control.Colorpicker = colorpicker
		return colorpicker
	end

	function Window:_createToggle(tab, options)
		options = options or {}

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

		toggle.Holder = Veil.Instance:Create("Frame", {
			Name = toggle.Name,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = #tab.ToggleControls + 1,
			Size = UDim2.new(1, 0, 0, rowHeight),
			Visible = toggle.Visible,
			Parent = parentColumn,
		})

		toggle.Button = Veil.Instance:Create("TextButton", {
			Name = "Hitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			ZIndex = 8,
			Parent = toggle.Holder,
		})

		toggle.LabelWrap = Veil.Instance:Create("Frame", {
			Name = "LabelWrap",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = hasSubtext and UDim2.fromOffset(0, 6) or UDim2.fromOffset(0, 0),
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
			Position = hasSubtext and UDim2.fromOffset(0, 0) or UDim2.new(0, 0, 0.5, 0),
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
				Position = UDim2.fromOffset(0, 18),
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
			Size = UDim2.fromOffset(ToggleSwitchWidth, ToggleSwitchHeight),
			ZIndex = 5,
			Parent = toggle.Holder,
		})
		createCorner(toggle.Switch, ToggleSwitchHeight / 2)

		toggle.SwitchDot = Veil.Instance:Create("Frame", {
			Name = "Dot",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = COLORS.ToggleOffDot,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(2, ToggleSwitchHeight / 2),
			Size = UDim2.fromOffset(ToggleDotSize, ToggleDotSize),
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
			local dotOnX = ToggleSwitchWidth - ToggleDotSize - 3
			local dotOffX = 2
			local targetBackground = value and COLORS.Accent or COLORS.ToggleOffBackground
			local targetDotColor = value and COLORS.ToggleOnDot or COLORS.ToggleOffDot
			local targetDotPosition = UDim2.fromOffset(value and dotOnX or dotOffX, ToggleSwitchHeight / 2)
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
			TweenService:Create(self.SwitchDot, TweenInfo.new(ToggleAnimationTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
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

		if not hasSubtext and type(toggle.Tooltip) == "string" and toggle.Tooltip ~= "" then
			toggle.Button.MouseEnter:Connect(function()
				toggle.Hovering = true
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

			toggle.Button.MouseLeave:Connect(function()
				toggle.Hovering = false
				self:HideTooltip(toggle)
			end)
		end

		toggle.Button.Active = not toggle.Disabled
		toggle:Set(toggle.Value, {
			Silent = true,
			Instant = true,
		})

		table.insert(tab.ToggleControls, toggle)
		return toggle
	end

	-- ── Slider shared internals ──────────────────────────────────────────────

	local function buildSliderTrack(holder, trackZoneTop, thumbRadius, trackInsetY)
		local trackZone = Veil.Instance:Create("Frame", {
			Name = "TrackZone",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, trackZoneTop),
			Size = UDim2.new(1, 0, 0, SliderThumbDiameter),
			ZIndex = 5,
			Parent = holder,
		})

		local trackBg = Veil.Instance:Create("Frame", {
			Name = "TrackBg",
			BackgroundColor3 = COLORS.ToggleOffBackground,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(thumbRadius, trackInsetY),
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
			Position = UDim2.fromOffset(thumbRadius, SliderThumbDiameter / 2),
			Size = UDim2.fromOffset(SliderThumbDiameter, SliderThumbDiameter),
			ZIndex = 7,
			Parent = trackZone,
		})
		createCorner(thumb, SliderThumbDiameter / 2)

		local hitbox = Veil.Instance:Create("TextButton", {
			Name = "Hitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
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
			Position = UDim2.fromOffset(0, 0),
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
			Size = UDim2.fromOffset(SliderValueWidth, 18),
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
				Position = UDim2.fromOffset(0, 18),
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

	-- ── Normal Slider ────────────────────────────────────────────────────────

	function Window:_createSlider(tab, options)
		options = options or {}

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

		slider.Holder = createTextRow(parentColumn, slider.Name, rowHeight)
		slider.Holder.LayoutOrder = type(options.Order) == "number" and options.Order or 999

		slider.TitleLabel, slider.ValueLabel, slider.SubtextLabel =
			buildSliderTextRows(slider.Holder, slider.Name, subtext, hasSubtext)

		slider.TrackZone, slider.TrackBg, slider.TrackFill, slider.Thumb, slider.Hitbox =
			buildSliderTrack(slider.Holder, trackZoneTop, thumbRadius, trackInsetY)

		function slider:_refreshTrack()
			local f = self.VisualFraction
			local trackW = self.TrackBg.AbsoluteSize.X
			self.TrackFill.Size = UDim2.new(f, 0, 1, 0)
			self.Thumb.Position = UDim2.fromOffset(thumbRadius + f * trackW, SliderThumbDiameter / 2)

			local disabled = self.Disabled
			self.TitleLabel.TextTransparency = disabled and 0.5 or 0
			if self.SubtextLabel then
				self.SubtextLabel.TextTransparency = disabled and 0.6 or 0.35
			end
			self.ValueLabel.TextTransparency = disabled and 0.6 or 0.25
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

		local dragging = false

		slider.Hitbox.InputBegan:Connect(function(input)
			if slider.Disabled then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			dragging = true
			slider.IsDragging = true
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
			end
		end))

		registerCleanup(self, RunService.Heartbeat:Connect(function()
			if math.abs(slider.TargetFraction - slider.VisualFraction) < 0.0005 then
				if slider.VisualFraction ~= slider.TargetFraction then
					slider.VisualFraction = slider.TargetFraction
					slider:_refreshTrack()
				end
				return
			end
			local alpha = slider.IsDragging and SliderDragLerpAlpha or SliderLerpAlpha
			slider.VisualFraction = slider.VisualFraction + (slider.TargetFraction - slider.VisualFraction) * alpha
			slider:_refreshTrack()
		end))

		slider:Set(default, { Instant = true, Silent = true })
		task.defer(function()
			slider.VisualFraction = slider.TargetFraction
			slider:_refreshTrack()
		end)

		return slider
	end

	-- ── Notched Slider ───────────────────────────────────────────────────────

	function Window:_createNotchedSlider(tab, options)
		options = options or {}

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

		slider.Holder = createTextRow(parentColumn, slider.Name, rowHeight)
		slider.Holder.LayoutOrder = type(options.Order) == "number" and options.Order or 999

		slider.TitleLabel, slider.ValueLabel, slider.SubtextLabel =
			buildSliderTextRows(slider.Holder, slider.Name, subtext, hasSubtext)

		slider.TrackZone, slider.TrackBg, slider.TrackFill, slider.Thumb, slider.Hitbox =
			buildSliderTrack(slider.Holder, trackZoneTop, thumbRadius, trackInsetY)

		-- Build notch marks below the track zone
		local notchCount = math.floor((max - min) / step + 0.5) + 1
		local notchZone = Veil.Instance:Create("Frame", {
			Name = "NotchZone",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(thumbRadius, trackZoneTop + SliderThumbDiameter + 2),
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
				Size = UDim2.fromOffset(2, 4),
				ZIndex = 5,
				Parent = notchZone,
			})
		end

		function slider:_refreshTrack()
			local f = self.VisualFraction
			local trackW = self.TrackBg.AbsoluteSize.X
			self.TrackFill.Size = UDim2.new(f, 0, 1, 0)
			self.Thumb.Position = UDim2.fromOffset(thumbRadius + f * trackW, SliderThumbDiameter / 2)

			local disabled = self.Disabled
			self.TitleLabel.TextTransparency = disabled and 0.5 or 0
			if self.SubtextLabel then
				self.SubtextLabel.TextTransparency = disabled and 0.6 or 0.35
			end
			self.ValueLabel.TextTransparency = disabled and 0.6 or 0.25
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

		local dragging = false

		slider.Hitbox.InputBegan:Connect(function(input)
			if slider.Disabled then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			dragging = true
			slider.IsDragging = true
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
			end
		end))

		registerCleanup(self, RunService.Heartbeat:Connect(function()
			if math.abs(slider.TargetFraction - slider.VisualFraction) < 0.0005 then
				if slider.VisualFraction ~= slider.TargetFraction then
					slider.VisualFraction = slider.TargetFraction
					slider:_refreshTrack()
				end
				return
			end
			local alpha = slider.IsDragging and SliderDragLerpAlpha or SliderLerpAlpha
			slider.VisualFraction = slider.VisualFraction + (slider.TargetFraction - slider.VisualFraction) * alpha
			slider:_refreshTrack()
		end))

		slider:Set(default, { Instant = true, Silent = true })
		task.defer(function()
			slider.VisualFraction = slider.TargetFraction
			slider:_refreshTrack()
		end)

		return slider
	end

	-- ── Range Slider ─────────────────────────────────────────────────────────

	function Window:_createRangeSlider(tab, options)
		options = options or {}

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

		slider.Holder = createTextRow(parentColumn, slider.Name, rowHeight)
		slider.Holder.LayoutOrder = type(options.Order) == "number" and options.Order or 999

		slider.TitleLabel, slider.ValueLabel, slider.SubtextLabel =
			buildSliderTextRows(slider.Holder, slider.Name, subtext, hasSubtext)

		-- Track zone (no single thumb from buildSliderTrack — build manually for two thumbs)
		slider.TrackZone = Veil.Instance:Create("Frame", {
			Name = "TrackZone",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, trackZoneTop),
			Size = UDim2.new(1, 0, 0, SliderThumbDiameter),
			ZIndex = 5,
			Parent = slider.Holder,
		})

		slider.TrackBg = Veil.Instance:Create("Frame", {
			Name = "TrackBg",
			BackgroundColor3 = COLORS.ToggleOffBackground,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(thumbRadius, trackInsetY),
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
			Position = UDim2.fromOffset(thumbRadius, SliderThumbDiameter / 2),
			Size = UDim2.fromOffset(SliderThumbDiameter, SliderThumbDiameter),
			ZIndex = 7,
			Parent = slider.TrackZone,
		})
		createCorner(slider.LowThumb, thumbRadius)

		slider.HighThumb = Veil.Instance:Create("Frame", {
			Name = "HighThumb",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = COLORS.Accent,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(thumbRadius, SliderThumbDiameter / 2),
			Size = UDim2.fromOffset(SliderThumbDiameter, SliderThumbDiameter),
			ZIndex = 7,
			Parent = slider.TrackZone,
		})
		createCorner(slider.HighThumb, thumbRadius)

		slider.LowHitbox = Veil.Instance:Create("TextButton", {
			Name = "LowHitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(SliderThumbDiameter + 8, SliderThumbDiameter),
			Text = "",
			ZIndex = 8,
			Parent = slider.TrackZone,
		})

		slider.HighHitbox = Veil.Instance:Create("TextButton", {
			Name = "HighHitbox",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(SliderThumbDiameter + 8, SliderThumbDiameter),
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
			Size = UDim2.fromScale(1, 1),
			Text = "",
			ZIndex = 6,
			Parent = slider.TrackZone,
		})

		local function formatRange(lo, hi)
			local fmtLo = formatSliderValue(lo, step)
			local fmtHi = formatSliderValue(hi, step)
			return fmtLo .. " – " .. fmtHi
		end

		function slider:_refreshTrack()
			local lo = self.LowVisual
			local hi = self.HighVisual
			local trackW = self.TrackBg.AbsoluteSize.X

			local loCenterX = thumbRadius + lo * trackW
			local hiCenterX = thumbRadius + hi * trackW

			self.LowThumb.Position = UDim2.fromOffset(loCenterX, SliderThumbDiameter / 2)
			self.HighThumb.Position = UDim2.fromOffset(hiCenterX, SliderThumbDiameter / 2)

			-- Thumb hitbox positions (centered on thumbs, with extra grab zone)
			self.LowHitbox.Position = UDim2.fromOffset(loCenterX - (SliderThumbDiameter / 2 + 4), 0)
			self.HighHitbox.Position = UDim2.fromOffset(hiCenterX - (SliderThumbDiameter / 2 + 4), 0)

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

		registerCleanup(self, RunService.Heartbeat:Connect(function()
			local isDragging = slider.ActiveThumb ~= nil
			local alpha = isDragging and SliderDragLerpAlpha or SliderLerpAlpha
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

		return slider
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
			Size = UDim2.fromScale(1, 1),
			ZIndex = 240,
			Parent = self.Surface,
		})

		self.PickerBackdrop = Veil.Instance:Create("TextButton", {
			Name = "AxisPickerBackdrop",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			Visible = false,
			ZIndex = 242,
			Parent = self.PickerSurface,
		})

		self.PickerBackdrop.MouseButton1Click:Connect(function()
			if self.ActivePickerPopup then
				self.ActivePickerPopup.Visible = false
				self.ActivePickerPopup:SetAttribute("AxisOpen", false)
				self.ActivePickerPopup = nil
			end
			if self.ActiveModeMenu then
				self.ActiveModeMenu.Visible = false
				self.ActiveModeMenu = nil
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

		self.ActivePickerPopup = nil
		popup.Visible = false
		popup:SetAttribute("AxisOpen", false)

		if not self.ActiveModeMenu and self.PickerBackdrop then
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
			if entry.Wrapper then
				Veil.Instance:SecureDestroy(entry.Wrapper)
				entry.Wrapper = nil
				entry.Card = nil
			end
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

		self._overlayOrder = self._overlayOrder + 1

		local wrapper, card = createOverlayCard(host, config.Width, self._overlayOrder, 210)
		card.Position = UDim2.fromOffset(config.EnterOffset.X, config.EnterOffset.Y)

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

			animateOverlayCard(entry.Card, Vector2.zero, true)
		end)

		task.delay(math.max(0.5, tonumber(options.Duration) or (kind == "Toast" and 3.5 or 5)), function()
			if self.ActiveOverlays then
				self.ActiveOverlays[entry.Id] = nil
			end
			self:_destroyOverlayEntry(entry)
		end)

		return entry
	end

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

	function Axis:Toast(options)
		return self:_createOverlay("Toast", options)
	end

	function Axis:Notify(options)
		return self:_createOverlay("Notification", options)
	end

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
		self.ActiveModeMenu = nil
	end

	return Axis
end
