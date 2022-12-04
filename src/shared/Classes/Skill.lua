export type Interface = {
	__index: Interface;
	new: () -> Interface;
	Destroy: (self: Interface) -> nil;

	Using: boolean;
	CustomData: { [string]: any };

	Update: (self: Interface, deltaTime: number) -> nil;

	Use: (self: Interface) -> nil;
	Equip: (self: Interface) -> nil;
}

local Skill = {} :: Interface
Skill.__index = Skill

function Skill.new()
	local self = setmetatable({}, Skill)
	self.CustomData = {}
	return self
end

function Skill:Destroy()
end

function Skill:Use()
end

function Skill:Equip()
end

function Skill:Update(deltaTime: number)
end

return Skill
