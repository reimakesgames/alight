local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local bridgenet = require(Packages.bridgenet)
local Profile = require(Shared.Profile)

local GetProfile = bridgenet.CreateBridge("GetProfile")

GetProfile:OnInvoke(function(player)
	local profile = Profile.new(player.UserId)
	return profile:Load()
end)

return true
