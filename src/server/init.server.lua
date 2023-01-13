local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local BridgeNet = require(Packages.BridgeNet)
BridgeNet.Start({})

local function Initialize(module: ModuleScript)
	task.spawn(function()
		require(module).init()
	end)
end

Initialize(script.performance)
Initialize(script.changelogs)
require(script.keybindsHandler)
