local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local tableOperations = require(Shared.tableOperations)

return function()
	describe("Table Operations Utility", function()
		it("should copy a table", function()
			local original = {
				foo = "bar",
				baz = {
					qux = "quux",
				},
			}
			local copy = tableOperations:DeepCopy(original)
			expect(copy).to.be.ok()
			expect(copy).never.to.equal(original)
			expect(copy.foo).to.equal(original.foo)
			expect(copy.baz).to.be.ok()
			expect(copy.baz).never.to.equal(original.baz)
			expect(copy.baz.qux).to.equal(original.baz.qux)
		end)

		it("should copy a metatable", function()
			local original = {}
			setmetatable(original, {
				__tostring = function()
					return "foo"
				end,
			})
			local copy = tableOperations:DeepCopy(original, true)
			expect(getmetatable(copy)).to.be.ok()
			expect(getmetatable(copy)).never.to.equal(getmetatable(original))
			expect(tostring(copy)).to.equal("foo")
		end)

		it("should copy both table and metatable", function()
			local original = {
				foo = "bar",
				baz = {
					qux = "quux",
				},
			}
			setmetatable(original, {
				__tostring = function()
					return "foo"
				end,
			})
			local copy = tableOperations:DeepCopy(original, true)
			expect(copy).to.be.ok()
			expect(copy).never.to.equal(original)
			expect(copy.foo).to.equal(original.foo)
			expect(copy.baz).to.be.ok()
			expect(copy.baz).never.to.equal(original.baz)
			expect(copy.baz.qux).to.equal(original.baz.qux)
			expect(getmetatable(copy)).to.be.ok()
			expect(getmetatable(copy)).never.to.equal(getmetatable(original))
			expect(tostring(copy)).to.equal("foo")
		end)

		it("should copy an empty table", function()
			local original = {}
			local copy = tableOperations:DeepCopy(original)
			expect(copy).to.be.ok()
			expect(copy).never.to.equal(original)
		end)
	end)
end
