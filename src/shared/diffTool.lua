--[=[
	@class diffTool

	A tool for diffing tables
]=]
local diffTool = {}

--[[
	depth is optional, defaults to 1
	its used to know how much depth in tables that gets diffed
	this prevents replacing the entire table if only one value changes
	good for networked tables

	visual example
	{prop1 = 1, prop2 = {prop3 = 3, prop4 = 4}}
	depth of 1:
	if prop3 changes, it will replace the entire prop2 table
	depth of 2:
	if prop3 changes, it will only replace the prop3 value
]]--

--[=[
	Compares two tables and returns a table with the differences, if any

	Depth is optional, defaults to 1. It's used to know how much depth in tables that gets diffed.
	This prevents replacing the entire table if only one value changes. Good for networked tables.

	@param t1 table
	@param t2 table
	@param depth number?

	@return table
]=]
function diffTool:tableDiff(t1, t2, depth: number?)
	local diff = {}
	assert(type(t1) == "table" and type(t2) == "table", "t1 and t2 must be tables")
	local newDepth = (if depth == nil and type(depth) ~= "number" then 1 else depth)
	for k, v in pairs(t1) do
		if type(v) == "table" and newDepth > 1 then
			local subDiff = self:tableDiff(v, t2[k], newDepth - 1)
			if next(subDiff) ~= nil then
				diff[k] = subDiff
			end
		elseif t2[k] ~= v then
			diff[k] = t2[k]
		end
	end
	for k, v in pairs(t2) do
		if t1[k] == nil then
			diff[k] = v
		end
	end
	return diff
end

--[[
	```lua
	local diffTool = require(game:GetService("ReplicatedStorage").Shared.diffTool)
	local t1 = {prop1 = 1, prop2 = {prop3 = 3, prop4 = 4}}
	local t2 = {prop1 = 1, prop2 = {prop3 = 3, prop4 = 5}}
	print(diffTool:tableDiff(t1, t2, 2))
	warn(diffTool:tableDiff(t1, t2, 1))
	```

	result:
	```lua
	09:28:16.351   ▼  {
		["prop2"] =  ▼  {
			["prop4"] = 5
		}
	}  -  Edit
	09:28:16.351   ▼  {
		["prop2"] =  ▼  {
			["prop3"] = 3,
			["prop4"] = 5
		}
	}  -  Edit
	```
]]--

return diffTool
