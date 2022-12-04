local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Classes = Shared:WaitForChild("Classes")
local Gameplay = Assets:WaitForChild("Gameplay")

local Camera = workspace:WaitForChild("Camera")

local ProjectileSkill = require(Classes:WaitForChild("ProjectileSkill"))

export type FlashSkillClass = ProjectileSkill.ProjectileSkillClass | {
	-- Use: (self: FireballSkillClass, camera: Camera, position: Vector3) -> nil;
}

local FlashSkill = {} :: FlashSkillClass
FlashSkill.__index = FlashSkill

local function ConvertPixelsToScreenScale(vector2: Vector2)
	local viewportSize = Camera.ViewportSize
	local x = vector2.X / viewportSize.X
	local y = vector2.Y / viewportSize.Y
	return Vector2.new(x, y)
end

local function CalculateFlashAmount(origin: CFrame, target: Vector3)
	local targetLookVector = (target - origin.Position).Unit
	local dot = origin.LookVector:Dot(targetLookVector)
	local flashAmount = math.clamp(dot, 0, 1)
	return flashAmount
end

local function Collided(_self: FlashSkillClass, result: RaycastResult)
end

local function Update(self: FlashSkillClass, _deltaTime: number)
	if self.__Lifetime >= 1.5 and not self.CustomData.Triggered then
		self.CustomData.Triggered = true
		self.Velocity = Vector3.new(0, 0, 0)
		self.ConstantForce = Vector3.new(0, -200, 0)
	end
end

local function End(self: FlashSkillClass)
	local parameters = RaycastParams.new()
	parameters.FilterDescendantsInstances = {self.Projectile, Players.LocalPlayer.Character, Camera}
	parameters.FilterType = Enum.RaycastFilterType.Blacklist
	local result = workspace:Raycast(Camera.CFrame.Position, self.Position - Camera.CFrame.Position, parameters)
	if result then
		return
	end

	local vector, inViewport = Camera:WorldToViewportPoint(self.Position)
	local scale = ConvertPixelsToScreenScale(vector :: Vector2)
	local flashGui = Gameplay:WaitForChild("Flash"):Clone()
	local flashAmount = CalculateFlashAmount(Camera.CFrame, self.Position)
	local fadeOutTime = 0.5 + flashAmount
	local peakFlashTime = flashAmount
	Debris:AddItem(flashGui, peakFlashTime + fadeOutTime + 0.1)
	flashGui.Flash.Position = UDim2.new(scale.X, 0, scale.Y, 0)
	flashGui.Enabled = true
	flashGui.Parent = Players.LocalPlayer.PlayerGui
	local flashTween = TweenService:Create(flashGui.Flash, TweenInfo.new(fadeOutTime, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {ImageTransparency = 1})
	local backgroundTween = TweenService:Create(flashGui.Background, TweenInfo.new(fadeOutTime, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Transparency = 1})
	if not inViewport then
		flashGui.Flash.Visible = false
	end
	task.delay(peakFlashTime, function()
		flashTween:Play()
		backgroundTween:Play()
	end)
end

function FlashSkill:Use(camera: Camera, position: Vector3)
	local projectile = ProjectileSkill.new()
	projectile:SetProjectile(Gameplay:WaitForChild("FireFlash"))
	projectile.Lifetime = 0.25
	projectile.Speed = 40

	projectile.BounceFriction = 1
	projectile.BounceCountMax = 8
	projectile.BounceSlopeAngle = -1

	projectile.ConstantForce = Vector3.new(0, 0, 0) + camera.CFrame.RightVector * 320
	projectile.BaseVelocity = Vector3.new(0, 0, 0)

	projectile:SetCollisionFunction(Collided)
	projectile:SetUpdateFunction(Update)
	projectile:SetEndFunction(End)
	projectile:Use(camera, position)
end

return FlashSkill
