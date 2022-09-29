local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Link = require(Packages:WaitForChild("link"))

local HydrateChangelogs = Link.WaitEvent("HydrateChangelogs")
local RequestChangelogs = Link.WaitEvent("RequestChangelogs")

local ChangelogsUI = PlayerGui:WaitForChild("Changelogs")

local stuff: string

RequestChangelogs:FireServer()
HydrateChangelogs.Event:Connect(function(theString)
	stuff = theString
	local stuffConvertedToTable = string.split(stuff, "\n")
	print(stuffConvertedToTable)
	for Index, Text in stuffConvertedToTable do
		local isHeader1 = string.match(Text, "^# ")
		local isHeader2 = string.match(Text, "^## ")
		local isSpace = string.len(Text) == 0

		if isHeader1 then
			local H1 = ChangelogsUI.Frame.Header1:Clone()
			H1.Text = string.gsub(Text, "^# ", "")
			H1.LayoutOrder = Index
			H1.Parent = ChangelogsUI.Frame.ScrollingFrame
			H1.Visible = true
			continue
		elseif isHeader2 then
			local H2 = ChangelogsUI.Frame.Header2:Clone()
			H2.Text = string.gsub(Text, "^## ", "")
			H2.LayoutOrder = Index
			H2.Parent = ChangelogsUI.Frame.ScrollingFrame
			H2.Visible = true
			continue
		elseif isSpace then
			local S = ChangelogsUI.Frame.Space:Clone()
			S.LayoutOrder = Index
			S.Parent = ChangelogsUI.Frame.ScrollingFrame
			S.Visible = true
			continue
		else
			local T = ChangelogsUI.Frame.Normal:Clone()
			T.Text = Text
			T.LayoutOrder = Index
			T.Parent = ChangelogsUI.Frame.ScrollingFrame
			T.Visible = true
			continue
		end
	end
end)
