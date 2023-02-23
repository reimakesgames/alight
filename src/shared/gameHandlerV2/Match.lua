local Round = require(script.Parent.Round)

local Rewards = {
	-- Player rewards
	Kill = 200,
	Saved = 1_000, -- If the team lost the round, this gets rewarded to the survivors of the team.

	-- Team rewards
	WonRound = 3_000,
	LostRound = 1_900,
	LoseStreak = 500,
	PlantedSpike = 300,
}

export type Type = {
	-- Private properties
	Rounds: {[number]: Round.Type},
	MatchMaxRounds: number,
	CurrentRound: number,



	-- Properties
	OvertimeEnabled: boolean,
	--[[
		If Overtime is enabled, teams will play indefinitely until one team wins.
		It starts when the teams are at 12-12 or (RoundsToWin - 1) - (RoundsToWin - 1).
		If the teams manage to tie again at 13-13 then the Overtime round is 2.
		The winning team is the team to get a 2 round lead.
	]]
	OvertimeRound: number,
	--[[
		This counts up every pair of rounds, so 1, 1, 2, 2, 3, 3, etc.
		Example if the teams are at 12-12, Overtime starts and the Overtime round is 1.
		If the teams are at 13-13, Overtime starts and the Overtime round is 2.
		If the teams are at 14-14, Overtime starts and the Overtime round is 3.
	]]
	HalfRoundStart: number,
	--[[
		This is the round number that the second half starts on.
		If the constructor did not provide a value, then it is set to the MatchMaxRounds / 2.
		24 max rounds = 12 half round start
	]]
	WinPoints: number,

	-- Functions
	new: (maximumRounds: number?, overtimeEnabled: boolean?, halfRoundStart: number?, winPoints: number?) -> Type,
}

local Match = {}

function Match.new(maximumRounds, overtimeEnabled, halfRoundStart, winPoints)
	maximumRounds = maximumRounds or 24

	local self = {
		Rounds = {},
		MatchMaxRounds = maximumRounds,
		CurrentRound = 1,

		OvertimeEnabled = overtimeEnabled,
		OvertimeRound = 0,
		HalfRoundStart = halfRoundStart or maximumRounds :: number / 2,
		WinPoints = winPoints or 13,
	}

	return self
end

return Match
