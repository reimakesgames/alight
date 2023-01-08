local isRealNumber = require(script.Parent.isRealNumber)

export type Type = {
	__index: Type;
	new: () -> (Type);
	Destroy: (self: Type) -> ();
	IsA: (self: Type, className: string) -> boolean;

	LoadAnimation: (self: Type, trackName: string, animation: Animation, properties: {
		animationPriority: Enum.AnimationPriority?,
		looped: boolean?,
	}) -> AnimationTrack;
	PlayAnimation: (self: Type, trackName: string, properties: {
		playSpeed: number?,
		playAtTime: number?,
		weight: number?,
		weightFade: number?,
		playReversed: boolean?,
	}) -> ();
	PauseAnimation: (self: Type, trackName: string) -> ();
	ResumeAnimation: (self: Type, trackName: string, newSpeed: number?) -> ();
	StopAnimation: (self: Type, trackName: string, properties: {
		weightFade: number?,
		forceStop: boolean?,
	}) -> ();

	AdjustWeight: (self: Type, trackName: string, weight: number) -> ();
	AdjustSpeed: (self: Type, trackName: string, speed: number) -> ();
	AdjustTimePosition: (self: Type, trackName: string, timePosition: number) -> ();

	Tracks: {[string]: AnimationTrack};
	_PauseList: {[string]: number};
	Animator: Animator;
}

local CLASS_NAME = "AnimatorClass"
local Animator = {} :: Type
Animator.__index = Animator

local function hasAnimator(self: Type)
	assert(self.Animator, "Animator not set")
end

function Animator.new()
	local self = setmetatable({
		Tracks = {},
		_PauseList = {},
		Animator = nil,
	}, Animator)

	return self
end

function Animator:Destroy()
	table.clear(self.Tracks)
	table.clear(self)
end

function Animator:IsA(className)
	return className == CLASS_NAME
end

function Animator:SetAnimator(animator)
	self.Animator = animator
end

function Animator:LoadAnimation(trackName, animation, properties)
	hasAnimator(self)
	local track = self.Animator:LoadAnimation(animation)
	track.Priority = properties.animationPriority or track.Priority
	track.Looped = properties.looped or track.Looped
	self.Tracks[trackName] = track
	return track
end

function Animator:PlayAnimation(trackName, properties)
	hasAnimator(self)
	local track = self.Tracks[trackName]
	if self._PauseList[trackName] then
		self._PauseList[trackName] = nil
	end
	if track then
		local playSpeed = isRealNumber(properties.playSpeed) and properties.playSpeed or 1
		playSpeed = properties.playReversed and -playSpeed or playSpeed
		local playWeight = isRealNumber(properties.weight) and properties.weight or 1
		local weightFade = isRealNumber(properties.weightFade) and properties.weightFade or 0.1
		track:Play(weightFade, playWeight, playSpeed)
		if isRealNumber(properties.playAtTime) then
			track.TimePosition = properties.playAtTime
		end
	end
end

function Animator:PauseAnimation(trackName)
	hasAnimator(self)
	local track = self.Tracks[trackName]
	if track then
		self._PauseList[trackName] = track.Speed
		track:AdjustSpeed(0)
	end
end

function Animator:ResumeAnimation(trackName, newSpeed)
	hasAnimator(self)
	local track = self.Tracks[trackName]
	if track then
		if newSpeed then
			if not isRealNumber(newSpeed) then
				error("Invalid number for newSpeed.")
			end
			track:AdjustSpeed(newSpeed)
		else
			local oldSpeed = self._PauseList[trackName]
			if oldSpeed then
				track:AdjustSpeed(oldSpeed)
			end
		end
		self._PauseList[trackName] = nil
	end
end

function Animator:StopAnimation(trackName, properties)
	hasAnimator(self)
	local track = self.Tracks[trackName]
	if track then
		local weightFade = properties.weightFade or 0.1
		local forceStop = properties.forceStop or false
		if properties.weightFade and properties.forceStop then
			warn("weightFade and forceStop are mutually exclusive. Ignoring forceStop.")
			forceStop = false
		end
		weightFade = forceStop and 0 or weightFade
		track:Stop(weightFade)
	end
end

function Animator:AdjustWeight(trackName, weight)
	hasAnimator(self)
	local track = self.Tracks[trackName]
	if track then
		track:AdjustWeight(weight)
	end
end

function Animator:AdjustSpeed(trackName, speed)
	hasAnimator(self)
	if not isRealNumber(speed) then
		error("Invalid number for speed.")
	end
	local track = self.Tracks[trackName]
	if track then
		track:AdjustSpeed(speed)
	end
end

function Animator:AdjustTimePosition(trackName, timePosition)
	hasAnimator(self)
	if not isRealNumber(timePosition) then
		error("Invalid number for timePosition.")
	end
	local track = self.Tracks[trackName]
	if track then
		if not track.IsPlaying then
			warn("Cannot adjust time position of a track that is not playing.")
			return
		end
		track.TimePosition = timePosition
	end
end

return Animator :: {
	new: () -> (Type);
}
