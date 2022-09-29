local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Link = require(Packages.link)

local GithubPuller = require(script.Parent.GithubPuller)


local File = "https://raw.githubusercontent.com/reimakesgames/hybrid-conflict/main/CHANGELOGS.md"


local HydrateChangelogs = Link.CreateEvent("HydrateChangelogs")
local RequestChangelogs = Link.CreateEvent("RequestChangelogs")

RequestChangelogs.Event:Connect(function(player)
	HydrateChangelogs:FireClient(player, GithubPuller:GetFileAsync(File))
end)
