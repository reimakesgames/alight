return function<Class>(ClassName: Class, Properties: {[string]: any}): Class
	local Object = Instance.new(ClassName)
	for Property, Value in Properties do
		if Property == "Parent" then
			continue
		end
		Object[Property] = Value
	end
	if Properties.Parent then
		Object.Parent = Properties.Parent
	end

	return Object
end