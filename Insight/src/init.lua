-- Insight — ESP module for STRATA-V1
-- Loadable via: loadstring(game:HttpGet(url))()(Toolkit, Veil)
-- Architecture mirrors MSESP: per-entity ESP objects updated on Heartbeat.
-- All instance creation goes through Veil.Instance:Create.
-- All service access goes through Veil.Services:Get.
return function(Toolkit, Veil)
	assert(type(Veil) == "table", "[Insight] Veil dependency required")
	assert(type(Veil.Instance) == "table", "[Insight] Veil.Instance required")
	assert(type(Veil.GUI) == "table", "[Insight] Veil.GUI required")

	local RunService    = Veil.Services:Get("RunService")
	local PlayersService = Veil.Services:Get("Players")
	local WorkspaceService = Veil.Services:Get("Workspace") or workspace

	-- ESP render config. Modified only via Insight:Configure.
	local _config = {
		ShowBox        = true,
		ShowName       = true,
		ShowDistance   = true,
		BoxColor       = Color3.fromRGB(255, 255, 255),
		BoxTransparency = 0,
		NameColor      = Color3.fromRGB(255, 255, 255),
		DistanceColor  = Color3.fromRGB(200, 200, 200),
		MaxDistance    = 1000,
		LineThickness  = 1,
	}

	local _state = {
		Active      = false,
		Surface     = nil,
		ESPObjects  = {},   -- [Player] → esp object
		HBConn      = nil,
		AddedConn   = nil,
		RemovedConn = nil,
	}

	local HALF_H = 3.0   -- HumanoidRootPart → top of head (R6)
	local HALF_W = 1.0   -- HRP → left/right
	local HALF_D = 0.6   -- HRP → front/back (thin for box fit)
	local NAME_Y_OFFSET = -18
	local DIST_Y_OFFSET = 4

	local function getCamera()
		return WorkspaceService.CurrentCamera
	end

	-- Projects character's AABB corners to screen; returns minX,minY,maxX,maxY or nil.
	local function charScreenBounds(character)
		local hrp = character:FindFirstChildOfClass("HumanoidRootPart")
		if not hrp then return nil end
		local camera = getCamera()
		if not camera then return nil end

		local cf = hrp.CFrame
		local h, w, d = HALF_H, HALF_W, HALF_D
		local corners = {
			cf * CFrame.new(-w,  h, -d), cf * CFrame.new(w,  h, -d),
			cf * CFrame.new(-w,  h,  d), cf * CFrame.new(w,  h,  d),
			cf * CFrame.new(-w, -h, -d), cf * CFrame.new(w, -h, -d),
			cf * CFrame.new(-w, -h,  d), cf * CFrame.new(w, -h,  d),
		}

		local minX, minY = math.huge, math.huge
		local maxX, maxY = -math.huge, -math.huge

		for _, corner in ipairs(corners) do
			local sp = camera:WorldToViewportPoint(corner.Position)
			if sp.Z <= 0 then return nil end
			if sp.X < minX then minX = sp.X end
			if sp.Y < minY then minY = sp.Y end
			if sp.X > maxX then maxX = sp.X end
			if sp.Y > maxY then maxY = sp.Y end
		end

		return minX, minY, maxX, maxY
	end

	-- Creates all UI elements for one player's ESP.
	local function createESP(player)
		if not _state.Surface then return end

		local t = _config.LineThickness
		local container = Veil.Instance:Create("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 5,
			Parent = _state.Surface,
		})

		local function makeLine()
			return Veil.Instance:Create("Frame", {
				BackgroundColor3 = _config.BoxColor,
				BackgroundTransparency = _config.BoxTransparency,
				BorderSizePixel = 0,
				ZIndex = 6,
				Visible = false,
				Parent = container,
			})
		end

		local function makeLabel(font, size, textColor)
			return Veil.Instance:Create("TextLabel", {
				BackgroundTransparency = 1,
				TextColor3 = textColor,
				Font = font,
				TextSize = size,
				TextStrokeTransparency = 0.5,
				TextStrokeColor3 = Color3.new(0, 0, 0),
				ZIndex = 7,
				Visible = false,
				Parent = container,
			})
		end

		local obj = {
			Container   = container,
			BoxTop      = makeLine(),
			BoxBottom   = makeLine(),
			BoxLeft     = makeLine(),
			BoxRight    = makeLine(),
			NameLabel   = makeLabel(Enum.Font.GothamBold, 12, _config.NameColor),
			DistLabel   = makeLabel(Enum.Font.Gotham, 10, _config.DistanceColor),
		}

		obj.NameLabel.Text = player.DisplayName or player.Name

		function obj:_hideAll()
			self.BoxTop.Visible    = false
			self.BoxBottom.Visible = false
			self.BoxLeft.Visible   = false
			self.BoxRight.Visible  = false
			self.NameLabel.Visible = false
			self.DistLabel.Visible = false
		end

		function obj:Update()
			local character = player.Character
			if not character then self:_hideAll(); return end

			local localPlayer = PlayersService.LocalPlayer
			local localHRP = localPlayer
				and localPlayer.Character
				and localPlayer.Character:FindFirstChildOfClass("HumanoidRootPart")
			local charHRP = character:FindFirstChildOfClass("HumanoidRootPart")
			if not charHRP then self:_hideAll(); return end

			local dist = localHRP and (charHRP.Position - localHRP.Position).Magnitude or 0
			if _config.MaxDistance > 0 and dist > _config.MaxDistance then
				self:_hideAll(); return
			end

			local minX, minY, maxX, maxY = charScreenBounds(character)
			if not minX then self:_hideAll(); return end

			local width  = maxX - minX
			local height = maxY - minY
			local cx = minX + width * 0.5

			-- Box
			if _config.ShowBox then
				self.BoxTop.Position    = UDim2.new(0, minX,      0, minY)
				self.BoxTop.Size        = UDim2.new(0, width,     0, t)
				self.BoxBottom.Position = UDim2.new(0, minX,      0, maxY - t)
				self.BoxBottom.Size     = UDim2.new(0, width,     0, t)
				self.BoxLeft.Position   = UDim2.new(0, minX,      0, minY)
				self.BoxLeft.Size       = UDim2.new(0, t,         0, height)
				self.BoxRight.Position  = UDim2.new(0, maxX - t,  0, minY)
				self.BoxRight.Size      = UDim2.new(0, t,         0, height)
				self.BoxTop.Visible    = true
				self.BoxBottom.Visible = true
				self.BoxLeft.Visible   = true
				self.BoxRight.Visible  = true
			else
				self.BoxTop.Visible    = false
				self.BoxBottom.Visible = false
				self.BoxLeft.Visible   = false
				self.BoxRight.Visible  = false
			end

			-- Name
			if _config.ShowName then
				self.NameLabel.Position = UDim2.new(0, cx - 60, 0, minY + NAME_Y_OFFSET)
				self.NameLabel.Size     = UDim2.new(0, 120, 0, 16)
				self.NameLabel.Visible  = true
			else
				self.NameLabel.Visible = false
			end

			-- Distance
			if _config.ShowDistance then
				self.DistLabel.Text     = math.floor(dist) .. "m"
				self.DistLabel.Position = UDim2.new(0, cx - 40, 0, maxY + DIST_Y_OFFSET)
				self.DistLabel.Size     = UDim2.new(0, 80, 0, 14)
				self.DistLabel.Visible  = true
			else
				self.DistLabel.Visible = false
			end
		end

		function obj:Remove()
			Veil.Instance:SecureDestroy(self.Container)
		end

		_state.ESPObjects[player] = obj
	end

	local function removeESP(player)
		local obj = _state.ESPObjects[player]
		if obj then
			pcall(obj.Remove, obj)
			_state.ESPObjects[player] = nil
		end
	end

	local function trackPlayer(player)
		if player == PlayersService.LocalPlayer then return end
		createESP(player)
	end

	local function updateAll()
		for _, obj in pairs(_state.ESPObjects) do
			pcall(obj.Update, obj)
		end
	end

	local Insight = {}
	Insight.__index = Insight

	function Insight:Enable()
		if _state.Active then return end
		_state.Active = true

		_state.Surface = Veil.GUI:CreateSurface("InsightESP")

		for _, p in ipairs(PlayersService:GetPlayers()) do
			trackPlayer(p)
		end

		_state.AddedConn   = PlayersService.PlayerAdded:Connect(trackPlayer)
		_state.RemovedConn = PlayersService.PlayerRemoving:Connect(removeESP)
		_state.HBConn      = RunService.Heartbeat:Connect(updateAll)
	end

	function Insight:Disable()
		if not _state.Active then return end
		_state.Active = false

		if _state.HBConn      then _state.HBConn:Disconnect();      _state.HBConn      = nil end
		if _state.AddedConn   then _state.AddedConn:Disconnect();   _state.AddedConn   = nil end
		if _state.RemovedConn then _state.RemovedConn:Disconnect(); _state.RemovedConn = nil end

		for player in pairs(_state.ESPObjects) do
			removeESP(player)
		end

		if _state.Surface then
			Veil.Instance:SecureDestroy(_state.Surface)
			_state.Surface = nil
		end
	end

	-- Applies config overrides and propagates color changes to live ESP objects.
	function Insight:Configure(options)
		if type(options) ~= "table" then return end
		for k, v in pairs(options) do
			if _config[k] ~= nil then _config[k] = v end
		end
		for _, obj in pairs(_state.ESPObjects) do
			if obj.BoxTop then
				for _, line in ipairs({ obj.BoxTop, obj.BoxBottom, obj.BoxLeft, obj.BoxRight }) do
					line.BackgroundColor3      = _config.BoxColor
					line.BackgroundTransparency = _config.BoxTransparency
				end
				obj.NameLabel.TextColor3 = _config.NameColor
				obj.DistLabel.TextColor3 = _config.DistanceColor
			end
		end
	end

	-- Protect public API: wrap Lua closures → C closures, lock metatable.
	local function _wrapIfLua(fn)
		if type(newcclosure) ~= "function" then return fn end
		local ok, w = pcall(newcclosure, fn)
		return (ok and w) or fn
	end

	for k, v in pairs(Insight) do
		if type(v) == "function" then rawset(Insight, k, _wrapIfLua(v)) end
	end
	rawset(Insight, "__metatable", "locked")
	if type(setreadonly) == "function" then pcall(setreadonly, Insight, true) end

	return Insight
end
