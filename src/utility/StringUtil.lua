local StringUtil = {}

function StringUtil.UppercaseFirstLetter(str: string)
	return string.upper(str:sub(1, 1)) .. str:sub(2, -1)
end

return StringUtil
