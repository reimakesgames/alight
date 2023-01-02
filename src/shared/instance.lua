return function (className: string, properties: {[string]: any}): Instance
	local object = Instance.new(className)
	if properties then
		for property, value in pairs(properties) do
			if property == "Parent" then
				continue
			end
			object[property] = value
		end
		if properties.Parent then
			object.Parent = properties.Parent
		end
	end

	return object
end
