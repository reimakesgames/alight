local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local Spring = require(Shared.Spring)

return function ()
	describe("Spring", function()
		local spring: Spring.Type

		beforeEach(function()
			spring = Spring.new(5, 50, 4, 4)
		end)

		it("should be a table", function()
			expect(spring).to.be.ok()
		end)

		it("should be able to destroy itself", function()
			spring:Destroy()
			expect(#spring).to.equal(0)
		end)

		it("should be able to check if it is a SpringClass", function()
			expect(spring:IsA("SpringClass")).to.equal(true)
			expect(spring:IsA("Spring")).to.equal(false)
		end)

		it("should be able to apply a force", function()
			spring:AddVelocity(Vector3.new(1, 2, 3))
			expect(spring.Velocity).to.equal(Vector3.new(1, 2, 3))
		end)

		it("should be able to set a target", function()
			spring:SetTarget(Vector3.new(1, 2, 3))
			expect(spring.Target).to.equal(Vector3.new(1, 2, 3))
		end)

		it("should be able to step", function()
			spring:SetTarget(Vector3.new(1, 2, 3))
			spring:Step(1)
			expect(spring.Position).never.to.equal(Vector3.new(1, 2, 3))
		end)
	end)
end
