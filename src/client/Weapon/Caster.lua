local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CurrentCamera = workspace.CurrentCamera

export type Caster = {
	FindThickness: (object: Instance, hitPosition: Vector3, startPosition: Vector3, rayDirection: Vector3) -> (number | nil);
	Cast: (startPosition: Vector3, rayDirection: Vector3) -> (RaycastResult | nil, Vector3)
}

local Caster = {}

function Caster:FindThickness(object: Instance, hitPosition: Vector3, startPosition: Vector3, endPosition: Vector3): (number | nil, Vector3 | nil)
	local RaycastParameter = RaycastParams.new()
	RaycastParameter.FilterDescendantsInstances = {object}
	RaycastParameter.FilterType = Enum.RaycastFilterType.Whitelist

	local RaycastResult = workspace:Raycast(startPosition, endPosition, RaycastParameter)
	if not RaycastResult then
		return nil, nil
	end

	local TravelDistance = (RaycastResult.Position - hitPosition).Magnitude
	return TravelDistance :: number, RaycastResult.Position :: Vector3
end

function Caster:Cast(startPosition: Vector3, endPosition: Vector3): (RaycastResult | nil)
	local RaycastParameter = RaycastParams.new()
	RaycastParameter.FilterDescendantsInstances = {LocalPlayer.Character, CurrentCamera}
	RaycastParameter.FilterType = Enum.RaycastFilterType.Blacklist

	local RaycastResult = workspace:Raycast(startPosition, endPosition, RaycastParameter)

	return RaycastResult
end

return Caster