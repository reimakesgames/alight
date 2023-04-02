local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local Viewmodel = require(Shared.Viewmodel)
local gunVfx = require(Shared.gunVfx)
local Spring = require(Shared.Spring)
local numberLerp = require(Shared.numberLerp)

local ViewmodelCache = {}
local ActiveViewmodel = nil

local Character

local AltFireDown = false

local WalkCycleSpring = Spring.new(5, 50, 4, 4)
local SwaySpring = Spring.new(5, 20, 2, 8)
local SwaySpringAngles = Spring.new(5, 50, 2, 8)
local WalkCycleX, WalkCycleY = 0.0, 0.0
local WalkingVelocityNoY = 0.0
local InterpolatedWalkingVelocityNoY = 0.0

--[[
	MovementInnacuracy is a value that is used to determine how much the gun should move when the player is moving.
	In VALORANT, these values snap to 0.4 and 1.0 when the player is moving, and snap back to 0.0 when the player is not moving.
	There is a weird case where if you were firing, then started moving, the gun will get to 100% in one second
	And if you were to walk instead of running, the gun will transition to 40% in 0.6 seconds because transitioning from 0-100 is 1 second and 100-40 is 0.6 seconds

	This will be faithful to the original game, so those who are used to the original game will feel right at home.
]]
local MovementInnacuracy = 0.0
local InterpolatedMovementInnacuracy = 0.0
-- ! TODO: Outsource this to the main combat file


--[[
	VALORANT's sensitivity translation from VALORANT to Roblox is as follows:
	0.3 -> 0.052
	1.0 -> 0.173 ???
	2.0 -> 0.346

	These values are insane, i will make this a tip in the game so that people can use the same sensitivity they use in VALORANT
	assuming they use the same dps and fov
	also screw roblox for making sensitivity values confusing, like is valorant sensitivity in radians? degrees? or what??
]]

local OldCameraCFrame = CFrame.new()
local OffsetCFrame = CFrame.new()
local TargetOffsetCFrame = CFrame.new()
local CameraDelta = Vector3.new()
local PivotPointCFrame = CFrame.new()

local function UpdateVariables(deltaTime, camera)
	local CameraLookVectorDifference = OldCameraCFrame.LookVector - camera.CFrame.LookVector
	local CameraLookVectorDelta = camera.CFrame:VectorToObjectSpace(CameraLookVectorDifference)
	OldCameraCFrame = camera.CFrame
	local AimpointCFrame = ActiveViewmodel.Rig.HumanoidRootPart.CFrame:ToObjectSpace(ActiveViewmodel.Rig.Model.Handle.AimPoint.WorldCFrame)
	if AltFireDown then
		TargetOffsetCFrame = AimpointCFrame:Inverse()
	else
		TargetOffsetCFrame = CFrame.new(0, 0, 0)
	end

	PivotPointCFrame = (ActiveViewmodel.Rig.HumanoidRootPart.CFrame * OffsetCFrame:Inverse()):ToObjectSpace(ActiveViewmodel.Rig.Model.Handle.MuzzlePoint.WorldCFrame)
	WalkCycleX = WalkCycleX + ((deltaTime * 20) * (InterpolatedWalkingVelocityNoY / 16))
	WalkCycleY = WalkCycleY + ((deltaTime * 10) * (InterpolatedWalkingVelocityNoY / 16))

	CameraDelta = Vector3.new(
		math.clamp(CameraLookVectorDelta.X, -((math.pi * 2) * deltaTime), ((math.pi * 2) * deltaTime)),
		math.clamp(CameraLookVectorDelta.Y, -((math.pi * 2) * deltaTime), ((math.pi * 2) * deltaTime)),
		math.clamp(CameraLookVectorDelta.Z, -((math.pi * 2) * deltaTime), ((math.pi * 2) * deltaTime))
	)

	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		if Humanoid and HumanoidRootPart then
			local HumanoidRootPartVelocity = HumanoidRootPart:GetVelocityAtPosition(HumanoidRootPart.Position)
			WalkingVelocityNoY = Vector3.new(HumanoidRootPartVelocity.X, 0, HumanoidRootPartVelocity.Z).Magnitude
		end
	end
