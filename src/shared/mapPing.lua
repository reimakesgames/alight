local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local BridgeNet = require(Packages.BridgeNet)
local fastInstance = require(Shared.fastInstance)

local LOCAL_ENVIRONMENT = RunService:IsClient()
local PING_FOLDER = if LOCAL_ENVIRONMENT then fastInstance("Folder", {Name = "__PINGS__",Parent = workspace,}) else nil

local ReplicatePing = BridgeNet.CreateBridge("ReplicatePing")

local mapPing = {}

local activePings = {}

local function CreatePing(player: Player, worldPosition: Vector3)
	-- before anything else, check if there is a nearby ping
	local nearbyPing = nil
	for _, ping in pairs(activePings) do
		if (ping.Position - worldPosition).Magnitude < 1 then
			nearbyPing = ping
			break
		end
	end

	local pingPart = fastInstance("Part", {
		Name = "Ping",
		Anchored = true,
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
		Archivable = false,
		Size = Vector3.new(1, 1, 1),
		Position = worldPosition,
		Parent = PING_FOLDER,
	})
	Debris:AddItem(pingPart, 10)
	local distance = (Camera.CFrame.Position - pingPart.Position).Magnitude / 4

	local pingBillboardGui = fastInstance("BillboardGui", {
		Name = "PingBillboardGui",
		Adornee = pingPart,
		Archivable = false,
		Active = true,
		Enabled = true,
		AlwaysOnTop = true,
		ClipsDescendants = false,
		LightInfluence = 0,
		MaxDistance = math.huge,
		ResetOnSpawn = false,
		Size = UDim2.new(0, 32, 0, 32),
		StudsOffset = Vector3.new(0, 0, 0),
		Parent = pingPart,
	})

	fastInstance("Frame", {
		Name = "PingFrame",
		Archivable = false,
		BackgroundColor3 = Color3.fromRGB(170, 255, 255),
		BorderSizePixel = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Rotation = 45,
		Size = UDim2.new(0, 8, 0, 8),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Parent = pingBillboardGui,
	})

	fastInstance("TextLabel", {
		Name = "PingTextLabel",
		Archivable = false,
		BackgroundTransparency = 1,
		Font = Enum.Font.SourceSans,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 16),
		Size = UDim2.new(1, 0, 1, 0),
		Text = `{math.floor(distance) * 2} m`,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = pingBillboardGui,
	})

	table.insert(activePings, pingPart)
	if nearbyPing then
		Debris:AddItem(nearbyPing, 0)
	end
end

local function PingClientReciever(player: Player, worldPosition: Vector3)
	-- ! DO NOT CHECK FOR TEAMS HERE, VERY BYPASSABLE
	CreatePing(player, worldPosition)
end

function mapPing.new(worldPosition: Vector3)
	CreatePing(LocalPlayer, worldPosition)
	ReplicatePing:Fire(worldPosition)
end

if LOCAL_ENVIRONMENT then
	ReplicatePing:Connect(PingClientReciever)
	task.spawn(function()
		while true do
			task.wait(0.25)
			for index, pingPart in ipairs(activePings) do
				if not pingPart.Parent then
					table.remove(activePings, index)
					continue
				end
				local distance = (Camera.CFrame.Position - pingPart.Position).Magnitude / 4
				local pingTextLabel = pingPart.PingBillboardGui.PingTextLabel
				pingTextLabel.Text = `{math.floor(distance) * 2} m`
			end
		end
	end)
else
	ReplicatePing:Connect(function(player: Player, worldPosition: Vector3)
		ReplicatePing:FireToAllExcept({player}, player, worldPosition)
	end)
end

return mapPing
