local RATELIMIT_DURATION = 8
local RATELIMIT_FORMAT = "Player %s is ratelimited for %s seconds"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages

local BridgeNet = require(Packages.BridgeNet)
local githubRaw = require(Shared.githubRaw)

local HydrateChangelogs = BridgeNet.CreateBridge("HydrateChangelogs")
local RequestChangelogs = BridgeNet.CreateBridge("RequestChangelogs")

local File = "reimakesgames/hybrid-conflict/main/CHANGELOG.md"

local RateLimits = {}

local changelogs = {}

function changelogs:init()
	RequestChangelogs:Connect(function(player)
		if not RateLimits[player] then
			RateLimits[player] = -60
		end

		if RateLimits[player] > workspace.DistributedGameTime then
			error(RATELIMIT_FORMAT:format(player.Name, math.ceil(RateLimits[player] - workspace.DistributedGameTime)))
			return
		end

		RateLimits[player] = workspace.DistributedGameTime + RATELIMIT_DURATION
		githubRaw:GetFile(File):andThen(function(contents)
			HydrateChangelogs:FireTo(player, contents)
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		RateLimits[player] = nil
	end)
end

return changelogs
