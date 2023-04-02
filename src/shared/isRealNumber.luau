-- return function(number: number?)
-- 	local isNumber = typeof(number) == "number"
-- 	local isFinite = isNumber and number ~= math.huge and number ~= -math.huge
-- 	local isReal = isFinite and number == number
-- 	return isReal
-- end

-- simplify
return function(number)
	-- return true if number is a number, not infinite, and not NaN
	return typeof(number) == "number" and number ~= math.huge and number ~= -math.huge and number == number
end
