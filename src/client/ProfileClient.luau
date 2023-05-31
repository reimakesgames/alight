local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local fusion = require(Packages.fusion)
local bridgenet = require(Packages.bridgenet)

local New = fusion.New
local Children = fusion.Children
local Value = fusion.Value

local GetProfile = bridgenet.CreateBridge("GetProfile")

local Profile = {}

function Profile:GenerateProfile()
	self.profile = Value("rbxassetid://0")

	self.profile:set(GetProfile:InvokeServerAsync().photo)

	return New "ScreenGui" {
		Name = "Profile",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,

		[Children] = {
			New "Frame" {
				Name = "ProfilePhoto",
				BackgroundColor3 = Color3.fromRGB(127, 127, 127),
				Size = UDim2.new(0, 128, 0, 128),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),

				[Children] = {
					New "ImageLabel" {
						Name = "Photo",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						Image = self.profile:get(),

						ScaleType = Enum.ScaleType.Crop,
					},
				},
			},
		}
	}
end

return Profile
