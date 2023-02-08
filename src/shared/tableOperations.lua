local tableOperations = {}

function tableOperations:DeepCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		if typeof(value) == "table" then
			copy[key] = self:DeepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

return tableOperations
