local HttpService = game:GetService("HttpService")

local GithubPuller = {
	RefreshList = {}
}

function GithubPuller:GetFileAsync(link, _depth: number?)
	_depth = _depth or 1
	if _depth > 5 then
		return error("Too much calls on :GetFileAsync() while requesting "..link)
	end
	local success, file = pcall(function()
		return HttpService:GetAsync(link)
	end)

	if not success then
		return GithubPuller:GetFileAsync(link, _depth + 1)
	end

	return file
end

task.spawn(function()
	while task.wait(120) do
		for _, link in GithubPuller.RefreshList do
			GithubPuller:GetFileAsync(link)
		end
	end
end)

return GithubPuller
