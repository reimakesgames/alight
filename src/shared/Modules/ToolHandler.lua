local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = ReplicatedFirst:WaitForChild("Utility")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Types = Shared:WaitForChild("Types")

local QuickInstance = require(Utility.QuickInstance)

local WeaponModel = require(Types.WeaponModel)
local R6CharacterModel = require(Types.R6CharacterModel)
local ActiveHumanoid = require(Types.ActiveHumanoid)

local PICKUP_HITBOX_NAME = "PICKUP_HITBOX"

local function GetMass(model: Model | Folder)
	local mass = 0
	for _, part: BasePart in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			mass += part.AssemblyMass
		end
	end
	return mass
end

local ToolHandler = {}

function ToolHandler.FilterCollider(part: BasePart)
	if not part:IsA("BasePart") then
		return
	end
	if part.Name == PICKUP_HITBOX_NAME then
		part:Destroy()
	end
	if part.Name == "Handle" and part.Parent:IsA("Tool") then
		part.CanCollide = false
		return
	end
	part.CanCollide = true
end

function ToolHandler.CreateHitbox(clone: WeaponModel.Type)
	local Orientation, _ = clone.Model:GetBoundingBox()
	local Hitbox = QuickInstance("Part", {
		Name = PICKUP_HITBOX_NAME;
		Shape = Enum.PartType.Ball;
		Transparency = 1;

		Massless = true;
		CanCollide = false;

		Size = Vector3.new(4, 4, 4);
		CFrame = Orientation
	})
	QuickInstance("WeldConstraint", {
		Parent = Hitbox;
		Part0 = Hitbox;
		Part1 = clone.Handle;
	})
	Hitbox:SetAttribute("HC_PICKUP", true)
	Hitbox.Parent = clone
end

function ToolHandler.DropTool(_: Player, tool: WeaponModel.Type, directionCFrame: CFrame)
	if not tool or not directionCFrame then
		return
	end
	if tool:GetAttribute("HC_VALID_WEAPON") == true then
		local newPosition = directionCFrame.Position + (directionCFrame.LookVector * 2)
		local Clone = tool:Clone()
		for _, part: BasePart in Clone:GetDescendants() do
			ToolHandler.FilterCollider(part)
		end
		ToolHandler.CreateHitbox(Clone)
		Clone.Parent = workspace
		Clone.Handle:ApplyImpulse(directionCFrame.LookVector * (GetMass(Clone) * 2))
		Clone.Handle:ApplyImpulse(Vector3.new(0, 1, 0) * (GetMass(Clone) * 2))
		Clone.Handle:ApplyAngularImpulse(directionCFrame.LookVector * (GetMass(Clone) * 0.1))
		Clone.Handle:FindFirstChildWhichIsA("TouchTransmitter", true):Destroy()
		Clone.Handle.CFrame = CFrame.new(newPosition, newPosition + directionCFrame.LookVector)
		tool:Destroy()
	end
end

function ToolHandler.EquipTool(player: Player, tool: WeaponModel.Type)
	if not tool or not tool:IsA("Tool") then
		return "no tool?"
	end
	local Character: R6CharacterModel.Type = player.Character
	local Humanoid: ActiveHumanoid.Type = Character:FindFirstChild("Humanoid")
	local Head: Part = Character:FindFirstChild("Head")
	local Hitbox: Part = tool:FindFirstChild("PICKUP_HITBOX")
	if not Humanoid then
		return "no humanoid?"
	end
	if not Head then
		return "no head?"
	end
	if not Hitbox then
		return "no hitbox?"
	end
	if (Hitbox.CFrame.Position - Head.CFrame.Position).Magnitude < 6 then
		Humanoid:EquipTool(tool)
		return "ok"
	end
	return "huh you failed all verification tests."
end

return ToolHandler
