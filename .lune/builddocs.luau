local fs = require("@lune/fs")
local process = require("@lune/process")

local function removeIfExists(dir)
	if fs.isDir(dir) then
		fs.removeDir(dir)
	end
end
local function moveChildrenOfDir(from, to)
	local children = fs.readDir(from)
	for _, child in ipairs(children) do
		fs.move(from .. "/" .. child, to .. "/" .. child)
	end
end

removeIfExists(".vercel") -- clear it because artefacts may be left over
removeIfExists("build") -- clear it because artefacts may be left over
fs.writeDir(".vercel/output/static")
fs.writeFile(".vercel/output/config.json", [[
{
	"version": 3
}
]])

local buildResult = process.spawn("moonwave.cmd", {
	"build"
})
if buildResult.ok then
	print("build finished")
	print(buildResult.stdout)
	moveChildrenOfDir("build", ".vercel/output/static")
	fs.removeDir("build")

	local deployResult = process.spawn("vercel.cmd", {
		"deploy",
		"--prebuilt",
		"-y"
	})
	if deployResult.ok then
		print("deploy finished")
		print(deployResult.stdout)
	else
		print(deployResult.stderr)
		process.exit(1)
	end
else
	print(buildResult.stderr)
	process.exit(1)
end
