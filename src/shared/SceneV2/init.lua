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
	Stopped: boolean,

	-- Methods
	AddClip: (clip: Clip.Type) -> (),
	CreateClip: (data: Clip.Segment) -> (),
	Play: (self: Type) -> (),
	Stop: (self: Type) -> (),

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
		Stopped = false,

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

	if #self.Timeline == 0 then
		self:AddClip(clip)
	else
		self.Timeline[#self.Timeline]:AppendClip(clip)
	end
end

function Scene:Play()
	repeat
		for index, clip in pairs(self.Timeline) do
			if self.Stopped then
				break
			end
			clip:Play(index)
		end
	until self.Stopped or not self.Looped
end

function Scene:Stop()
	self.Stopped = true
	for _, clip in pairs(self.Timeline) do
		clip:Stop()
	end
end

return Scene
