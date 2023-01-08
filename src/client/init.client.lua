local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local BridgeNet = require(Packages.BridgeNet)
BridgeNet.Start({})

require(script.performance).init()
require(script.changelogs).init()