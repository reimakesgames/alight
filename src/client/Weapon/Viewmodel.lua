local Camera = workspace.CurrentCamera

local function QuickInstance(ClassName: string, Properties: {[string]: any})
	local Object = Instance.new(ClassName)
	for Property, Value in Properties do
		Object[Property] = Value
	end

	return Object
end

type DefaultArms = {
	Animator: Animator;
	["Left Arm"]: Part;
	["Right Arm"]: Part;
	HumanoidRootPart: Part;
}

export type Viewmodel = {
	new: (model: Model) -> Viewmodel;
	Cull: (self: Viewmodel, enabled: boolean) -> nil;
	SetCFrame: (self: Viewmodel, cframe: CFrame) -> nil;

	Model: Model | DefaultArms;
	Culled: boolean;
}

local Viewmodel = {}
Viewmodel.__index = Viewmodel

function Viewmodel.new(model: Model): Viewmodel
	local self = setmetatable({
		Culled = true
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