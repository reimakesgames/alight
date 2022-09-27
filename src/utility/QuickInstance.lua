return function<Class>(ClassName: Class, Properties: {[string]: any}): Class
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