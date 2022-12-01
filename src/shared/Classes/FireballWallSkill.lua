local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Classes = Shared:WaitForChild("Classes")
local Gameplay = Assets:WaitForChild("Gameplay")

local ProjectileSkill = require(Classes:WaitForChild("ProjectileSkill"))

local LocalPlayer = Players.LocalPlayer

export type FireballWallSkillClass = ProjectileSkill.ProjectileSkillClass | {
	Cast: (self: FireballWallSkillClass, camera: Camera, position: Vector3) -> nil;
}

local FireballWallSkill = {} :: FireballWallSkillClass
FireballWallSkill.__index = FireballWallSkill

local function ConnectWallBeams(currentWall: Part | any, nextWall: Part | any?, isFirstWall: boolean)
	local beams = {}
	for _, beam: Beam in currentWall:GetChildren() do
		if beam:IsA("Beam") then
			table.insert(beams, beam)
			if isFirstWall and not nextWall then
				beam.Attachment0 = currentWall.Back
				beam.Attachment1 = currentWall.Front
			elseif isFirstWall and nextWall then
				beam.Attachment0 = currentWall.Back
				beam.Attachment1 = nextWall.Center
			elseif not isFirstWall and nextWall then
				beam.Attachment0 = currentWall.Center
				beam.Attachment1 = nextWall.Center
			elseif not isFirstWall and not nextWall then
				beam.Attachment0 = currentWall.Center
				beam.Attachment1 = currentWall.Front
			end
			beam.Width0 = 0
			beam.Width1 = 0
		end
	end

	return beams
end

local function CreateLines(startPosition: Vector3, endPosition: Vector3, ignoreList: {[number]: BasePart})
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = ignoreList
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local line = Gameplay:WaitForChild("FireballWallLine"):Clone()
	-- cast positions to the floor
	local result = workspace:Raycast(startPosition, Vector3.new(0, -128, 0), raycastParams)
	local result2 = workspace:Raycast(endPosition, Vector3.new(0, -128, 0), raycastParams)
	if result and result2 then
		startPosition = result.Position
		endPosition = result2.Position

		local centerPosition = (startPosition + endPosition) / 2
		local cframe = CFrame.new(centerPosition, endPosition)
		line.CFrame = cframe
		line.Size = Vector3.new(1, 1, (startPosition - endPosition).Magnitude)
		line.Parent = workspace
	end
	return line
end

function FireballWallSkill:Cast(camera: Camera, position: Vector3)
	local castTime = 0
	local overTimeLimit = false
	local oldPosition = position
	local lines = {}
	local projectile = ProjectileSkill.new()
	projectile:SetProjectile(Gameplay:WaitForChild("Fireball"))
	projectile.ProjectileLifetime = 1
	projectile.ProjectileSpeed = 40
	projectile.ProjectileBounceFriction = 0
	projectile.ProjectileBounceCountMax = 0
	projectile.ProjectileConstantForce = Vector3.new(0, 0, 0)
	projectile:SetImpactFunction(function(result: RaycastResult)
		local line = CreateLines(oldPosition, result.Position + (result.Normal * 0.01), {projectile.Projectile, LocalPlayer.Character})
		table.insert(lines, line)
	end)
	projectile:SetEndFunction(function()
		task.spawn(function()
			local walls = {}
			local wallBeams = {}
			for _, line in lines do
				local wall = Gameplay:WaitForChild("FireballWall"):Clone()
				table.insert(walls, wall)
				wall.Size = Vector3.new(0.25, 1, line.Size.Z)
				wall.CFrame = line.CFrame

				Debris:AddItem(wall, 8.3)
				Debris:AddItem(line, 8.3)

				for _, beam in line:GetChildren() do
					if beam:IsA("Beam") then
						local lineTween = TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Width0 = 0, Width1 = 0})
						task.delay(8, function()
							lineTween:Play()
						end)
					end
				end
			end
			for i, wall in walls do
				local nextWall = walls[i + 1]
				table.insert(wallBeams, ConnectWallBeams(wall, nextWall, i == 1))
			end
			for i, wall in walls do
				TweenService:Create(wall, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {CFrame = wall.CFrame * CFrame.new(0, 5, 0), Size = Vector3.new(wall.Size.X, 10, wall.Size.Z)}):Play()
				local wallTween = TweenService:Create(wall, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = wall.CFrame * CFrame.new(0, -5, 0), Size = Vector3.new(wall.Size.X, 0, wall.Size.Z)})
				task.delay(8, function()
					wallTween:Play()
				end)
				for _, beam in wallBeams[i] do
					TweenService:Create(beam, TweenInfo.new(0.5), {Width0 = 10, Width1 = 10}):Play()
				end
				wall.Parent = workspace
				task.wait()
				task.wait()

			end
		end)
	end)
	projectile:Cast(camera, position)
	projectile.UpdateRBXScriptConnection = RunService.Stepped:Connect(function(_, deltaTime)
		castTime += deltaTime
		-- create a line every 1/8th of a second
		if castTime >= 0.125 then
			castTime = castTime - 0.125
			local line = CreateLines(oldPosition, projectile.ProjectilePosition, {projectile.Projectile, LocalPlayer.Character})
			table.insert(lines, line)
			oldPosition = projectile.ProjectilePosition
		end
		projectile.ProjectileVelocity = camera.CFrame.LookVector * projectile.ProjectileSpeed

		projectile:Update(deltaTime)
	end)
end

return FireballWallSkill
