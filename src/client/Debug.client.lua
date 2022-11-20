local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Build = ReplicatedFirst:WaitForChild("build")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Link = require(Packages:WaitForChild("link"))

local GetPing = Link:WaitFunction("GetPing")

local Root = PlayerGui:WaitForChild("debug")
local DATA = require(Build:WaitForChild("data"))

local Ping: number = 0
local Fps: number = 0
local Testing = DATA.testing == "yes" and "dev-build-" or ""

local TimeFunction = RunService:IsRunning() and time or os.clock
local LastIteration, Start
local FrameUpdateTable: {[number]: number} = {}

Start = TimeFunction()

Root.disclaimer.Text = DATA.stage .. " gameplay"
RunService.RenderStepped:Connect(function(_deltaTime)
	LastIteration = TimeFunction()
	for Index = #FrameUpdateTable, 1, -1 do
		FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index] or nil
	end
	FrameUpdateTable[1] = LastIteration
	Fps = math.floor(TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start))

	local Display =
		"Version: " .. Testing .. DATA.version .. "-" .. DATA.stage .. "\n" ..
		"FPS: " .. tostring(Fps) .. "\n" ..
		"PING: " .. Ping .. "\n"
	Root.display.Text = Display
	Root.displayShadow.Text = Display
end)

while true do
	task.spawn(function()
		local start = tick()
		GetPing:InvokeServer()
		local finish = tick() - start
		Ping = math.floor(finish * 500)
	end)
	task.wait(0.25)
end
