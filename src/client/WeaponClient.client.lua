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
local Prisma = require(Packages:WaitForChild("prisma"))
local Viewmodel = require(Classes:WaitForChild("Viewmodel"))
local Animator = require(Classes:WaitForChild("Animator"))
local Spring = require(Classes:WaitForChild("Spring"))
local RaycastHandler = require(Modules:WaitForChild("RaycastHandler"))
local VFXHandler = require(Modules:WaitForChild("VFXHandler"))
local SFXHandler = require(Modules:WaitForChild("SFXHandler"))

local RequestForRNGSeedSignal = Link:WaitEvent("RequestForRNGSeed")
local SendRNGSeedSignal = Link:WaitEvent("SendRNGSeed")
local WeaponFireSignal = Link:WaitEvent("WeaponFire")

local Viewmodels = {}
local CurrentViewmodel: Viewmodel.ViewmodelClass?
local CurrentAnimator: Animator.AnimatorClass?
local _CurrentTool: Tool?
local WeaponIdleAnimation = Instance.new("Animation")
WeaponIdleAnimation.AnimationId = "rbxassetid://11060004291"
local WeaponInspectAnimation = Instance.new("Animation")
WeaponInspectAnimation.AnimationId = "rbxassetid://11303640542"
local WeaponReloadAnimation = Instance.new("Animation")
WeaponReloadAnimation.AnimationId = "rbxassetid://11086817696"
local WeaponEmptyReloadAnimation = Instance.new("Animation")
WeaponEmptyReloadAnimation.AnimationId = "rbxassetid://11087239261"

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

local CrouchToolIdleAnimation = Instance.new("Animation")
CrouchToolIdleAnimation.AnimationId = "rbxassetid://11240708962"
local CrouchToolWalkAnimation = Instance.new("Animation")
CrouchToolWalkAnimation.AnimationId = "rbxassetid://11240710136"
local IdleToolAnimation = Instance.new("Animation")
IdleToolAnimation.AnimationId = "rbxassetid://11240305064"
local WalkingToolAnimation = Instance.new("Animation")
WalkingToolAnimation.AnimationId = "rbxassetid://11240352821"
local RunningToolAnimation = Instance.new("Animation")
RunningToolAnimation.AnimationId = "rbxassetid://11240170037"

local WalkCycleX = 0.0
local WalkCycleY = 0.0
local CharacterVelocityMagnitude = 0.0
local EquippedModifier = 0.0
local SprintingModifier = 0.0
local FiringModifier = 0.0
local ReloadingModifier = 0.0
local MovingModifier = 0.0
local CamX, CamY, CamZ = 0.0, 0.0, 0.0

local WalkSpeedModifier = 1.0
local HipHeightModifier = 0.0

local ViewmodelCFrame = CFrame.new()
local _ShiftButtonDown = false
local Mouse1Down = false
local _Mouse2Down = false
local ActiveTool = false
local Sprinting = false
local Crouching = false
local Firing = false
local Reloading = false
local Aiming = false
local Inspecting = false

local ReloadThread: thread

local Reserve = 75
local Capacity = 25
local Magazine = 25

Prisma:ToggleLegRotation(false)

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
	EquippedModifier = LerpTools:LinearInterpolate(EquippedModifier, ActiveTool and 1 or 0, 32)
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

local function UpdateHUD()
	local HUD = LocalPlayer.PlayerGui:FindFirstChild("HUD")
	if not HUD then
		return
	end
	HUD.Enabled = ActiveTool
	local Body = HUD:FindFirstChild("Ammunition")
	if not Body then
		return
	end
	local MagazineLabel = Body:FindFirstChild("Magazine")
	local ReserveLabel = Body:FindFirstChild("Reserve")
	MagazineLabel.Text = tostring(Magazine)
	ReserveLabel.Text = tostring(Reserve)
end

local function CancelInspect()
	Inspecting = false
	CurrentViewmodel.Animator.Tracks.idle:AdjustWeight(1)
	CurrentViewmodel.Animator.Tracks.inspect:Stop(0.0001)
end

