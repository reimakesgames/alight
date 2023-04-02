local RunService = game:GetService("RunService")

export type Tracker = {

}

local Trackers = {}

local HitboxTracker = {}
HitboxTracker.__index = HitboxTracker

local function extrapolateCharacterRig(lastIteration: Model, currentIteration: Model, alpha: number)
	local iteratedCharacter = currentIteration:Clone()

	for _, part in pairs(iteratedCharacter:GetDescendants()) do
		if part:IsA("BasePart") then
			local lastPart = lastIteration:FindFirstChild(part.Name)

			if lastPart then
				part.CFrame = lastPart.CFrame:Lerp(part.CFrame, alpha)
			end
		end
	end
end

function HitboxTracker.new(maximumHitboxAge: number, character: Model)
	local self = setmetatable({
		HitboxHistory = {},

		MaximumHitboxAge = maximumHitboxAge,
		Character = character,
	}, HitboxTracker)
	character.Archivable = true
	table.insert(Trackers, self)
	return self
end

function HitboxTracker:Destroy()
	for index, tracker in pairs(Trackers) do
		if tracker == self then
			table.remove(Trackers, index)
			break
		end
	end
end

function HitboxTracker:Track(totalTime, deltaTime)
	-- Total time is the total time the server has been running
	-- use totalTime to use as a relative reference frame

	-- Delta time is the time since the last frame
	-- use deltaTime to extrapolate the character rig or to add as a new element

	if not workspace:FindFirstChild("HITBOXES") then
		return
	end

	local currentHitbox = self.Character:Clone()
	-- ! expensive as fuck
	-- ! WARNING
	-- ! WARNING
	-- ! WARNING
	-- ! WARNING
	-- ! WARNING
	-- ! WARNING
	for _, part in currentHitbox:GetDescendants() do
		if part:IsA("BasePart") then
			part.CanCollide = false
			part.Transparency = 0.2
			part.Anchored = true
			part.Color = Color3.new(0, math.floor((totalTime * 2) % 2), 0)
		else
			part:Destroy()
		end
	end
	currentHitbox.Parent = workspace.HITBOXES

	-- this table is sorted from newest to oldest
	table.insert(self.HitboxHistory, {
		Time = totalTime,
		Hitbox = currentHitbox,
	})

	-- ! expensive as fuck
	-- ! expensive as fuck
	-- ! expensive as fuck
	-- ! expensive as fuck
	-- ! expensive as fuck
	-- ! expensive as fuck
	-- ! expensive as fuck
	-- ! expensive as fuck
	-- ! expensive as fuck
	-- ! expensive as fuck
	for index, hitbox in self.HitboxHistory do
		local nextHitbox = self.HitboxHistory[index + 1]

		if nextHitbox then
			if nextHitbox.Time < totalTime - self.MaximumHitboxAge then
				self.HitboxHistory[index].Hitbox:Destroy()
				table.clear(self.HitboxHistory[index])
				table.remove(self.HitboxHistory, index)
			end
		end
	end
end

function HitboxTracker:Get()

end

local counter = 1
-- the server lag is really bad
-- so we sample the hitboxes every 3rd frame
RunService.Stepped:Connect(function(totalTime, deltaTime)
	-- for _, tracker in Trackers do
	-- 	tracker:Track(totalTime, deltaTime)
	-- end
	counter = counter + 1
	if counter % 5 == 0 then
		for index, tracker in Trackers do
			tracker:Track(totalTime, deltaTime)
		end
	end
end)

return HitboxTracker
