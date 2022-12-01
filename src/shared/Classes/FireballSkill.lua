local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Classes = Shared:WaitForChild("Classes")
local Gameplay = Assets:WaitForChild("Gameplay")

local ProjectileSkill = require(Classes:WaitForChild("ProjectileSkill"))

export type FireballSkillClass = ProjectileSkill.ProjectileSkillClass | {
	Cast: (self: FireballSkillClass, camera: Camera, position: Vector3) -> nil;
}

local FireballSkill = {} :: FireballSkillClass
FireballSkill.__index = FireballSkill

function FireballSkill:Cast(camera: Camera, position: Vector3)
	local projectile = ProjectileSkill.new()
	projectile:SetProjectile(Gameplay:WaitForChild("Fireball"))
	projectile.ProjectileLifetime = 8
	projectile.ProjectileSpeed = 32
	projectile.ProjectileBounceFriction = 0.75
	projectile.ProjectileBounceCountMax = 8
	projectile.ProjectileBounceSlopeAngle = 15
	projectile.ProjectileConstantForce = Vector3.new(0, -20, 0)
	projectile.ProjectileBaseVelocity = Vector3.new(0, 4, 0)
	projectile:SetImpactFunction(function(result: RaycastResult)
		local impact = Gameplay:WaitForChild("FireballImpact"):Clone()
		Debris:AddItem(impact, 4.6)
		impact.Size = Vector3.new(0.125, 1, 1)
		impact.Position = result.Position
		TweenService:Create(impact, TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = Vector3.new(0.125, 16, 16)}):Play()
		impact.Parent = workspace
		task.delay(4, function()
			TweenService:Create(impact, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Transparency = 1}):Play()
		end)
	end)
	projectile:Cast(camera, position)
	local castTime = 0
	local overTimeLimit = false
	projectile.UpdateRBXScriptConnection = RunService.Stepped:Connect(function(_, deltaTime)
		castTime += deltaTime
		if castTime >= 1.5 and not overTimeLimit then
			overTimeLimit = true
			projectile.ProjectileVelocity = Vector3.new(0, 0, 0)
			projectile.ProjectileConstantForce = Vector3.new(0, -200, 0)
		end
		projectile:Update(deltaTime)
	end)
end

return FireballSkill
