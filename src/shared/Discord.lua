local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage.Shared

local Webhook = require(Shared.Webhook)
local PromiseType = require(Shared.PromiseType)
local WebhookIDs = ServerStorage.__WEBHOOKS__

local WEBHOOK_PROXY = "https://webhook.lewisakura.moe/"
local WEBHOOK_FOOTER_TEXT = "Webhook API v0.1"

local IsDevServer = RunService:IsStudio()
local Color = if IsDevServer then 15105570 else 5763719
local Color3IfiedColor = Color3.fromHex(string.format("%x", Color))
local ColorH, ColorS, ColorV = Color3IfiedColor:ToHSV()
local ColorAdjusted = Color3.fromHSV(math.clamp(ColorH + ((math.random()-0.5) * 0.2), 0, 1), ColorS, ColorV)
Color = tonumber(ColorAdjusted:ToHex(), 16)
print(Color)

local WebhookURL = WEBHOOK_PROXY .. if IsDevServer then WebhookIDs.Dev.Value else WebhookIDs.Prod.Value

print(WebhookURL)

export type Type = {
	identifiers: {[string]: Type},
	lastMessageTimestamp: number;

	new: (identifier: string, ratelimit: number?) -> Type,
	Post: (data: {[string]: any}) -> (PromiseType.Promise<string>)
}

local Discord = {
	identifiers = {}
} :: Type
Discord.__index = Discord

local WebhookPipe = Webhook.new(WebhookURL)

function Discord.new(identifier: string, ratelimit: number?)
	-- this function lets you create an identifier for your webhook ids
	-- if the identifier exists, it returns the already existing identifier
	identifier = identifier:upper()
	if table.find(Discord.identifiers, identifier) then
		return Discord.identifiers[identifier]
	end

	local self = setmetatable({
		identifier = identifier,
		queue = {},
		ratelimit = ratelimit or 2,
	}, Discord)

	Discord.identifiers[identifier] = self

	return self
end

function Discord:Post(data: {[string]: any})
	local footer = {text = `{WEBHOOK_FOOTER_TEXT} [{self.identifier}]`}
	for _, embed in data["embeds"] do
		embed["footer"] = footer
		embed["color"] = embed["color"] or Color
	end

	local timestamp = os.time()
	local timeSinceLastMessage = timestamp - (self.lastMessageTimestamp or 0)

	if timeSinceLastMessage < self.ratelimit then
		warn("Rate limit was reached! Your request was put on a queue.")
		table.insert(data.embeds, {title = "Rate Limit Warning", description = `Messages in queue: {#self.queue}`, color = 15548997, footer = footer})
		table.insert(self.queue, HttpService:JSONEncode(data))
	else
		self.lastMessageTimestamp = timestamp
		WebhookPipe:PUSH(HttpService:JSONEncode(data))
	end

	if not self.__taskSpawned then
		self.__taskSpawned = true
		task.spawn(function()
			while #self.queue > 0 do
				local queuedMessage = table.remove(self.queue, 1)
				WebhookPipe:PUSH(queuedMessage)
			end
			self.__taskSpawned = false
		end)
	end
end

return Discord
