local TweenService = game:GetService("TweenService")

local EASING_STYLES = {
	linear = Enum.EasingStyle.Linear,
	sine = Enum.EasingStyle.Sine,
	quad = Enum.EasingStyle.Quad,
	cubic = Enum.EasingStyle.Cubic,
	quart = Enum.EasingStyle.Quart,
	quint = Enum.EasingStyle.Quint,
	exponential = Enum.EasingStyle.Exponential,
	circular = Enum.EasingStyle.Circular,
	elastic = Enum.EasingStyle.Elastic,
	back = Enum.EasingStyle.Back,
	bounce = Enum.EasingStyle.Bounce,
	[""] = Enum.EasingStyle.Linear,
}

export type Path = {
	Transition: number,
	Duration: number,
	EasingStyle: Enum.EasingStyle,
	CFrame: CFrame,
}

export type SceneModel = Model & {
	CameraPosition: Folder & {
		[any]: Part & {
			Transition: NumberValue,
			Duration: NumberValue,
			EasingStyle: StringValue,
		},
	},
	Characters: Folder & {
		[any]: Model & {
			Humanoid: Humanoid & {
				Animator: Animator,
				[string]: Animation,
			},
		},
	},
}

export type Type = {
	Camera: Camera,

	SceneModel: SceneModel,
	CameraTimeline: { [number]: Path },

	new: (sceneModel: SceneModel) -> Type,
	Destroy: (self: Type) -> (),

}

local Scene = {}
Scene.__index = Scene

local function ConvertToEasingStyle(string)
	return EASING_STYLES[string]
end

local function GenerateCameraPath(folder: Folder)
	local path = {}

	-- since the folder contains parts named from 1 to n, we can manually iterate over the folder
	repeat
		local part = folder:FindFirstChild(tostring(#path + 1))
		if part then
			table.insert(path, {
				Transition = part.Transition.Value,
				Duration = part.Duration.Value,
				EasingStyle = ConvertToEasingStyle(part.EasingStyle.Value),
				CFrame = part.CFrame,
			})
		end
	until not part

	return path
end

local function CreateCameraTween(camera: Camera, path: Path, nextPath: Path)
	if path.Transition <= 0 then
		camera.CFrame = nextPath.CFrame
		return
	end
	local tweenInfo = TweenInfo.new(
		path.Transition,
		path.EasingStyle,
		Enum.EasingDirection.InOut
	)

	local tween = TweenService:Create(camera, tweenInfo, {
		CFrame = if nextPath then nextPath.CFrame else path.CFrame,
	})

	return tween
end

local function LoadAnimationsInCharacters(model: SceneModel)
	local animations = {}
	for _, character in model.Characters:GetChildren() do
		animations[character] = {}

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			-- the animations are stored in Humanoid, it contains Animations from 1 to n
			repeat
				local animation = humanoid:FindFirstChild(tostring(#animations[character] + 1))
				if animation then
					table.insert(animations[character], humanoid.Animator:LoadAnimation(animation))
				end
			until not animation
		end
	end

	return animations
end

local function ChainAnimations(animations: { [number]: AnimationTrack })
	task.spawn(function()
		local lastAnimation = animations[#animations]
		lastAnimation.Looped = true

		for index, animation in animations do
			local nextAnimation = animations[index + 1]

			animation:Play()
			print("Playing animation")
			animation.Ended:Wait()
			print("Animation ended")

			if nextAnimation then
				print("Playing next animation")
				continue
			end
		end
	end)
end

local function CheckSceneModel(sceneModel: SceneModel)
	assert(sceneModel:IsA("Model"), "SceneModel must be a Model")
	assert(sceneModel.CameraPosition, "SceneModel must have a CameraPosition folder")
	assert(sceneModel.CameraPosition:IsA("Folder"), "SceneModel.CameraPosition must be a Folder")
	assert(#sceneModel.CameraPosition:GetChildren() > 0, "SceneModel.CameraPosition must have at least one part")
end

function Scene.new(sceneModel: SceneModel)
	CheckSceneModel(sceneModel)

	local CameraTimeline = GenerateCameraPath(sceneModel.CameraPosition)

	local self = setmetatable({
		Camera = workspace.CurrentCamera,
		SceneModel = sceneModel,
		CameraTimeline = CameraTimeline,
	}, Scene)

	return self
end

function Scene:Destroy()
	self.Camera = nil
	self.SceneModel = nil
end



function Scene:RunScene(loop: boolean)
	print("Running scene")
	self.Camera.CameraType = Enum.CameraType.Scriptable
	self.Camera.CFrame = self.SceneModel.CameraPosition[1].CFrame

	local Animations = LoadAnimationsInCharacters(self.SceneModel)
	for _, animations in Animations do
		ChainAnimations(animations)
	end
	local function iterate()
		for index, path in pairs(self.CameraTimeline) do
			local nextPath = self.CameraTimeline[index + 1]
			if loop and not nextPath then
				nextPath = self.CameraTimeline[1]
			end
			if path.Duration > 0 then
				task.wait(path.Duration)
			end
			self.Camera.CameraType = Enum.CameraType.Scriptable
			self.Camera.CFrame = path.CFrame
			local tween = CreateCameraTween(self.Camera, path, nextPath)
			if not tween then
				continue
			end
			tween:Play()
			tween.Completed:Wait()
		end
	end
	iterate()
	if loop then
		while true do
			iterate()
		end
	end

	self.Camera.CameraType = Enum.CameraType.Custom
	print("Scene finished")
end

return Scene :: {
	new: (sceneModel: SceneModel) -> Type
}
