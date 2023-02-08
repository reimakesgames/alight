local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local isRealNumber = require(Shared.isRealNumber)

return function()
	describe("isRealNumber", function()
		it("should return true for a number", function()
			expect(isRealNumber(1)).to.equal(true)
		end)

		it("should return false for string, table, boolean, and nil", function()
			expect(isRealNumber("1")).to.equal(false)
			expect(isRealNumber({})).to.equal(false)
			expect(isRealNumber(true)).to.equal(false)
			expect(isRealNumber(nil)).to.equal(false)
		end)

		it("should return false for a NaN", function()
			expect(isRealNumber(0/0)).to.equal(false)
		end)

		it("should return false for a positive infinity", function()
			expect(isRealNumber(1/0)).to.equal(false)
		end)

		it("should return false for a negative infinity", function()
			expect(isRealNumber(-1/0)).to.equal(false)
		end)
	end)

end
