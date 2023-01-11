local VIEWMODELS_DIRECTORY_NAME = "__VIEWMODELS__"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local fastInstance = require(Shared.fastInstance)
local Animator = require(Shared.Animator)

type Rig = Model & {
	AnimationController: AnimationController & {
		Animator: Animator,
	},
	["Left Arm"]: Part,
	["Right Arm"]: Part,

	HumanoidRootPart: Part & {
		Camera: Motor6D,
		Joint: Motor6D,
	},
	Camera: Part,
	Joint: Part & {
		Handle: Motor6D,
		LeftArm: Motor6D,
		RightArm: Motor6D,
	},

	Model: Model & {
		Handle: Part & {
			MuzzlePoint: Attachment & {
				Smoke: ParticleEmitter,
				Shockwave: ParticleEmitter,
				Flash: ParticleEmitter,
			}, -- for bullets
			EjectionPoint: Attachment & {
				Smoke: ParticleEmitter,
				Shockwave: ParticleEmitter,
				Flash: ParticleEmitter,
			}, -- for shells
			AimPoint: Attachment, -- for aiming
			PivotPoint: Attachment, -- for recoil pivoting
		},
	},
}

type Arms = Model & {
	Humanoid: Humanoid,
	["Left Arm"]: Part,
	["Right Arm"]: Part,
}

local function ViewmodelsFolder()
	return Camera:FindFirstChild(VIEWMODELS_DIRECTORY_NAME)
		or fastInstance("Folder", { Name = VIEWMODELS_DIRECTORY_NAME, Parent = Camera })
end

local function isRig(rig: Rig): ()
	assert(rig:FindFirstChild("HumanoidRootPart"), "Rig missing HumanoidRootPart")
	assert(rig:FindFirstChild("Camera"), "Rig missing Camera")
	assert(rig:FindFirstChild("Joint"), "Rig missing Joint")
	assert(rig:FindFirstChild("Model"), "Rig missing Model")
	assert(rig:FindFirstChild("AnimationController"), "Rig missing AnimationController")
	assert(rig:FindFirstChild("Left Arm"), "Rig missing Left Arm")
	assert(rig:FindFirstChild("Right Arm"), "Rig missing Right Arm")
end

local function isArms(arms: Arms): ()
	assert(arms:FindFirstChild("Humanoid"), "Arms missing Humanoid")
	assert(arms:FindFirstChild("Left Arm"), "Arms missing Left Arm")
	assert(arms:FindFirstChild("Right Arm"), "Arms missing Right Arm")
end

export type ViewmodelClass = {
	__index: ViewmodelClass,
	new: (rig: Rig) -> (ViewmodelClass),
	Destroy: (self: ViewmodelClass) -> (),
	IsA: (self: ViewmodelClass, className: string) -> (boolean),

	Decorate: (self: ViewmodelClass, arms: Arms) -> (),
	Cull: (self: ViewmodelClass, enabled: boolean) -> (),
	SetCFrame: (self: ViewmodelClass, cframe: CFrame) -> (),
	LoadDictAnimations: (dict: { [string]: { Animation: Animation, Properties: { [string]: boolean } } }) -> (),

	Rig: Rig,
	Arms: Arms,
	Animator: Animator.Type,
	Culled: boolean,
}

local CLASS_NAME = "ViewmodelClass"
local Viewmodel = {} :: ViewmodelClass
Viewmodel.__index = Viewmodel

function Viewmodel.new(rig)
	isRig(rig)
	local self = setmetatable({
		Animator = Animator.new(),
		Culled = true,
	}, Viewmodel)

	local newRig = rig:Clone()
	newRig.Parent = ViewmodelsFolder()
	self.Rig = newRig
	self.Animator.Animator = self.Rig.AnimationController.Animator
	self:Cull(true)

	return self :: ViewmodelClass
end

function Viewmodel:Destroy()
	if self.Rig then
		self.Rig:Destroy()
	end
	if self.Arms then
		self.Arms:Destroy()
	end
	setmetatable(self, nil)
	table.clear(self)
end

function Viewmodel:IsA(className)
	return className == CLASS_NAME
end

function Viewmodel:Decorate(arms)
	assert(self.Rig, "Viewmodel must have a model to decorate")
	isArms(arms)
	local newArms = arms:Clone()

	fastInstance("Motor6D", {
		Part0 = newArms["Left Arm"],
		Part1 = self.Rig["Left Arm"],
		Parent = newArms["Left Arm"],
	})

	fastInstance("Motor6D", {
		Part0 = newArms["Right Arm"],
		Part1 = self.Rig["Right Arm"],
		Parent = newArms["Right Arm"],
	})

	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Character:WaitForChild("Body Colors"):Clone().Parent = newArms
	Character:WaitForChild("Shirt"):Clone().Parent = newArms

	newArms.Name = self.Rig.Name .. "_DECORATION"
	newArms.Parent = ViewmodelsFolder()

	self.Arms = newArms
	self.Rig["Left Arm"].Transparency = 1
	self.Rig["Right Arm"].Transparency = 1
end

function Viewmodel:Cull(enabled: boolean)
	assert(self.Rig, "Viewmodel must have a model to cull")
	assert(typeof(enabled) == "boolean", "Cull must be called with a boolean")
	self.Culled = enabled
	if enabled then
		self.Rig:PivotTo(CFrame.new(0, -128, 0))
	end
end

function Viewmodel:SetCFrame(cframe: CFrame)
	assert(self.Rig, "Viewmodel must have a model to set cframe")
	if self.Culled then
		return
	end
	self.Rig:PivotTo(cframe)
end

function Viewmodel:LoadDictAnimations(dict: { [string]: { Animation: Animation, Properties: { [string]: boolean } } })
	assert(self.Rig, "Viewmodel must have a model to load animations")
	assert(self.Animator, "Viewmodel must have an animator to load animations")
	assert(typeof(dict) == "table", "LoadDictAnimations must be called with a table")
	for name, data in pairs(dict) do
		self.Animator:LoadAnimation(name, data.Animation or data[1], data.Properties or data[2])
	end
end

return Viewmodel :: {
	new: (model: Model) -> ViewmodelClass,
}
