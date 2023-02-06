local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SceneV2 = require(ReplicatedStorage.Shared.SceneV2)
local Scene = SceneV2.new(true)

local World = workspace.World
local CameraPositions = World.CameraPositions

-- local NewClip = Clip.new()
-- NewClip:CreateSegment({
-- 	Duration = 5,
-- }, {
-- 	CameraStart = CFrame.new(0, 4, 4),
-- 	CameraEnd = CFrame.lookAt(Vector3.new(0, 8, 16), Vector3.zero),
-- 	CameraEase = Enum.EasingStyle.Sine,

-- 	CameraFOVStart = 30,
-- 	CameraFOVEnd = 70,
-- 	CameraFOVEase = Enum.EasingStyle.Sine,
-- })

-- NewScene:AddClip(NewClip)

Scene:CreateClip({
	Duration = 6,
}, {
	CameraStart = CameraPositions[1].CFrame,
	CameraEnd = CameraPositions[2].CFrame,

	CameraFOVStart = 50,

	Animatables = {
		workspace.World.Characters.reimakesgames.Animatable,
		workspace.World.Model.Animatable,
	}
})

Scene:CreateClip({
	Duration = 6,
}, {
	CameraStart = CameraPositions[3].CFrame,
	CameraEnd = CameraPositions[4].CFrame,

	CameraFOVStart = 30,

	Animatables = {
		workspace.World.Gun.Radar.SurfaceGui.Frame.Frame.TextLabel.Animatable,
	}
})

Scene:CreateClip({
	Duration = 6,
}, {
	CameraStart = CameraPositions[5].CFrame,
	CameraEnd = CameraPositions[6].CFrame,

	CameraFOVStart = 50,
})

Scene:CreateClip({
	Duration = 6,
}, {
	CameraStart = CameraPositions[7].CFrame,
	CameraEnd = CameraPositions[8].CFrame,

	CameraFOVStart = 50,

	Animatables = {
		workspace.World.Model.Animatable,
	}
})

return Scene
