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
local LocalPlayer = Players.LocalPlayer

local Caster = require(script.Caster)
local CastEffects = require(script.CastEffects)
local SoundEffects = require(script.SoundEffects)
local Viewmodel = require(script.Viewmodel)
local Spring = require(Utility.Spring)

local CurrentViewmodel
local Anim = Instance.new("Animation")
Anim.AnimationId = "rbxassetid://11060004291"
local Anim2 = Instance.new("Animation")
Anim2.AnimationId = "rbxassetid://11086817696"
local Anim3 = Instance.new("Animation")
Anim3.AnimationId = "rbxassetid://11087239261"
local reloadAnimation, emptyReloadAnimation

local Player = Players.LocalPlayer

local function LinearInterpolate(x: number, y: number, alpha: number)
	return x * (1 - alpha) + y * alpha
end
local CharacterVelocityMagnitude = 0
local SprintingModifier = 0
local FiringModifier = 0
local WalkSpeedModifier = 1
local CamX, CamY, CamZ = 0, 0, 0

local ViewmodelCFrame = CFrame.new()
local ShiftButtonDown = false
local Mouse1Down = false
local Mouse2Down = false
local Sprinting = false
local Firing = false
local Aiming = false

local MaxAmmo = 30
local Ammo = 30

local function UpdateHUD()
	LocalPlayer.PlayerGui.HUD.Ammo.Text = Ammo .. " /" .. MaxAmmo
end

local function WeaponFire(origin: Vector3, direction: Vector3)
	CurrentViewmodel.Springs.Recoil:ApplyForce(Vector3.new(0, 0, math.random(32, 40)))
	CurrentViewmodel.Springs.RecoilNoise:ApplyForce(Vector3.new(0, 0, math.random(-8, 8)))

	CastEffects:EmitParticlesFrom(CurrentViewmodel.Model.WeaponModel.Handle.Exit)
	SoundEffects:PlaySound(workspace.FireSounds.fire)

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
	local PastMinVelocity = Vector3.new(CharacterVelocity.X, 0, CharacterVelocity.Z).Magnitude > 8 and 1 or 0
	FiringModifier = Firing and 0 or LinearInterpolate(FiringModifier, 1, deltaTime * 16)
	SprintingModifier = LinearInterpolate(SprintingModifier, PastMinVelocity, deltaTime * 16)

	CurrentViewmodel.Springs.Sway:ApplyForce(Vector3.new(MouseDelta.X / 256, MouseDelta.Y / 256))
	CurrentViewmodel.Springs.WalkCycle:ApplyForce(Vector3.new(math.sin(time() * 20 * WalkSpeedModifier), math.sin(time() * 10 * WalkSpeedModifier), 0))

	local AimCFrame = CurrentViewmodel.Model.HumanoidRootPart.CFrame:ToObjectSpace(CurrentViewmodel.Model.WeaponModel.Handle.AimPoint.WorldCFrame)
	local RootCameraCFrame = CurrentViewmodel.Model.HumanoidRootPart.CFrame:ToObjectSpace(CurrentViewmodel.Model.Camera.CFrame)
	local x, y, z = RootCameraCFrame:ToEulerAnglesYXZ()
	CamX, CamY, CamZ = LinearInterpolate(CamX, x, deltaTime * 4), LinearInterpolate(CamY, y, deltaTime * 4), LinearInterpolate(CamZ, z, deltaTime * 4)
	local RootCameraAngles = CFrame.Angles(CamX, CamY, CamZ)

	if Aiming then
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

	local SprintingShift = CFrame.Angles(
		0,
		(SprintingModifier * (1 - PercentageToGoal)) * FiringModifier * ((WalkSpeedModifier - 1) * 4),
		0
	)

	Camera.CFrame = Camera.CFrame * RootCameraAngles
	CurrentViewmodel:SetCFrame(Camera.CFrame * RecoilNoise * SwayAngles * WalkCycleAngles * SprintingShift * ViewmodelCFrame * RecoilOffset)
end

local function UpdateCharacterWalkSpeed(deltaTime)
	if Sprinting then
		WalkSpeedModifier = LinearInterpolate(WalkSpeedModifier, 1.25, (deltaTime * 16))
	else
		WalkSpeedModifier = LinearInterpolate(WalkSpeedModifier, 1, (deltaTime * 16))
	end

	LocalPlayer.Character.Humanoid.WalkSpeed = 16 * WalkSpeedModifier
end

local function AmmunitionLogic()
	if Ammo >= MaxAmmo + 1 then
		return
	elseif Ammo > 0 then
		reloadAnimation:Play()
		reloadAnimation.Stopped:Once(function()
			Ammo = MaxAmmo + 1
			UpdateHUD()
		end)
	elseif Ammo == 0 then
		emptyReloadAnimation:Play()
		emptyReloadAnimation.Stopped:Once(function()
			Ammo = MaxAmmo
			UpdateHUD()
		end)
	end
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if Firing or Ammo == 0 then return end

		Sprinting = false
		Mouse1Down = true
		repeat
			Firing = true
			local OriginPosition: Vector3 = Camera.CFrame.Position
			local LookVector: Vector3 = Camera.CFrame.LookVector

			workspace.FireSounds.fire:Play()
			workspace.FireSounds.distant:Play()

			WeaponFire(OriginPosition, LookVector)
			Ammo = Ammo - 1
			UpdateHUD()
			task.wait(0.1)
			Firing = false
		until not Mouse1Down or Ammo == 0
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		Sprinting = false
		Mouse2Down = true
		Aiming = true
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		Aiming = false

		ShiftButtonDown = true
		Sprinting = true
	elseif input.KeyCode == Enum.KeyCode.R then
		AmmunitionLogic()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Mouse1Down = false
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		Mouse2Down = false
		Aiming = false
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		ShiftButtonDown = false
		Sprinting = false
	end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
	CurrentViewmodel = Viewmodel.new(ReplicatedStorage.v_UMP45)
	CurrentViewmodel:Decorate(ReplicatedStorage.DecorationArms)
	CurrentViewmodel.Model.AnimationController.Animator:LoadAnimation(Anim):Play()
	reloadAnimation = CurrentViewmodel.Model.AnimationController.Animator:LoadAnimation(Anim2)
	emptyReloadAnimation = CurrentViewmodel.Model.AnimationController.Animator:LoadAnimation(Anim3)
end)

LocalPlayer.CharacterRemoving:Connect(function(character)
	CurrentViewmodel:CleanUp()
	CurrentViewmodel = nil
end)

RunService.RenderStepped:Connect(function(deltaTime)
	if CurrentViewmodel then
		UpdateViewmodel(deltaTime)
	end
	UpdateCharacterWalkSpeed(deltaTime)

	UserInputService.MouseIconEnabled = not Aiming
end)
