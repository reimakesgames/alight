--[=[
	This is not a class, but it's impossible to document a function without a class.

	@class fastInstance
]=]

--[=[
	A function for creating instances quickly, with optional properties

	It is recommended to use this function instead of Instance.new() when creating instances with properties.

	As opposed to making a variable and then setting the properties, this function will set the properties before Parenting the object.
	This is due to server-side parenting being replicated first, then the properties being set, which can cause visual glitches.

	@function fastInstance
	@within fastInstance
	@param className string
	@param properties table?

	@return Instance
]=]
return function (className: string, properties: {[string]: any}): Instance
	local object = Instance.new(className :: any)
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
