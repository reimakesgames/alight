local ITERATIONS = 8

export type Spring = {
	ApplyForce: (self: Spring, force: Vector3) -> nil;
	Step: (self: Spring, deltaTime: number) -> Vector3;

	Target: Vector3;
	Position: Vector3;
	Velocity: Vector3;

	Mass: number;
	Force: number;
	Damping: number;
	Speed: number;
}

local Spring = {}
Spring.__index = Spring

function Spring.new(mass: number, force: number, damping: number, speed: number)
	local spring = setmetatable({
		Target = Vector3.new(),
		Position = Vector3.new(),
		Velocity = Vector3.new(),

		Mass = mass or 5,
		Force = force or 50,
		Damping = damping or 4,
		Speed = speed or 4,
	}, Spring)

	return spring
end

function Spring:ApplyForce(force: Vector3)
	local X, Y, Z = force.X, force.Y, force.Z
	if X ~= X or X == math.huge or X == -math.huge then
		X = 0
	end
	if Y ~= Y or Y == math.huge or Y == -math.huge then
		Y = 0
	end
	if Z ~= Z or Z == math.huge or Z == -math.huge then
		Z = 0
	end
	self.Velocity = self.Velocity + Vector3.new(X, Y, Z)
end

function Spring:Step(deltaTime: number)
	local scaledDeltaTime = math.min(deltaTime, 1) * self.Speed / ITERATIONS

	for _ = 1, ITERATIONS do
		local iterationForce = self.Target - self.Position
		local acceleration = (iterationForce * self.Force) / self.Mass

		acceleration = acceleration - self.Velocity * self.Damping

		self.Velocity = self.Velocity + acceleration * scaledDeltaTime
		self.Position = self.Position + self.Velocity * scaledDeltaTime
	end

	return self.Position
end

return Spring
