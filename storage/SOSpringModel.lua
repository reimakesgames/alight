export type Type = {
	__index: Type,
	new: (f: number, z: number, r: number, x0: Vector3) -> Type,
	Step: (self: Type, T: number) -> Vector3,

	Target: Vector3,
	Velocity: Vector3,

	f: number,
	z: number,
	r: number,

	xp: Vector3,
	y: Vector3,
	yd: Vector3,

	K1: number,
	K2: number,
	K3: number,
}

local NewVector3 = {}
NewVector3.__index = NewVector3

function NewVector3.new(x, y, z)
	return setmetatable({X = x, Y = y, Z = z}, NewVector3)
end

function NewVector3.__add(a, b)
	return NewVector3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z)
end

function NewVector3.__sub(a, b)
	return NewVector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
end

function NewVector3.__mul(a, b)
	if type(a) == "number" then
		return NewVector3.new(a * b.X, a * b.Y, a * b.Z)
	elseif type(b) == "number" then
		return NewVector3.new(a.X * b, a.Y * b, a.Z * b)
	end
	error("Invalid operands for multiplication")
end

function NewVector3.__div(a, b)
	if type(a) == "table" and type(b) == "number" then
		return NewVector3.new(a.X / b, a.Y / b, a.Z / b)
	end
	error("Invalid operands for division")
end

local Spring = {} :: Type
Spring.__index = Spring

function Spring.new(f: number, z: number, r: number, x0)
	local self = {
		xp = x0, -- Previous input
		y = x0, -- State variables
		yd = NewVector3.new(0, 0, 0),

		K1 = z / (math.pi * f), -- Damping coefficient
		K2 = 1 / ((2 * math.pi * f) * (2 * math.pi * f)), -- Force constant
		K3 = r * z / (2 * math.pi * f), -- Spring constant
	}

	return setmetatable(self, { __index = Spring }) :: Type
end

function Spring:Step(T)
	if not self.Velocity then
		-- Estimate velocity
		self.Velocity = (self.Target - self.xp) / T
		self.xp = self.Target
	end

	-- Clamp k2 to guarantee stability without jitter
	local k2_stable = math.max(self.K2, (T * T / 2) + T*self.K1/ 2, T * self.K1)

	-- Update the velocity and position of the spring
	self.y = self.y + (self.yd * T)
	self.yd = self.yd + T * ((self.Target + self.K3*self.Velocity) - self.y - self.K1*self.yd) / k2_stable

	return Vector3.new(self.y.X, self.y.Y, self.y.Z)
end

return Spring
