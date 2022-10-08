local Debris = game:GetService("Debris")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Utility = ReplicatedFirst.Utility

local Camera = workspace.CurrentCamera

local QuickInstance = require(Utility.QuickInstance)

type Tracer = {
	Object: Part;
	StartPosition: Vector3;
	EndPosition: Vector3;
	Magnitude: number;
	_ready: boolean;
}

local function EffectsFolder()
	return Camera:FindFirstChild("Effects") or QuickInstance("Folder", {Name = "Effects", Parent = Camera})
end

local Assets = ReplicatedStorage:WaitForChild("Assets")
-- local Packages = ReplicatedStorage:WaitForChild("Packages")

local Gameplay = Assets:WaitForChild("Gameplay")
local Environment = Gameplay:WaitForChild("Environment")

-- local Janitor = require(Packages:WaitForChild("janitor"))

local _TracersList = {}
local BeamUpdates = {}

local VFXHandler = {}

function VFXHandler:EmitMuzzleParticles(attachment: Attachment)
	for _, object: ParticleEmitter in attachment:GetChildren() do
		if not object:IsA("ParticleEmitter") then continue end

		if object.Name == "Flash" or object.Name == "Shockwave" then
			object:Emit(1)
		elseif object.Name == "Smoke" then
			object:Emit(8)
		end
	end
end

-- function ParticleEffects:NewBulletHole(hitPosition: Vector3, hitNormal: Vector3, hitObject: BasePart)
-- 	local bulletHole = Environment.BulletHole:Clone()
-- 	bulletHole.CFrame = CFrame.new(hitPosition, hitPosition + hitNormal)
-- 	local Weld = QuickInstance("WeldConstraint")
-- 	Weld.Part0 = bulletHole
-- 	Weld.Part1 = hitObject
-- 	Weld.Parent = bulletHole
-- 	bulletHole.Parent = EffectsFolder()
-- 	task.delay(0.1, function()
-- 		for _, object in bulletHole.Emitters:GetChildren() do
-- 			object.Enabled = false
-- 		end
-- 	end)
-- 	task.delay(1, function()
-- 		bulletHole.Emitters:Destroy()
-- 	end)
-- end

function VFXHandler:NewBulletHole(position: Vector3, normal: Vector3, object: BasePart)
	local emitterAttachment = Environment.NewBulletHole.Main:Clone()
	local attachment0 = Environment.NewBulletHole.Attachment0:Clone()
	local attachment1 = Environment.NewBulletHole.Attachment1:Clone()

	attachment0.Beam.Attachment0 = attachment0
	attachment0.Beam.Attachment1 = attachment1

	emitterAttachment.Parent = object
	attachment0.Parent = object
	attachment1.Parent = object

	emitterAttachment.WorldCFrame = CFrame.new(position, position + normal)
	attachment0.WorldCFrame = CFrame.new(position + emitterAttachment.WorldCFrame.RightVector * 0.25, position + emitterAttachment.WorldCFrame.RightVector * 0.25 + normal)
	attachment1.WorldCFrame = CFrame.new(position + emitterAttachment.WorldCFrame.RightVector * -0.25, position + emitterAttachment.WorldCFrame.RightVector * -0.25 + normal)

	for _, object in emitterAttachment:GetChildren() do
		if object:IsA("ParticleEmitter") then
			object:Emit(8)
		end
	end

	task.delay(1, function()
		emitterAttachment:Destroy()
	end)
end

