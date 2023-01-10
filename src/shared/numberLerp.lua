return function (origin: number, target: number, t: number, dt: number): number
	return origin + ((target - origin) * (1 - t ^ dt))
end
