local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local Assets = ReplicatedStorage.Assets

local Viewmodel = require(Shared.Viewmodel)
local fastInstance = require(Shared.fastInstance)

local viewmodelHandler = require(script.Parent.viewmodelHandler)

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Rig = Assets.v_UMP45
local Arms = Assets.Arms

local function OnCharacterAdded(character)
	Character = character
	viewmodelHandler.SetCharacter(character)
end

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
	LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
	viewmodelHandler.SetCharacter(Character)

	viewmodelHandler.CacheViewmodel(viewmodel)
	viewmodelHandler.SetViewmodel(viewmodel)
end

return combatSystem