function VFXHandler:NewBulletExit(position: Vector3, normal: Vector3, object: BasePart, exitNormal: Vector3)
	local emitterAttachment = Environment.NewBulletHole.Main:Clone()
	local attachment0 = Environment.NewBulletHole.Attachment0:Clone()
	local attachment1 = Environment.NewBulletHole.Attachment1:Clone()

	attachment0.Beam.Attachment0 = attachment0
	attachment0.Beam.Attachment1 = attachment1

	emitterAttachment.Parent = object
	attachment0.Parent = object
	attachment1.Parent = object

	emitterAttachment.WorldCFrame = CFrame.new(position, position + normal)
	attachment0.WorldCFrame = CFrame.new(position + emitterAttachment.WorldCFrame.RightVector * 0.25, position + emitterAttachment.WorldCFrame.RightVector * 0.25 + normal)
	attachment1.WorldCFrame = CFrame.new(position + emitterAttachment.WorldCFrame.RightVector * -0.25, position + emitterAttachment.WorldCFrame.RightVector * -0.25 + normal)
	emitterAttachment.WorldCFrame = CFrame.new(position, position + exitNormal)

	for _, object in emitterAttachment:GetChildren() do
		if object:IsA("ParticleEmitter") then
			object:Emit(8)
		end
	end

	task.delay(1, function()
		emitterAttachment:Destroy()
	end)
end

function VFXHandler:NewBulletSmoke(origin: Vector3, goal: Vector3)
	local bulletSmoke = Environment.Smoke:Clone()
	bulletSmoke.CFrame = CFrame.new(origin, goal)
	-- bulletSmoke.Start.WorldPosition = startPosition
	bulletSmoke.End.WorldPosition = goal
	bulletSmoke.Parent = EffectsFolder()

	table.insert(BeamUpdates, bulletSmoke)

	task.delay(1, function()
		bulletSmoke:Destroy()
	end)
end

function VFXHandler:NewBulletShell(originCFrame)
	local bulletShell = Environment.Shell:Clone()
	bulletShell.CFrame = originCFrame
	bulletShell.Parent = EffectsFolder()
	bulletShell:ApplyImpulse(bulletShell.CFrame.LookVector * 0.15)
	bulletShell:ApplyAngularImpulse(Vector3.new(0, 0.001, 0))

	bulletShell.Touched:Once(function()
		Debris:AddItem(bulletShell.Impact, bulletShell.Impact.TimeLength)
		local Velocity = bulletShell:GetVelocityAtPosition(bulletShell.Position)
		bulletShell.Impact.PlaybackSpeed = 1 + ((math.random() * 0.2) - 0.1)
		bulletShell.Impact.Volume = math.clamp(Velocity.Magnitude / 128, 0, 1)
		bulletShell.Impact:Play()
	end)
end

function VFXHandler:NewTracer(origin: Vector3, lookVector: Vector3)
	local _Tracer = Environment.Tracer:Clone()

	_Tracer.CFrame = CFrame.new(origin, origin + lookVector)
	_Tracer.Parent = EffectsFolder()

	table.insert(_TracersList, {
		Object = _Tracer;
		StartPosition = origin;
		EndPosition = origin + lookVector;
		Magnitude = (origin - (origin + lookVector)).Magnitude;
		_ready = false;
	})
end

function VFXHandler:__CreateRaycastDebug(origin: Vector3, goal: Vector3)
	local startPart = Environment.Start:Clone()
	local endPart = Environment.End:Clone()

	startPart.Position = origin
	endPart.Position = goal

	startPart.Parent = workspace
	endPart.Parent = workspace
	startPart.Attachment.Beam.Attachment1 = endPart.Attachment
end

RunService:BindToRenderStep("HC_TracerUpdate", Enum.RenderPriority.Input.Value - 25, function(deltaTime)
	for Index, Beam in BeamUpdates do
		if Beam.Parent == nil then
			table.remove(BeamUpdates, Index)
			continue
		end
		local Percentage = math.clamp((Beam.Start.WorldPosition - Beam.End.WorldPosition).Magnitude / 16, 0, 1)

		local TheValue = Beam.Beam.Transparency.Keypoints[1].Value + deltaTime
		local TheOtherValue = TheValue + ((1 - TheValue) * Percentage)
		Beam.Beam.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, TheValue),
			NumberSequenceKeypoint.new(1, TheOtherValue)
		}
	end

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

return VFXHandler