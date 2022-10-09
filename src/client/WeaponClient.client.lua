local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Utility = ReplicatedFirst:WaitForChild("Utility")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Gameplay = Assets:WaitForChild("Gameplay")
local Environment = Gameplay:WaitForChild("Environment")
local Classes = Shared:WaitForChild("Classes")
local Modules = Shared:WaitForChild("Modules")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local LerpTools = require(Utility.LerpUtil)
local Link = require(Packages:WaitForChild("link"))
local Viewmodel = require(Classes:WaitForChild("Viewmodel"))
local Animator = require(Classes:WaitForChild("Animator"))
local Spring = require(Classes:WaitForChild("Spring"))
local RaycastHandler = require(Modules:WaitForChild("RaycastHandler"))
local VFXHandler = require(Modules:WaitForChild("VFXHandler"))
local SFXHandler = require(Modules:WaitForChild("SFXHandler"))

local RequestForRNGSeedSignal = Link.WaitEvent("RequestForRNGSeed")
local SendRNGSeedSignal = Link.WaitEvent("SendRNGSeed")
local WeaponFireSignal = Link.WaitEvent("WeaponFire")

local CurrentViewmodel
local CurrentAnimator: Animator.AnimatorClass?
local idleObject = Instance.new("Animation")
idleObject.AnimationId = "rbxassetid://11060004291"
local ReloadAnimation = Instance.new("Animation")
ReloadAnimation.AnimationId = "rbxassetid://11086817696"
local EmptyReloadAnimation = Instance.new("Animation")
EmptyReloadAnimation.AnimationId = "rbxassetid://11087239261"
local CrouchIdleAnimation = Instance.new("Animation")
CrouchIdleAnimation.AnimationId = "rbxassetid://11213476779"
local CrouchWalkAnimation = Instance.new("Animation")
CrouchWalkAnimation.AnimationId = "rbxassetid://11213471255"
local IdleAnimation = Instance.new("Animation")
IdleAnimation.AnimationId = "rbxassetid://11219539529"
local WalkingAnimation = Instance.new("Animation")
WalkingAnimation.AnimationId = "rbxassetid://11218984236"
local RunningAnimation = Instance.new("Animation")
RunningAnimation.AnimationId = "rbxassetid://11218980268"

local WalkCycleX = 0.0
local WalkCycleY = 0.0
local CharacterVelocityMagnitude = 0.0
local SprintingModifier = 0.0
local FiringModifier = 0.0
local ReloadingModifier = 0.0
local MovingModifier = 0.0
local CamX, CamY, CamZ = 0.0, 0.0, 0.0

local WalkSpeedModifier = 1.0
local HipHeightModifier = 0.0

local ViewmodelCFrame = CFrame.new()
local ShiftButtonDown = false
local Mouse1Down = false
local Mouse2Down = false
local Sprinting = false
local Crouching = false
local Firing = false
local Reloading = false
local Aiming = false

local MaxAmmo = 25
local Ammo = 25

local function UpdateHUD()
	LocalPlayer.PlayerGui.HUD.Ammo.Text = Ammo .. " /" .. MaxAmmo
end

local function FindHumanoidAndDamage(Result)
	local Model = Result.Instance:FindFirstAncestorWhichIsA("Model")
	if Model then
		local Humanoid = Model:FindFirstChildWhichIsA("Humanoid")
		if Humanoid then
			Humanoid.Health = Humanoid.Health - 28
		end
	end
end

local function AddNoiseOnLookVector(partDepth, origin, direction, random)
	local RadiusModifier = (Random.new(random * 12345):NextNumber() / 0.25) * (partDepth * 2)
	local AngleModifier = (random * 360)
	local x = RadiusModifier * math.sin(math.rad(AngleModifier));
	local y = RadiusModifier * math.cos(math.rad(AngleModifier));
	return CFrame.new(origin, origin + direction) * CFrame.Angles(math.rad(y), math.rad(x), 0)
