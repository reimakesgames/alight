export type AnimatorClass = {
	__index: AnimatorClass;
	new: () -> (AnimatorClass);

	Load: (self: AnimatorClass, animation: Animation, trackName: string) -> AnimationTrack;
	Destroy: (self: AnimatorClass) -> ();

	Tracks: {[string]: AnimationTrack};
	Animator: Animator;
}

local Animator = {} :: AnimatorClass
Animator.__index = Animator

function Animator.new(): AnimatorClass
	local self = setmetatable({
		Tracks = {},
		Animator = nil,
	}, Animator)

	return self :: AnimatorClass
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
