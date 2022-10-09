export type AnimatorClass = {
	Load: (self: AnimatorClass, animation: Animation, trackName: string) -> AnimationTrack;
	Destroy: (self: AnimatorClass) -> ();

	Tracks: Dictionary<AnimationTrack>;
	Animator: Animator;
}

local Animator = {}
Animator.__index = Animator

function Animator.new(): AnimatorClass
	local self = setmetatable({
		Tracks = {},
		Animator = nil,
	}, Animator)

	return self
end

function Animator:Load(animation: Animation, trackName: string)
	local animationTrack = self.Animator:LoadAnimation(animation)
	self.Tracks[trackName] = animationTrack
	return animationTrack
end

function Animator:Destroy()
	table.clear(self.Tracks)
	table.clear(self)
end

return Animator :: {
	new: () -> AnimatorClass
}