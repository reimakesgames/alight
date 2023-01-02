local HEADER_FORMAT = "<font size=\"32\"><b>%s</b></font>\n"
local SUBHEADER_FORMAT = "<font size=\"24\"><b>%s</b></font>\n"
local TEXT_FORMAT = "    • %s\n"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local BridgeNet = require(Packages.BridgeNet)

local HydrateChangelogs = BridgeNet.CreateBridge("HydrateChangelogs")
local RequestChangelogs = BridgeNet.CreateBridge("RequestChangelogs")

local ChangelogsUI = PlayerGui:WaitForChild("Changelogs")

local ChangelogsText: string

local changelogs = {}

function changelogs.init()
	RequestChangelogs:Fire()
	HydrateChangelogs:Connect(function(theString)
		ChangelogsText = theString
		local ChangelogsTextTable = string.split(ChangelogsText, "\n")

		ChangelogsUI.Frame.ScrollingFrame:ClearAllChildren()
		local ListContainer = ChangelogsUI.Frame.Frame:Clone()
		local List = ListContainer.list
		ListContainer.Visible = true
		ListContainer.Parent = ChangelogsUI.Frame.ScrollingFrame

		for _, text in ChangelogsTextTable do
			local isHeader1 = string.match(text, "^# ")
			local isHeader3 = string.match(text, "^### ")
			local isText = string.match(text, "^- ")
			local isSpace = string.len(text) == 0
			if isHeader1 then
				List.Text = List.Text .. HEADER_FORMAT:format(string.sub(text, 3))
				continue
			end
			if isHeader3 then
				List.Text = List.Text .. SUBHEADER_FORMAT:format(string.sub(text, 5))
				continue
			end
			if isSpace then
				List.Text = List.Text .. "\n"
				continue
			end
			if isText then
				List.Text = List.Text .. TEXT_FORMAT:format(string.sub(text, 3))
				continue
			end
		end
	end)
end

return changelogs
