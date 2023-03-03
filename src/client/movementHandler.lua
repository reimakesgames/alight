local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local FastSignal = require(Packages.FastSignal)
local isRealNumber = require(Shared.isRealNumber)

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- These variables are unsafe and MUST BE CHECKED before performing operations
local Character: Model & any
local Humanoid: Humanoid

local BaseVelocity = 16
local VelocityMultiplier = 1.0

--[[
	Acceleration is a constant value, it defines how much the character accelerates in a second

	Deceleration is a constant value, but it is a percentage instead
		If Deceleration is 1, then the player decelerates the same rate as the Acceleration does
		Otherwise if it's 0.5, then the player decelerates half the rate Acceleration has

	PlayerAcceleration is calculated by:
		a = A*D
]]
local Acceleration = 128 -- how much the velocity changes per second
local Deceleration = 0.5 -- a percentage value
local WallFriction = 0.2 -- a percentage value

local Velocity = Vector3.new(0, 0, 0)
local Position = Vector3.new(0, 0, 0)
local PreviousPosition = Vector3.new(0, 0, 0)
local PreviousDeltaTime = 0
local Input = Vector3.new(0, 0, 0)
local W, A, S, D = false, false, false, false

local function CallSecure()
	return (Character and Humanoid)
end

local function BooleanToNumber(value: boolean): number
	return value and 1 or 0
end

export type Type = {
	init: () -> (),

	__inputsSinked: boolean,
	RelativeVelocity: Vector3,
	WorldVelocity: Vector3,

	InputSinkChanged: typeof(FastSignal.new()),
	ShiftLockChanged: typeof(FastSignal.new()),

	SinkInputs: (self: Type, enabled: boolean) -> (),
	AdjustVelocityMultiplier: (self: Type, multiplier: number) -> (),
}

local movementHandler = {
	__inputsSinked = false,
	RelativeVelocity = Vector3.new(),
	WorldVelocity = Vector3.new(),

	InputSinkChanged = FastSignal.new(),
	ShiftLockChanged = FastSignal.new(),
}

local function PhysicsUpdate(deltaTime: number): ()
	if not CallSecure() then return end

	-- force the player to have 0 walkspeed
	Humanoid.WalkSpeed = 0

	local IsGrounded = Humanoid.FloorMaterial ~= Enum.Material.Air

	local CameraLookVector = Camera.CFrame.LookVector
	local CharacterCFrame = Character.PrimaryPart.CFrame
	local MovementRequest = Input * (BaseVelocity * VelocityMultiplier)
	local VelocityDifference = (MovementRequest - Velocity).Unit

	--[[
		this conditional ensures that the magnitude of the PhysicsVelocity is always a real number
		why? because if the magnitude is 0, then the vector is a zero vector, and if the magnitude is NaN, then the vector is a NaN vector
		honestly i don't get the NaN and 0 errors in vectors
	]]
	if not isRealNumber(VelocityDifference.Magnitude) then
		VelocityDifference = Vector3.zero
	end

	local Modifier = 1
	if MovementRequest == Vector3.zero then
		Modifier = Acceleration * Deceleration
	else
		Modifier = Acceleration
	end

	-- this checks if the player is moving into a wall and if so, it slows them down
	if ((PreviousPosition - Position).Magnitude / PreviousDeltaTime) < (Velocity.Magnitude * 0.8) then
		Velocity = Velocity * WallFriction
	end

	if not IsGrounded then
		Modifier = Modifier * 0.1
		print("air")
	end
	Velocity = Velocity + ((VelocityDifference * Modifier) * deltaTime)

	-- this conditional makes sure that if Velocity is close to zero, then it is set to zero
	-- this fixes the issue where your velocity would flicker when coming to a halt
	if Velocity:FuzzyEq(Vector3.zero, 0.5) and MovementRequest == Vector3.zero then
		Velocity = Vector3.zero
	end

	if Velocity:FuzzyEq(MovementRequest, 0.2) then
		Velocity = MovementRequest
	end

	local CameraLookVectorUnit = Vector2.new(CameraLookVector.X, CameraLookVector.Z).Unit
	local CameraDirection = math.atan2(-CameraLookVectorUnit.X, -CameraLookVectorUnit.Y)
	-- local CharacterLookVectorUnit = Vector2.new(CharacterLookVector.X, CharacterLookVector.Z).Unit
	-- local CharacterDirection = math.atan2(-CharacterLookVectorUnit.X, -CharacterLookVectorUnit.Y)

	local RelativeVelocity = CFrame.Angles(0, CameraDirection, 0) * CFrame.new(Velocity)
	-- local RelativeVelocityDirection = smoothenedAtan2(-RelativeVelocity.X, -RelativeVelocity.Z)

	movementHandler.WorldVelocity = RelativeVelocity.Position
	movementHandler.RelativeVelocity = Velocity

	local NewCFrame = CharacterCFrame + (RelativeVelocity.Position * deltaTime)

	PreviousPosition = Position
	Character:PivotTo(NewCFrame)
	Position = Vector3.new(NewCFrame.X, 0, NewCFrame.Z)

	LocalPlayer.PlayerGui.debug.TextLabel.Text = math.round((Position - PreviousPosition).Magnitude * 100) / 100 ..
		"\n" .. math.round((Position - PreviousPosition).Magnitude / deltaTime * 100) / 100

	PreviousDeltaTime = deltaTime
