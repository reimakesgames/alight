local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local TimeRemaining = 0.0

local PHASES = {
	"PreRound",
	"Combat",
	"SpikePlanted",
	"PostRound",
}

export type Type = {
	-- Properties
	CurrentPhase: string,

	-- Functions
	new: () -> Type,
	Start: (self: Type, duration: number) -> (), -- alias for StartPreRound
	StartPreRound: (self: Type, duration: number) -> (),
	StartCombat: (self: Type, duration: number) -> (),
	SpikePlanted: (self: Type, duration: number) -> (),
	StartPostRound: (self: Type, duration: number) -> (),
	EndRound: (self: Type) -> (),
}

local CurrentRound: Type

local Round = {}
Round.__index = Round

function Round.new()
	local self = setmetatable({
		CurrentPhase = "PreRound",
	}, Round)

	return self
end

--[[
	Phases are flows

	PreRound -> Combat >> PostRound
	30s/40s  -> 1m40s  >> 5s

	PreRound -> Combat >> SpikePlanted >> PostRound
	30s/40s  -> 1m40s  >> 40s          >> 5s

	PreRound goes to Combat when the round starts, it will only go to combat when the preround timer ends.
	Combat goes to PostRound when the round ends, if a team gets eliminated, it will go to PostRound immediately.
	Or if the combat timer ends, it will go to PostRound regardless.
	If someone plants the spike, it will go to SpikePlanted, which will go to PostRound when the spike explodes or it gets defused.
	PostRound goes to PreRound when the timer ends, it will only go to PreRound when the postround timer ends.
]]

local function formatTime(time: number): string
	-- if the time is from 11-whatever, then we'll show it as m:ss
	-- if the time is 10 seconds or less, then we'll show it as ss.ms

	if time <= 10 then
		return string.format("%.2f", time)
	else
		local minutes = math.floor(time / 60)
		local seconds = math.floor(time % 60)
		return string.format("%d:%02d", minutes, seconds)
	end
end

function Round:StartPreRound(duration)
	CurrentRound = self
	TimeRemaining = duration
	CurrentRound.CurrentPhase = PHASES[1]
end
-- alias
function Round:Start(duration)
	Round:StartPreRound(duration)
end

function Round:StartCombat(duration)
	TimeRemaining = TimeRemaining + duration
	CurrentRound.CurrentPhase = PHASES[2]

	-- TODO: Drop barriers
end

function Round:SpikePlanted(duration)
	TimeRemaining = duration
	CurrentRound.CurrentPhase = PHASES[3]

	-- TODO: when it explodes, call Round:PostWinRound
end

function Round:StartPostRound(duration)
	TimeRemaining = duration
	CurrentRound.CurrentPhase = PHASES[4]
end

function Round:EndRound()
	-- TODO: Calculate rewards
	for _, player in pairs(Players:GetPlayers()) do
		player:LoadCharacter()
	end
	self:StartPreRound(5)
end

RunService.Stepped:Connect(function(timeElapsed: number, deltaTime: number)
	if CurrentRound == nil then
		return
	end

	TimeRemaining = TimeRemaining - deltaTime
	if TimeRemaining <= 0 then
		TimeRemaining = 0
		-- TODO: Go to next phase
		if CurrentRound.CurrentPhase == "PreRound" then
			CurrentRound:StartCombat(15)
		elseif CurrentRound.CurrentPhase == "Combat" then
			CurrentRound:StartPostRound(5)
		elseif CurrentRound.CurrentPhase == "SpikePlanted" then
			CurrentRound:StartPostRound(5)
		elseif CurrentRound.CurrentPhase == "PostRound" then
			CurrentRound:EndRound()
		end
	end
	print(CurrentRound.CurrentPhase, TimeRemaining)
	LocalPlayer.PlayerGui.HUD.TimeRemaining.Text = formatTime(TimeRemaining)
	if CurrentRound.CurrentPhase == "Combat" and TimeRemaining <= 10 then
		LocalPlayer.PlayerGui.HUD.TimeRemaining.TextColor3 = Color3.fromRGB(255, 0, 0)
	else
		LocalPlayer.PlayerGui.HUD.TimeRemaining.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end)

return Round
