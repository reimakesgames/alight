local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local Symbol = require(Shared.Symbol)

return function()
	describe("Symbol", function()
		it("should return a new symbol", function()
			local symbol = Symbol("test")
			expect(symbol).to.be.ok()
		end)

		it("should return the same symbol for the same name", function()
			local symbol1 = Symbol("test")
			local symbol2 = Symbol("test")
			expect(symbol1).to.equal(symbol2)
		end)

		it("should return a different symbol for a different name", function()
			local symbol1 = Symbol("test")
			local symbol2 = Symbol("test2")
			expect(symbol1).never.to.equal(symbol2)
		end)

		it("should be named correctly", function()
			local symbol = Symbol("test")
			expect(tostring(symbol)).to.equal("Symbol(test)")
		end)

		it("should deny access to the metatable", function()
			local symbol = Symbol("test")
			local mt = getmetatable(symbol)
			expect(function()
				mt.__tostring = function()
					return "Symbol(test)"
				end
			end).to.throw()
		end)
	end)
end
