local Dependencies = {}

local toolkitCache

function Dependencies.GetToolkit()
	if toolkitCache then
		return toolkitCache
	end

	local cursor = script.Parent
	while cursor do
		local siblingToolkit = cursor:FindFirstChild("Toolkit")
		if siblingToolkit and siblingToolkit:FindFirstChild("src") then
			toolkitCache = require(siblingToolkit.src)
			return toolkitCache
		end

		cursor = cursor.Parent
	end

	error("[Veil] Unable to locate Toolkit")
end

return Dependencies
