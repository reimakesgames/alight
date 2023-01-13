local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local Assets = ReplicatedStorage.Assets

local Viewmodel = require(Shared.Viewmodel)
local fastInstance = require(Shared.fastInstance)

local viewmodelHandler = require(script.Parent.viewmodelHandler)
local keybindsHandler = require(script.Parent.keybindsHandler)

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Rig = Assets.v_UMP45
local Arms = Assets.Arms

local Walking = false

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
		if input.KeyCode == keybindsHandler.keybinds.Gameplay.Walk then
			Walking = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == keybindsHandler.keybinds.Gameplay.Walk then
			Walking = false
		end
	end)
end

return combatSystem
