local fastInstance = require(script.Parent.fastInstance)
local isRealNumber = require(script.Parent.isRealNumber)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

export type Type = {
	new: (width: number) -> (),


}

--[[
	NEWS, 1234
]]
local ARM_ANCHOR_POINTS = {
	Vector2.new(0, 1),
	Vector2.new(0, 0),
	Vector2.new(1, 0),
	Vector2.new(0, 0)
}

--[[
	Creates modifiable arms for crosshairs
]]
local function CreateArms(width: number, sizeX: number, sizeY: number?)
	--! parameters can be condensed into a table instead idfk
	local arms = {}
	for i = 1, 4 do
		arms[i] = fastInstance("Frame", {
			AnchorPoint = ARM_ANCHOR_POINTS[i],

			--this checks whether if an arm is x or y to allow pairs
			Size = if i == 1 or i == 4 then UDim2.fromOffset(width, sizeY or sizeX) else UDim2.fromOffset(sizeX, width),

			--[[
				why magic number?

				well if the index is 2, which is the right side, it will offset it to the right with width
				if the index is 4, which is the bottom arm ,ti will shift it down by width
			]]
			Position = UDim2.fromOffset(if i == 2 then width else 0, if i == 4 then width else 0),

			BorderSizePixel = 0,
		})
	end
	return arms
end

local Crosshair = {} :: Type
Crosshair.__index = Crosshair

-- deprecated and is for placeholder
local __active

function Crosshair.new(width: number)
	assert(isRealNumber(width), "provided variable isn't a number")

	-- this is a tiny dumb function that shouldn't be in prod to help refresh the crosshair by calling crosshair.new() multiple times
	if __active then
		__active:Destroy()
	end

	local ScreenGui = fastInstance("ScreenGui", {
		IgnoreGuiInset = true,

		Parent = LocalPlayer.PlayerGui,
	})
	local Frame = fastInstance("Frame", {
		Size = UDim2.fromOffset(width, width),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),

		BackgroundTransparency = 1,

		Parent = ScreenGui,
	})
	local Arms = CreateArms(width, 4)
	for _, arm in Arms do
		arm.Parent = Frame

		--! can apply some properties here already, or in line 26 to just condense the parameters into a table
		--! idk i suck at doing stuff like this
	end

	__active = ScreenGui
end

function Crosshair:Adjust()

end

return Crosshair :: {
	new: (width: number) -> ()
}
