-- return function (number: number): boolean
-- 	local isNumberType = type(number) == "number"
-- 	local isNotNaN = (number == number)
-- 	local isNotPositiveInf = not (number == math.huge)
-- 	local isNotNegativeInf = not (number == -math.huge)
-- 	return isNumberType and isNotNaN and isNotPositiveInf and isNotNegativeInf
-- end

return function (number: number): boolean
	return (type(number) == "number") and (number == number) and (not (number == math.huge)) and (not (number == -math.huge))
end
