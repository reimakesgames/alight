local RunService = game:GetService("RunService")

export type Type = {
	__index: Type;
	new: (mass: number, force: number, damping: number, speed: number) -> Type;
	destroy: (self: Type) -> nil;

	addVelocity: (self: Type, force: Vector3) -> nil;
	update: (self: Type, deltaTime: number) -> Vector3;
	setTarget: (self: Type, target: Vector3) -> nil;

	target: Vector3;
	position: Vector3;
	velocity: Vector3;

	mass: number;
	force: number;
	damping: number;
	speed: number;
}

local Spring = {}
Spring.__index = Spring

local ITERATIONS = 8
local isRealNumber = require(script.Parent.isRealNumber)

--[=[
	@class Spring

	A spring is a physics simulation that can be used to animate a value over time.
	When a spring is created, it is given a target value. The spring will then
	animate towards that value, taking into account the mass, force, damping, and
	speed of the spring.
]=]
--[=[
	@prop target Vector3
	@within Spring
	@since 0.6.0
	@readonly

	The target of the spring. This is the value that the spring will animate towards.
]=]

--[=[
	@prop position Vector3
	@within Spring
	@since 0.6.0
	@readonly

	The current position of the spring. This is the value that the spring is currently at.
]=]
--[=[
	@prop velocity Vector3
	@within Spring
	@since 0.6.0
	@readonly

	The current velocity of the spring. This is the speed at which the spring is currently moving.
]=]
--[=[
	@prop mass number
	@within Spring
	@since 0.6.0
	@readonly

	The mass of the spring. Higher mass means the spring will be more sluggish.
]=]
--[=[
	@prop force number
	@within Spring
	@since 0.6.0
	@readonly

	The force of the spring. Higher force means the spring will be more responsive.
]=]
--[=[
	@prop damping number
	@within Spring
	@since 0.6.0
	@readonly

	The damping of the spring. Higher damping means the spring will be more sluggish.
]=]
--[=[
	@prop speed number
	@within Spring
	@since 0.6.0
	@readonly

	The speed of the spring. Higher speed means the spring will be more responsive.
]=]

--[=[
	@param mass number? -- 5
	@param force number? -- 50
	@param damping number? -- 4
	@param speed number? -- 4
	@return Spring -- A new spring object.
	@since 0.6.0

	A function that creates a new spring object.

	:::caution
	If you do not need the spring anymore, you should call the `Destroy` method on it.
	:::
]=]
function Spring.new(mass: number?, force: number?, damping: number?, speed: number?): Type
	local spring = setmetatable({
		target = Vector3.new(),
		position = Vector3.new(),
		velocity = Vector3.new(),

		mass = mass or 5,
		force = force or 50,
		damping = damping or 4,
		speed = speed or 4,
	}, Spring)

	return spring :: Type
end

--[=[
	@return nil
	@since 0.6.0

	A method that destroys the spring.
	You should call this method when you no longer need the spring.
]=]
function Spring:destroy()
	setmetatable(self, nil)
	table.clear(self)
end

--[=[
	@param force Vector3 -- The force to add to the spring.
	@since 0.6.0

	A method that adds a provided `force` to the spring's velocity.
]=]
function Spring:addVelocity(force: Vector3)
	local X, Y, Z = force.X, force.Y, force.Z
	X = isRealNumber(X) and X or 0
	Y = isRealNumber(Y) and Y or 0
	Z = isRealNumber(Z) and Z or 0
	self.velocity = self.velocity + Vector3.new(X, Y, Z)
end

--[=[
	@param target Vector3 -- The target to set the spring to.
	@since 0.6.0

	A method that sets the target of the spring.

	:::tip
	You can use this method to animate the spring to a new target without affecting the current velocity.
	:::
]=]
function Spring:setTarget(target: Vector3)
	self.target = target
end

--[=[
	@param deltaTime number -- The delta time since the last frame.
	@since 0.6.0

	A method that updates the spring.
	This method should be called once every frame.

	@return Vector3 -- The current position of the spring.
]=]
function Spring:update(deltaTime: number)
	local scaledDeltaTime = math.min(deltaTime, 1) * self.speed / ITERATIONS

	for _ = 1, ITERATIONS do
		local iterationForce = self.target - self.position
		local acceleration = (iterationForce * self.force) / self.mass
		acceleration = acceleration - self.velocity * self.damping
		self.velocity = self.velocity + acceleration * scaledDeltaTime
		self.position = self.position + self.velocity * scaledDeltaTime
	end

	return self.position
end

return Spring :: {
	new: (mass: number, force: number, damping: number, speed: number) -> Type;
}
