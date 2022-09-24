local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera

type Tracer = {
	Object: Part;
	StartPosition: Vector3;
	EndPosition: Vector3;
	Magnitude: number;
	_ready: boolean;
}

local function QuickInstance(ClassName: string, Properties: {[string]: any})
	local Object = Instance.new(ClassName)
	for Property, Value in Properties do
		Object[Property] = Value
	end

	return Object
end

local Assets = ReplicatedStorage:WaitForChild("Assets")
-- local Packages = ReplicatedStorage:WaitForChild("Packages")

local Gameplay = Assets:WaitForChild("Gameplay")
local Environment = Gameplay:WaitForChild("Environment")

-- local Janitor = require(Packages:WaitForChild("janitor"))

local _TracersList = {}

local CastEffects = {}

function CastEffects:NewBulletHole(hitPosition: Vector3, hitNormal: Vector3)
	local bulletHole = Environment.BulletHole:Clone()
	bulletHole.CFrame = CFrame.new(hitPosition, hitPosition + hitNormal)
	bulletHole.Parent = Camera:FindFirstChild("Effects") or QuickInstance("Folder", {Name = "Effects", Parent = Camera})
	task.delay(0.1, function()
		for _, object in bulletHole.Emitters:GetChildren() do
			object.Enabled = false
		end
	end)
	task.delay(1, function()
		bulletHole.Emitters:Destroy()
	end)
end

function CastEffects:CreateFakeTracer(StartPosition: Vector3, EndPosition: Vector3)
	local _Tracer = Environment.Tracer:Clone()

	_Tracer.CFrame = CFrame.new(StartPosition, StartPosition + (EndPosition - StartPosition).Unit)
	_Tracer.Parent = Camera:FindFirstChild("Effects") or QuickInstance("Folder", {Name = "Effects", Parent = Camera})

	table.insert(_TracersList, {
		Object = _Tracer;
		StartPosition = StartPosition;
		EndPosition = EndPosition;
		Magnitude = (StartPosition - EndPosition).Magnitude;
		_ready = false;
	})
end

function CastEffects:CreateRaycastDebug(origin, goal)
	local startPart = Environment.Start:Clone()
	local endPart = Environment.End:Clone()

	startPart.Position = origin
	endPart.Position = goal

	startPart.Parent = workspace
	endPart.Parent = workspace
	startPart.Attachment.Beam.Attachment1 = endPart.Attachment
end

RunService:BindToRenderStep("HC_TracerUpdate", Enum.RenderPriority.Input.Value - 25, function(deltaTime)
	for Index, Tracer: Tracer in _TracersList do
		if not Tracer._ready then
			Tracer._ready = true
			continue
		end
		Tracer.Object.CFrame = Tracer.Object.CFrame + (Tracer.Object.CFrame.LookVector * (deltaTime * 512))
		if (Tracer.StartPosition - Tracer.Object.Position).Magnitude > Tracer.Magnitude then
			Tracer.Object:Destroy()
			table.remove(_TracersList, Index)
			table.clear(Tracer)
		end
	end
end)

return CastEffects