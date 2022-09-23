local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera

type Tracer = {
	Object: Part;
	StartPosition: Vector3;
	EndPosition: Vector3;
	Magnitude: number;
	Ready: boolean;
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

function CastEffects:NewBulletHole(HitPosition: Vector3, HitNormal: Vector3)
	local _BulletHole = Environment.BulletHole:Clone()
	_BulletHole.CFrame = CFrame.new(HitPosition, HitPosition + HitNormal)
	_BulletHole.Parent = Camera:FindFirstChild("Effects") or QuickInstance("Folder", {Name = "Effects", Parent = Camera})
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
		Ready = false;
	})
end

function CastEffects:CreateRaycastDebug(Origin, Stop)
	local Start = Environment.Start:Clone()
	local End = Environment.End:Clone()

	Start.Position = Origin
	End.Position = Stop

	Start.Parent = workspace
	End.Parent = workspace
	Start.Attachment.Beam.Attachment1 = End.Attachment
end

RunService:BindToRenderStep("HC_TracerUpdate", Enum.RenderPriority.Input.Value - 25, function(deltaTime)
	for Index, Tracer: Tracer in _TracersList do
		if not Tracer.Ready then
			Tracer.Ready = true
			continue
		end
		Tracer.Object.CFrame = Tracer.Object.CFrame + (Tracer.Object.CFrame.LookVector * (deltaTime * 256))
		if (Tracer.StartPosition - Tracer.Object.Position).Magnitude > Tracer.Magnitude then
			Tracer.Object:Destroy()
			table.remove(_TracersList, Index)
			table.clear(Tracer)
		end
	end
end)

return CastEffects