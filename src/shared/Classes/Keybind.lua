local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local FastSignal = require(Packages.fastsignal)

export type KeybindClass = {
	Destroy: (self: KeybindClass) -> ();

	Name: string;
	Key: Enum.KeyCode | Enum.UserInputType;
	Signal: FastSignal.Class;
	Contexts: Array<string>
}

local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(): KeybindClass
	local self = setmetatable({
		Signal = FastSignal.new()
	}, Keybind)

	return self :: KeybindClass
end

function Keybind:Destroy()
	table.clear(self.Contexts)
	table.clear(self)
	print(self)
end

return Keybind :: { new: () -> ( KeybindClass ) }
