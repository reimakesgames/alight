local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local BridgeNet = require(Packages.BridgeNet)
local GetPing = BridgeNet.CreateBridge("GetPing")

local performance = {}

function performance.init()
	GetPing:OnInvoke(function()
		return
	end)
end

return performance
