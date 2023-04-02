local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isRealNumber = require(ReplicatedStorage.Shared.isRealNumber)

return function()
	describe("isRealNumber", function()
		it("should return true for a real number", function()
			expect(isRealNumber(1)).to.equal(true)
		end)

		it("should return false for a non-number", function()
			expect(isRealNumber("1")).to.equal(false)
		end)

		it("should return false for a non-real number", function()
			expect(isRealNumber(math.huge)).to.equal(false)
			expect(isRealNumber(-math.huge)).to.equal(false)
			expect(isRealNumber(0/0)).to.equal(false)
		end)

		it("should return false for nil", function()
			expect(isRealNumber(nil)).to.equal(false)
		end)
	end)
end