local function ReloadBulletLogic()
	if Reserve == 0 then
		return
	end

	if Magazine > 0 then
		Reloading = true
		CurrentViewmodel.Animator.Tracks.reload:Play()
		task.wait(CurrentViewmodel.Animator.Tracks.reload.Length)
		local use = math.min((Capacity + 1) - Magazine, Reserve)
		Magazine = Magazine + use
		Reserve = Reserve - use
		UpdateHUD()

		Reloading = false
	elseif Magazine == 0 then
		Reloading = true
		CurrentViewmodel.Animator.Tracks.emptyReload:Play()
		task.wait(CurrentViewmodel.Animator.Tracks.emptyReload.Length)
		local use = math.min(Capacity - Magazine, Reserve)
		Magazine = Magazine + use
		Reserve = Reserve - use
		UpdateHUD()

		Reloading = false
	end
end

local function FireBulletLogic()
	Magazine = Magazine - 1
end

local RNG: Random

RequestForRNGSeedSignal:FireServer()
SendRNGSeedSignal.Event:Connect(function(Seed)
	RNG = Random.new(Seed)
end)

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if not ActiveTool then return end
		if Firing then return end
		if Magazine == 0 then return end
		if Reloading then return end
		CancelInspect()

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
			FireBulletLogic()
			UpdateHUD()
			task.wait(0.1)
			Firing = false
		until not Mouse1Down or Magazine == 0
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		if not ActiveTool then return end
		CancelInspect()

		Sprinting = false
		_Mouse2Down = true
		Aiming = true
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		if Firing then return end
		if Reloading then return end
		Crouching = false
		Aiming = false

		_ShiftButtonDown = true
		Sprinting = true
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		Sprinting = false
		Crouching = true
	elseif input.KeyCode == Enum.KeyCode.R then
		if not ActiveTool then return end
		if Firing then return end
		if Magazine >= Capacity + 1 then return end
		if Reloading then return end
		Sprinting = false

		ReloadThread = coroutine.create(ReloadBulletLogic)
		coroutine.resume(ReloadThread)
	elseif input.KeyCode == Enum.KeyCode.G then
		if not ActiveTool then return end
		if Firing then return end
		if Inspecting then return end
		Inspecting = true
		CurrentViewmodel.Animator.Tracks.idle:AdjustWeight(0.0001)
		CurrentViewmodel.Animator.Tracks.inspect:Play(0.1, 1, 1)
		CurrentViewmodel.Animator.Tracks.inspect.Stopped:Once(CancelInspect)
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Mouse1Down = false
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		_Mouse2Down = false
		Aiming = false
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		_ShiftButtonDown = false
		Sprinting = false
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		Crouching = false
	end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
	UpdateHUD()

	WalkCycleX = 0.0
	WalkCycleY = 0.0
	CharacterVelocityMagnitude = 0.0
	EquippedModifier = 0.0
	SprintingModifier = 0.0
	FiringModifier = 0.0
	ReloadingModifier = 0.0
	MovingModifier = 0.0
	CamX, CamY, CamZ = 0.0, 0.0, 0.0

	WalkSpeedModifier = 1.0
	HipHeightModifier = 0.0

	ViewmodelCFrame = CFrame.new()
	_ShiftButtonDown = false
	Mouse1Down = false
	_Mouse2Down = false
	ActiveTool = false
	Sprinting = false
	Crouching = false
	Firing = false
	Reloading = false
	Aiming = false

	Reserve = 75
	Capacity = 25
	Magazine = 25

	CurrentAnimator = Animator.new()
	CurrentAnimator.Animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")

	CurrentAnimator:Load(IdleAnimation, "idle"):Play(0.1, 1)
	CurrentAnimator:Load(CrouchIdleAnimation, "crouchIdle"):Play(0.1, 0)
	CurrentAnimator:Load(CrouchWalkAnimation, "crouchWalk"):Play(0.1, 0)
	CurrentAnimator:Load(WalkingAnimation, "walkingAnimation"):Play(0.1, 0)
	CurrentAnimator:Load(RunningAnimation, "runningAnimation"):Play(0.1, 0)

	CurrentAnimator:Load(IdleToolAnimation, "idleTool"):Play(0.1, 0)
	CurrentAnimator:Load(CrouchToolIdleAnimation, "crouchToolIdle"):Play(0.1, 0)
	CurrentAnimator:Load(CrouchToolWalkAnimation, "crouchToolWalk"):Play(0.1, 0)
	CurrentAnimator:Load(WalkingToolAnimation, "walkingToolAnimation"):Play(0.1, 0)
	CurrentAnimator:Load(RunningToolAnimation, "runningToolAnimation"):Play(0.1, 0)

	character.ChildAdded:Connect(function(object)
		if not object:IsA("Tool") then
			return
		end

		if object:GetAttribute("HC_VALID_WEAPON") then
			Prisma:ToggleArms(true, true)
			Prisma:ToggleTorsoLag(false)
			ActiveTool = true
			_CurrentTool = object

			CurrentViewmodel = Viewmodels[object]
			if not CurrentViewmodel then
				CurrentViewmodel = Viewmodel.new(ReplicatedStorage.v_UMP45)
				Viewmodels[object] = CurrentViewmodel

				CurrentViewmodel.Animator:Load(WeaponIdleAnimation, "idle"):Play(0.1, 1, 1)
				CurrentViewmodel.Animator:Load(WeaponInspectAnimation, "inspect")
				CurrentViewmodel.Animator:Load(WeaponReloadAnimation, "reload")
				CurrentViewmodel.Animator:Load(WeaponEmptyReloadAnimation, "emptyReload")

				CurrentViewmodel:Decorate(ReplicatedStorage.DecorationArms)
				CurrentViewmodel:Cull(false)
			end

			UpdateHUD()
		end
	end)

	character.ChildRemoved:Connect(function(object)
		if not object:IsA("Tool") then
			return
		end

		if object:GetAttribute("HC_VALID_WEAPON") then
			if ReloadThread then
				coroutine.close(ReloadThread)
			end
			CurrentViewmodel.Animator.Tracks.inspect:Stop()
			CurrentViewmodel.Animator.Tracks.reload:Stop()
			CurrentViewmodel.Animator.Tracks.emptyReload:Stop()
			Prisma:ToggleArms(false, false)
			Prisma:ToggleTorsoLag(true)
			ActiveTool = false
			_CurrentTool = nil
			Mouse1Down = false
			_Mouse2Down = false
			Firing = false
			Reloading = false
			Aiming = false
			Inspecting = false

			Viewmodels[object]:Cull(true)

			UpdateHUD()
		end
	end)
