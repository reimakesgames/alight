local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Link = require(Packages:WaitForChild("link"))
local GetPing = Link:CreateFunction("GetPing")
GetPing:OnServerInvoke(function()
	return
end)
