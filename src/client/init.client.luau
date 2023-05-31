local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local bridgenet = require(Packages.bridgenet)
bridgenet.Start({})

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Profile = require(script.ProfileClient):GenerateProfile()
Profile.Parent = PlayerGui
