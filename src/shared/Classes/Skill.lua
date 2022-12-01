-- Skill is an interface

export type SkillClass = {
	__index: SkillClass;
	new: () -> SkillClass;
	CleanUp: (self: SkillClass) -> nil;

	Cast: (self: SkillClass) -> nil;
}

local SkillClass = {} :: SkillClass
SkillClass.__index = SkillClass

function SkillClass.new()
	local self = setmetatable({}, SkillClass)
	return self
end

function SkillClass:CleanUp()
end

function SkillClass:Cast()
end

return SkillClass
