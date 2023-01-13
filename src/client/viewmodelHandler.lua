local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local Viewmodel = require(Shared.Viewmodel)
local Spring = require(Shared.Spring)
local numberLerp = require(Shared.numberLerp)

local ViewmodelCache = {}
local ActiveViewmodel = nil

local Character

local WalkCycleSpring = Spring.new(5, 50, 4, 4)
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

--[[
	VALORANT's sensitivity translation from VALORANT to Roblox is as follows:
	0.3 -> 0.052
	1.0 -> 0.173 ???
	2.0 -> 0.346

	These values are insane, i will make this a tip in the game so that people can use the same sensitivity they use in VALORANT
	assuming they use the same dps and fov
	also screw roblox for making sensitivity values confusing, like is valorant sensitivity in radians? degrees? or what??
]]

local function UpdateVariables(deltaTime)
	WalkCycleX = WalkCycleX + ((deltaTime * 20) * (InterpolatedWalkingVelocityNoY / 16))
	WalkCycleY = WalkCycleY + ((deltaTime * 10) * (InterpolatedWalkingVelocityNoY / 16))

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
	UpdateVariables(deltaTime)
	WalkCycleSpring:AddVelocity(Vector3.new(math.sin(WalkCycleX) * (deltaTime * 32), math.sin(WalkCycleY) * (deltaTime * 32), 0))
	WalkCycleSpring:Step(deltaTime)
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

	local WalkGunDown = CFrame.Angles(
		-InterpolatedMovementInnacuracy * 0.05,
		0,
		0
	)

	local ViewmodelCFrame = CameraCFrame * WalkGunDown * WalkCycle
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

return viewmodelHandler
