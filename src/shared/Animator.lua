local isRealNumber = require(script.Parent.isRealNumber)

export type Type = {
	__index: Type;
	new: () -> (Type);
	Destroy: (self: Type) -> nil;
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
	}) -> nil;
	PauseAnimation: (self: Type, trackName: string) -> nil;
	ResumeAnimation: (self: Type, trackName: string, newSpeed: number?) -> nil;
	StopAnimation: (self: Type, trackName: string, properties: {
		weightFade: number?,
		forceStop: boolean?,
	}) -> nil;

	AdjustWeight: (self: Type, trackName: string, weight: number) -> nil;
	AdjustSpeed: (self: Type, trackName: string, speed: number) -> nil;
	AdjustTimePosition: (self: Type, trackName: string, timePosition: number) -> nil;

	Tracks: {[string]: AnimationTrack};
	_PauseList: {[string]: number};
	Animator: Animator;
}

local CLASS_NAME = "AnimatorClass"
local Animator = {
	className = CLASS_NAME;
	ClassName = CLASS_NAME;
} :: Type
Animator.__index = Animator

function Animator.new(): Type
	local self = setmetatable({
		Tracks = {},
		_PauseList = {},
		Animator = nil,
	}, Animator)

	return self :: Type
end

function Animator:Destroy()
	table.clear(self.Tracks)
	table.clear(self)
end

function Animator:IsA(className: string)
	return className == CLASS_NAME
end

function Animator:LoadAnimation(trackName: string, animation: Animation, properties): AnimationTrack
	local track = self.Animator:LoadAnimation(animation)
	track.Priority = properties.animationPriority or track.Priority
	track.Looped = properties.looped or track.Looped
	self.Tracks[trackName] = track
	return track
end

function Animator:PlayAnimation(trackName: string, properties): nil
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

function Animator:PauseAnimation(trackName: string): nil
	local track = self.Tracks[trackName]
	if track then
		self._PauseList[trackName] = track.Speed
		track:AdjustSpeed(0)
	end
end

function Animator:ResumeAnimation(trackName: string, newSpeed: number?): nil
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

function Animator:StopAnimation(trackName: string, properties): nil
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

function Animator:AdjustWeight(trackName: string, weight: number): nil
	local track = self.Tracks[trackName]
	if track then
		track:AdjustWeight(weight)
	end
end

function Animator:AdjustSpeed(trackName: string, speed: number): nil
	if not isRealNumber(speed) then
		error("Invalid number for speed.")
	end
	local track = self.Tracks[trackName]
	if track then
		track:AdjustSpeed(speed)
	end
end

function Animator:AdjustTimePosition(trackName: string, timePosition: number): nil
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
	new: () -> Type
}
