return function(ClassName: string, Properties: {[string]: any}): Instance
	local Object = Instance.new(ClassName)
	if Properties then
		for Property, Value in Properties do
			if Property == "Parent" then
				continue
			end
			Object[Property] = Value
		end
		if Properties.Parent then
			Object.Parent = Properties.Parent
		end
	end

	return Object
end
