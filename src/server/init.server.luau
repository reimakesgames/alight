local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local bridgenet = require(Packages.bridgenet)
bridgenet.Start({})

require(script.ProfileServer)
