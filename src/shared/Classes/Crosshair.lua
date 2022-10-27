local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Utility = ReplicatedFirst.Utility
local QuickInstance = require(Utility.QuickInstance)

export type CrosshairArmEnabled = {
	Bottom: boolean,
	Left: boolean,
	Right: boolean,
	Top: boolean,
}

export type CrosshairProperties = {
	Color: Color3?,
	Opacity: number?,
	Height: number?,
	Width: number?,
	Gap: number?,
	CenterDotEnabled: boolean?,
	Crosshairs: CrosshairArmEnabled?,
}

local Root = QuickInstance("Frame", {
	Parent = game.StarterGui.HUD,
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(255, 0, 0),
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0.5, 0),
})

local function CreateCrosshair(properties: CrosshairProperties)
	properties.Color = properties.Color or Color3.new(1, 1, 1)
	properties.Opacity = properties.Opacity or 0
	properties.Height = properties.Height or 4
	properties.Width = properties.Width or 2
	properties.Gap = properties.Gap or 8
	properties.CenterDotEnabled = properties.CenterDotEnabled ~= nil and properties.CenterDotEnabled or true
	properties.Crosshairs = properties.Crosshairs or { Bottom = true, Left = true, Right = true, Top = true }
	local MainCrosshair = QuickInstance("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, properties.Gap * 2, 0, properties.Gap * 2),
	})
	if properties.Crosshairs.Bottom then
		QuickInstance("Frame", {
			Name = "Bottom",
			AnchorPoint = Vector2.new(0.5, 0),
			Parent = MainCrosshair,
			BackgroundColor3 = properties.Color,
			BackgroundTransparency = properties.Opacity,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 1, 0),
			Size = UDim2.new(0, properties.Width, 0, properties.Height),
		})
	end
	if properties.Crosshairs.Left then
		QuickInstance("Frame", {
			Name = "Left",
			AnchorPoint = Vector2.new(1, 0.5),
			Parent = MainCrosshair,
			BackgroundColor3 = properties.Color,
			BackgroundTransparency = properties.Opacity,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, properties.Height, 0, properties.Width),
		})
	end
	if properties.Crosshairs.Right then
		QuickInstance("Frame", {
			Name = "Right",
			AnchorPoint = Vector2.new(0, 0.5),
			Parent = MainCrosshair,
			BackgroundColor3 = properties.Color,
			BackgroundTransparency = properties.Opacity,
			BorderSizePixel = 0,
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0, properties.Height, 0, properties.Width),
		})
	end
	if properties.Crosshairs.Top then
		QuickInstance("Frame", {
			Name = "Top",
			AnchorPoint = Vector2.new(0.5, 1),
			Parent = MainCrosshair,
			BackgroundColor3 = properties.Color,
			BackgroundTransparency = properties.Opacity,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(0, properties.Width, 0, properties.Height),
		})
	end
	if properties.CenterDotEnabled then
		QuickInstance("Frame", {
			Name = "Center",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Parent = MainCrosshair,
			BackgroundColor3 = properties.Color,
			BackgroundTransparency = properties.Opacity,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, properties.Width, 0, properties.Width),
		})
	end
	for _, arm in MainCrosshair:GetChildren() do
		-- QuickInstance("UICorner", {
		-- 	CornerRadius = UDim.new(0, 2),
		-- 	Parent = arm,
		-- })
		QuickInstance("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			Color = Color3.new(),
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1,
			Transparency = 0.75 + (properties.Opacity * 0.25),
			Parent = arm,
		})
	end
	return MainCrosshair
end

local Crosshair = {}

function Crosshair.new()
	local Structure = Root:Clone()
	local Thing = CreateCrosshair({
		Color = Color3.new(0, 1, 0);
		Opacity = 0;
		Height = 4;
		Width = 2;
		Gap = 4;
		CenterDotEnabled = false;
		Crosshairs = {
			Bottom = true;
			Left = true;
			Right = true;
			Top = true;
		}
	})
	Thing.Parent = Structure
	return Structure
end

return Crosshair
