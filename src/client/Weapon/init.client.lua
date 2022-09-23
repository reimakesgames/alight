local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Gameplay = Assets:WaitForChild("Gameplay")
local Environment = Gameplay:WaitForChild("Environment")

local Camera = workspace.CurrentCamera
local Viewmodel = ReplicatedStorage:WaitForChild("v_UMP45"):Clone()

local Caster = require(script.Caster)
local CastEffects = require(script.CastEffects)

local function WeaponFire(Origin: Vector3, Direction: Vector3)
	local Result: RaycastResult = Caster:Cast(Origin, Direction * 1024)
	
	if not Result then
		CastEffects:CreateFakeTracer(Viewmodel["UMP-45"].Handle.Exit.WorldPosition, Origin + (Direction * 1024))
		return
	end

	CastEffects:NewBulletHole(Result.Position, Result.Normal)
	-- CastEffects:CreateFakeTracer(Origin, Result.Position)
	CastEffects:CreateFakeTracer(Viewmodel["UMP-45"].Handle.Exit.WorldPosition, Result.Position)

	local PartDepth, HitPosition = Caster:FindThickness(Result.Instance, Result.Position, Result.Position + (Direction * 64), -Direction * 64)

	if not PartDepth then
		return
	end
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local OriginPosition: Vector3 = Camera.CFrame.Position
		local LookVector: Vector3 = Camera.CFrame.LookVector

		WeaponFire(OriginPosition, LookVector)
	end
end)

RunService.RenderStepped:Connect(function(deltaTime)
	Viewmodel.Parent = Camera
	Viewmodel:SetPrimaryPartCFrame(Camera.CFrame)
end)
