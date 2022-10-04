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

local Spring = require(Utility.Spring)
local LerpTools = require(Utility.LerpTools)

local Caster = require(script.Caster)
local ParticleEffects = require(script.ParticleEffects)
local SoundEffects = require(script.SoundEffects)
local Viewmodel = require(script.Viewmodel)

local CurrentViewmodel
local Anim = Instance.new("Animation")
Anim.AnimationId = "rbxassetid://11060004291"
local Anim2 = Instance.new("Animation")
Anim2.AnimationId = "rbxassetid://11086817696"
local Anim3 = Instance.new("Animation")
Anim3.AnimationId = "rbxassetid://11087239261"
local reloadAnimation, emptyReloadAnimation

local WalkCycleX = 0
local WalkCycleY = 0
local CharacterVelocityMagnitude = 0
local SprintingModifier = 0
local FiringModifier = 0
local ReloadingModifier = 0
local WalkSpeedModifier = 1
local MovingModifier = 0
local CamX, CamY, CamZ = 0, 0, 0

local ViewmodelCFrame = CFrame.new()
local ShiftButtonDown = false
local Mouse1Down = false
local Mouse2Down = false
local Sprinting = false
local Firing = false
local Reloading = false
local Aiming = false

local MaxAmmo = 25
local Ammo = 25

local function UpdateHUD()
	LocalPlayer.PlayerGui.HUD.Ammo.Text = Ammo .. " /" .. MaxAmmo
end

local function WeaponFire(origin: Vector3, direction: Vector3)
	CurrentViewmodel.Springs.Recoil:ApplyForce(Vector3.new(0, 0, math.random(32, 40)))
	CurrentViewmodel.Springs.RecoilNoise:ApplyForce(Vector3.new(0, 0, math.random(-8, 8)))

	ParticleEffects:EmitParticlesFrom(CurrentViewmodel.Model.WeaponModel.Handle.Muzzle)
	task.delay(0.02, function()
		ParticleEffects:EmitParticlesFrom(CurrentViewmodel.Model.WeaponModel.Handle.EjectionPort)
		ParticleEffects:NewBulletShell(CurrentViewmodel.Model.WeaponModel.Handle.EjectionPort.WorldCFrame)
	end)
	SoundEffects:PlaySound(workspace.FireSounds.fire)

	local Result: RaycastResult = Caster:Cast(origin, direction * 1024)

	if not Result then
		ParticleEffects:NewBulletSmoke(CurrentViewmodel.Model.WeaponModel.Handle.Muzzle.WorldPosition, origin + (direction * 1024))
		ParticleEffects:CreateFakeTracer(CurrentViewmodel.Model.WeaponModel.Handle.Muzzle.WorldPosition, origin + (direction * 1024))
		return
	end

	ParticleEffects:NewBulletHole(Result.Position, Result.Normal, Result.Instance)
	ParticleEffects:NewBulletSmoke(CurrentViewmodel.Model.WeaponModel.Handle.Muzzle.WorldPosition, Result.Position)
	-- CastEffects:CreateFakeTracer(Origin, Result.Position)
	ParticleEffects:CreateFakeTracer(CurrentViewmodel.Model.WeaponModel.Handle.Muzzle.WorldPosition, Result.Position)

	local Model = Result.Instance:FindFirstAncestorWhichIsA("Model")
	if Model then
		local Humanoid = Model:FindFirstChildWhichIsA("Humanoid")
		if Humanoid then
			Humanoid.Health = Humanoid.Health - 28
		end
	end

	local PartDepth, HitPosition = Caster:FindThickness(Result.Instance, Result.Position, Result.Position + (direction * 64), -direction * 64)

	if not PartDepth then
		return
	end
end

