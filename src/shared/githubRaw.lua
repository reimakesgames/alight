local RECURSION_LIMIT = 5
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/"

local HttpService = game:GetService("HttpService")

local githubRaw = {
	RefreshList = {}
}

function githubRaw:GetFileAsync(link, _depth: number?)
	_depth = _depth or 1
	if _depth > RECURSION_LIMIT then
		return error("Too much calls on :GetFileAsync() while requesting "..link)
	end
	local success, file = pcall(function()
		return HttpService:GetAsync(GITHUB_RAW_URL .. link)
	end)

	if not success then
		return githubRaw:GetFileAsync(link, _depth + 1)
	end

	return file
end

task.spawn(function()
	while task.wait(120) do
		for _, link in githubRaw.RefreshList do
			githubRaw:GetFileAsync(link)
		end
	end
end)

return githubRaw
