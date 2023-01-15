local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
require(script.keybindsHandler)
require(Shared.mapPing)
