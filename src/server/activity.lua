local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Shared = ReplicatedStorage.Shared
local dateFormat = require(Shared.dateFormat)

local PlayerJoins: {[Player]: number} = {}
local PlayerPlayDuration: {[string]: number} = {}

local Joins = 0
local UniquePlayers = 0

local SERVER_START_TIME = tick()

local Discord = require(Shared.Discord)
local PlayerActivityWebhook = Discord.new("Player Activity")
local ServerActivityWebhook = Discord.new("Server Activity")

local function PlayerListCreate(player: Player)
	return `{player.Name}|{player.DisplayName}|{player.UserId}`
end

local function ListPlayersPlayDuration()
	local str = ""
	for player, duration in PlayerPlayDuration do
		local playerData = player:split("|")
		local username = playerData[1]
		local displayname = playerData[2]
		local userid = playerData[3]

		str = str .. `[{username} ({displayname})](https://www.roblox.com/users/{userid}/profile)\nPlayed for: \`{dateFormat:secondsToCleanHMS(duration)}\`\n\n`
	end

	return str
end

local Activity = {}

function Activity.init()
	ServerActivityWebhook:Post({
		embeds = {
			{
				title = "Server Initialized",
				url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
				description = `JobId: \`{if game.JobId:len() == 0 then "None" else game.JobId}\`\nPlaceId: \`{game.PlaceId or "None"}\`\nPlace Version: \`{game.PlaceVersion or "None"}\``,
			}
		}
	})
	game:BindToClose(function()
		task.wait(2)
		ServerActivityWebhook:Post({
			embeds = {
				{
					title = "Server Closed",
					url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
					description =
					`JobId: \`{if game.JobId:len() == 0 then "None" else game.JobId}\`\nPlaceId: \`{game.PlaceId or "None"}\`\nPlace Version: \`{game.PlaceVersion or "None"}\`\n\n` ..
					`Server Lifetime: \`{dateFormat:secondsToCleanHMS(tick() - SERVER_START_TIME)}\`\nJoins: \`{Joins}\`\nUnique Joins: \`{UniquePlayers}\`\n\n` ..
					`**Players That joined:**\n` .. ListPlayersPlayDuration(),
				}
			}
		})
	end)

	Players.PlayerAdded:Connect(function(player: Player)
		Joins = Joins + 1
		PlayerJoins[player] = tick()
		PlayerActivityWebhook:Post({
			embeds = {{
				title = `{player.Name} ({player.DisplayName}) has joined a server.`,
				link = `https://www.roblox.com/users/{player.UserId}/profile`,
				description =
				`JobId: \`{if game.JobId:len() == 0 then "None" else game.JobId}\`\nPlaceId: \`{game.PlaceId}\`\nPlace Version: \`{game.PlaceVersion}\`\n\n` ..
				`UserId: \`{player.UserId}\`\nFollowUserId\`{player.FollowUserId}\`\nPremiumUser: \`{if player.MembershipType.Value == 5 then "true" else "false"}\`\n\n` ..
				`AccountAge: \`{dateFormat:accountAgeToDMY(player.AccountAge)}\`\nVerified: \`{if player.HasVerifiedBadge then "true" else "false"}\`\nLocale: \`{player.LocaleId}\``
			}}
		})
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		local PlayerDuration = tick() - PlayerJoins[player]
		local AccessKey = PlayerListCreate(player)
		if not PlayerPlayDuration[AccessKey] then
			UniquePlayers = UniquePlayers + 1
		end
		PlayerPlayDuration[AccessKey] = if PlayerPlayDuration[AccessKey] then PlayerPlayDuration[AccessKey] + PlayerDuration else PlayerDuration
		local Previous = `Play Duration: \`{dateFormat:secondsToCleanHMS(PlayerDuration)}\` \`({dateFormat:secondsToCleanHMS(PlayerPlayDuration[AccessKey])})\`\n`

		PlayerActivityWebhook:Post({
			embeds = {{
				title = `{player.Name} ({player.DisplayName}) has left a server.`,
				link = `https://www.roblox.com/users/{player.UserId}/profile`,
				description =
				`JobId: \`{if game.JobId:len() == 0 then "None" else game.JobId}\`\nPlaceId: \`{game.PlaceId}\`\nPlace Version: \`{game.PlaceVersion}\`\n\n` ..
				Previous
			}}
		})
	end)
end

return Activity
