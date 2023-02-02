local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = ReplicatedFirst:WaitForChild("Utility")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Gameplay = Assets:WaitForChild("Gameplay")
local Environment = Gameplay:WaitForChild("Environment")
local Classes = Shared:WaitForChild("Classes")
local Modules = Shared:WaitForChild("Modules")

local Link = require(Packages:WaitForChild("link"))
local RaycastHandler = require(Modules:WaitForChild("RaycastHandler"))

local RequestForRNGSeedSignal = Link:CreateEvent("RequestForRNGSeed")
local SendRNGSeedSignal = Link:CreateEvent("SendRNGSeed")
local WeaponFireSignal = Link:CreateEvent("WeaponFire")

local PlayerRandomGenerators: {[string]: Random} = {}

local function AddNoiseOnLookVector(PartDepth, origin, direction, random)
	local RadiusModifier = (Random.new(random * 12345):NextNumber() / 0.25) * (PartDepth * 2)
	local AngleModifier = (random * 360)
	local x = RadiusModifier * math.sin(math.rad(AngleModifier));
	local y = RadiusModifier * math.cos(math.rad(AngleModifier));
	return CFrame.new(origin, origin + direction) * CFrame.Angles(math.rad(y), math.rad(x), 0)
end

local function WeaponFire(startPoint: Vector3, lookVector: Vector3, player: Player, randomNumber: number)
	local parameter = RaycastParams.new()
	parameter.FilterDescendantsInstances = { player.Character }
	parameter.FilterType = Enum.RaycastFilterType.Blacklist
	-- normal raycast

	local PenetrationPower = 4

	local Result = RaycastHandler:Raycast(startPoint, lookVector, 1024, parameter)
	if not Result then
		return
	end
	PenetrationPower = PenetrationPower - ((startPoint - Result.Position).Magnitude / 1024)
	local WallbangCount = 1

	-- FindHumanoidAndDamage(Result)

	repeat
		-- finding part thickness

		local DepthResult, Depth = RaycastHandler:CheckHitDepth(Result.Instance, Result.Position, lookVector)
		if not DepthResult then
			return
		end
		PenetrationPower = PenetrationPower - Depth
		if PenetrationPower < 0 then
			break
		end

		-- wall bang thing

		local WallbangDirection = AddNoiseOnLookVector(Depth, startPoint, lookVector, randomNumber)
		local RemainingDistance = (1024 - (startPoint - DepthResult.Position).Magnitude)
		local WallbangResult: RaycastResult = RaycastHandler:Raycast(DepthResult.Position, WallbangDirection.LookVector, RemainingDistance, parameter)
		PenetrationPower = PenetrationPower - ((startPoint - Result.Position).Magnitude / 1024)
		if not WallbangResult then
			return
		end

		Result = WallbangResult
		startPoint = DepthResult.Position
		lookVector = WallbangDirection.LookVector

		WallbangCount = WallbangCount + 1

		-- FindHumanoidAndDamage(Result)
	until WallbangCount > 4
end


RequestForRNGSeedSignal.Event:Connect(function(player: Player)
	if PlayerRandomGenerators[player.Name] then
		return
	end
	local Seed = player.UserId - math.random(-32, 32)
	PlayerRandomGenerators[player.Name] = Random.new(Seed)
	SendRNGSeedSignal:FireClient(player, Seed)
end)

WeaponFireSignal.Event:Connect(function(player: Player, origin: Vector3, direction: Vector3)
	if not PlayerRandomGenerators[player.Name] then
		player:Kick("You have been kicked for: Attempting to fire without an RNG seed")
	end

	local random = PlayerRandomGenerators[player.Name]:NextNumber()
	WeaponFire(origin, direction, player, random)
end)
