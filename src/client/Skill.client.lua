local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Classes = Shared:WaitForChild("Classes")

local LocalPlayer = Players.LocalPlayer
local FireballSkill = require(Classes:WaitForChild("FireballSkill"))
local FireballWallSkill = require(Classes:WaitForChild("FireballWallSkill"))
local FlashSkill = require(Classes:WaitForChild("FlashSkill"))

UserInputService.InputBegan:Connect(function(inputObject, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end
	if inputObject.KeyCode == Enum.KeyCode.E then
		if LocalPlayer.Character then
			local camera = workspace.CurrentCamera
			local position = (LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 1.5, 0)).Position
			FireballSkill:Use(camera, position)
		end
	end
	if inputObject.KeyCode == Enum.KeyCode.C then
		if LocalPlayer.Character then
			local camera = workspace.CurrentCamera
			local position = (LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 1.5, 0)).Position
			FireballWallSkill:Use(camera, position)
		end
	end
	if inputObject.KeyCode == Enum.KeyCode.Q then
		if LocalPlayer.Character then
			local camera = workspace.CurrentCamera
			local position = (LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 1.5, 0)).Position
			FlashSkill:Use(camera, position)
		end
	end
end)
