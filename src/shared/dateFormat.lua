local DAYS_IN_MONTH = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

local dateFormat = {}

function dateFormat:accountAgeToDMY(accountAge)
	local d, m, y = 0, 0, 0
	d = accountAge
	while d >= 365 do
		if y % 4 == 0 then
			d = d - 366
		else
			d = d - 365
		end
		y = y + 1
	end
	for i = 1, 12 do
		if d > DAYS_IN_MONTH[i] then
			d = d - DAYS_IN_MONTH[i]
			m = m + 1
		else
			break
		end
		if m == 12 then
			m = 0
			y = y + 1
			if y % 4 == 0 then
				DAYS_IN_MONTH[2] = 29
			else
				DAYS_IN_MONTH[2] = 28
			end
		end
	end
	return d .. "d " .. m .. "m " .. y .. "y"
end

function dateFormat:secondsToCleanHMS(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	seconds = seconds % 60
	if hours > 0 then
		return string.format("%dh %02dm %02ds", hours, minutes, seconds)
	elseif minutes > 0 then
		return string.format("%02dm %02ds", minutes, seconds)
	else
		return string.format("%02ds", seconds)
	end
end

return dateFormat
