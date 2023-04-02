local function ValidateType(value, expectedType)
	if typeof(value) ~= expectedType then
		error(string.format("Expected type:%s, got:%s", expectedType, typeof(value)), 3)
	end
end

local boxCharacters = {
	topLeftCorner = "\xDA",
	topRightCorner = "\xBF",
	bottomLeftCorner = "\xC0",
	bottomRightCorner = "\xD9",

	verticalLine = "\xB3",
	horizontalLine = "\xC4",

	verticalLineRight = "\xC3",
	verticalLineLeft = "\xB4",
	horizontalLineUp = "\xC1",
	horizontalLineDown = "\xC2",

	cross = "\xC5",
}

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

local function boxCharactersLine(lineType, widths)
	local left, middle, right
	if lineType == "top" then
		left = boxCharacters.topLeftCorner
		middle = boxCharacters.horizontalLineDown
		right = boxCharacters.topRightCorner
	elseif lineType == "middle" then
		left = boxCharacters.verticalLineRight
		middle = boxCharacters.cross
		right = boxCharacters.verticalLineLeft
	elseif lineType == "bottom" then
		left = boxCharacters.bottomLeftCorner
		middle = boxCharacters.horizontalLineUp
		right = boxCharacters.bottomRightCorner
	end

	local line = left
	for i, width in pairs(widths) do
		line = line .. string.rep(boxCharacters.horizontalLine, width)
		if i ~= #widths then
			line = line .. middle
		end
	end
	line = line .. right .. "\n"

	return line
end

local function boxCharactersEntry(entries, widths)
	local line = boxCharacters.verticalLine
	for i, entry in entries do
		local width = widths[i]
		local padding = width - #tostring(entry)
		local leftPadding = math.floor(padding / 2)
		local rightPadding = padding - leftPadding

		line = line .. string.rep(" ", leftPadding) .. entry .. string.rep(" ", rightPadding) .. boxCharacters.verticalLine
	end

	return line .. "\n"
end

function tableOperations:PrintArray(array)
	ValidateType(array, "table")
	local headers = {"(index)", "Values"}

	local arrayString = "\n"

	-- find the widest entry in a column
	local indexWidth, valueWidth = headers[1]:len(), headers[2]:len()
	for index, value in array do
		if #tostring(index) > indexWidth then
			indexWidth = #tostring(index)
		end
		if #tostring(value) > valueWidth then
			valueWidth = #tostring(value)
		end
	end

	indexWidth = indexWidth + 2
	valueWidth = valueWidth + 2
	arrayString = arrayString .. boxCharactersLine("top", {indexWidth, valueWidth})
	arrayString = arrayString .. boxCharactersEntry(headers, {indexWidth, valueWidth})
	arrayString = arrayString .. boxCharactersLine("middle", {indexWidth, valueWidth})
	for index, value in array do
		arrayString = arrayString .. boxCharactersEntry({index, value}, {indexWidth, valueWidth})
	end
	arrayString = arrayString .. boxCharactersLine("bottom", {indexWidth, valueWidth})

	print(arrayString)
end

return tableOperations