end

local function WeaponFire(startPoint: Vector3, lookVector: Vector3, randomNumber: number)
	local parameter = RaycastParams.new()
	parameter.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
	parameter.FilterType = Enum.RaycastFilterType.Blacklist
	CurrentViewmodel.Springs.Recoil:ApplyForce(Vector3.new(0, 0, math.random(32, 40)))
	CurrentViewmodel.Springs.RecoilNoise:ApplyForce(Vector3.new(0, 0, math.random(-8, 8)))

	VFXHandler:EmitMuzzleParticles(CurrentViewmodel.Model.WeaponModel.Handle.Muzzle)
	task.delay(0.02, function()
		VFXHandler:EmitMuzzleParticles(CurrentViewmodel.Model.WeaponModel.Handle.EjectionPort)
		VFXHandler:NewBulletShell(CurrentViewmodel.Model.WeaponModel.Handle.EjectionPort.WorldCFrame)
	end)
	SFXHandler:PlaySound(workspace.FireSounds.fire)

	-- normal raycast

	local PenetrationPower = 4
	print(PenetrationPower)

	local Result = RaycastHandler:Raycast(startPoint, lookVector, 1024, parameter)
	if not Result then
		-- ParticleEffects:__CreateRaycastDebug(Camera.CFrame.Position, origin + (direction * 1024))
		VFXHandler:NewBulletSmoke(CurrentViewmodel.Model.WeaponModel.Handle.Muzzle.WorldPosition, startPoint + (lookVector * 16))
		VFXHandler:NewTracer(CurrentViewmodel.Model.WeaponModel.Handle.Muzzle.WorldPosition, CurrentViewmodel.Model.WeaponModel.Handle.Muzzle.WorldPosition + (lookVector * 1024))
		return
	end
	PenetrationPower = PenetrationPower - ((startPoint - Result.Position).Magnitude / 1024)
	print(PenetrationPower)
	-- ParticleEffects:__CreateRaycastDebug(Camera.CFrame.Position, Result.Position)
	VFXHandler:NewBulletHole(Result.Position, Result.Normal, Result.Instance)
	VFXHandler:NewBulletSmoke(CurrentViewmodel.Model.WeaponModel.Handle.Muzzle.WorldPosition, Result.Position)
	VFXHandler:NewTracer(CurrentViewmodel.Model.WeaponModel.Handle.Muzzle.WorldPosition, Result.Position)

	FindHumanoidAndDamage(Result)

	local WallbangCount = 1

	repeat
		-- finding part thickness

		local DepthResult, Depth = RaycastHandler:CheckHitDepth(Result.Instance, Result.Position, lookVector)
		if not DepthResult then
			return
		end
		PenetrationPower = PenetrationPower - Depth
		print(PenetrationPower)
		if PenetrationPower < 0 then
			break
		end

		-- wall bang thing

		local WallbangDirection = AddNoiseOnLookVector(Depth, startPoint, lookVector, randomNumber)
		local RemainingDistance = (1024 - (startPoint - DepthResult.Position).Magnitude)
		VFXHandler:NewBulletExit(DepthResult.Position, DepthResult.Normal, DepthResult.Instance, WallbangDirection.LookVector)
		local WallbangResult: RaycastResult = RaycastHandler:Raycast(DepthResult.Position, WallbangDirection.LookVector, RemainingDistance, parameter)
		PenetrationPower = PenetrationPower - ((startPoint - Result.Position).Magnitude / 1024)
		print(PenetrationPower)
		if not WallbangResult then
			-- ParticleEffects:__CreateRaycastDebug(ThicknessResult.Position, RemainingDistanceLookVector)
			VFXHandler:NewBulletSmoke(DepthResult.Position, DepthResult.Position + (lookVector * 16))
			return
		end
		-- ParticleEffects:__CreateRaycastDebug(ThicknessResult.Position, WallbangResult.Position)
		VFXHandler:NewBulletHole(WallbangResult.Position, WallbangResult.Normal, WallbangResult.Instance)
		VFXHandler:NewBulletSmoke(DepthResult.Position, WallbangResult.Position)

		Result = WallbangResult
		startPoint = DepthResult.Position
		lookVector = WallbangDirection.LookVector

		WallbangCount = WallbangCount + 1
		FindHumanoidAndDamage(WallbangResult)
	until WallbangCount > 4
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

	for _, spring: Spring.SpringClass in CurrentViewmodel.Springs do
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