local function UpdateViewmodel(deltaTime)
	LerpTools.DeltaTime = deltaTime
	WalkCycleX = WalkCycleX + (deltaTime * 20 * WalkSpeedModifier)
	WalkCycleY = WalkCycleY + (deltaTime * 10 * WalkSpeedModifier)

	local MouseDelta = UserInputService:GetMouseDelta()
	local CharacterVelocity = LocalPlayer.Character.HumanoidRootPart:GetVelocityAtPosition(LocalPlayer.Character.HumanoidRootPart.Position)
	CharacterVelocityMagnitude = LerpTools:LinearInterpolate(CharacterVelocityMagnitude, Vector3.new(CharacterVelocity.X, 0, CharacterVelocity.Z).Magnitude, 8)
	FiringModifier = Firing and 0 or LerpTools:LinearInterpolate(FiringModifier, 1, 16)
	SprintingModifier = LerpTools:LinearInterpolate(SprintingModifier, Sprinting and 1 or 0, 16)
	ReloadingModifier = LerpTools:LinearInterpolate(ReloadingModifier, Reloading and 1 or 0, 8)
	MovingModifier = LerpTools:LinearInterpolate(MovingModifier, math.clamp(Vector3.new(CharacterVelocity.X, 0, CharacterVelocity.Z).Magnitude / 8, 0, 1), 16)

	CurrentViewmodel.Springs.Sway:ApplyForce(Vector3.new(MouseDelta.X / 256, MouseDelta.Y / 256))
	CurrentViewmodel.Springs.SwayPivot:ApplyForce(Vector3.new(MouseDelta.X / 256, MouseDelta.Y / 256))
	CurrentViewmodel.Springs.WalkCycle:ApplyForce(Vector3.new(math.sin(WalkCycleX) * (deltaTime * 32), math.sin(WalkCycleY) * (deltaTime * 32), 0))

	local AimCFrame = CurrentViewmodel.Model.HumanoidRootPart.CFrame:ToObjectSpace(CurrentViewmodel.Model.WeaponModel.Handle.AimPoint.WorldCFrame)
	local RootCameraCFrame = CurrentViewmodel.Model.HumanoidRootPart.CFrame:ToObjectSpace(CurrentViewmodel.Model.Camera.CFrame)
	local x, y, z = RootCameraCFrame:ToEulerAnglesYXZ()
	CamX, CamY, CamZ = LerpTools:LinearInterpolate(CamX, x, 16), LerpTools:LinearInterpolate(CamY, y, 16), LerpTools:LinearInterpolate(CamZ, z, 16)
	local RootCameraAngles = CFrame.Angles(CamX, CamY, CamZ)

	if Aiming then
		ViewmodelCFrame = ViewmodelCFrame:Lerp(AimCFrame:Inverse(), LerpTools:CreateFramerateIndependentAlpha(12))
	else
		ViewmodelCFrame = ViewmodelCFrame:Lerp(CFrame.new(0, 0, 0), LerpTools:CreateFramerateIndependentAlpha(12))
	end

	local PivotPointCFrame = (CurrentViewmodel.Model.HumanoidRootPart.CFrame * ViewmodelCFrame:Inverse()):ToObjectSpace(CurrentViewmodel.Model.WeaponModel.Handle.PivotPoint.WorldCFrame)

	for _, spring: Spring.Spring in CurrentViewmodel.Springs do
		spring:Step(deltaTime)
	end

	local Sway = CurrentViewmodel.Springs.Sway.Position
	local SwayPivot = CurrentViewmodel.Springs.Sway.Position
	local WalkCycle = CurrentViewmodel.Springs.WalkCycle.Position
	local Recoil = CurrentViewmodel.Springs.Recoil.Position
	local RecoilNoise = CurrentViewmodel.Springs.RecoilNoise.Position

	local PercentageToGoal = ViewmodelCFrame.Position.Magnitude / AimCFrame.Position.Magnitude

	local SwayAngles = CFrame.Angles(
		-Sway.Y * (0.1 + ((1 - PercentageToGoal) * 0.9)) * (1 - SprintingModifier), -- Up and down
		-Sway.X * (1 - PercentageToGoal) * (1 - SprintingModifier), -- Left and right
		-- -Sway.X,
		(-Sway.X * 0.5) * PercentageToGoal -- tilt left and right on zoom
	)

	local RecoilOffset = CFrame.new(
		0,
		0,
		Recoil.Z / 32
	)

	local RecoilNoiseAngles = CFrame.Angles(
		0,
		RecoilNoise.Z / 512,
		(RecoilNoise.Z / 32) * PercentageToGoal
	)

	local WalkCycleAngles = CFrame.Angles(
		(WalkCycle.X / 1024) * CharacterVelocityMagnitude * (0.25 + ((1 - PercentageToGoal) * 0.75)) * (1 - ReloadingModifier) * (1 + (SprintingModifier * 4)),
		(WalkCycle.Y / 1024) * CharacterVelocityMagnitude * (0.25 + ((1 - PercentageToGoal) * 0.75)) * (1 - ReloadingModifier) * (1 + (SprintingModifier * 8)),
		0
	)

	local SprintingShift = CFrame.Angles(
		0,
		(SprintingModifier * (1 - PercentageToGoal)) * FiringModifier * ((WalkSpeedModifier - 1) * 4) * MovingModifier,
		0
	)

	local PivotPointAngles = CFrame.Angles(
		-Recoil.Z / 512,
		SwayPivot.X / 16 * PercentageToGoal,
		RecoilNoise.Z / 256
	)

	Camera.CFrame = Camera.CFrame * RootCameraAngles
	local BaseCFrame = RecoilNoiseAngles * SwayAngles * WalkCycleAngles * SprintingShift * ViewmodelCFrame * RecoilOffset
	local RotatedCFrame = (PivotPointCFrame * PivotPointAngles):ToObjectSpace(BaseCFrame)
	local RevertedRotatedCFrame:CFrame = Camera.CFrame * PivotPointCFrame:ToWorldSpace(RotatedCFrame)
	if RunService:IsStudio() then
		workspace.T.CFrame = Camera.CFrame + (RevertedRotatedCFrame.LookVector * 32)
	end
	CurrentViewmodel:SetCFrame(RevertedRotatedCFrame)
end

local function UpdateCharacterWalkSpeed(deltaTime)
	LerpTools.DeltaTime = deltaTime

	if Sprinting then
		WalkSpeedModifier = LerpTools:LinearInterpolate(WalkSpeedModifier, 1.25, 16)
	else
		WalkSpeedModifier = LerpTools:LinearInterpolate(WalkSpeedModifier, 1, 16)
	end

	LocalPlayer.Character.Humanoid.WalkSpeed = 16 * WalkSpeedModifier
end

local function AmmunitionLogic()
	if Ammo > 0 then
		reloadAnimation:Play()
		Reloading = true
		reloadAnimation.Stopped:Once(function()
			Ammo = MaxAmmo + 1
			UpdateHUD()
			Reloading = false
		end)
	elseif Ammo == 0 then
		emptyReloadAnimation:Play()
		Reloading = true
		emptyReloadAnimation.Stopped:Once(function()
			Ammo = MaxAmmo
			UpdateHUD()
			Reloading = false
		end)
	end
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if Firing then return end
		if Ammo == 0 then return end
		if Reloading then return end

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
		if Firing then return end
		if Reloading then return end
		Aiming = false

		ShiftButtonDown = true
		Sprinting = true
	elseif input.KeyCode == Enum.KeyCode.R then
		if Firing then return end
		if Ammo >= MaxAmmo + 1 then return end
		if Reloading then return end
		Sprinting = false

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
