local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Promise = require(Packages.Promise)
local PromiseType = require(Shared.PromiseType)

export type Type = {
	webhookLink: string,

	new: (webhook: string) -> (Type),
	PUSH: (data: any) -> PromiseType.Promise<string>
}

local function CheckIfWebhooksAreMuted()
	if not ServerStorage:FindFirstChild("MuteWebhooks") then
		return false
	end
	if not ServerStorage.MuteWebhooks:IsA("BoolValue") then
		return false
	end
	if not ServerStorage.MuteWebhooks.Value then
		return false
	end

	return true
end

local Webhook = {} :: Type
Webhook.__index = Webhook

function Webhook.new(webhook: string)
	local self = setmetatable({
		webhookLink = webhook
	}, Webhook)

	return self
end

function Webhook:PUSH(data: any)
	if RunService:IsStudio() then
		if CheckIfWebhooksAreMuted() then
			return
		end
	end

	return Promise.new(function(resolve, _, _)
		local success, result = pcall(function()
			HttpService:PostAsync(self.webhookLink, data)
		end)
		print(success)
		print(result)
		if success then
			resolve(result)
		end
	end)
end

return Webhook