local function UpdateHumanoid(deltaTime)
	LerpTools.DeltaTime = deltaTime

	if Sprinting then
		WalkSpeedModifier = LerpTools:LinearInterpolate(WalkSpeedModifier, 1.25, 16)
		HipHeightModifier = LerpTools:LinearInterpolate(HipHeightModifier, 0, 8)
	elseif Crouching then
		WalkSpeedModifier = LerpTools:LinearInterpolate(WalkSpeedModifier, 0.5, 16)
		HipHeightModifier = LerpTools:LinearInterpolate(HipHeightModifier, 1, 8)
	else
		WalkSpeedModifier = LerpTools:LinearInterpolate(WalkSpeedModifier, 1, 16)
		HipHeightModifier = LerpTools:LinearInterpolate(HipHeightModifier, 0, 8)
	end

	LocalPlayer.Character.Humanoid.HipHeight = -HipHeightModifier
	LocalPlayer.Character.Humanoid.WalkSpeed = 16 * WalkSpeedModifier
end

local function AmmunitionLogic()
	if Ammo > 0 then
		CurrentViewmodel.Animator.Tracks.reload:Play()
		Reloading = true
		CurrentViewmodel.Animator.Tracks.reload.Stopped:Once(function()
			Ammo = MaxAmmo + 1
			UpdateHUD()
			Reloading = false
		end)
	elseif Ammo == 0 then
		CurrentViewmodel.Animator.Tracks.emptyReload:Play()
		Reloading = true
		CurrentViewmodel.Animator.Tracks.emptyReload.Stopped:Once(function()
			Ammo = MaxAmmo
			UpdateHUD()
			Reloading = false
		end)
	end
end

local RNG: Random

RequestForRNGSeedSignal:FireServer()
SendRNGSeedSignal.Event:Connect(function(Seed)
	RNG = Random.new(Seed)
end)

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
			local random = RNG:NextNumber()
			local OriginPosition: Vector3 = Camera.CFrame.Position
			local LookVector: Vector3 = Camera.CFrame.LookVector

			workspace.FireSounds.fire:Play()
			workspace.FireSounds.distant:Play()

			WeaponFire(OriginPosition, LookVector, random)
			WeaponFireSignal:FireServer(OriginPosition, LookVector)
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
		Crouching = false
		Aiming = false

		ShiftButtonDown = true
		Sprinting = true
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		Sprinting = false
		Crouching = true
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
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		Crouching = false
	end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
	CurrentViewmodel = Viewmodel.new(ReplicatedStorage.v_UMP45)
	CurrentAnimator = Animator.new()
	CurrentAnimator.Animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")

	CurrentViewmodel.Animator:Load(idleObject, "idle"):Play(0.1, 1, 1)
	CurrentViewmodel.Animator:Load(ReloadAnimation, "reload")
	CurrentViewmodel.Animator:Load(EmptyReloadAnimation, "emptyReload")

	CurrentViewmodel:Decorate(ReplicatedStorage.DecorationArms)
	CurrentViewmodel:Cull(false)

	CurrentAnimator:Load(IdleAnimation, "idle"):Play(0.1, 1)
	CurrentAnimator:Load(CrouchIdleAnimation, "crouchIdle"):Play(0.1, 0)
	CurrentAnimator:Load(CrouchWalkAnimation, "crouchWalk"):Play(0.1, 0)
	CurrentAnimator:Load(WalkingAnimation, "walkingAnimation"):Play(0.1, 0)
	CurrentAnimator:Load(RunningAnimation, "runningAnimation"):Play(0.1, 0)
