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

local LOOKUP_TABLE = {}
LOOKUP_TABLE.AnchorPoint = {
	Top = Vector2.new(0.5, 1);
	Bottom = Vector2.new(0.5, 0);
	Left = Vector2.new(1, 0.5);
	Right = Vector2.new(0, 0.5);
	Center = Vector2.new(0.5, 0.5);
}
LOOKUP_TABLE.Position = {
	Top = UDim2.fromScale(0.5, 0);
	Bottom = UDim2.fromScale(0.5, 1);
	Left = UDim2.fromScale(0, 0.5);
	Right = UDim2.fromScale(1, 0.5);
	Center = UDim2.fromScale(0.5, 0.5);
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
	properties.CenterDotEnabled = properties.CenterDotEnabled
	properties.Crosshairs = properties.Crosshairs or { Bottom = true, Left = true, Right = true, Top = true }
	local Container = QuickInstance("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, properties.Gap * 2, 0, properties.Gap * 2),
	})

	local function CreateCrosshairArm(name: string)
		local IS_VERTICAL = name == "Top" or name == "Bottom"
		local IS_CENTER = name == "Center"
		local X = IS_VERTICAL and properties.Width or IS_CENTER and properties.Width or properties.Height
		local Y = IS_VERTICAL and properties.Height or IS_CENTER and properties.Width or properties.Width
		QuickInstance("Frame", {
			AnchorPoint = LOOKUP_TABLE.AnchorPoint[name],
			Position = LOOKUP_TABLE.Position[name],
			Size = UDim2.fromOffset(X, Y),

			BackgroundColor3 = properties.Color,
			BackgroundTransparency = properties.Opacity,

			BorderSizePixel = 0,

			Name = name,
			Parent = Container,
		})
	end

	if properties.Crosshairs.Top then
		CreateCrosshairArm("Top")
	end
	if properties.Crosshairs.Bottom then
		CreateCrosshairArm("Bottom")
	end
	if properties.Crosshairs.Left then
		CreateCrosshairArm("Left")
	end
	if properties.Crosshairs.Right then
		CreateCrosshairArm("Right")
	end

	if properties.CenterDotEnabled then
		QuickInstance("Frame", {
			Name = "Center",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Parent = Container,
			BackgroundColor3 = properties.Color,
			BackgroundTransparency = properties.Opacity,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, properties.Width, 0, properties.Width),
		})
	end
	for _, arm in Container:GetChildren() do
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
	return Container
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
	local ThingTwo = CreateCrosshair({
		Color = Color3.new(0, 1, 0);
		Opacity = 0;
		Height = 2;
		Width = 2;
		Gap = 12;
		CenterDotEnabled = false;
		Crosshairs = {
			Bottom = true;
			Left = true;
			Right = true;
			Top = true;
		}
	})
	ThingTwo.Parent = Structure
	return Structure
end

return Crosshair
