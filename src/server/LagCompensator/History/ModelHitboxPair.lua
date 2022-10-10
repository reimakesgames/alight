local defaultInstanceModifiers = {
	["BasePart"] = function(part)
		if part:IsA("BasePart") then
			part.Anchored = true
			part.Transparency = .5
			part.CanCollide = false
		else
			error("Invalid type passed into BasePart callback function")
		end
	end
}

local function FindInArray(array, whatToFind)
	return array[whatToFind]
end

local ModelHitboxPair = {};
ModelHitboxPair.__index = ModelHitboxPair

function ModelHitboxPair.new(...)
	local self = setmetatable({}, ModelHitboxPair)
	self:constructor(...)
	return self
end

function ModelHitboxPair:constructor(model, hitboxParent, permittedTypesArray, santizeCallbacks)
	if hitboxParent == nil then hitboxParent = game.Workspace.CurrentCamera end
	if permittedTypesArray == nil then permittedTypesArray = { "BasePart" } end
	if santizeCallbacks == nil then santizeCallbacks = defaultInstanceModifiers end
	local numvals = {}
	local cloneToOriginalUnsanitizedMap = {}
	for _, object in model:GetDescendants() do
		local numValue = Instance.new("NumberValue")
		numValue.Name = "TmpCouplingId"
		numValue.Value = #numvals
		numValue.Parent = object
		numvals[#numvals + 1] = { object, numValue }
	end
	local priorArchivable = model.Archivable
	model.Archivable = true
	local clone = model:Clone()
	model.Archivable = priorArchivable
	for _, cloneObj in clone:GetDescendants() do
		local cloneNumValue = cloneObj:FindFirstChild("TmpCouplingId")
		if cloneNumValue then
			local _4 = numvals[cloneNumValue.Value + 1]
			local originalObj = _4[1]
			local originalNumValue = _4[2]
			cloneToOriginalUnsanitizedMap[cloneObj] = originalObj
			originalNumValue:Destroy()
			cloneNumValue:Destroy()
		elseif cloneObj.Name ~= "TmpCouplingId" then
			warn("Object not tagged with a TmpCouplingId" .. cloneObj:GetFullName())
		end
	end
	local originalToCloneSanitizedMap = {}
	for _, keptObj in self:SanitizeInstance(clone, permittedTypesArray) do
		originalToCloneSanitizedMap[assert(cloneToOriginalUnsanitizedMap[keptObj])] = keptObj
		for permittedType, callback in santizeCallbacks do
			if keptObj:IsA(permittedType) then
				callback(keptObj)
			end
		end
	end
	self.hitbox = clone
	self.map = originalToCloneSanitizedMap
	self.original = model
	clone.Parent = hitboxParent
end

function ModelHitboxPair:SanitizeInstance(instance, permittedTypes, kept)
	if kept == nil then kept = {}; end
	for _, child in instance:GetChildren() do
		if not permittedTypes[child.ClassName] then
			child:Destroy()
		else
			kept[#kept + 1] = child;
			self:SanitizeInstance(child, permittedTypes, kept)
		end
	end
	return kept
end

return ModelHitboxPair;
