local HttpService = game:GetService("HttpService")

local Util = {}

function Util.IsCallable(value)
	return type(value) == "function"
end

function Util.Try(callback, ...)
	if not Util.IsCallable(callback) then
		return false, "Expected callback to be a function"
	end

	return pcall(callback, ...)
end

function Util.TableShallowCopy(source)
	local copy = {}

	if type(source) ~= "table" then
		return copy
	end

	for key, value in pairs(source) do
		copy[key] = value
	end

	return copy
end

function Util.TableDeepCopy(source, seen)
	if type(source) ~= "table" then
		return source
	end

	seen = seen or {}
	if seen[source] then
		return seen[source]
	end

	local copy = {}
	seen[source] = copy

	for key, value in pairs(source) do
		copy[Util.TableDeepCopy(key, seen)] = Util.TableDeepCopy(value, seen)
	end

	return copy
end

function Util.Assign(target, ...)
	target = target or {}

	for index = 1, select("#", ...) do
		local source = select(index, ...)
		if type(source) == "table" then
			for key, value in pairs(source) do
				target[key] = value
			end
		end
	end

	return target
end

function Util.ClearTable(target)
	if type(target) ~= "table" then
		return target
	end

	for key in pairs(target) do
		target[key] = nil
	end

	return target
end

function Util.RandomString(length)
	length = math.max(1, tonumber(length) or 12)

	local characters = table.create(length)
	for index = 1, length do
		characters[index] = string.char(math.random(48, 122))
	end

	return table.concat(characters)
end

function Util.GenerateId(prefix)
	prefix = prefix or "id"

	local success, guid = pcall(HttpService.GenerateGUID, HttpService, false)
	if success and type(guid) == "string" then
		return string.format("%s_%s", prefix, guid:gsub("%-", ""))
	end

	return string.format("%s_%s", prefix, Util.RandomString(16))
end

return Util