end)

LocalPlayer.CharacterRemoving:Connect(function(_character)
	for _, viewmodel in Viewmodels do
		viewmodel:CleanUp()
	end
	table.clear(Viewmodels)
	CurrentViewmodel = nil
	CurrentAnimator:Destroy()
	CurrentAnimator = nil :: Animator.AnimatorClass?
end)

local moveSwitch = false
local stoppedSwitch = true

RunService.RenderStepped:Connect(function(deltaTime)
	local LeftEnabled = Sprinting or not ActiveTool
	local RightEnabled = Sprinting or not ActiveTool
	Prisma:ToggleArms(not LeftEnabled, not RightEnabled)

	if CurrentViewmodel then
		CurrentViewmodel:Cull(not ActiveTool)
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
						CurrentAnimator.Tracks.walkingToolAnimation:Stop(0.1)
						CurrentAnimator.Tracks.runningAnimation:Stop(0.1)
						CurrentAnimator.Tracks.runningToolAnimation:Stop(0.1)
						CurrentAnimator.Tracks.crouchWalk:Stop(0.1)

						CurrentAnimator.Tracks.idle:Play(0.1, (1 - EquippedModifier))
						CurrentAnimator.Tracks.idleTool:Play(0.1, EquippedModifier)
						CurrentAnimator.Tracks.crouchIdle:Play(0.1, 0)
						CurrentAnimator.Tracks.crouchToolIdle:Play(0.1, 0)
					end

					moveSwitch = true
				else
					if moveSwitch then
						moveSwitch = false
						CurrentAnimator.Tracks.walkingAnimation:Play(0.1, 0, 1)
						CurrentAnimator.Tracks.walkingToolAnimation:Play(0.1, 0, 1)
						CurrentAnimator.Tracks.runningAnimation:Play(0.1, 0, 1)
						CurrentAnimator.Tracks.runningToolAnimation:Play(0.1, 0, 1)
						CurrentAnimator.Tracks.crouchWalk:Play(0.1, 0, 1)
						CurrentAnimator.Tracks.crouchToolWalk:Play(0.1, 0, 1)
					end
					CurrentAnimator.Tracks.walkingAnimation:AdjustWeight(Speed * (1 - math.abs(HipHeightModifier)) * (1 - EquippedModifier) * (1 - SprintingModifier), 0.1)
					CurrentAnimator.Tracks.walkingToolAnimation:AdjustWeight(Speed * (1 - math.abs(HipHeightModifier)) * EquippedModifier * (1 - SprintingModifier), 0.1)
					CurrentAnimator.Tracks.runningAnimation:AdjustWeight(Speed * (1 - math.abs(HipHeightModifier)) * (1 - EquippedModifier) * SprintingModifier, 0.1)
					CurrentAnimator.Tracks.runningToolAnimation:AdjustWeight(Speed * (1 - math.abs(HipHeightModifier)) * EquippedModifier * SprintingModifier, 0.1)
					CurrentAnimator.Tracks.crouchWalk:AdjustWeight(Speed * HipHeightModifier * (1 - EquippedModifier), 0.1)
					CurrentAnimator.Tracks.crouchToolWalk:AdjustWeight(Speed * HipHeightModifier * EquippedModifier, 0.1)

					stoppedSwitch = true
				end
				CurrentAnimator.Tracks.idle:AdjustWeight((1 - (Speed / 16)) * (1 - math.abs(HipHeightModifier)) * (1 - EquippedModifier), 0.1)
				CurrentAnimator.Tracks.idleTool:AdjustWeight((1 - (Speed / 16)) * (1 - math.abs(HipHeightModifier)) * EquippedModifier, 0.1)
				CurrentAnimator.Tracks.crouchIdle:AdjustWeight(math.abs(HipHeightModifier) * (1 - EquippedModifier), 0.1)
				CurrentAnimator.Tracks.crouchToolIdle:AdjustWeight(math.abs(HipHeightModifier) * EquippedModifier, 0.1)
				-- CurrentAnimator.Tracks.idle:AdjustWeight(math.clamp(1 - Speed, 0, 1))
				-- CurrentAnimator.Tracks.walkingAnimation:AdjustWeight(Speed * (1 - HipHeightModifier) * (1 - SprintingModifier))
				-- CurrentAnimator.Tracks.runningAnimation:AdjustWeight(Speed * (1 - HipHeightModifier) * SprintingModifier)
				-- CurrentAnimator.Tracks.crouchIdle:AdjustWeight(HipHeightModifier)
				-- CurrentAnimator.Tracks.crouchWalk:AdjustWeight(Speed * HipHeightModifier)
				CurrentAnimator.Tracks.idle:AdjustSpeed((Speed / 15))
				CurrentAnimator.Tracks.idleTool:AdjustSpeed((Speed / 15))
				CurrentAnimator.Tracks.walkingAnimation:AdjustSpeed((Speed / 15))
				CurrentAnimator.Tracks.walkingToolAnimation:AdjustSpeed((Speed / 15))
				CurrentAnimator.Tracks.runningAnimation:AdjustSpeed((Speed / 15))
				CurrentAnimator.Tracks.runningToolAnimation:AdjustSpeed((Speed / 15))
				CurrentAnimator.Tracks.crouchWalk:AdjustSpeed((Speed / 15))
				CurrentAnimator.Tracks.crouchToolWalk:AdjustSpeed((Speed / 15))
			end)
		end
	end

	UserInputService.MouseIconEnabled = not Aiming
end)

-- hello github
