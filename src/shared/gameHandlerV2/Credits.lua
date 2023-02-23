local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local isRealNumber = require(Shared.isRealNumber)

export type Credits = {
	_player: Player,
	credits: number,

	Change: (amount: number) -> (),
	HasEnough: (amount: number) -> boolean,
}

local Credits = {}
Credits.__index = Credits

local function playerExists(player: Player): boolean
	return Players:FindFirstChild(player.Name) ~= nil
end

function Credits.new(player: Player)
	assert(typeof(player) == "Instance" and player:IsA("Player"), "Player must be a player")
	assert(playerExists(player), "Player does not exist or isn't in the server")

	local self = setmetatable({
		_player = player,

		credits = 0,
	}, Credits)

	return self
end

--[[
	Changes the player's credits by the given amount.

	@param amount The amount to change the player's credits by.
]]
function Credits:Change(amount: number)
	assert(isRealNumber(amount), "Amount must be a real number")

	self.credits += amount
end

function Credits:HasEnough(amount: number)
	assert(isRealNumber(amount), "Amount must be a real number")

	return self.credits >= amount
end

return Credits
