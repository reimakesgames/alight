local function ValidateType(value, expectedType)
	if typeof(value) ~= expectedType then
		error(string.format("Expected type:%s, got:%s", expectedType, typeof(value)), 3)
	end
end

local tableOperations = {}

function tableOperations:DeepCopy(original, copyMetatable: boolean?)
	ValidateType(original, "table")
	local copy = {}
	for key, value in pairs(original) do
		if typeof(value) == "table" then
			copy[key] = self:DeepCopy(value)
		else
			copy[key] = value
		end
	end
	if copyMetatable then
		setmetatable(copy, tableOperations:DeepCopy(getmetatable(original)))
	end
	return copy
end

return tableOperations
