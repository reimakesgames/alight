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
	ChangelogsUI.Frame.ScrollingFrame:ClearAllChildren()
	local list = ChangelogsUI.Frame.Frame:Clone()
	list.list.Text = ""
	list.Parent = ChangelogsUI.Frame.ScrollingFrame
	list.Visible = true
	-- ChangelogsUI.Frame.button.UIListLayout:Clone().Parent = ChangelogsUI.Frame.ScrollingFrame
	stuff = theString
	local stuffConvertedToTable = string.split(stuff, "\n")
	print(stuffConvertedToTable)
	for _, Text in stuffConvertedToTable do
		local isHeader1 = string.match(Text, "^# ")
		local isHeader3 = string.match(Text, "^### ")
		local isText = string.match(Text, "^- ")
		local isSpace = string.len(Text) == 0

		if isHeader1 then
			list.list.Text = list.list.Text .. '<font size="32"><b>' .. string.gsub(Text, "^# ", "") .. "</b></font>" .. "\n"
			continue
		elseif isHeader3 then
			list.list.Text = list.list.Text .. '<font size="24"><b>' .. string.gsub(Text, "^## ", "") .. "</b></font>" .. "\n"
			continue
		elseif isSpace then
			list.list.Text = list.list.Text .. Text .. "\n"
			continue
		elseif isText then
			list.list.Text = list.list.Text .. string.gsub(Text, "^## ", "") .. "  • " .. Text .. "\n"
			continue
		end
	end
end)
