local ServerScriptService = game:GetService("ServerScriptService")
local BacktrackableHitboxCFrame = require(ServerScriptService:WaitForChild("Server"):WaitForChild("LagCompensator"):WaitForChild("History"):WaitForChild("BacktrackableHitboxCFrame"))
local FRAME_COUNT = 30;
return BacktrackableHitboxCFrame.new(script.Parent, FRAME_COUNT)
