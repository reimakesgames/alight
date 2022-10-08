local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Link = require(Packages.link)

local GithubPuller = require(script.Parent.GithubHandler)


local File = "https://raw.githubusercontent.com/reimakesgames/hybrid-conflict/main/CHANGELOG.md"


local HydrateChangelogs = Link.CreateEvent("HydrateChangelogs")
local RequestChangelogs = Link.CreateEvent("RequestChangelogs")

local RateLimits = {}

RequestChangelogs.Event:Connect(function(player)
	if not RateLimits[player] then
		RateLimits[player] = -60
	end

	if RateLimits[player] > workspace.DistributedGameTime then
		print(RateLimits[player], workspace.DistributedGameTime)
		print(RateLimits[player] > workspace.DistributedGameTime)
		error("Player " .. player.Name .. " is ratelimited for " .. RateLimits[player] - workspace.DistributedGameTime .. " seconds")
		return
	end

	RateLimits[player] = workspace.DistributedGameTime + 8
	HydrateChangelogs:FireClient(player, GithubPuller:GetFileAsync(File))
end)

Players.PlayerRemoving:Connect(function(player)
	RateLimits[player] = nil
end)
