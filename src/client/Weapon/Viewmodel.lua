local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Utility = ReplicatedFirst.Utility
local Spring = require(Utility.Spring)

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function QuickInstance(ClassName: string, Properties: {[string]: any})
	local Object = Instance.new(ClassName)
	for Property, Value in Properties do
		Object[Property] = Value
	end

	return Object
end

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

export type Viewmodel = {
	new: (model: Model) -> Viewmodel;
	Cull: (self: Viewmodel, enabled: boolean) -> nil;
	SetCFrame: (self: Viewmodel, cframe: CFrame) -> nil;
	Decorate: (self: Viewmodel, model: Model) -> nil;
	CleanUp: (self: Viewmodel) -> nil;

	Model: Model | DefaultArms;
	Culled: boolean;
	Springs: {[string]: Spring.Spring};
	Decoration: Model;
}

local Viewmodel = {}
Viewmodel.__index = Viewmodel

function Viewmodel.new(model: Model): Viewmodel
	local self = setmetatable({
		Culled = true;
		Springs = {
			Sway = Spring.new(5, 50, 4, 4);
			WalkCycle = Spring.new(5, 50, 4, 4);
			Recoil = Spring.new(5, 25, 3, 16);
			RecoilNoise = Spring.new(5, 50, 2, 8)
		}
	}, Viewmodel)

	local newModel: Model | DefaultArms = model:Clone()
	newModel.Parent = ViewmodelsFolder()
	self.Model = newModel

	return self
end

function Viewmodel:Decorate(model: Model)
	local newModel = model:Clone()

	local leftArmMotor: Motor6D = QuickInstance("Motor6D", {
		Part0 = newModel["Left Arm"];
		Part1 = self.Model["Left Arm"];
	})
	leftArmMotor.Parent = newModel["Left Arm"]
	local rightArmMotor: Motor6D = QuickInstance("Motor6D", {
		Part0 = newModel["Right Arm"];
		Part1 = self.Model["Right Arm"];
	})
	rightArmMotor.Parent = newModel["Right Arm"]

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
	self.Model:PivotTo(cframe)
end

function Viewmodel:CleanUp()
	self.Model:Destroy()
	self.Decoration:Destroy()
	for _, Spring: Spring.Spring in self.Springs do
		table.clear(Spring)
	end
	table.clear(self.Springs)
	table.clear(self)
end

return Viewmodel :: {
	new: (model: Model) -> Viewmodel
}