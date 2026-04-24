local Protection = {}
Protection.__index = Protection

local function resolveProtectGui()
	if type(protectgui) == "function" then
		return protectgui
	end

	if type(protect_gui) == "function" then
		return protect_gui
	end

	if type(syn) == "table" and type(syn.protect_gui) == "function" then
		return syn.protect_gui
	end

	return nil
end

function Protection.new()
	return setmetatable({}, Protection)
end

function Protection:GetHandler()
	return resolveProtectGui()
end

function Protection:Apply(instance)
	local handler = self:GetHandler()
	if not handler or not instance then
		return false
	end

	local success = pcall(handler, instance)
	return success
end

return Protection
