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
local Walking = 0.0
local WalkingVelocityNoY = 0.0

local InterpolatedWalking = 0.0
local InterpolatedWalkingVelocityNoY = 0.0

local function UpdateVariables(deltaTime)
	WalkCycleX = WalkCycleX + ((deltaTime * 20) * (InterpolatedWalkingVelocityNoY / 16))
	WalkCycleY = WalkCycleY + ((deltaTime * 10) * (InterpolatedWalkingVelocityNoY / 16))

	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		if Humanoid and HumanoidRootPart then
			Walking = Humanoid.MoveDirection.Magnitude
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
	InterpolatedWalking = numberLerp(InterpolatedWalking, Walking, 0.001, deltaTime)
	InterpolatedWalkingVelocityNoY = numberLerp(InterpolatedWalkingVelocityNoY, WalkingVelocityNoY, 0.0001, deltaTime)

	local CameraCFrame = camera.CFrame

	local WalkCycle = CFrame.Angles(
		(WalkCycleSpring.Position.X / 1024) * InterpolatedWalkingVelocityNoY,
		(WalkCycleSpring.Position.Y / 1024) * InterpolatedWalkingVelocityNoY,
		0
	)

	local WalkGunDown = CFrame.Angles(
		-InterpolatedWalking * 0.05, -- ! could be replaced with movement inaccuracy
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
