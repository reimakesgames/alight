local Players = game:GetService("Players")
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
local PingTimes = require(Modules:WaitForChild("PingTimes"))

local RequestForRNGSeedSignal = Link.CreateEvent("RequestForRNGSeed")
local SendRNGSeedSignal = Link.CreateEvent("SendRNGSeed")
local WeaponFireSignal = Link.CreateEvent("WeaponFire")

local PlayerRandomGenerators: Dictionary<Random> = {}

local function AddNoiseOnLookVector(PartDepth, origin, direction, random)
	local RadiusModifier = (Random.new(random * 12345):NextNumber() / 0.25) * (PartDepth * 2)
	local AngleModifier = (random * 360)
	local x = RadiusModifier * math.sin(math.rad(AngleModifier));
	local y = RadiusModifier * math.cos(math.rad(AngleModifier));
	return CFrame.new(origin, origin + direction) * CFrame.Angles(math.rad(y), math.rad(x), 0)
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

local function FindHitbox(whoShot: Player, victimCharacter: Model)
	if not victimCharacter then return end
	local Ping = PingTimes[whoShot]
	require(victimCharacter.Hitbox):BacktrackHitbox(Ping)
	return require(victimCharacter.Hitbox)
end

local function WeaponFire(startPoint: Vector3, lookVector: Vector3, player: Player, hitPlayers: Array<Player>, randomNumber: number)
	local Hitboxes = {}
	local parameter = RaycastParams.new()
	parameter.FilterDescendantsInstances = { player.Character }
	parameter.FilterType = Enum.RaycastFilterType.Blacklist
	-- normal raycast

	local PenetrationPower = 4
	print(PenetrationPower)

	for _, targetPlayer in hitPlayers do
		local Hitbox = FindHitbox(player, targetPlayer.Character)
		local NewHitbox
		if Hitbox then
			NewHitbox = Hitbox:GetHitbox():Clone()
			print(NewHitbox)
		end
		if NewHitbox then
			NewHitbox.Parent = workspace
			table.insert(Hitboxes, Hitbox)
		end
	end
	local Result = RaycastHandler:Raycast(startPoint, lookVector, 1024, parameter)
	if not Result then
		return
	end
	FindHumanoidAndDamage(Result)
	local Thing = Environment.Server:Clone()
	Thing.CFrame = CFrame.new(Result.Position, Result.Position + Result.Normal)
	Thing.Parent = workspace
	PenetrationPower = PenetrationPower - ((startPoint - Result.Position).Magnitude / 1024)
	print(PenetrationPower)
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
		Thing = Environment.Server:Clone()
		Thing.CFrame = CFrame.new(DepthResult.Position, DepthResult.Position + DepthResult.Normal)
		Thing.Parent = workspace

		-- wall bang thing

		local WallbangDirection = AddNoiseOnLookVector(Depth, startPoint, lookVector, randomNumber)
		local RemainingDistance = (1024 - (startPoint - DepthResult.Position).Magnitude)
		local WallbangResult: RaycastResult = RaycastHandler:Raycast(DepthResult.Position, WallbangDirection.LookVector, RemainingDistance, parameter)
		PenetrationPower = PenetrationPower - ((startPoint - Result.Position).Magnitude / 1024)
		print(PenetrationPower)
		if not WallbangResult then
			return
		end
		FindHumanoidAndDamage(WallbangResult)
		Thing = Environment.Server:Clone()
		Thing.CFrame = CFrame.new(WallbangResult.Position, WallbangResult.Position + WallbangResult.Normal)
		Thing.Parent = workspace

		Result = WallbangResult
		startPoint = DepthResult.Position
		lookVector = WallbangDirection.LookVector

		WallbangCount = WallbangCount + 1
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

WeaponFireSignal.Event:Connect(function(player: Player, origin: Vector3, direction: Vector3, hitPlayers: Array<Player>)
	if not PlayerRandomGenerators[player.Name] then
		player:Kick("You have been kicked for: Attempting to fire without an RNG seed")
	end
	print(hitPlayers)

	local random = PlayerRandomGenerators[player.Name]:NextNumber()
	WeaponFire(origin, direction, player, hitPlayers, random)
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local Hitbox = script.Parent.LagCompensator.Hitbox:Clone()
		Hitbox.Parent = character
		local thing = require(Hitbox)
		print(thing)
	end)
end)
