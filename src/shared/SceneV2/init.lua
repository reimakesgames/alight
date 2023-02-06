local Clip = require(script.Clip)

export type Timeline = {
	[number]: Clip.Type,
}

export type Type = {
	-- Class Defaults
	new: (looped: boolean?) -> Type,
	Destroy: () -> (),

	-- Properties
	__SceneID: string,
	Looped: boolean,

	-- Methods
	AddClip: (clip: Clip.Type) -> (),
	CreateClip: (data: Clip.Segment) -> (Clip.Type),
	Play: () -> (),
	Stop: () -> (),

	-- Variables
	LowDetailMode: boolean,

	-- Functions
}

local Scene = {}
Scene.__index = Scene

local MaxScenes = 0xFF
local CurrentScenes = 0

function Scene.new(looped: boolean?)
	local MySceneID = string.format("%02X", CurrentScenes)

	if CurrentScenes >= MaxScenes then
		CurrentScenes = 0
		warn("Max scenes reached, resetting to 0")
	else
		CurrentScenes += 1
	end

	local self = setmetatable({
		__SceneID = `Scene_{MySceneID}`,
		Looped = looped or false,

		Timeline = {},
	}, Scene)

	return self
end

function Scene:Destroy()
end

function Scene:AddClip(clip: Clip.Type)
	table.insert(self.Timeline, clip)

	print(`Added clip {clip.__ClipID} to scene {self.__SceneID}`)
end

function Scene:CreateClip(metadata, data)
	local clip = Clip.new()
	clip:CreateSegment(metadata, data)

	self:AddClip(clip)

	return clip
end

function Scene:Play()
	repeat
		for index, clip in pairs(self.Timeline) do
			clip:Play(index)
		end
	until not self.Looped
end

return Scene
