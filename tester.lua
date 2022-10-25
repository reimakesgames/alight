-- This is a required VSCode extension
-- VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=discretegames.f5anything

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Tests = ServerStorage:WaitForChild("Tests")

local TestEZ = require(Packages.testez)
local Bootstrapper = require(Tests.container.bootstrap)

Bootstrapper:run({
	-- Tests["test.spec"],
	-- Tests["KeybindsManager.spec"]
})
