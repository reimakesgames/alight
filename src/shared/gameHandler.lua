--[[
	Credits Taken from Valorant 6.02

	Income Sources:

	Kill - 200 Credits
	Plant Spike - 300 Credits
	Round Win - 3,000 Credits
	Round Loss 1 - 1,900 Credits
	Round Loss 2 - 2,400 Credits
	Round Loss 3 - 2,900 Credits

	You may recieve less than the minimum shown for a loss if you survive (save) under certain circumstances.

	Attackers who lose but survive without planting the spike recieve a reduced
	number of credits for losing (1,000) with no loss streak bonus.

	Defenders who lose but survive after the spike is detonated also recieve a
	reduced number of credits for losing (1,000) with no loss streak bonus.

	* This means that if you survive, you will recieve a minimum of 1,000 credits
	* for a loss.
	* If you die on a lost round, you will recieve the Round Loss Bonus.

	* Ingame terms, If you saved, you will recieve 1,000 credits for a loss.
	* If you died, you will recieve the Round Loss Bonus.
]]

--[[
	When overtime is enabled, the game will resume when 12-12 is reached. The first team to
	get a 2 point lead will win the game.

	When overtime is disabled, the game will end with a Sudden Death round when 12-12 is reached.
	Whoever wins the Sudden Death round will win the game.
]]

export type Round = {
	attackerPlayerCount: number,
	defenderPlayerCount: number,

	combatLogs: { [number]: CombatLog },
	attackerAlivePlayers: { [number]: GamePlayer },
	defenderAlivePlayers: { [number]: GamePlayer },

	attackersWon: boolean,
	defendersWon: boolean,

	timerExpired: boolean,
	attackersEliminated: boolean,
	defendersEliminated: boolean,

	planted: boolean,

	defused: boolean,
	exploded: boolean,
}

export type GamePlayer = {
	name: string,
	team: GameTeam,

	credits: number,

	__alive: boolean,
}

export type CombatLog = {
	killer: GamePlayer,
	victim: GamePlayer,

	weapon: string,
}

export type GameTeam = {
	players: { [number]: GamePlayer },

	points: number,
	loseStreak: number,
}

local gameHandler = {
	Attackers = {
		players = {},

		points = 0,
		loseStreak = 0,
	},

	Defenders = {
		players = {},

		points = 0,
		loseStreak = 0,
	},

	roundsArray = {} :: { [number]: Round },
	currentRound = {} :: Round,
	secondHalf = false,
}

local players = {}

