return function (number: number): boolean
	return not (type(number) ~= "number" and number ~= number and number == math.huge and number == -math.huge)
end
