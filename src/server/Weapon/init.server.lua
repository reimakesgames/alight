local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Utility = ReplicatedFirst:WaitForChild("Utility")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Assets = ReplicatedStorage:WaitForChild("Assets")

local Gameplay = Assets:WaitForChild("Gameplay")
local Environment = Gameplay:WaitForChild("Environment")

local Link = require(Packages:WaitForChild("link"))
local Caster = require(script.Caster)

local RequestForRNGSeedSignal = Link.CreateEvent("RequestForRNGSeed")
local SendRNGSeedSignal = Link.CreateEvent("SendRNGSeed")
local WeaponFireSignal = Link.CreateEvent("WeaponFire")

local RandomTables: Dictionary<Random> = {}

local function AddNoiseOnLookVector(PartDepth, origin, direction, random)
	local RadiusModifier = (Random.new(random * 12345):NextNumber() / 0.25) * (PartDepth * 2)
	local AngleModifier = (random * 360)
	local x = RadiusModifier * math.sin(math.rad(AngleModifier));
	local y = RadiusModifier * math.cos(math.rad(AngleModifier));
	return CFrame.new(origin, origin + direction) * CFrame.Angles(math.rad(y), math.rad(x), 0)
end

local function WeaponFire(origin: Vector3, direction: Vector3, player: Player, random: number)
	-- normal raycast

	local PenetrationPower = 4
	print(PenetrationPower)

	local Result = Caster:Cast(origin, direction * 1024, player.Character)
	if not Result then
		return
	end
	local Thing = Environment.Server:Clone()
	Thing.CFrame = CFrame.new(Result.Position, Result.Position + Result.Normal)
	Thing.Parent = workspace
	PenetrationPower = PenetrationPower - ((origin - Result.Position).Magnitude / 1024)
	print(PenetrationPower)
	local WallbangCount = 1

	repeat
		-- finding part thickness

		local PartDepth, ThicknessResult = Caster:FindThickness(Result.Instance, Result.Position, Result.Position + (direction * 64), -direction * 64)
		if not ThicknessResult then
			return
		end
		local Thing = Environment.Server:Clone()
		Thing.CFrame = CFrame.new(ThicknessResult.Position, ThicknessResult.Position + ThicknessResult.Normal)
		Thing.Parent = workspace
		PenetrationPower = PenetrationPower - PartDepth
		print(PenetrationPower)
		if PenetrationPower < 0 then
			break
		end

		-- wall bang thing

		local WallbangDirection = AddNoiseOnLookVector(PartDepth, origin, direction, random)
		local RemainingDistanceLookVector = (WallbangDirection.LookVector * (1024 - (origin - ThicknessResult.Position).Magnitude))
		local WallbangResult: RaycastResult = Caster:Cast(ThicknessResult.Position, RemainingDistanceLookVector, player.Character)
		PenetrationPower = PenetrationPower - ((origin - Result.Position).Magnitude / 1024)
		print(PenetrationPower)
		if not WallbangResult then
			return
		end
		local Thing = Environment.Server:Clone()
		Thing.CFrame = CFrame.new(WallbangResult.Position, WallbangResult.Position + WallbangResult.Normal)
		Thing.Parent = workspace

		Result = WallbangResult
		origin = ThicknessResult.Position
		direction = RemainingDistanceLookVector.Unit

		WallbangCount = WallbangCount + 1
	until WallbangCount > 4
end


RequestForRNGSeedSignal.Event:Connect(function(player: Player)
	if RandomTables[player.Name] then
		return
	end
	local Seed = player.UserId - math.random(-32, 32)
	RandomTables[player.Name] = Random.new(Seed)
	SendRNGSeedSignal:FireClient(player, Seed)
end)

WeaponFireSignal.Event:Connect(function(player: Player, origin: Vector3, direction: Vector3)
	if not RandomTables[player.Name] then
		player:Kick("You have been kicked for: Attempting to fire without an RNG seed")
	end

	local random = RandomTables[player.Name]:NextNumber()
	WeaponFire(origin, direction, player, random)
end)
