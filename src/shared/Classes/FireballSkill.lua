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
	-- Use: (self: FireballSkillClass, camera: Camera, position: Vector3) -> nil;
}

local FireballSkill = {} :: FireballSkillClass
FireballSkill.__index = FireballSkill

local function Collided(_self: FireballSkillClass, result: RaycastResult)
	local impact: Part = Gameplay:WaitForChild("FireballImpact"):Clone()
	Debris:AddItem(impact, 4.6)
	impact.Size = Vector3.new(0.125, 1, 1)
	impact.Position = result.Position
	TweenService:Create(impact, TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = Vector3.new(0.125, 16, 16)}):Play()
	impact.Parent = workspace
	task.delay(4, function()
		TweenService:Create(impact, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Transparency = 1}):Play()
	end)
end

local function Update(self: FireballSkillClass, _deltaTime: number)
	if self.__Lifetime >= 1.5 and not self.CustomData.Triggered then
		self.CustomData.Triggered = true
		self.Velocity = Vector3.new(0, 0, 0)
		self.ConstantForce = Vector3.new(0, -200, 0)
	end
end

function FireballSkill:Use(camera: Camera, position: Vector3)
	local projectile = ProjectileSkill.new()
	projectile:SetProjectile(Gameplay:WaitForChild("Fireball"))
	projectile.Lifetime = 8
	projectile.Speed = 32

	projectile.BounceFriction = 0.75
	projectile.BounceCountMax = 8
	projectile.BounceSlopeAngle = 15

	projectile.ConstantForce = Vector3.new(0, -20, 0)
	projectile.BaseVelocity = Vector3.new(0, 4, 0)

	projectile:SetCollisionFunction(Collided)
	projectile:SetUpdateFunction(Update)
	projectile:Use(camera, position)
end

return FireballSkill
