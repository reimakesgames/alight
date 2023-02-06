local TweenService = game:GetService("TweenService")

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
			[number]: Light | ParticleEmitter | Sound | Model | ModuleScript,
		}
	},
}

export type Timeline = {
	[number]: Segment,
}

export type Type = {
	-- Class Defaults
	new: () -> Type,
	Destroy: () -> (),

	-- Properties
	__ClipID: string,

	Timeline: {[number]: {[string]: any}},

	Length: number,

	-- Methods
	Play: () -> (),
	Stop: () -> (),

	CreateSegment: (Metadata: {[string]: any}, Data: {[string]: any}) -> (),
}

local MaxClips = 0xFF
local CurrentClips = 0

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

		__ClipID = `Clip_{MyClipID}`,
	}, Clip)

	return self
end

function Clip:Destroy()
end

function Clip:Play(myIndex)
	for index, segment: Segment in self.Timeline do
		if segment.Data.Animatables then
			for _, animatable in segment.Data.Animatables do
				task.spawn(function()
					if animatable:IsA("ModuleScript") then
						require(animatable)(myIndex)
					end
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

		cameraTween.Completed:Wait()
		cameraFOVTween:Cancel()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end

function Clip:Stop()
end

function Clip:CreateSegment(Metadata: {[string]: any}, Data: {[string]: any})
	local segment: Segment = {
		Metadata = Metadata,
		Data = Data,
	}

	table.insert(self.Timeline, segment)
end

return Clip
