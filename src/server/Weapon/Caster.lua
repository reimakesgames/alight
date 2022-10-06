local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

export type Caster = {
	FindThickness: (object: Instance, hitPosition: Vector3, startPosition: Vector3, rayDirection: Vector3) -> (number | nil);
	Cast: (startPosition: Vector3, rayDirection: Vector3) -> (RaycastResult | nil, Vector3)
}

local Caster = {}

function Caster:FindThickness(object: Instance, hitPosition: Vector3, startPosition: Vector3, endPosition: Vector3): (number | nil, RaycastResult | nil)
	local RaycastParameter = RaycastParams.new()
	RaycastParameter.FilterDescendantsInstances = {object}
	RaycastParameter.FilterType = Enum.RaycastFilterType.Whitelist

	local RaycastResult = workspace:Raycast(startPosition, endPosition, RaycastParameter)
	if not RaycastResult then
		return nil, nil
	end

	local TravelDistance = (RaycastResult.Position - hitPosition).Magnitude
	return TravelDistance :: number, RaycastResult :: RaycastResult
end

function Caster:Cast(startPosition: Vector3, endPosition: Vector3, character): (RaycastResult | nil)
	local RaycastParameter = RaycastParams.new()
	RaycastParameter.FilterDescendantsInstances = {character}
	RaycastParameter.FilterType = Enum.RaycastFilterType.Blacklist

	local RaycastResult = workspace:Raycast(startPosition, endPosition, RaycastParameter)

	return RaycastResult
end

return Caster