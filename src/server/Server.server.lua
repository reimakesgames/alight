local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Utility = ReplicatedFirst.Utility

local Modules = Shared:WaitForChild("Modules")
local Types = Shared:WaitForChild("Types")

local Link = require(Packages:WaitForChild("link"))
local ToolHandler = require(Modules:WaitForChild("ToolHandler"))
local RagdollHandler = require(Modules:WaitForChild("RagdollHandler"))
local QuickInstance = require(Utility.QuickInstance)
local R6CharacterModel = require(Types.R6CharacterModel)
local ActiveHumanoid = require(Types.ActiveHumanoid)
local WeaponModel = require(Types.WeaponModel)

local DropToolSignal = Link:CreateEvent("DropTool")
local EquipToolFunction = Link:CreateFunction("EquipTool")

local function GenerateGuid()
	return QuickInstance("StringValue", {
		Name = "GUID";
		Value = HttpService:GenerateGUID(false)
	})
end

local function CharacterDied(player: Player, character: R6CharacterModel.Type)
	character:FindFirstChild("Health"):Destroy()
	character.HumanoidRootPart:SetNetworkOwner()
	local Tool: WeaponModel.Type = character:FindFirstChildWhichIsA("Tool")
	local Head: Part = character:FindFirstChild("Head")
	for _, object: BasePart in character:GetDescendants() do
		if not object:IsA("BasePart") then continue end
		if object:IsDescendantOf(Tool) then continue end
		local isAccessory = object:FindFirstAncestorOfClass("Accessory")
		if isAccessory then
			object.CanCollide = false
			continue
		end
	end
	if Tool and Head then
		ToolHandler.DropTool(player, Tool, Head.CFrame)
	end
	RagdollHandler.Activate(character)
	character.HumanoidRootPart.Velocity = character.HumanoidRootPart.CFrame.LookVector * -200
	character["Right Arm"].Velocity = character["Right Arm"].CFrame.RightVector * -200
	character["Left Arm"].Velocity = character["Left Arm"].CFrame.RightVector * 200
end

local function CharacterAdded(player: Player, character: R6CharacterModel.Type)
	for _, obj: WeaponModel.Type in ServerStorage.WeaponsTemporary:GetChildren() do
		local tool = obj:Clone()
		local guid = GenerateGuid()
		guid.Parent = tool
		tool.Parent = player.Backpack
	end
	local Humanoid: ActiveHumanoid.Type = character:WaitForChild("Humanoid")
	Humanoid.BreakJointsOnDeath = false
	Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health > 0 then return end
		CharacterDied(player, character)
	end)
end

local function PlayerAdded(player: Player)
	if player.Character then
		CharacterAdded(player, player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		CharacterAdded(player, character)
	end)
end

for _, player in Players:GetPlayers() do
	PlayerAdded(player)
end
Players.PlayerAdded:Connect(PlayerAdded)
DropToolSignal.Event:Connect(ToolHandler.DropTool)
EquipToolFunction:OnServerInvoke(ToolHandler.EquipTool)
