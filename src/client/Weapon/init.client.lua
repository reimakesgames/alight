local Players = game:GetService("Players")
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
local Anim = Instance.new("Animation")
Anim.AnimationId = "rbxassetid://11060004291"
CurrentViewmodel.Model.AnimationController.Animator:LoadAnimation(Anim):Play()

local Player = Players.LocalPlayer

local function LinearInterpolate(x: number, y: number, alpha: number)
	return x * (1 - alpha) + y * alpha
end
local CharacterVelocityMagnitude = 0

local ViewmodelCFrame = CFrame.new()
local Mouse1Down = false
local Mouse2Down = false
local Firing = false

local function WeaponFire(origin: Vector3, direction: Vector3)
	CurrentViewmodel.Springs.Recoil:ApplyForce(Vector3.new(0, 0, math.random(32, 40)))
	CurrentViewmodel.Springs.RecoilNoise:ApplyForce(Vector3.new(0, 0, math.random(-8, 8)))

	CastEffects:EmitParticlesFrom(CurrentViewmodel.Model.WeaponModel.Handle.Exit)

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
	local CharacterVelocity = Player.Character.HumanoidRootPart:GetVelocityAtPosition(Player.Character.HumanoidRootPart.Position)
	CharacterVelocityMagnitude = LinearInterpolate(CharacterVelocityMagnitude, Vector3.new(CharacterVelocity.X, 0, CharacterVelocity.Z).Magnitude, deltaTime * 8)
	CurrentViewmodel.Springs.Sway:ApplyForce(Vector3.new(MouseDelta.X / 256, MouseDelta.Y / 256))
	CurrentViewmodel.Springs.WalkCycle:ApplyForce(Vector3.new(math.sin(time() * 20), math.sin(time() * 10), 0))

	local AimCFrame = CurrentViewmodel.Model.HumanoidRootPart.CFrame:ToObjectSpace(CurrentViewmodel.Model.WeaponModel.Handle.AimPoint.WorldCFrame)

	if Mouse2Down then
		ViewmodelCFrame = ViewmodelCFrame:Lerp(AimCFrame:Inverse(), deltaTime * 12)
	else
		ViewmodelCFrame = ViewmodelCFrame:Lerp(CFrame.new(0, 0, 0), deltaTime * 12)
	end

	for _, spring: Spring.Spring in CurrentViewmodel.Springs do
		spring:Step(deltaTime)
	end

	local Sway = CurrentViewmodel.Springs.Sway.Position
	local WalkCycle = CurrentViewmodel.Springs.WalkCycle.Position
	local Recoil = CurrentViewmodel.Springs.Recoil.Position
	local RecoilNoise = CurrentViewmodel.Springs.RecoilNoise.Position

	local PercentageToGoal = ViewmodelCFrame.Position.Magnitude / AimCFrame.Position.Magnitude

	local SwayAngles = CFrame.Angles(
		-Sway.Y * (0.1 + ((1 - PercentageToGoal) * 0.9)), -- Up and down
		-Sway.X * (1 - PercentageToGoal), -- Left and right
		-- -Sway.X,
		(-Sway.X * 0.5) * PercentageToGoal -- tilt left and right on zoom
	)

	local RecoilOffset = CFrame.new(
		0,
		0,
		Recoil.Z / 32
	)

	local RecoilNoise = CFrame.Angles(
		0,
		0,
		(RecoilNoise.Z / 32) * PercentageToGoal
	)

	local WalkCycleAngles = CFrame.Angles(
		(WalkCycle.X / 512) * CharacterVelocityMagnitude * (0.1 + ((1 - PercentageToGoal) * 0.9)),
		(WalkCycle.Y / 512) * CharacterVelocityMagnitude * (0.1 + ((1 - PercentageToGoal) * 0.9)),
		0
	)

	CurrentViewmodel:SetCFrame(Camera.CFrame * RecoilNoise * SwayAngles * WalkCycleAngles * ViewmodelCFrame * RecoilOffset)
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if Firing then return end

		Mouse1Down = true
		repeat
			Firing = true
			local OriginPosition: Vector3 = Camera.CFrame.Position
			local LookVector: Vector3 = Camera.CFrame.LookVector

			workspace.FireSounds.fire:Play()
			workspace.FireSounds.distant:Play()

			WeaponFire(OriginPosition, LookVector)
			task.wait(0.1)
			Firing = false
		until not Mouse1Down
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		Mouse2Down = true
		UserInputService.MouseIconEnabled = false
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Mouse1Down = false
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		Mouse2Down = false
		UserInputService.MouseIconEnabled = true
	end
end)

RunService.RenderStepped:Connect(function(deltaTime)
	UpdateViewmodel(deltaTime)
end)
