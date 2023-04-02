local RunService = game:GetService("RunService")

local SIZE = 1
local BLOOM = 2
local BRIGHTNESS = 50

local Camera = workspace.CurrentCamera
local CameraCFrame = Camera.CFrame

local ActiveTracers = {}

local vtracers = {}
vtracers.__index = vtracers

function vtracers.new(startingPosition, endingPosition)
	local self = setmetatable({
		TimeLast = nil,
		PosLast = nil,
		VelLast = nil,

		TimeNow = tick(),
		PosNow = CameraCFrame:PointToWorldSpace(startingPosition),
		VelNow = nil,

		Start = startingPosition,
		End = endingPosition,

		Attachment0 = Instance.new("Attachment"),
		Attachment1 = Instance.new("Attachment"),
		Beam = Instance.new("Beam"),
		Position = startingPosition,
	}, vtracers)

	self.Beam.Attachment0 = self.Attachment0
	self.Beam.Attachment1 = self.Attachment1
	self.Beam.Segments = 16
	self.Beam.TextureSpeed = 0
	self.Beam.Texture = "http://www.roblox.com/asset/?id=2650195052"
	self.Beam.Transparency = NumberSequence.new(0)
	self.Beam.FaceCamera = true

	self.Attachment0.Parent = workspace.Terrain
	self.Attachment1.Parent = workspace.Terrain
	self.Beam.Parent = workspace.Terrain

	table.insert(ActiveTracers, self)

	return self
end

function vtracers:Update(tracerPosition, deltaTime)
	if (self.Position - self.Start).magnitude > (self.End - self.Start).magnitude then
		self:Destroy()
		return
	end

	local TimeNew = tick()
	local PosNew = CameraCFrame:PointToObjectSpace(tracerPosition)
	local VelNew
	if self.TimeLast then
		VelNew = 2 / (TimeNew - self.TimeNow) * (PosNew - self.PosNow) - (PosNew - self.PosLast) / (TimeNew - self.TimeLast)
	else
		VelNew = (PosNew - self.PosNow) / (TimeNew - self.TimeNow)
		self.VelNow = VelNew
	end

	self.TimeLast, self.VelLast, self.PosLast = self.TimeNow, self.VelNow, self.PosNow
	self.TimeNow, self.VelNow, self.PosNow = TimeNew, VelNew, PosNew

	local Magnitude0 = self.VelLast.Magnitude
	local Magnitude1 = self.VelNow.Magnitude
	-- self.Beam.CurveSize0 = deltaTime / 4 * Magnitude0
	-- self.Beam.CurveSize1 = deltaTime / 4 * Magnitude1
	self.Attachment0.Position = CameraCFrame * self.PosLast
	self.Attachment1.Position = CameraCFrame * self.PosNow
	if Magnitude0 > 1.0E-8 then
		self.Attachment0.Axis = CameraCFrame:VectorToWorldSpace(self.VelLast / Magnitude0)
	end
	if Magnitude1 > 1.0E-8 then
		self.Attachment1.Axis = CameraCFrame:VectorToWorldSpace(self.VelNow / Magnitude1)
	end
	local Distance0 = -self.PosLast.z
	local Distance1 = -self.PosNow.z
	if Distance0 < 0 then
		Distance0 = 0
	end
	if Distance1 < 0 then
		Distance1 = 0
	end
	local Width0 = SIZE + BLOOM * Distance0
	local Width1 = SIZE + BLOOM * Distance1
	local Length = ((self.PosNow - self.PosLast) * Vector3.new(1, 1, 0)).Magnitude
	local Transparency = 1 - 4 * SIZE * SIZE / ((Width0 + Width1) * (2 * Length + Width0 + Width1)) * BRIGHTNESS
	self.Beam.Width0 = Width0
	self.Beam.Width1 = Width1
	self.Beam.Transparency = NumberSequence.new(Transparency)
end

function vtracers:Destroy()
	self.Attachment0:Destroy()
	self.Attachment1:Destroy()
	self.Beam:Destroy()
	self.MARKED_FOR_DELETION = true
end

RunService:BindToRenderStep("__TRACERS__", Enum.RenderPriority.Camera.Value, function(deltaTime)
	for i, tracer in ActiveTracers do
		if tracer.MARKED_FOR_DELETION then
			table.remove(ActiveTracers, i)
			continue
		end
		tracer.Position = tracer.Position or tracer.Start
		local nextPosition = tracer.Position + ((tracer.End - tracer.Start).Unit * deltaTime) * 512
		tracer.Position = nextPosition
		tracer:Update(nextPosition, deltaTime)
	end
end)

return vtracers
