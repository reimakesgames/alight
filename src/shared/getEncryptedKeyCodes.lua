local function filledKeyCodeEnumItems()
	-- there are literally missing values in the KeyCode enum
	-- causing horrifying bugs
	-- so we have to manually fill it since we can't rely on the enum
	local result = table.create(1017)
	for _, name in Enum.KeyCode:GetEnumItems() do
		result[name.Value] = name
	end
	return result
end
local function filledUserInputTypeEnumItems()
	-- there are literally missing values in the UserInputType enum
	-- causing horrifying bugs
	-- so we have to manually fill it since we can't rely on the enum
	local result = table.create(22)
	for _, name in Enum.UserInputType:GetEnumItems() do
		result[name.Value] = name
	end
	return result
end
local KeyCodeEnumItems = filledKeyCodeEnumItems()
local UserInputTypeEnumItems = filledUserInputTypeEnumItems()

return function (keybind: number): Enum.KeyCode | Enum.UserInputType
	-- if the keybind is a KeyCode, it will be 100 + the KeyCode's value
	-- if the keybind is a UserInputType, it will be the UserInputType's value
	if keybind >= 100 then
		return KeyCodeEnumItems[keybind - 100]
	else
		return UserInputTypeEnumItems[keybind]
	end
end
