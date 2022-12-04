local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Classes = Shared:WaitForChild("Classes")

local Skill = require(Classes:WaitForChild("Skill"))

local Camera = workspace.CurrentCamera

export type ProjectileSkillClass = Skill.Interface | {
	new: () -> ProjectileSkillClass;
	Destroy: (self: ProjectileSkillClass) -> nil;

	Projectile: (BasePart | Model)?;

	Position: Vector3;
	Velocity: Vector3;

	__Lifetime: number;
	__UpdateRBXScriptConnection: RBXScriptConnection?;

	Lifetime: number;
	Speed: number;
	ConstantForce: Vector3;
	BaseVelocity: Vector3;

	BounceCount: number;
	BounceCountMax: number;
	BounceFriction: number;
	BounceSlopeAngle: number;

	__CollisionFunction: (self: ProjectileSkillClass, result: RaycastResult) -> nil;
	__EndFunction: (self: ProjectileSkillClass) -> nil;

	Update: (self: ProjectileSkillClass, deltaTime: number) -> nil;

	Use: (self: ProjectileSkillClass, camera: Camera, position: Vector3) -> nil;
	SetProjectile: (self: ProjectileSkillClass, projectile: BasePart | Model?) -> nil;
	SetUpdateFunction: (self: ProjectileSkillClass, func: (self: ProjectileSkillClass, deltaTime: number) -> nil) -> nil;
	SetCollisionFunction: (self: ProjectileSkillClass, impactFunction: (self: ProjectileSkillClass, result: RaycastResult) -> nil) -> nil;
	SetEndFunction: (self: ProjectileSkillClass, endFunction: (self: ProjectileSkillClass) -> nil) -> nil;
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

	self:SetCollisionFunction(function() end)
	self:SetEndFunction(function() end)
	self:SetUpdateFunction(function() end)

	self.__Lifetime = 0
	self.Lifetime = 0
	self.Speed = 0

	self.BaseVelocity = Vector3.new(0, 0, 0)
	self.ConstantForce = Vector3.new(0, 0, 0)

	self.BounceCount = 0
	self.BounceCountMax = 0
	self.BounceFriction = 0
	self.BounceSlopeAngle = 0
	return self
end

function ProjectileSkill:Destroy()
	if self.Projectile then
		self.Projectile:Destroy()
	end
	if self.__UpdateRBXScriptConnection then
		self.__UpdateRBXScriptConnection:Disconnect()
	end
	self.Using = false
	self.Projectile = nil
end

function ProjectileSkill:Update(deltaTime: number)
	local projectile = self.Projectile
	if not projectile then return end
	local primaryPart = FindPrimaryPart(projectile)
	if not primaryPart then return end

	local moveAmount = self.Speed * (deltaTime / 4)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {projectile, Camera}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local position: Vector3 = self.Position
	local velocity: Vector3 = self.Velocity
	for _ = 1, 4 do
		local result = workspace:Raycast(position, velocity * (deltaTime / 4), raycastParams)
		if result then
			local hitSlopeAngle = math.deg(math.acos(result.Normal:Dot(Vector3.new(0, 1, 0))))
			if self.BounceCount < self.BounceCountMax and hitSlopeAngle > self.BounceSlopeAngle then
				self.BounceCount += 1
				local normal = result.Normal
				local lookVector = primaryPart.CFrame.LookVector
				local reflected = lookVector - 2 * normal * lookVector:Dot(normal)
				local distance = (result.Position - primaryPart.Position).Magnitude
				position = result.Position + (reflected * (moveAmount - distance))
				velocity = (reflected * velocity.Magnitude) * self.BounceFriction
			else
				self:__CollisionFunction(result)
				self:__EndFunction()
				self:Destroy()
				return
			end
		else
			position = position + (velocity * (deltaTime / 4))
		end
		velocity = velocity + (self.ConstantForce * (deltaTime / 4))
	end
	self.__Lifetime += deltaTime
	self.Position = position
	self.Velocity = velocity
	primaryPart:PivotTo(CFrame.new(self.Position, self.Position + self.Velocity))
end

function ProjectileSkill:Use(camera: Camera, position: Vector3)
	self.Using = true
	task.delay(self.Lifetime, function()
		if self.Projectile then
			self:__EndFunction()
			self:Destroy()
		end
	end)

	local projectile = self.Projectile
	if not projectile then return end
	local primaryPart = FindPrimaryPart(projectile)
	if not primaryPart then return end

	self.Position = position + camera.CFrame.LookVector * 2
	self.Velocity = (camera.CFrame.LookVector * self.Speed) + self.BaseVelocity
	primaryPart:PivotTo(CFrame.new(self.Position, self.Position + self.Velocity))
	primaryPart.Parent = workspace
end

function ProjectileSkill:SetProjectile(projectile: BasePart | Model)
	local newProjectile = projectile:Clone()
	local primaryPart = FindPrimaryPart(newProjectile)
	if primaryPart then
		self.Projectile = newProjectile
	else
		warn("ProjectileSkill: Projectile does not have a PrimaryPart")
	end
end

function ProjectileSkill:SetUpdateFunction(updateFunction: (self: ProjectileSkillClass, deltaTime: number) -> nil)
	if self.__UpdateRBXScriptConnection then
		self.__UpdateRBXScriptConnection:Disconnect()
	end
	self.__UpdateRBXScriptConnection = RunService.Stepped:Connect(function(_, deltaTime)
		if self.Using then
			updateFunction(self, deltaTime)
			self:Update(deltaTime)
		end
	end)
end

function ProjectileSkill:SetCollisionFunction(collisionFunction: (self: ProjectileSkillClass, result: RaycastResult) -> nil)
	self.__CollisionFunction = collisionFunction
end

function ProjectileSkill:SetEndFunction(endFunction: (self: ProjectileSkillClass) -> nil)
	self.__EndFunction = endFunction
end

return ProjectileSkill
