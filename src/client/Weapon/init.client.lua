local UserInputService = game:GetService("UserInputService")

local Camera = workspace.CurrentCamera

local Caster = require(script.Caster)

local function CreatePair(Origin, Stop)
	local Start = workspace.Start:Clone()
	local End = workspace.End:Clone()

	Start.Position = Origin
	End.Position = Stop

	Start.Parent = workspace
	End.Parent = workspace
	Start.Attachment.Beam.Attachment1 = End.Attachment
end

local function Cast()
	local Result: RaycastResult = Caster:Cast(Camera.CFrame.Position, Camera.CFrame.LookVector * 1024)
	print(Result)

	if not Result then
		return
	end

	CreatePair(Camera.CFrame.Position, Result.Position)

	local PartDepth, HitPosition = Caster:FindThickness(Result.Instance, Result.Position, Camera.CFrame.Position + (Camera.CFrame.LookVector * 512), -Camera.CFrame.LookVector * 512)
	print(PartDepth)
	print(HitPosition)
	CreatePair(Camera.CFrame.Position + (Camera.CFrame.LookVector * 512), HitPosition)

	if not PartDepth then
		return
	end
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Cast()
	end
end)