end)

LocalPlayer.CharacterRemoving:Connect(function(character)
	CurrentViewmodel:CleanUp()
	CurrentViewmodel = nil
	CurrentAnimator:Destroy()
	CurrentAnimator = nil :: Animator.AnimatorClass?
end)

local moveSwitch = false
local stoppedSwitch = true

RunService.RenderStepped:Connect(function(deltaTime)
	if CurrentViewmodel then
		UpdateViewmodel(deltaTime)
	end
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		UpdateHumanoid(deltaTime)
		local CharacterVelocity = LocalPlayer.Character.HumanoidRootPart:GetVelocityAtPosition(LocalPlayer.Character.HumanoidRootPart.Position)
		local Speed = Vector2.new(CharacterVelocity.X, CharacterVelocity.Z).Magnitude

		if CurrentAnimator then
			pcall(function()
				if Speed <= 0.1 then
					Speed = 0
					if stoppedSwitch then
						stoppedSwitch = false
						CurrentAnimator.Tracks.walkingAnimation:Stop(0.1)
						CurrentAnimator.Tracks.runningAnimation:Stop(0.1)
						CurrentAnimator.Tracks.crouchWalk:Stop(0.1)
						CurrentAnimator.Tracks.idle:Play(0.1, 1)
						CurrentAnimator.Tracks.crouchIdle:Play(0.1, 0)
					end
					CurrentAnimator.Tracks.idle:AdjustWeight(math.clamp(1 - Speed, 0, 1))
					CurrentAnimator.Tracks.crouchIdle:AdjustWeight(math.abs(HipHeightModifier))
					moveSwitch = true
				else
					if moveSwitch then
						moveSwitch = false
						CurrentAnimator.Tracks.walkingAnimation:Play(0.1, 0, 1)
						CurrentAnimator.Tracks.runningAnimation:Play(0.1, 0, 1)
						CurrentAnimator.Tracks.crouchWalk:Play(0.1, 0, 1)
					end
					CurrentAnimator.Tracks.walkingAnimation:AdjustWeight((Speed + HipHeightModifier) * (1 - SprintingModifier), 0.2)
					CurrentAnimator.Tracks.runningAnimation:AdjustWeight((Speed + HipHeightModifier) * SprintingModifier, 0.2)
					CurrentAnimator.Tracks.crouchWalk:AdjustWeight(Speed * math.abs(HipHeightModifier), 0.2)
					CurrentAnimator.Tracks.idle:AdjustWeight(math.clamp(1 - Speed, 0, 1))
					CurrentAnimator.Tracks.crouchIdle:AdjustWeight(math.abs(HipHeightModifier))
					stoppedSwitch = true
				end
				-- CurrentAnimator.Tracks.idle:AdjustWeight(math.clamp(1 - Speed, 0, 1))
				-- CurrentAnimator.Tracks.walkingAnimation:AdjustWeight(Speed * (1 - HipHeightModifier) * (1 - SprintingModifier))
				-- CurrentAnimator.Tracks.runningAnimation:AdjustWeight(Speed * (1 - HipHeightModifier) * SprintingModifier)
				-- CurrentAnimator.Tracks.crouchIdle:AdjustWeight(HipHeightModifier)
				-- CurrentAnimator.Tracks.crouchWalk:AdjustWeight(Speed * HipHeightModifier)
				CurrentAnimator.Tracks.walkingAnimation:AdjustSpeed((Speed / 16))
				CurrentAnimator.Tracks.runningAnimation:AdjustSpeed((Speed / 16))
				CurrentAnimator.Tracks.crouchWalk:AdjustSpeed((Speed / 16))
			end)
		end
	end

	UserInputService.MouseIconEnabled = not Aiming
end)
