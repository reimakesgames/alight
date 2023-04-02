local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared
local BridgeNet = require(Packages.BridgeNet)
BridgeNet.Start({})

local function Initialize(module: ModuleScript)
	task.spawn(function()
		require(module).init()
	end)
end

Initialize(script.performance)
Initialize(script.changelogs)
Initialize(script.activity)
require(script.keybindsHandler)
require(Shared.mapPing)

local HitboxTracker = require(Shared.hitboxTimetravel.HitboxTracker)

Players.PlayerAdded:Connect(function(player)
	if player.Character then
		HitboxTracker.new(0.2, player.Character)
	end
	player.CharacterAdded:Connect(function(newCharacter)
		HitboxTracker.new(0.2, newCharacter)
	end)
end)
