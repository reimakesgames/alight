local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared
local BridgeNet = require(Packages.BridgeNet)
local Promise = require(Packages.Promise)
local PromiseType = require(Shared.PromiseType)
local getEncryptedKeyCodes = require(Shared.getEncryptedKeyCodes)
local GetKeybindsFromServer = BridgeNet.CreateBridge("GetKeybindsFromServer")

local function FixKeybinds(keybinds: { [string]: { [string]: number } })
	print(keybinds)
	local fixedKeybinds = {}
	for category, keybind in pairs(keybinds) do
		-- if the first letter of the category is _ then it's a private category, or a property of the keybinds table
		if category:sub(1, 1) == "_" then
			continue
		end
		for name, key in pairs(keybind) do
			print(category, name, key)
			print(getEncryptedKeyCodes(key))
			if fixedKeybinds[category] == nil then
				fixedKeybinds[category] = {}
			end
			fixedKeybinds[category][name] = getEncryptedKeyCodes(key)
		end
	end
	return fixedKeybinds
end

local Client = {
	keybinds = {} :: { [string]: { [string]: number } },
}

function Client:RegisterKeybind(key: Enum.KeyCode | Enum.UserInputType, name: string, category: string)
	assert(typeof(key) == "EnumItem", "key must be an EnumItem")
	assert(typeof(name) == "string", "name must be a string")
	assert(typeof(category) == "string", "category must be a string")
	if self.keybinds[category] == nil then
		self.keybinds[category] = {}
	end
	self.keybinds[category][name] = key
end

function Client:GetKeybind(name: string, category: string): (Enum.KeyCode | Enum.UserInputType)?
	assert(typeof(name) == "string", "name must be a string")
	assert(typeof(category) == "string", "category must be a string")
	if self.keybinds[category] == nil then
		warn(`Category "${category}" does not exist`)
		return nil
	end
	if self.keybinds[category][name] == nil then
		warn(`Keybind "${name}" in category "${category}" does not exist`)
		return nil
	end
	return self.keybinds[category][name]
end

function Client:LoadKeybindsFromServer()
	GetKeybindsFromServer:InvokeServer():andThen(function(value)
		value = FixKeybinds(value)
		self.keybinds = value
	end)
end

return Client
