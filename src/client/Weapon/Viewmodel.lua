local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Utility = ReplicatedFirst.Utility
local Spring = require(Utility.Spring)

local Camera = workspace.CurrentCamera

local function QuickInstance(ClassName: string, Properties: {[string]: any})
	local Object = Instance.new(ClassName)
	for Property, Value in Properties do
		Object[Property] = Value
	end

	return Object
end

type DefaultArms = {
	AnimationController: AnimationController;
	["Left Arm"]: Part;
	["Right Arm"]: Part;
	HumanoidRootPart: Part;
	WeaponModel: Model;
	Camera: Part;
}

export type Viewmodel = {
	new: (model: Model) -> Viewmodel;
	Cull: (self: Viewmodel, enabled: boolean) -> nil;
	SetCFrame: (self: Viewmodel, cframe: CFrame) -> nil;

	Model: Model | DefaultArms;
	Culled: boolean;
	Springs: {[number]: Spring.Spring};
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
	newModel.Parent = Camera:FindFirstChild("Viewmodels") or QuickInstance("Folder", {Name = "Viewmodels", Parent = Camera})
	self.Model = newModel

	return self
end

function Viewmodel:Cull(enabled: boolean): nil
	self.Culled = enabled
	self.Model:PivotTo(CFrame.new(0, -128, 0))
end

function Viewmodel:SetCFrame(cframe: CFrame): nil
	self.Model:PivotTo(cframe)
end

return Viewmodel :: {
	new: (model: Model) -> Viewmodel
}