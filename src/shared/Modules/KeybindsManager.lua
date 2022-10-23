export type ActionClass = {
	RegisterKey: (self: ActionClass, key: Enum.KeyCode | Enum.UserInputType) -> ();
	GetKeyType: (self: ActionClass) -> (Enum.KeyCode | Enum.UserInputType);

	Name: string;
	Key: Enum.KeyCode | Enum.UserInputType;
}

export type KeybindsManager = {
	CreateAction: (self: KeybindsManager, name: string) -> (ActionClass);

	Actions: Dictionary<ActionClass> | {[string]: ActionClass}
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

	KeybindsManager.Actions[name] = Action

	return Action :: ActionClass
end

function ActionClass:RegisterKey(key: Enum.KeyCode | Enum.UserInputType): nil
	if key.EnumType ~= Enum.KeyCode and key.EnumType ~= Enum.UserInputType then
		return error("provided key is not a Enum.KeyCode or Enum.UserInputType")
	end

	self.Key = key
end

function ActionClass:GetKeyType()
	return self.Key.EnumType
end

-- TODO: add saving
-- TODO: create a workflow to replace everything that relies on static code

-- TODO: separate KeyCodes and UserInputTypes to support two types for future proofing
-- FIXED: can be replaced with a function returning the key type

return KeybindsManager
