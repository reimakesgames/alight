local DataStoreService = game:GetService("DataStoreService")

local ProfilePhotos = DataStoreService:GetDataStore("ProfilePhotos")

local Profile = {}
Profile.__index = Profile

export type Type = {
	userId: number,
	photo: string?,
	transform: Vector2?,
}

function Profile.new(userId: number)
	local self = setmetatable({}, Profile)
	self.userId = userId
	return self
end

function Profile:Load()
	local success, result = pcall(function()
		return ProfilePhotos:GetAsync(self.userId)
	end)
	if success then
		return result
	else
		warn(result)
		warn("Returning default profile and disabling profile saving for this session.")
		return {
			photo = "rbxassetid://13605685527",
			transform = Vector2.new(0, 0),
		}
	end
end

function Profile:Save(photo: string?, transform: Vector2?)
	local success, result = pcall(function()
		ProfilePhotos:SetAsync(self.userId, {
			photo = photo,
			transform = transform,
		})
	end)
	if success then
		return result
	else
		return warn(result)
	end
end

return Profile
