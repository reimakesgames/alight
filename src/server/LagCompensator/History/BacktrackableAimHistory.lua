local InterpolationQueue = require(script.Parent.Parent.InterpolationQueue.InterpolationQueue)
local BacktrackableAimHistory = {}
BacktrackableAimHistory.__index = BacktrackableAimHistory
function BacktrackableAimHistory.new(...)
	local self = setmetatable({}, BacktrackableAimHistory)
	self:constructor(...)
	return self
end
function BacktrackableAimHistory:constructor(cframeEvent, maxsize)
	self.history = InterpolationQueue.new(maxsize)
	cframeEvent.Event:Connect(self.Append)
end
function BacktrackableAimHistory:Append(from, target)
	print("Appending")
	self.history:Append(CFrame.new(from, target), game.Workspace.DistributedGameTime)
end
function BacktrackableAimHistory:BacktrackAim(bySeconds)
	self.history:InterpolateAtTime(game.Workspace.DistributedGameTime - bySeconds)
end

return BacktrackableAimHistory
