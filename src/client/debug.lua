local DEBUG_FORMAT =
"Version: %s%s-%s\n"..
"FPS: %s (%sms)\n"..
"PING: %sms\n"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local BridgeNet = require(Packages.BridgeNet)
local constants = require(Shared.constants)

local GetPing = BridgeNet.CreateBridge("GetPing")

local DebugGui = PlayerGui:WaitForChild("debug")

local Ping: number = 0
local FramesPerSecond: number = 0
local isTesting = constants.RELEASE and "" or "dev-build-"

local TimeFunction = RunService:IsRunning() and time or os.clock
local LastIteration, Start
local FrameUpdateTable: {[number]: number} = {}

local debug = {}

function debug.init()
	Start = TimeFunction()

	DebugGui.disclaimer.Text = constants.GAME_DEVELOPMENT_STAGE .. " gameplay"
	RunService.RenderStepped:Connect(function(deltaTime)
		LastIteration = TimeFunction()
		for Index = #FrameUpdateTable, 1, -1 do
			FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index] or nil
		end
		FrameUpdateTable[1] = LastIteration
		FramesPerSecond = math.floor(TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start))
		local Format = DEBUG_FORMAT:format(isTesting, constants.GAME_VERSION, constants.GAME_DEVELOPMENT_STAGE, tostring(FramesPerSecond), tostring(math.floor(deltaTime * 1000)), Ping)
		DebugGui.display.Text = Format
		DebugGui.displayShadow.Text = Format
	end)

	while true do
		task.spawn(function()
			local start = tick()
			GetPing:InvokeServerAsync()
			local finish = tick() - start
			Ping = math.floor(finish * 500)
		end)
		task.wait(0.25)
	end
end

return debug