end

local viewmodelHandler = {}

function viewmodelHandler.Update(deltaTime, camera)
	UpdateVariables(deltaTime, camera)
	WalkCycleSpring:AddVelocity(Vector3.new(math.sin(WalkCycleX) * (deltaTime * 32), math.sin(WalkCycleY) * (deltaTime * 32), 0))
	SwaySpring:AddVelocity(Vector3.new(CameraDelta.X, -CameraDelta.Y, 0))
	SwaySpringAngles:AddVelocity(Vector3.new(CameraDelta.X, -CameraDelta.Y, 0))

	WalkCycleSpring:Step(deltaTime)
	SwaySpring:Step(deltaTime)

	OffsetCFrame = OffsetCFrame:Lerp(TargetOffsetCFrame, deltaTime * 16)
	InterpolatedWalkingVelocityNoY = numberLerp(InterpolatedWalkingVelocityNoY, WalkingVelocityNoY, 0.0001, deltaTime)
	if WalkingVelocityNoY >= 15 then
		MovementInnacuracy = 1
	elseif WalkingVelocityNoY >= 7 then
		MovementInnacuracy = 0.4
	else
		MovementInnacuracy = 0
	end
	InterpolatedMovementInnacuracy = numberLerp(InterpolatedMovementInnacuracy, MovementInnacuracy, 0.0001, deltaTime)

	local CameraCFrame = camera.CFrame

	local WalkCycle = CFrame.Angles(
		(WalkCycleSpring.Position.X / 1024) * InterpolatedWalkingVelocityNoY,
		(WalkCycleSpring.Position.Y / 1024) * InterpolatedWalkingVelocityNoY,
		0
	)

	local Sway = CFrame.Angles(
		(SwaySpring.Position.Y / 4),
		(SwaySpring.Position.X / 4),
		0
	)

	local WalkGunDown = CFrame.Angles(
		-InterpolatedMovementInnacuracy * 0.05,
		0,
		0
	)

	local PivotPointAngles = CFrame.Angles(
		(-SwaySpringAngles.Position.Y / 8),
		(-SwaySpringAngles.Position.X / 8),
		0
	)

	local ViewmodelCFrame = Sway * OffsetCFrame * WalkCycle * WalkGunDown
	ViewmodelCFrame = (PivotPointCFrame * PivotPointAngles):ToObjectSpace(ViewmodelCFrame)
	ViewmodelCFrame = CameraCFrame * PivotPointCFrame:ToWorldSpace(ViewmodelCFrame)

	if ActiveViewmodel then
		ActiveViewmodel:SetCFrame(ViewmodelCFrame)
	end
end

function viewmodelHandler.CacheViewmodel(viewmodel: Viewmodel.ViewmodelClass)
	ViewmodelCache[viewmodel] = true
end

function viewmodelHandler.SetViewmodel(viewmodel: Viewmodel.ViewmodelClass)
	-- cull the previous active viewmodel despite if we're going to cull everything on the list
	if ActiveViewmodel then
		ActiveViewmodel:Cull(true)
	end
	ActiveViewmodel = viewmodel
	for cachedViewmodel, _ in pairs(ViewmodelCache) do
		-- to reduce on function calls, we can just check the Viewmodel.Culled property
		if cachedViewmodel ~= viewmodel and not cachedViewmodel.Culled then
			cachedViewmodel:Cull(true)
		end
	end
	if ViewmodelCache[viewmodel] then
		viewmodel:Cull(false)
	end
end

function viewmodelHandler.GetViewmodel()
	return ActiveViewmodel
end

function viewmodelHandler.SetCharacter(character)
	Character = character
end

function viewmodelHandler.SetAltFireDown(enabled)
	AltFireDown = enabled
end

function viewmodelHandler.Fire()
	-- gunVfx:EmitMuzzleParticles(ActiveViewmodel.Rig.Model.Handle.MuzzlePoint)
end

return viewmodelHandler
