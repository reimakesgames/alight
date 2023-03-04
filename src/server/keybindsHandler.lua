local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Packages = ReplicatedStorage.Packages
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
		AltFire = IType(UserInputType.MouseButton2),
		Reload = KCode(KeyCode.R),
		Inspect = KCode(KeyCode.Y),
		Interact = KCode(KeyCode.F),

		Primary = KCode(KeyCode.One),
		Secondary = KCode(KeyCode.Two),
		Melee = KCode(KeyCode.Three),
		Spike = KCode(KeyCode.Four),

		Ping = KCode(KeyCode.Z),
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
			-- i forgot to add new _prop categories
			if keybinds[category] == nil then
				keybinds[category] = KEYBINDS_DEFAULT[category]
			end
			continue
		end
		if keybinds[category] == nil then
			keybinds[category] = KEYBINDS_DEFAULT[category]
		else
			UpdateMissingKeybindsInCategory(category, keybinds[category])
		end
	end
	return keybinds
end

-- this is a function that checks if the keybinds are malformed
-- you shouldn't be able to save malformed categories
-- this is just a safety measure to prevent illegal access to the data store
-- it's not a security measure, it's just a way to prevent the data store from being filled with garbage
-- there's nothing you can do with datastore access as an exploiter anyway
local function CheckKeybindsForMalformations(keybinds: { _exists: boolean, [string]: { [string]: number } })
	if keybinds._exists ~= true then
		return false
	end
	-- check if there's a new category in our keybinds, if there is then it's malformed
	for category, _ in pairs(keybinds) do
		if category:sub(1, 1) == "_" then
			-- check if there are things in the category that shouldn't be there
			-- especially because _prop is a valid category name, and will be saved to the datastore
			if KEYBINDS_DEFAULT[category] == nil then
				return false
			end
			continue
		end
		if KEYBINDS_DEFAULT[category] == nil then
			return false
		end
	end
	-- check if there's a new keybind in our keybinds, if there is then it's malformed
	for category, _ in pairs(KEYBINDS_DEFAULT) do
		if category:sub(1, 1) == "_" then
			continue
		end
		for keyName, _ in pairs(KEYBINDS_DEFAULT[category]) do
			if keybinds[category][keyName] == nil then
				return false
			end
		end
	end
	return true
end

local Server = {
	keybinds = {},
}

-- newKeybinds is optional, if it's nil then it will return the keybinds for the player
-- it's also a diff, so it only needs to contain the keybinds that need to be changed
GetKeybindsFromServer:OnInvoke(function(player: Player, newKeybinds: { _exists: boolean, [string]: { [string]: number } }?)
	if newKeybinds ~= nil then
		if not CheckKeybindsForMalformations(newKeybinds) then
			warn("Malformed keybinds!")
			return nil
		end
		Server.keybinds[player.UserId] = newKeybinds
		return true
	end
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
		if value == nil or (not value.exists) then
			KeybindsDataStore:SetAsync(player.UserId, KEYBINDS_DEFAULT)
			value = KEYBINDS_DEFAULT
		end
		Server.keybinds[player.UserId] = UpdateMissingKeybinds(value)
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
