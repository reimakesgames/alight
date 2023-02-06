local TweenService = game:GetService("TweenService")

local tableOperations = require(script.Parent.Parent.tableOperations)

export type Segment = {
	Metadata: {
		Duration: number,
	},
	Data: {
		CameraStart: CFrame,
		CameraEnd: CFrame,
		CameraEase: Enum.EasingStyle,
		CameraDirection: Enum.EasingDirection,

		CameraFOVStart: number,
		CameraFOVEnd: number,
		CameraFOVEase: Enum.EasingStyle,
		CameraFOVDirection: Enum.EasingDirection,

		Animatables: {
			[number]: ModuleScript,
		}
	},
}

export type Timeline = {
	[number]: Segment,
}

export type Type = {
	-- Class Defaults
	new: () -> Type,
	Destroy: (self: Type) -> (),

	-- Properties
	__ClipID: string,
	Stopped: boolean,

	Timeline: {[number]: {[string]: any}},

	-- Methods
	Play: (self: Type) -> (),
	Stop: (self: Type) -> (),

	CreateSegment: (self: Type, Metadata: {[string]: any}, Data: {[string]: any}) -> (),
	AppendClip: (self: Type, clip: Type) -> (),
}

local MaxClips = 0xFF
local CurrentClips = 0

local ActiveTweens = {}

local Clip = {}
Clip.__index = Clip
Clip.__tostring = function(self)
	return `Clip: {self.__SceneID}`
end

function Clip.new()
	local MyClipID = string.format("%02X", CurrentClips)
	-- the string.format function is used to convert the number to a hexadecimal string while also padding it with a 0 if it's less than 16
	if CurrentClips >= MaxClips then
		CurrentClips = 0
	else
		CurrentClips += 1
	end

	local self = setmetatable({
		Timeline = {},
		Stopped = false,

		__ClipID = `Clip_{MyClipID}`,
	}, Clip)

	return self
end

function Clip:Destroy()
	for _, segment in self.Timeline do
		if segment.Data.Animatables then
			table.clear(segment.Data.Animatables)
		end
		table.clear(segment.Data)
		table.clear(segment.Metadata)
	end
	table.clear(self.Timeline)
	table.clear(self)
end

function Clip:Play(clipIndex)
	for segmentIndex, segment: Segment in self.Timeline do
		if self.Stopped then
			break
		end
		print(segment)
		if segment.Data.Animatables then
			for _, animatable in segment.Data.Animatables do
				task.spawn(function()
					require(animatable)(clipIndex, segmentIndex, segment.Metadata, segment.Data)
				end)
			end
		end

		local duration = segment.Metadata.Duration

		local cameraStart = segment.Data.CameraStart
		local cameraEnd = segment.Data.CameraEnd or cameraStart
		local cameraEase = segment.Data.CameraEase or Enum.EasingStyle.Linear
		local cameraDirection = segment.Data.CameraDirection or Enum.EasingDirection.Out

		local cameraFOVStart = segment.Data.CameraFOVStart
		local cameraFOVEnd = segment.Data.CameraFOVEnd or cameraFOVStart
		local caneraFOVEase = segment.Data.CameraFOVEase or Enum.EasingStyle.Linear
		local cameraFOVDirection = segment.Data.CameraFOVDirection or Enum.EasingDirection.Out

		local cameraTweenInfo = TweenInfo.new(duration, cameraEase, cameraDirection)
		local cameraFOVTweenInfo = TweenInfo.new(duration, caneraFOVEase, cameraFOVDirection)

		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		workspace.CurrentCamera.CFrame = cameraStart
		workspace.CurrentCamera.FieldOfView = cameraFOVStart

		local cameraTween = TweenService:Create(workspace.CurrentCamera, cameraTweenInfo, {
			CFrame = cameraEnd,
		})
		local cameraFOVTween = TweenService:Create(workspace.CurrentCamera, cameraFOVTweenInfo, {
			FieldOfView = cameraFOVEnd,
		})

		cameraTween:Play()
		cameraFOVTween:Play()
		table.insert(ActiveTweens, cameraTween)
		table.insert(ActiveTweens, cameraFOVTween)

		cameraTween.Completed:Wait()
		cameraFOVTween:Cancel()
		table.remove(ActiveTweens, table.find(ActiveTweens, cameraTween))
		table.remove(ActiveTweens, table.find(ActiveTweens, cameraFOVTween))
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end

function Clip:Stop()
	self.Stopped = true
	for _, tween in ActiveTweens do
		tween:Cancel()
	end
	table.clear(ActiveTweens)
end

function Clip:CreateSegment(Metadata: {[string]: any}, Data: {[string]: any})
	local segment: Segment = {
		Metadata = Metadata,
		Data = Data,
	}

	table.insert(self.Timeline, segment)
end

function Clip:AppendClip(clip: Type)
	-- hard copy the timeline
	-- thanks roblox for not saying that table.insert gives the pointer to the table
	for _, segment in clip.Timeline do
		table.insert(self.Timeline, tableOperations:DeepCopy(segment))
	end
	clip:Destroy()
end

return Clip
