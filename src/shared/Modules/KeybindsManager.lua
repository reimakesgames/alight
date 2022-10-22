export type ActionClass = {
	RegisterKey: (key: Enum.KeyCode | Enum.UserInputType) -> ();

	Name: string;
	Key: Enum.KeyCode | Enum.UserInputType;
}

export type KeybindsManager = {
	CreateAction: (name: string) -> (ActionClass);

	Actions: Dictionary<ActionClass>
}

local KeybindsManager = {
	Actions = {}
}

local ActionClass = {}
ActionClass.__index = ActionClass

function KeybindsManager:CreateAction(name: string): ActionClass
	if not name then
		return error("no name provided")
	end

	local Action = setmetatable({
		Name = name
	}, ActionClass)

	return Action :: ActionClass
end

function ActionClass:RegisterKey(key: Enum.KeyCode | Enum.UserInputType): nil
	if key.EnumType ~= Enum.KeyCode or key.EnumType ~= Enum.UserInputType then
		return error("provided key is not a Enum.KeyCode or Enum.UserInputType")
	end

	ActionClass.Key = key
end

-- TODO: add saving
-- TODO: create a workflow to replace everything that relies on static code
-- TODO: separate KeyCodes and UserInputTypes to support two types for future proofing

return KeybindsManager
