local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage.Shared
local Classes = Shared.Classes

local Keybind = require(Classes.Keybind)

export type InputHandler = {

}

local States = {}

local ActiveKeys: {[Enum.KeyCode | Enum.UserInputType]: {[number]: Keybind.KeybindClass}} = {}

local InputHandler = {}
InputHandler.__index = InputHandler

function InputHandler:CreateCommand(name: string, context: {[number]: string})
	local keybind = Keybind.new()
	keybind.Name = name
	keybind.Contexts = context
	local command = setmetatable(keybind, InputHandler)
	if not ActiveKeys[keybind.Key] then
		ActiveKeys[keybind.Key] = {}
	end
	table.insert(ActiveKeys[keybind.Key], command)
	return command
end

UserInputService.InputBegan:Connect(function(input, _)
	local activeKey = ActiveKeys[input.KeyCode] or ActiveKeys[input.UserInputType]
	if not (typeof(activeKey) == "table" and #activeKey > 0) then
		return
	end

	for _, keybind in activeKey do
		for _, context in keybind.Contexts do
			if not States[context] then
				continue
			end
			keybind.Signal:Fire()
		end
	end
end)

return InputHandler
