local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Mouse = Players.LocalPlayer:GetMouse()

local Shared = ReplicatedStorage.Shared
local Assets = ReplicatedStorage.Assets

local Viewmodel = require(Shared.Viewmodel)
local fastInstance = require(Shared.fastInstance)
local mapPing = require(Shared.mapPing)

local viewmodelHandler = require(script.Parent.viewmodelHandler)
local keybindsHandler = require(script.Parent.keybindsHandler)

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Rig = Assets.v_UMP45
local Arms = Assets.Arms

local Walking = false
local Aiming = false
local Firing = false
local Shooting = false

local function OnCharacterAdded(character)
	Character = character
	viewmodelHandler.SetCharacter(character)
end

keybindsHandler:LoadKeybindsFromServer()

local combatSystem = {}

function combatSystem.init()
	print("Viewmodel created")
	local viewmodel = Viewmodel.new(Rig)
	viewmodel:Decorate(Arms)
	viewmodel:LoadDictAnimations({
		idle = {
			fastInstance("Animation", {
				AnimationId = "rbxassetid://11060004291",
				Name = "idle",
			}), {
				animationPriority = Enum.AnimationPriority.Idle,
				looped = true,
			}
		},
	})
	viewmodel.Animator:PlayAnimation("idle")
	RunService:BindToRenderStep("__VIEWMODEL__", Enum.RenderPriority.Camera.Value, function(deltaTime)
		viewmodelHandler.Update(deltaTime, Camera)
	end)
	RunService:BindToRenderStep("__AFTER__", Enum.RenderPriority.Input.Value + 1, function(_deltaTime)
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		Humanoid.WalkSpeed = Walking and 8 or 16
	end)
	LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
	viewmodelHandler.SetCharacter(Character)

	viewmodelHandler.CacheViewmodel(viewmodel)
	viewmodelHandler.SetViewmodel(viewmodel)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == keybindsHandler.Keybinds.Gameplay.Walk then
			Walking = true
		end
		if input.UserInputType == keybindsHandler.Keybinds.Gameplay.Fire then
			if Firing then return end
			if Shooting then return end
			Firing = true
			task.spawn(function()
				repeat
					Shooting = true
					viewmodelHandler.Fire()
					task.wait(0.1)
					Shooting = false
				until not Firing
			end)
		end
		if input.UserInputType == keybindsHandler.Keybinds.Gameplay.AltFire then
			Aiming = not Aiming
			viewmodelHandler.SetAltFireDown(Aiming)
		end

		if input.KeyCode == keybindsHandler.Keybinds.Gameplay.Ping then
			mapPing.new(Mouse.Hit.Position) -- ! THIS IS A TEMPORARY SOLUTION, REPLACE AS RAYCAST FILTERS ARE IMPLEMENTED
		end
	end)
	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == keybindsHandler.Keybinds.Gameplay.Fire then
			Firing = false
		end
		if input.KeyCode == keybindsHandler.Keybinds.Gameplay.Walk then
			Walking = false
		end
	end)
end

return combatSystem
