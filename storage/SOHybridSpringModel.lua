export type Type = {
	__index: Type,
	new: (mass: number, force: number, damping: number, speed: number) -> Type,
	ApplyForce: (self: Type, force: Vector3) -> nil,
	Step: (self: Type, deltaTime: number) -> nil,
	ChangeMass: (self: Type, mass: number) -> nil,
	ChangeForce: (self: Type, force: number) -> nil,
	ChangeDamping: (self: Type, damping: number) -> nil,
	ChangeSpeed: (self: Type, speed: number) -> nil,

	Target: Vector3,
	Position: Vector3,
	Velocity: Vector3,
	Acceleration: Vector3,

	Mass: number,
	Force: number,
	Damping: number,
	Speed: number,

	K1: number,
	K2: number,
	K3: number,
}

local ITERATIONS = 8

local Spring = {} :: Type
Spring.__index = Spring

function Spring.new(mass: number, force: number, damping: number, speed: number)
	local self = {
		Target = Vector3.new(),
		Position = Vector3.new(),
		Velocity = Vector3.new(),
		Acceleration = Vector3.new(),

		Mass = mass or 5,
		Force = force or 50,
		Damping = damping or 4,
		Speed = speed or 4,

		-- Constants for the second-order spring model
		K1 = damping / mass, -- Damping coefficient
		K2 = force / mass, -- Force constant
		K3 = force / mass, -- Spring constant
	} :: Type

	return setmetatable(self, Spring)
end

function Spring:ApplyForce(force: Vector3)
	self.Velocity = self.Velocity + force / self.Mass
end

function Spring:Step(deltaTime)
	local scaledDeltaTime = math.min(deltaTime, 1) * self.Speed / ITERATIONS

	for _ = 1, ITERATIONS do
		-- Calculate the force acting on the spring
		local iterationForce = self.Target - self.Position

		-- Calculate the acceleration of the spring
		local newAcceleration = ((iterationForce * self.Force) / self.Mass) - (self.Damping * self.Velocity) - self.Acceleration

		-- Clamp k2 to guarantee stability without jitter
		local k2_stable = math.max(self.K2, (scaledDeltaTime * scaledDeltaTime) / 2 + (scaledDeltaTime * self.K1) / 2, (scaledDeltaTime * self.K1))

		-- Update the velocity and position of the spring
		self.Velocity = self.Velocity + (self.Acceleration * scaledDeltaTime) + (newAcceleration * scaledDeltaTime)
		self.Position = self.Position + (self.Velocity * scaledDeltaTime)

		-- Update the acceleration of the spring
		self.Acceleration = ((iterationForce + (self.K3 * self.Velocity) - self.Position) - (self.K1 * self.Velocity)) / k2_stable
	end
end

function Spring:ChangeMass(mass: number)
	self.Mass = mass
	self.K1 = self.Damping / self.Mass
	self.K2 = self.Force / self.Mass
	self.K3 = self.Force / self.Mass
end

function Spring:ChangeForce(force: number)
	self.Force = force
	self.K2 = self.Force / self.Mass
	self.K3 = self.Force / self.Mass
end

function Spring:ChangeDamping(damping: number)
	self.Damping = damping
	self.K1 = self.Damping / self.Mass
end

function Spring:ChangeSpeed(speed: number)
	self.Speed = speed
end

return Spring :: {
	new: (mass: number, force: number, damping: number, speed: number) -> Type,
}
