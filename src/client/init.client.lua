local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage.Packages
local BridgeNet = require(Packages.BridgeNet)
BridgeNet.Start({})

UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

-- local function Initialize(module: ModuleScript)
-- 	task.spawn(function()
-- 		require(module).init()
-- 	end)
-- end

-- Initialize(script.performance)
-- Initialize(script.changelogs)
-- Initialize(script.movementHandler)
-- Initialize(script.combatSystem)

local Scene = require(ReplicatedStorage.Shared.Scene)
local NewScene = Scene.new(workspace.World)

NewScene:RunScene(true)
