local ModifiedLinearInterpolate = {
	DeltaTime = 0
}

function ModifiedLinearInterpolate:CreateFramerateIndependentAlpha(speed)
	return 1 - math.exp(-speed * ModifiedLinearInterpolate.DeltaTime)
end

function ModifiedLinearInterpolate:LinearInterpolate(numberToInterpolate, target, speed)
	local alpha = 1 - math.exp(-speed * ModifiedLinearInterpolate.DeltaTime)
	return numberToInterpolate * (1 - alpha) + target * alpha
end

return ModifiedLinearInterpolate
