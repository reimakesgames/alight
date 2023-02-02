local RaycastHandler = {}

function RaycastHandler:Raycast(startPosition: Vector3, lookVector: Vector3, distance: number, parameter: RaycastParams): RaycastResult?
	local RaycastResult = workspace:Raycast(startPosition, lookVector * distance, parameter)

	return RaycastResult
end

function RaycastHandler:CheckHitDepth(object: BasePart, origin: Vector3, lookVector: Vector3): (RaycastResult?, number?)
	local Parameter = RaycastParams.new()
	Parameter.FilterDescendantsInstances = { object }
	Parameter.FilterType = Enum.RaycastFilterType.Whitelist

	local Result = workspace:Raycast(origin + (lookVector * 64), -lookVector * 64, Parameter)
	if not Result then
		return
	end
	local Depth = (origin - Result.Position).Magnitude

	return Result, Depth
end

return RaycastHandler