--[[
	This function creates a new round and adds it to the roundsArray.
	And each round has different adresses in memory so it can be modified without
	overwriting every round.
]]
local function newRound()
	table.insert(gameHandler.roundsArray, {
		attackerPlayerCount = #gameHandler.Attackers.players,
		defenderPlayerCount = #gameHandler.Defenders.players,

		combatLogs = {} :: { [number]: CombatLog },
		attackerAlivePlayers = {} :: { [number]: GamePlayer },
		defenderAlivePlayers = {} :: { [number]: GamePlayer },

		-- a broader win condition
		attackersWon = false,
		defendersWon = false,

		timerExpired = false,
		attackersEliminated = false,
		defendersEliminated = false,

		planted = false,

		defused = false,
		exploded = false,
	})
	gameHandler.currentRound = gameHandler.roundsArray[#gameHandler.roundsArray]
end

local function checkForWinCondition()
	if #gameHandler.currentRound.defenderAlivePlayers == 0 then
		gameHandler.currentRound.defendersEliminated = true
		gameHandler.currentRound.attackersWon = true
	elseif #gameHandler.currentRound.attackerAlivePlayers == 0 then
		gameHandler.currentRound.attackersEliminated = true
		gameHandler.currentRound.defendersWon = true
	end
end

function gameHandler:NewGame(overtimeEnabled: boolean, roundsInHalf: number, winPoints: number)
	gameHandler.Attackers = {
		players = {},

		points = 0,
		loseStreak = 0,
	}

	gameHandler.Defenders = {
		players = {},

		points = 0,
		loseStreak = 0,
	}

	gameHandler.roundsArray = {}
	gameHandler.currentRound = {} :: Round
	gameHandler.secondHalf = false

	gameHandler.overtimeEnabled = overtimeEnabled
	gameHandler.roundsInHalf = roundsInHalf
	gameHandler.winPoints = winPoints
end

function gameHandler:NewRound()
	if #gameHandler.roundsArray == gameHandler.roundsInHalf then
		gameHandler.secondHalf = true
		gameHandler.Attackers.loseStreak = 0
		gameHandler.Defenders.loseStreak = 0
		-- clear credits
		for _, player in pairs(gameHandler.Attackers.players) do
			player.credits = 0
		end
		for _, player in pairs(gameHandler.Defenders.players) do
			player.credits = 0
		end
	end

	newRound()

	for _, player in pairs(gameHandler.Attackers.players) do
		player.__alive = true
		table.insert(gameHandler.currentRound.attackerAlivePlayers :: { [number]: GamePlayer }, player)
	end

	for _, player in pairs(gameHandler.Defenders.players) do
		player.__alive = true
		table.insert(gameHandler.currentRound.defenderAlivePlayers :: { [number]: GamePlayer }, player)
	end
end

function gameHandler:EndRound()
	local lastRound = gameHandler.roundsArray[#gameHandler.roundsArray - 1]
	local winner = ""

	local attackersSurvivors = 0
	local defendersSurvivors = 0

	for _, player in gameHandler.Attackers.players do
		if player.__alive then
			attackersSurvivors += 1
		end
	end

	for _, player in gameHandler.Defenders.players do
		if player.__alive then
			defendersSurvivors += 1
		end
	end
	print("Attackers Survivors: " .. attackersSurvivors)
	print("Defenders Survivors: " .. defendersSurvivors)

	if gameHandler.currentRound.attackersWon then
		gameHandler.Attackers.points += 1
		gameHandler.Attackers.loseStreak = 0
		if #gameHandler.roundsArray > 1 then
			local hasReachedLoseStreakLimit = gameHandler.Defenders.loseStreak >= 2
			if lastRound.attackersWon and not hasReachedLoseStreakLimit then
				gameHandler.Defenders.loseStreak += 1
			end
		end
		winner = "Attackers"
	elseif gameHandler.currentRound.defendersWon then
		gameHandler.Defenders.points += 1
		gameHandler.Defenders.loseStreak = 0
		if #gameHandler.roundsArray > 1 then
			local hasReachedLoseStreakLimit = gameHandler.Attackers.loseStreak >= 2
			if lastRound.defendersWon and not hasReachedLoseStreakLimit then
				gameHandler.Attackers.loseStreak += 1
			end
		end
		winner = "Defenders"
	end
	warn(winner .. " won the round!")



	if gameHandler.currentRound.exploded then
		for _, player in pairs(gameHandler.Attackers.players) do
			player.credits += 3000
		end

		for _, player in pairs(gameHandler.Defenders.players) do
			if player.__alive then
				player.credits += 1000
			else
				player.credits += 1900 + (gameHandler.Defenders.loseStreak * 500)
			end
		end
	elseif gameHandler.currentRound.defused then
		for _, player in pairs(gameHandler.Defenders.players) do
			player.credits += 3000
		end

		for _, player in pairs(gameHandler.Attackers.players) do
			player.credits += 1900 + (gameHandler.Attackers.loseStreak * 500)
		end
	end

	if gameHandler.currentRound.timerExpired then
		for _, player in pairs(gameHandler.Defenders.players) do
			player.credits += 3000
		end

		for _, player in pairs(gameHandler.Attackers.players) do
			if player.__alive then
				player.credits += 1000
			else
				player.credits += 1900 + (gameHandler.Attackers.loseStreak * 500)
			end
		end
	end

	if gameHandler.currentRound.attackersEliminated then
		for _, player in pairs(gameHandler.Defenders.players) do
			player.credits += 3000
		end

		for _, player in pairs(gameHandler.Attackers.players) do
			player.credits += 1900 + (gameHandler.Attackers.loseStreak * 500)
		end
	end

	if gameHandler.currentRound.defendersEliminated then
		for _, player in pairs(gameHandler.Attackers.players) do
			player.credits += 3000
		end

		for _, player in pairs(gameHandler.Defenders.players) do
			player.credits += 1900 + (gameHandler.Defenders.loseStreak * 500)
		end
	end

	if gameHandler.secondHalf then
		if gameHandler.Attackers.points == gameHandler.roundsInHalf and gameHandler.Defenders.points == gameHandler.roundsInHalf then
			if gameHandler.overtimeEnabled then
				if gameHandler.Attackers.points - gameHandler.Defenders.points >= 2 then
					-- attackers win
					warn("Attackers Win")
				elseif gameHandler.Defenders.points - gameHandler.Attackers.points >= 2 then
					-- defenders win
					warn("Defenders Win")
				else

				end
				local overtimeRound = #gameHandler.roundsArray - (gameHandler.roundsInHalf * 2)
				overtimeRound = math.floor(overtimeRound / 2) + 1
				warn("Overtime " .. overtimeRound)
			else
				-- sudden death
				warn("Sudden Death")
			end
		end
	end
end

function gameHandler:__NEW_PSEUDO_PLAYER(name: string, team: GameTeam)
	local player = {
		name = name,
		team = team,

		credits = 0,

		__alive = true,
	}

	table.insert(players, player)
	if player.team == gameHandler.Attackers then
		table.insert(gameHandler.Attackers.players, player)
	elseif player.team == gameHandler.Defenders then
		table.insert(gameHandler.Defenders.players, player)
	end

	return player
end

function gameHandler:__PLAYER_KILLED(player: GamePlayer, killer: GamePlayer?, weapon: string?)
	print("Player Killed")
	if killer then
		killer.credits += 200
	end

	local combatLog = {
		killer = killer or "World",
		victim = player,

		weapon = weapon or "Fall Damage",
	}

	player.__alive = false
	-- remove player from alive players
	if player.team == gameHandler.Attackers then
		for i, alivePlayer in pairs(gameHandler.currentRound.attackerAlivePlayers) do
			if alivePlayer == player then
				table.remove(gameHandler.currentRound.attackerAlivePlayers, i)
				break
			end
		end
	else
		for i, alivePlayer in pairs(gameHandler.currentRound.defenderAlivePlayers) do
			if alivePlayer == player then
				table.remove(gameHandler.currentRound.defenderAlivePlayers, i)
				break
			end
		end
	end

	table.insert(gameHandler.currentRound.combatLogs :: { [number]: CombatLog }, combatLog)
	checkForWinCondition()
end

function gameHandler:__SPIKE_PLANTED()
	gameHandler.currentRound.planted = true
	for _, player in gameHandler.Attackers.players do
		player.credits += 300
	end
end

function gameHandler:__SPIKE_DEFUSED()
	gameHandler.currentRound.defendersWon = true
	gameHandler.currentRound.defused = true
end

function gameHandler:__SPIKE_EXPLODED()
	gameHandler.currentRound.attackersWon = true
	gameHandler.currentRound.exploded = true
end

function gameHandler:__TIMER_EXPIRED()
	gameHandler.currentRound.defendersWon = true
	gameHandler.currentRound.timerExpired = true
end

function gameHandler:__RESET_CREDITS()
	for _, player in pairs(players) do
		player.credits = 0
	end
end

return gameHandler
