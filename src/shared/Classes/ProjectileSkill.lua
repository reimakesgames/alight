local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Classes = Shared:WaitForChild("Classes")

local Skill = require(Classes:WaitForChild("Skill"))

export type ProjectileSkillClass = Skill.SkillClass | {
	Projectile: (BasePart | Model)?;
	ProjectilePosition: Vector3;
	ProjectileVelocity: Vector3;

	Lifetime: number;
	UpdateRBXScriptConnection: RBXScriptConnection?;

	ProjectileLifetime: number;
	ProjectileSpeed: number;
	ProjectileConstantForce: Vector3;
	ProjectileBaseVelocity: Vector3;

	ProjectileBounceCount: number;
	ProjectileBounceCountMax: number;
	ProjectileBounceFriction: number;
	ProjectileBounceSlopeAngle: number;

	ImpactFunction: (result: RaycastResult) -> nil;
	EndFunction: () -> nil;

	Update: (self: ProjectileSkillClass, deltaTime: number) -> nil;

	Cast: (self: ProjectileSkillClass, camera: Camera, position: Vector3) -> nil;
	SetProjectile: (self: ProjectileSkillClass, projectile: BasePart | Model?) -> nil;
	SetImpactFunction: (self: ProjectileSkillClass, impactFunction: (result: RaycastResult) -> nil) -> nil;
	SetEndFunction: (self: ProjectileSkillClass, endFunction: () -> nil) -> nil;
}

local function FindPrimaryPart(projectile: BasePart | Model): BasePart?
	if projectile:IsA("Part") then
		return projectile
	elseif projectile:IsA("Model") then
		if projectile.PrimaryPart then
			return projectile.PrimaryPart
		else
			warn("ProjectileSkill: Model does not have a PrimaryPart")
			return nil
		end
	end
end

local ProjectileSkill = {} :: ProjectileSkillClass
ProjectileSkill.__index = ProjectileSkill

function ProjectileSkill.new()
	local self: ProjectileSkillClass = setmetatable(Skill.new(), ProjectileSkill)
	self:SetImpactFunction(function() end)
	self:SetEndFunction(function() end)
	self.ProjectileBaseVelocity = Vector3.new(0, 0, 0)
	self.ProjectileConstantForce = Vector3.new(0, 0, 0)
	self.ProjectileLifetime = 0
	self.ProjectileSpeed = 0
	self.ProjectileBounceCount = 0
	self.ProjectileBounceCountMax = 0
	self.ProjectileBounceFriction = 0
	self.ProjectileBounceSlopeAngle = 0
	self.Lifetime = 0
	return self
end

function ProjectileSkill:CleanUp()
	if self.Projectile then
		self.Projectile:Destroy()
	end
	if self.UpdateRBXScriptConnection then
		self.UpdateRBXScriptConnection:Disconnect()
	end
	self.Projectile = nil
end

function ProjectileSkill:Update(deltaTime: number)
	local projectile = self.Projectile
	if not projectile then return end
	local primaryPart = FindPrimaryPart(projectile)
	if not primaryPart then return end

	local moveAmount = self.ProjectileSpeed * (deltaTime / 4)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {projectile}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local position: Vector3 = self.ProjectilePosition
	local velocity: Vector3 = self.ProjectileVelocity
	for _ = 1, 4 do
		local result = workspace:Raycast(position, velocity * (deltaTime / 4), raycastParams)
		if result then
			local hitSlopeAngle = math.deg(math.acos(result.Normal:Dot(Vector3.new(0, 1, 0))))
			if self.ProjectileBounceCount < self.ProjectileBounceCountMax and hitSlopeAngle > self.ProjectileBounceSlopeAngle then
				self.ProjectileBounceCount += 1
				local normal = result.Normal
				local lookVector = primaryPart.CFrame.LookVector
				local reflected = lookVector - 2 * normal * lookVector:Dot(normal)
				local distance = (result.Position - primaryPart.Position).Magnitude
				position = result.Position + (reflected * (moveAmount - distance))
				velocity = (reflected * velocity.Magnitude) * self.ProjectileBounceFriction
			else
				self.ImpactFunction(result)
				self.EndFunction()
				self:CleanUp()
				return
			end
		else
			position = position + (velocity * (deltaTime / 4))
		end
		velocity = velocity + (self.ProjectileConstantForce * (deltaTime / 4))
	end
	self.Lifetime += deltaTime
	self.ProjectilePosition = position
	self.ProjectileVelocity = velocity
	primaryPart:PivotTo(CFrame.new(self.ProjectilePosition, self.ProjectilePosition + self.ProjectileVelocity))
end

function ProjectileSkill:Cast(camera: Camera, position: Vector3)
	task.delay(self.ProjectileLifetime, function()
		if self.Projectile then
			self.EndFunction()
			self:CleanUp()
		end
	end)
	local projectile = self.Projectile
	if projectile then
		local primaryPart = FindPrimaryPart(projectile)
		if primaryPart then
			self.ProjectilePosition = position + camera.CFrame.LookVector * 2
			self.ProjectileVelocity = (camera.CFrame.LookVector * self.ProjectileSpeed) + self.ProjectileBaseVelocity
			self.ProjectileBounceCount = 0
			primaryPart:PivotTo(CFrame.new(self.ProjectilePosition, self.ProjectilePosition + self.ProjectileVelocity))
			primaryPart.Parent = workspace
		end
	end
end

function ProjectileSkill:SetProjectile(projectile: BasePart | Model)
	local newProjectile = projectile:Clone()
	local primaryPart = FindPrimaryPart(newProjectile)
	if primaryPart then
		self.Projectile = newProjectile
	end
end

function ProjectileSkill:SetImpactFunction(impactFunction: (result: RaycastResult) -> nil)
	self.ImpactFunction = impactFunction
end

function ProjectileSkill:SetEndFunction(endFunction: () -> nil)
	self.EndFunction = endFunction
end

return ProjectileSkill
