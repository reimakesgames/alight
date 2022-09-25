local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Utility = ReplicatedFirst:WaitForChild("Utility")
local Assets = ReplicatedStorage:WaitForChild("Assets")

local Gameplay = Assets:WaitForChild("Gameplay")
local Environment = Gameplay:WaitForChild("Environment")

local Camera = workspace.CurrentCamera

local Caster = require(script.Caster)
local CastEffects = require(script.CastEffects)
local Viewmodel = require(script.Viewmodel)
local Spring = require(Utility.Spring)

local CurrentViewmodel = Viewmodel.new(ReplicatedStorage.v_UMP45)

local ViewmodelCFrame = CFrame.new()
local Aiming = false

local function WeaponFire(origin: Vector3, direction: Vector3)
	local Result: RaycastResult = Caster:Cast(origin, direction * 1024)

	if not Result then
		CastEffects:NewBulletSmoke(CurrentViewmodel.Model.WeaponModel.Handle.Exit.WorldPosition, origin + (direction * 1024))
		CastEffects:CreateFakeTracer(CurrentViewmodel.Model.WeaponModel.Handle.Exit.WorldPosition, origin + (direction * 1024))
		return
	end

	CastEffects:NewBulletHole(Result.Position, Result.Normal)
	CastEffects:NewBulletSmoke(CurrentViewmodel.Model.WeaponModel.Handle.Exit.WorldPosition, Result.Position)
	-- CastEffects:CreateFakeTracer(Origin, Result.Position)
	CastEffects:CreateFakeTracer(CurrentViewmodel.Model.WeaponModel.Handle.Exit.WorldPosition, Result.Position)

	local PartDepth, HitPosition = Caster:FindThickness(Result.Instance, Result.Position, Result.Position + (direction * 64), -direction * 64)

	if not PartDepth then
		return
	end
end

local function UpdateViewmodel(deltaTime)
	local MouseDelta = UserInputService:GetMouseDelta()
	CurrentViewmodel.Springs.Sway:ApplyForce(Vector3.new(MouseDelta.X / 256, MouseDelta.Y / 256))

	if Aiming then
		local AimCFrame = CurrentViewmodel.Model.HumanoidRootPart.CFrame:ToObjectSpace(CurrentViewmodel.Model.WeaponModel.Handle.AimPoint.WorldCFrame)
		ViewmodelCFrame = ViewmodelCFrame:Lerp(AimCFrame:Inverse(), deltaTime * 12)
	else
		ViewmodelCFrame = ViewmodelCFrame:Lerp(CFrame.new(0, 0, 0), deltaTime * 12)
	end

	for _, spring: Spring.Spring in CurrentViewmodel.Springs do
		spring:Step(deltaTime)
	end

	local Sway = CurrentViewmodel.Springs.Sway.Position

	CurrentViewmodel:SetCFrame(Camera.CFrame * CFrame.Angles(-Sway.Y, -Sway.X, 0) * ViewmodelCFrame)
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local OriginPosition: Vector3 = Camera.CFrame.Position
		local LookVector: Vector3 = Camera.CFrame.LookVector

		workspace.FireSounds.fire:Play()
		workspace.FireSounds.distant:Play()

		WeaponFire(OriginPosition, LookVector)
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		Aiming = true
		UserInputService.MouseIconEnabled = false
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		Aiming = false
		UserInputService.MouseIconEnabled = true
	end
end)

RunService.RenderStepped:Connect(function(deltaTime)
	UpdateViewmodel(deltaTime)
end)
