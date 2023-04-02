local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Shared = ReplicatedStorage.Shared
local fastInstance = require(Shared.fastInstance)

local function createMiniPopup(text: string, description: string?, icon: string?)
	local main = fastInstance("Frame", {
		Position = UDim2.new(1, -16, 1, -16),
		AnchorPoint = Vector2.new(1, 1),
		Size = UDim2.new(0, 320, 0, 40),

		BackgroundColor3 = Color3.fromRGB(32, 32, 32),
	})

	local textLabel = fastInstance("TextLabel", {
		Position = UDim2.new(0, 40, 0, 10),
		Size = UDim2.new(1, -40, 0, 20),

		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 20,
		FontFace = Font.fromName("Ubuntu"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,

		Parent = main,
	})

	local closeButton = fastInstance("TextButton", {
		-- center the button vertically and place it to the right side
		Position = UDim2.new(1, -30, 0, 10),
		Size = UDim2.new(0, 20, 0, 20),

		BackgroundTransparency = 1,
		Text = "X",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 20,
		FontFace = Font.fromName("Ubuntu"),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,

		Parent = main,
	})

	local expandButton = fastInstance("TextButton", {
		Position = UDim2.new(1, -50, 0, 10),
		Size = UDim2.new(0, 20, 0, 20),

		BackgroundTransparency = 1,
		Text = "V",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 20,
		FontFace = Font.fromName("Ubuntu"),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,

		Parent = main,
	})

	local descriptionLabel = fastInstance("TextLabel", {
		Position = UDim2.new(0, 10, 0, 40),
		Size = UDim2.new(1, -10, 0, 20),

		BackgroundTransparency = 1,
		Text = description,
		TextTransparency = 1,
		TextColor3 = Color3.fromRGB(191, 191, 191),
		TextSize = 20,
		FontFace = Font.fromName("Ubuntu"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,

		Parent = main,
	})

	local addIcon, color
	if icon == "info" then
		addIcon = "i"
		color = Color3.fromRGB(0, 255, 255)
	elseif icon == "warning" then
		addIcon = "!"
		color = Color3.fromRGB(255, 255, 0)
	elseif icon == "error" then
		addIcon = "X"
		color = Color3.fromRGB(255, 0, 0)
	end

	local icon = fastInstance("TextLabel", {
		Position = UDim2.new(0, 10, 0, 10),
		Size = UDim2.new(0, 20, 0, 20),

		BackgroundTransparency = 1,
		Text = addIcon,
		TextColor3 = color,
		TextSize = 20,
		FontFace = Font.fromName("Ubuntu"),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,

		Parent = main,
	})

	local scriptIdentity = fastInstance("TextLabel", {
		-- place it at the bottom right corner
		Position = UDim2.new(1, -4, 1, -4),
		AnchorPoint = Vector2.new(1, 1),
		Size = UDim2.new(0, 0, 0, 0),

		BackgroundTransparency = 1,
		Text = script.Name,
		TextColor3 = Color3.fromRGB(191, 191, 191),
		TextTransparency = 1,
		TextSize = 12,
		FontFace = Font.fromName("Ubuntu"),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Bottom,

		Parent = main,
	})

	expandButton.MouseButton1Click:Connect(function()
		if descriptionLabel.TextTransparency == 1 then
			descriptionLabel.TextTransparency = 0
			scriptIdentity.TextTransparency = 0
			expandButton.Text = "^"
			-- main:TweenSize(UDim2.new(0, 320, 0, 120), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			main.Size = UDim2.new(0, 320, 0, 120)
		else
			descriptionLabel.TextTransparency = 1
			scriptIdentity.TextTransparency = 1
			expandButton.Text = "V"
			-- main:TweenSize(UDim2.new(0, 320, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			main.Size = UDim2.new(0, 320, 0, 40)
		end
	end)

	closeButton.MouseButton1Click:Connect(function()
		-- main:TweenPosition(UDim2.new(1, 320, 1, -16), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true, function()
		-- 	main:Destroy()
		-- end)
		main:Destroy()
	end)

	return main
end

local popup = createMiniPopup("hewo", "uwu owo ;3", "info")
local popup2 = createMiniPopup("hewo", "uwu owo ;3", "warning")
local popup3 = createMiniPopup("hewo", "uwu owo ;3", "error")
popup.Parent = PlayerGui:WaitForChild("mcore")
popup2.Parent = PlayerGui:WaitForChild("mcore")
popup3.Parent = PlayerGui:WaitForChild("mcore")