end

local function UpdatePlayerMovementRequest(_deltaTime: number): ()
	-- Don't delete this, this is an 'uncompressed' version of the code below
	-- local Forward = Vector3.new(0, 0, if W then -1 else 0)
	-- local Backward = Vector3.new(0, 0, if S then 1 else 0)
	-- local Left = Vector3.new(if A then -1 else 0, 0, 0)
	-- local Right = Vector3.new(if D then 1 else 0, 0, 0)
	-- local MovementSummary = (Forward + Backward + Left + Right)

	-- local MovementSummary = Vector2.new((if D then 1 else 0) - (if A then 1 else 0), (if S then 1 else 0) - (if W then 1 else 0))
	-- this could be simplified to this
	local MovementSummary = Vector3.new(BooleanToNumber(D) - BooleanToNumber(A), 0, BooleanToNumber(S) - BooleanToNumber(W))
	Input = if MovementSummary.Magnitude > 0 then MovementSummary.Unit else MovementSummary
end

local function UpdateThread(_, deltaTime: number): ()
	UpdatePlayerMovementRequest(deltaTime)
	PhysicsUpdate(deltaTime)
end

local function CharacterAdded(character: Model & any): ()
	Character = character
	print(`Character now exists at {character:GetFullName()}`)
	print("Waiting for Humanoid to be created")
	-- this WaitForChild call is unsafe, as we can't be sure that there's nothing else named Humanoid
	Humanoid = Character:WaitForChild("Humanoid")
	Character.PrimaryPart = Character:WaitForChild("HumanoidRootPart")
	print(`Found Humanoid at {Humanoid:GetFullName()}`)
end

local function CharacterRemoving(character: Model & any): ()
	print(`Character deleted at {character:GetFullName()}`)
	Character = nil :: any
	Humanoid = nil :: any
	print("Unreferenced Character Related Objects")
end

local function KeyDown(inputObject: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then return end
	if inputObject.UserInputType ~= Enum.UserInputType.Keyboard then
		--print("ignored a non keyboard input")
		return
	end

	local key = inputObject.KeyCode
	if key == Enum.KeyCode.W then
		W = true
	elseif key == Enum.KeyCode.S then
		S = true
	elseif key == Enum.KeyCode.A then
		A = true
	elseif key == Enum.KeyCode.D then
		D = true
	end
end

local function KeyUp(inputObject: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then return end
	if inputObject.UserInputType ~= Enum.UserInputType.Keyboard then
		--print("ignored a non keyboard input")
		return
	end

	local key = inputObject.KeyCode
	if key == Enum.KeyCode.W then
		W = false
	elseif key == Enum.KeyCode.S then
		S = false
	elseif key == Enum.KeyCode.A then
		A = false
	elseif key == Enum.KeyCode.D then
		D = false
	end
end

function movementHandler:SinkInputs(enabled: boolean): ()
	movementHandler.__inputsSinked = enabled
	movementHandler.InputSinkChanged:Fire(enabled)
end

function movementHandler:AdjustVelocityMultiplier(multiplier: number): ()
	assert(isRealNumber(multiplier), "multiplier must be a real number")
	VelocityMultiplier = multiplier
end

function movementHandler.init()
	if LocalPlayer.Character then
		CharacterAdded(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(CharacterAdded)
	LocalPlayer.CharacterRemoving:Connect(CharacterRemoving)
	RunService.Stepped:Connect(UpdateThread)
	UserInputService.InputBegan:Connect(KeyDown)
	UserInputService.InputEnded:Connect(KeyUp)
end

return movementHandler :: Type
