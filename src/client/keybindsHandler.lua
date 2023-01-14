local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared
local BridgeNet = require(Packages.BridgeNet)
local getEncryptedKeyCodes = require(Shared.getEncryptedKeyCodes)
local diffTool = require(Shared.diffTool)
local GetKeybindsFromServer = BridgeNet.CreateBridge("GetKeybindsFromServer")

local function KCode(key: Enum.KeyCode): number
	return key.Value + 100
end

local function IType(key: Enum.UserInputType): number
	return key.Value
end

local function DeserializeKeybinds(keybinds: { [string]: { [string]: number } })
	local fixedKeybinds = {}
	for category, keybind in pairs(keybinds) do
		-- if the first letter of the category is _ then it's a private category, or a property of the keybinds table
		if category:sub(1, 1) == "_" then
			continue
		end
		for name, key in pairs(keybind) do
			if fixedKeybinds[category] == nil then
				fixedKeybinds[category] = {}
			end
			fixedKeybinds[category][name] = getEncryptedKeyCodes(key)
		end
	end
	return fixedKeybinds
end

local Client = {
	keybindsYouLoadedWith = {} :: { [string]: { [string]: number } },
	numberedKeybinds = {} :: { [string]: { [string]: number } },
	Keybinds = {} :: { [string]: { [string]: Enum.UserInputType & Enum.KeyCode } },
}

local function RefreshKeybinds()
	Client.Keybinds = DeserializeKeybinds(Client.numberedKeybinds)
end

function Client:UpdateKeybind(key: Enum.KeyCode | Enum.UserInputType, name: string, category: string)
	assert(typeof(key) == "EnumItem", "key must be an EnumItem")
	assert(typeof(name) == "string", "name must be a string")
	assert(typeof(category) == "string", "category must be a string")
	-- convert the key to a number

	if Client.numberedKeybinds[category] == nil then
		Client.numberedKeybinds[category] = {}
	end
	local numberifiedKeyOrWhateverThisCodeSucks
	if typeof(key) == "EnumItem" then
		if key.EnumType == Enum.KeyCode then
			numberifiedKeyOrWhateverThisCodeSucks = KCode(key :: Enum.KeyCode)
		elseif key.EnumType == Enum.UserInputType then
			numberifiedKeyOrWhateverThisCodeSucks = IType(key :: Enum.UserInputType)
		end
	end
	Client.numberedKeybinds[category][name] = numberifiedKeyOrWhateverThisCodeSucks
	RefreshKeybinds()
end

function Client:GetKeybind(name: string, category: string): (Enum.KeyCode | Enum.UserInputType)?
	assert(typeof(name) == "string", "name must be a string")
	assert(typeof(category) == "string", "category must be a string")
	if Client.Keybinds[category] == nil then
		warn(`Category "${category}" does not exist`)
		return nil
	end
	if Client.Keybinds[category][name] == nil then
		warn(`Keybind "${name}" in category "${category}" does not exist`)
		return nil
	end
	return Client.Keybinds[category][name]
end

function Client:LoadKeybindsFromServer()
	GetKeybindsFromServer:InvokeServer():andThen(function(value)
		Client.numberedKeybinds = value
		Client.keybindsYouLoadedWith = value
		print(value)
		RefreshKeybinds()
	end):catch(function(err)
		warn("Failed to load keybinds from server")
		warn(err)
	end)
end

function Client:SaveKeybindsToServer()
	local keybindsDiff = diffTool:tableDiff(Client.keybindsYouLoadedWith, Client.numberedKeybinds, 2)
	print(keybindsDiff)
	if next(keybindsDiff) == nil then
		print("Keybinds are the same as the ones you loaded with, not saving")
		return
	end
	GetKeybindsFromServer:InvokeServer(keybindsDiff):andThen(function(result)
		if result == false then
			warn("Failed to save keybinds to server")
		elseif result == nil then
			warn("Failed to save keybinds to server, Your keybinds are malformed.")
		elseif result == true then
			print("Saved keybinds to server")
			Client.keybindsYouLoadedWith = Client.numberedKeybinds
			RefreshKeybinds()
		end
	end):catch(function(err)
		warn("Failed to save keybinds to server")
		warn(err)
	end)
end

return Client
