local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local PromiseType = require(script.Parent.PromiseType)
type Promise<T> = PromiseType.Promise<T>

local GITHUB_RAW_URL = "https://raw.githubusercontent.com/"

export type githubRaw = {
	RefreshList: {[number]: string},
	GetFile: (link: string) -> Promise<string>,
	GetFileWithRetries: (link: string, maxRetries: number?) -> Promise<string>,
}
local githubRaw = {
	RefreshList = {},
}

function githubRaw:GetFile(link: string)
	return Promise.try(function()
		return HttpService:GetAsync(GITHUB_RAW_URL .. link)
	end)
end

function githubRaw:GetFileWithRetries(link: string, maxRetries: number?)
	return Promise.retry(githubRaw.GetFile, maxRetries or 5, githubRaw, link)
end

task.spawn(function()
	while task.wait(120) do
		for _, link in githubRaw.RefreshList do
			githubRaw:GetFileWithRetries(link):catch(function(err)
				warn("Failed to fetch " .. link, err)
			end)
		end
	end
end)

return githubRaw
