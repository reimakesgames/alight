local Debris = game:GetService("Debris")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Utility = ReplicatedFirst.Utility

local QuickInstance = require(Utility.QuickInstance)

local function ActiveSoundsFolder()
	return workspace:FindFirstChild("ActiveSoundsFolder") or QuickInstance("Folder", {Name = "ActiveSoundsFolder", Parent = workspace})
end

export type SoundSettings = {
	SoundPosition: boolean | Vector3;
	SoundSize: Vector3?
}

local SFXHandler = {}

function SFXHandler:PlaySound(soundObject: Sound, soundSettings: SoundSettings?)
	local newSound = soundObject:Clone()
	soundSettings = soundSettings or {}
	Debris:AddItem(newSound, soundObject.TimeLength)

	if soundSettings.SoundPosition == false or soundSettings.SoundPosition == nil then
		newSound.Parent = ActiveSoundsFolder()
	else
		QuickInstance("Part", {
			Anchored = true;
			CanCollide = false;
			CanQuery = false;
			CanTouch = false;
			Size = soundSettings.SoundSize or Vector3.new(1, 1, 1);
			Parent = ActiveSoundsFolder()
		})
	end

	newSound:Play()
end

return SFXHandler