local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Modules = Shared:WaitForChild("Modules")

local InputHandler = require(Modules.InputHandler)

return function ()
	describe("InputHandler", function()
		it("does something", function()
			
		end)
	end)
end
