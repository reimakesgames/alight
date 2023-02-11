local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local gameHandler = require(Shared.gameHandler)

return function()
	describeFOCUS("gameHandler", function()
		it("should create a new game", function()
			gameHandler:NewGame(true, 8, 9)
			expect(gameHandler).to.be.ok()
		end)

		it("should create a PSEUDO PLAYER", function()
			local rei = gameHandler:__NEW_PSEUDO_PLAYER("rei", gameHandler.Defenders)
			local shiro = gameHandler:__NEW_PSEUDO_PLAYER("shiro", gameHandler.Attackers)
			local reiIsInDefenders = gameHandler.Defenders.players[1] == rei
			local shiroIsInAttackers = gameHandler.Attackers.players[1] == shiro
			expect(reiIsInDefenders).to.equal(true)
			expect(shiroIsInAttackers).to.equal(true)
			expect(rei).to.be.ok()
			expect(shiro).to.be.ok()
		end)

		it("should create a new round", function()
			gameHandler:NewRound()
			expect(gameHandler.currentRound).to.be.ok()
		end)

		it("should end a round", function()
			gameHandler:__TIMER_EXPIRED()
			print(gameHandler.currentRound.defendersWon)
			expect(gameHandler.currentRound.defendersWon).to.equal(true)
		end)

		it("should reward defenders 3,000 creds and surviving attackers 1,000 creds", function()
			gameHandler:EndRound()
			print(gameHandler.Defenders.players[1].credits)
			print(gameHandler.Attackers.players[1].credits)
			expect(gameHandler.Defenders.players[1].credits).to.equal(3000)
			expect(gameHandler.Attackers.players[1].credits).to.equal(1000)
		end)

		it("should do lose bonus", function()
			gameHandler:NewRound()
			gameHandler:__PLAYER_KILLED(gameHandler.Attackers.players[1], gameHandler.Defenders.players[1], "knife")
			gameHandler:EndRound()
			print(gameHandler.Defenders.players[1].credits)
			print(gameHandler.Attackers.players[1].credits)
			expect(gameHandler.Defenders.players[1].credits).to.equal(3000 + 3000 + 200)
			expect(gameHandler.Attackers.players[1].credits).to.equal(1000 + 1900 + 500)

			gameHandler:NewRound()
			gameHandler:__PLAYER_KILLED(gameHandler.Attackers.players[1], gameHandler.Defenders.players[1], "knife")
			gameHandler:EndRound()
			print(gameHandler.Defenders.players[1].credits)
			print(gameHandler.Attackers.players[1].credits)
			expect(gameHandler.Defenders.players[1].credits).to.equal(3000 + 3000 + 200 + 3000 + 200)
			expect(gameHandler.Attackers.players[1].credits).to.equal(1000 + 1900 + 500 + 1900 + 1000)
		end)

		it("should reward attackers for planting", function()
			gameHandler:__RESET_CREDITS()
			gameHandler:NewRound()
			gameHandler:__SPIKE_PLANTED()
			print(gameHandler.Defenders.players[1].credits)
			print(gameHandler.Attackers.players[1].credits)
			expect(gameHandler.Defenders.players[1].credits).to.equal(0)
			expect(gameHandler.Attackers.players[1].credits).to.equal(300)
		end)

		it("should be a defender win when spike is defused", function()
			gameHandler:__SPIKE_DEFUSED()
			gameHandler:EndRound()
			print(gameHandler.currentRound.defendersWon)
			print(gameHandler.Defenders.players[1].credits)
			print(gameHandler.Attackers.players[1].credits)
			expect(gameHandler.currentRound.defendersWon).to.equal(true)
			expect(gameHandler.Defenders.players[1].credits).to.equal(3000)
			expect(gameHandler.Attackers.players[1].credits).to.equal(300 + 2900)
		end)

		it("should be an attacker win when spike is planted and exploded", function()
			gameHandler:__RESET_CREDITS()
			gameHandler:NewRound()
			gameHandler:__SPIKE_PLANTED()
			gameHandler:__SPIKE_EXPLODED()
			gameHandler:EndRound()
			print(gameHandler.currentRound.defendersWon)
			print(gameHandler.Defenders.players[1].credits)
			print(gameHandler.Attackers.players[1].credits)
			expect(gameHandler.currentRound.defendersWon).to.equal(false)
			expect(gameHandler.Defenders.players[1].credits).to.equal(1000)
			expect(gameHandler.Attackers.players[1].credits).to.equal(300 + 3000)
		end)
	end)
end
