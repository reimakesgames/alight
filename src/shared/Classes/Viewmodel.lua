local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = ReplicatedFirst:WaitForChild("Utility")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Classes = Shared:WaitForChild("Classes")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local QuickInstance = require(Utility.QuickInstance)
local Spring = require(Classes.Spring)
local Animator = require(Classes.Animator)

local function ViewmodelsFolder()
	return Camera:FindFirstChild("Viewmodels") or QuickInstance("Folder", {Name = "Viewmodels", Parent = Camera})
end

type DefaultArms = {
	AnimationController: AnimationController | {
		Animator: Animator
	};
	HumanoidRootPart: Part;
	Camera: Part;
	WeaponModel: Model | {
		AimPoint: Attachment;
		Muzzle: Attachment;
		EjectionPort: Attachment;
	};
	["Left Arm"]: Part;
	["Right Arm"]: Part;
}

export type ViewmodelClass = {
	Cull: (self: ViewmodelClass, enabled: boolean) -> nil;
	SetCFrame: (self: ViewmodelClass, cframe: CFrame) -> nil;
	Decorate: (self: ViewmodelClass, model: Model) -> nil;
	CleanUp: (self: ViewmodelClass) -> nil;

	Animator: Animator.AnimatorClass;

	Model: Model | DefaultArms;
	Culled: boolean;
	Springs: {[string]: Spring.SpringClass};
	Decoration: Model;
	ReloadStage: string;
	ReloadResumptionPoint: number;
}

local Viewmodel = {}
Viewmodel.__index = Viewmodel

function Viewmodel.new(model: Model): ViewmodelClass
	local self = setmetatable({
		Animator = Animator.new();

		Culled = true;
		Springs = {
			Sway = Spring.new(5, 50, 4, 4);
			SwayPivot = Spring.new(5, 50, 2, 8);
			WalkCycle = Spring.new(5, 50, 4, 4);
			Recoil = Spring.new(5, 25, 3, 16);
			RecoilNoise = Spring.new(5, 50, 2, 8)
		};
		ReloadStage = "none";
		ReloadResumptionPoint = 0.0;
	}, Viewmodel)

	local newModel: Model | DefaultArms = model:Clone()
	newModel.Parent = ViewmodelsFolder()
	self.Model = newModel
	self.Animator.Animator = self.Model.AnimationController.Animator
	self:Cull(true)

	return self
end

function Viewmodel:Decorate(model: Model)
	local newModel = model:Clone()

	QuickInstance("Motor6D", {
		Part0 = newModel["Left Arm"];
		Part1 = self.Model["Left Arm"];
		Parent = newModel["Left Arm"]
	})

	QuickInstance("Motor6D", {
		Part0 = newModel["Right Arm"];
		Part1 = self.Model["Right Arm"];
		Parent = newModel["Right Arm"]
	})

	LocalPlayer.Character:WaitForChild("Body Colors"):Clone().Parent = newModel
	LocalPlayer.Character:WaitForChild("Shirt"):Clone().Parent = newModel

	newModel.Name = self.Model.Name .. "_DECORATION"
	newModel.Parent = ViewmodelsFolder()

	self.Decoration = newModel
	self.Model["Left Arm"].Transparency = 1
	self.Model["Right Arm"].Transparency = 1
end

function Viewmodel:Cull(enabled: boolean): nil
	self.Culled = enabled
	self.Model:PivotTo(CFrame.new(0, -128, 0))
end

function Viewmodel:SetCFrame(cframe: CFrame): nil
	if self.Culled then
		return
	end
	self.Model:PivotTo(cframe)
end

function Viewmodel:CleanUp()
	self.Model:Destroy()
	self.Decoration:Destroy()
	for _, spring: Spring.SpringClass in self.Springs do
		table.clear(spring)
	end
	table.clear(self.Springs)
	table.clear(self)
end

return Viewmodel :: {
	new: (model: Model) -> ViewmodelClass
}