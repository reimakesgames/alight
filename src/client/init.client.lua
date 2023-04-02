local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local debug = PlayerGui:WaitForChild("debug")
local frame = debug:WaitForChild("Frame")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local BridgeNet = require(Packages.BridgeNet)
local fastInstance = require(Shared.fastInstance)

local clickedPlay = fastInstance("BindableEvent", {
	Name = "ClickedPlay",
	Parent = script,
})

-- this is a temporary solution to the problem of the game not being able to be played due to the menu screen

BridgeNet.Start({})

local function Initialize(module: ModuleScript)
	task.spawn(function()
		require(module).init()
	end)
end

clickedPlay.Event:Connect(function()
	Initialize(script.performance)
	Initialize(script.changelogs)
	Initialize(script.movementHandler)
	Initialize(script.combatSystem)
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end)

RunService.Stepped:Connect(function(totalTime: number)
	frame.BackgroundColor3 = Color3.new(0, math.floor((totalTime * 2) % 2), 0)
end)
