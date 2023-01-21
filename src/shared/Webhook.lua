local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

local Webhook = {} :: Type
Webhook.__index = Webhook

function Webhook.new(webhook: string)
	local self = setmetatable({
		webhookLink = webhook
	}, Webhook)

	return self
end

function Webhook:PUSH(data: any)
	return Promise.new(function(resolve, reject, onCancel)
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
