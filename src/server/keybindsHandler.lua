local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared
local BridgeNet = require(Packages.BridgeNet)
local GetKeybindsFromServer = BridgeNet.CreateBridge("GetKeybindsFromServer")

local KeyCode = Enum.KeyCode
local UserInputType = Enum.UserInputType

local KeybindsDataStore = DataStoreService:GetDataStore("Keybinds")

-- why is this here?
-- because roblox is stupid and doesn't allow you to use Enum.KeyCode in a DataStore, so we have to convert it to a number
-- add 100 to the value of KeyCode to avoid conflicts with UserInputType
local function KCode(key: Enum.KeyCode): number
	return key.Value + 100
end

-- same goes for UserInputType
local function IType(key: Enum.UserInputType): number
	return key.Value
end

local KEYBINDS_DEFAULT = {
	_exists = true,
	Gameplay = {
		Walk = KCode(KeyCode.LeftShift),
		Crouch = KCode(KeyCode.LeftControl),

		Fire = IType(UserInputType.MouseButton1),
		Reload = KCode(KeyCode.R),
		Inspect = KCode(KeyCode.Y),
		Interact = KCode(KeyCode.F),

		Primary = KCode(KeyCode.One),
		Secondary = KCode(KeyCode.Two),
		Melee = KCode(KeyCode.Three),
		Spike = KCode(KeyCode.Four),
	}
}

local function UpdateMissingKeybinds(keybinds: { _exists: boolean, [string]: { [string]: number } })
	local function UpdateMissingKeybindsInCategory(name, category: { [string]: number })
		for keyName, key in pairs(KEYBINDS_DEFAULT[name]) do
			if category[keyName] == nil then
				category[keyName] = key
			end
		end
	end
	for category, _ in pairs(KEYBINDS_DEFAULT) do
		if category:sub(1, 1) == "_" then
			continue
		end
		if keybinds[category] == nil then
			keybinds[category] = KEYBINDS_DEFAULT[category]
		else
			UpdateMissingKeybindsInCategory(category, keybinds[category])
		end
	end
end

local Server = {
	keybinds = {},
}

GetKeybindsFromServer:OnInvoke(function(player: Player)
	while Server.keybinds[player.UserId] == nil do
		task.wait(0.5)
	end
	return Server.keybinds[player.UserId]
end)

Players.PlayerAdded:Connect(function(player: Player)
	local success, value = pcall(function()
		return KeybindsDataStore:GetAsync(player.UserId)
	end)
	if success then
		if (not value.exists) or value == nil then
			KeybindsDataStore:SetAsync(player.UserId, KEYBINDS_DEFAULT)
			value = KEYBINDS_DEFAULT
		end
		UpdateMissingKeybinds(value)
		Server.keybinds[player.UserId] = value
	else
		warn(`Failed to load keybinds for {player.Name} ({player.UserId})!`)
		warn(value)
		-- ! TODO: add a webhook to send this to discord
		-- ! Possibly create a ticket system for this or an error code system
		-- ! so that the user can send the error code to the devs
		local keybinds = KEYBINDS_DEFAULT
		keybinds._canSave = false
		Server.keybinds[player.UserId] = keybinds
	end
end)

Players.PlayerRemoving:Connect(function(player: Player)
	if Server.keybinds[player.UserId] == nil then
		return
	end
	if Server.keybinds[player.UserId]._canSave == false then
		warn("User had issues loading keybinds, not saving to prevent data loss.")
		-- ! TODO: add a webhook to send this to discord
		-- ! Possibly create a ticket system for this or an error code system
		-- ! so that the user can send the error code to the devs
		return
	end
	KeybindsDataStore:SetAsync(player.UserId, Server.keybinds[player.UserId])
	Server.keybinds[player.UserId] = nil
end)

return Server
