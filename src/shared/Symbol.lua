local symbols = {}

local function Symbol(name)
	if symbols[name] then
		return symbols[name]
	end
	local symbol = newproxy(true)
	local mt = getmetatable(symbol)
	mt.__tostring = function()
		return "Symbol(" .. name .. ")"
	end
	mt.__metatable = "The metatable is locked"
	symbols[name] = symbol
	return symbol
end

return Symbol
