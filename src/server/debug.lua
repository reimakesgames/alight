local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local BridgeNet = require(Packages.BridgeNet)
local GetPing = BridgeNet.CreateBridge("GetPing")

local debug = {}

function debug.init()
	GetPing:OnInvoke(function()
		return
	end)
end

return debug
