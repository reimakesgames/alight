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

--[=[
	A Spring is a physics simulation that can be used to simulate a spring-like effect.

	@class Spring
]=]
local CLASS_NAME = "SpringClass"
local Spring = {} :: Type
Spring.__index = Spring

--[=[
	@prop Target Vector3
	@within Spring
	@readonly

	The target position of the spring.
]=]

--[=[
	@prop Position Vector3
	@within Spring
	@readonly

	The current position of the spring.
]=]

--[=[
	@prop Velocity Vector3
	@within Spring
	@readonly

	The current velocity of the spring.
]=]

--[=[
	@prop Mass number
	@within Spring
	@readonly

	The mass of the spring.
]=]

--[=[
	@prop Force number
	@within Spring
	@readonly

	The force of the spring.
]=]

--[=[
	@prop Damping number
	@within Spring
	@readonly

	The damping of the spring.
]=]

--[=[
	@prop Speed number
	@within Spring
	@readonly

	The speed of the spring.
]=]

--[=[
	Creates a new Spring.

	@param mass number
	@param force number
	@param damping number
	@param speed number
	@return Spring
]=]

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

--[=[
	Destroys the Spring.

	@return nil
]=]
function Spring:Destroy()
	setmetatable(self, nil)
	table.clear(self)
end

--[=[
	Checks if the Spring is a Spring.

	@param className string
	@return boolean
]=]
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

--[=[
	Sets the target position of the Spring.

	@param target Vector3
	@return nil
]=]
function Spring:SetTarget(target: Vector3)
	self.Target = target
end

--[=[
	Steps the Spring with an internal iteration count of 8.

	This updates the position and velocity of the Spring, and returns the new position.

	This should be called every frame.

	@param deltaTime number
	@return Vector3
]=]
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
