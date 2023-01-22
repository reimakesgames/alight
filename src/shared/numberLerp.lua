--[[
	This function is a linear interpolation (lerp) function that can be used in two different circumstances. It takes four parameters:

	origin: the starting value
	target: the desired end value
	speed: a value that controls the rate of interpolation (the smaller the value, the slower the interpolation)
	dt: an optional parameter that represents the time delta (in seconds) since the last update. If this value is not provided, it defaults to 1.

	The function calculates the interpolated value by multiplying the difference between the origin and target by the speed, and then adding the result to the origin.
	The final result is also multiplied by dt with 60 that is used to convert seconds to frames. It returns the interpolated value as a number.

	---

	### Framerate Independent Lerp
	```lua
	game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
		local result = numberLerp(current, target, 0.2, deltaTime)
		-- returns the result with frame independency
	end)
	```

	### Normal Lerp
	```lua
	local result = numberLerp(current, target, 0.2)
	-- returns the typical 20% of current to target
	```
]]
return function (origin: number, target: number, speed: number, dt: number?): number
	if not dt then
		dt = 1
	else
		dt = dt * 60
	end
	return origin + (((target - origin) * speed) * dt :: number)
end
