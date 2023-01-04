local isRealNumber = require(script.Parent.isRealNumber)

local ITERATIONS = 8

export type Type = {
	__index: Type;
	new: (mass: number, force: number, damping: number, speed: number) -> Type;
	Destroy: (self: Type) -> nil;
	IsA: (self: Type, className: string) -> boolean;

	AddVelocity: (self: Type, force: Vector3) -> nil;
	Step: (self: Type, deltaTime: number) -> Vector3;
	SetTarget: (self: Type, target: Vector3) -> nil;

	Target: Vector3;
	Position: Vector3;
	Velocity: Vector3;

	Mass: number;
	Force: number;
	Damping: number;
	Speed: number;
}

local CLASS_NAME = "SpringClass"
local Spring = {} :: Type
Spring.__index = Spring

function Spring.new(mass: number?, force: number?, damping: number?, speed: number?): Type
	local spring = setmetatable({
		Target = Vector3.new(),
		Position = Vector3.new(),
		Velocity = Vector3.new(),

		Mass = mass or 5,
		Force = force or 50,
		Damping = damping or 4,
		Speed = speed or 4,
	}, Spring)

	return spring :: Type
end

function Spring:Destroy()
	setmetatable(self, nil)
	table.clear(self)
end

function Spring:IsA(className: string)
	return className == CLASS_NAME
end

function Spring:AddVelocity(force: Vector3)
	local X, Y, Z = force.X, force.Y, force.Z
	X = isRealNumber(X) and X or 0
	Y = isRealNumber(Y) and Y or 0
	Z = isRealNumber(Z) and Z or 0
	self.Velocity = self.Velocity + Vector3.new(X, Y, Z)
end

function Spring:SetTarget(target: Vector3)
	self.Target = target
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

return Spring :: {
	new: (mass: number, force: number, damping: number, speed: number) -> (Type)
}
