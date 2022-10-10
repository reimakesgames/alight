local InterpolatableFrame = {}
InterpolatableFrame.__index = InterpolatableFrame
function InterpolatableFrame.new(...)
	local self = setmetatable({}, InterpolatableFrame)
	self:constructor(...)
	return self
end
function InterpolatableFrame:constructor(contents, time)
	self.contents = contents
	self.time = time
end
function InterpolatableFrame:InterpolateAtTime(other, sampleAt)
	assert(self.time ~= other.time, "Frames have identical timings.")
	local first
	local last
	if self.time < other.time then
		first = self
		last = other
	else
		first = other
		last = self
	end
	return first:Interpolate(last, (sampleAt - first.time) / (last.time - first.time))
end
function InterpolatableFrame:Interpolate(other, alpha)
	return InterpolatableFrame.new(self.contents:Lerp(other.contents, alpha), ((other.time - self.time) * alpha) + self.time)
end

-- SLIDING WINDOW??

local SlidingWindow = {}
SlidingWindow.__index = SlidingWindow
function SlidingWindow.new(...)
	local self = setmetatable({}, SlidingWindow)
	self:constructor(...)
	return self
end
function SlidingWindow:constructor(MaxSize)
	self.CurrentSize = 0
	self.StartIndex = 0
	self.Sequence = {}
	self.MaxSize = MaxSize
end
function SlidingWindow:Append(item)
	if self.CurrentSize < self.MaxSize then
		self.Sequence[self.CurrentSize + 1] = item
		self.CurrentSize = self.CurrentSize + (1)
	else
		self.Sequence[self.StartIndex + 1] = item
		self.StartIndex = (self.StartIndex + 1) % self.MaxSize
	end
end
function SlidingWindow:Index(i)
	assert(i < self.MaxSize, "Index out of bounds")
	return self.Sequence[(i + self.StartIndex) % self.MaxSize + 1]
end
function SlidingWindow:GetCurrentSize()
	return self.CurrentSize
end

-- INTERPOL QUEUE

local InterpolationQueue = {}
InterpolationQueue.__index = InterpolationQueue
function InterpolationQueue.new(...)
	local self = setmetatable({}, InterpolationQueue)
	self:constructor(...)
	return self
end
function InterpolationQueue:constructor(MaxSize)
	self.sequence = SlidingWindow.new(MaxSize)
end
function InterpolationQueue:GetTimeBegin()
	local firstSequence = self.sequence:Index(0)
	if firstSequence then
		return firstSequence.time
	end
end
function InterpolationQueue:GetTimeEnd()
	local lastSequence = self.sequence:Index(self.sequence:GetCurrentSize() - 1)
	if lastSequence then
		return lastSequence.time
	end
end
function InterpolationQueue:IsEmpty()
	return self.sequence:GetCurrentSize() <= 0
end
function InterpolationQueue:Append(item, itemTime)
	local lastSequence = self.sequence:Index(self.sequence:GetCurrentSize() - 1)
	if lastSequence then
		local largestTime = lastSequence.time
		assert(itemTime > largestTime, "insertion time " .. itemTime .. " is less than or equal to the current largest: " .. largestTime .. ". Was the same element inserted twice?")
	end
	self.sequence:Append(InterpolatableFrame.new(item, itemTime))
end
function InterpolationQueue:InterpolateAtTime(sampleTime)
	local size = self.sequence:GetCurrentSize()
	if size == 0 then
		return nil
	elseif size == 1 then
		return self.sequence:Index(0)
	else
		local left = 0
		local right = self.sequence:GetCurrentSize() - 1
		assert(right - left > 0, "Attempt to interpolate on an empty queue.")
		local middle
		while right - left > 1 do
			middle = math.floor((right - left) / 2) + left
			local middleFrame = self.sequence:Index(middle)
			if middleFrame.time > sampleTime then
				right = middle
			elseif middleFrame.time < sampleTime then
				left = middle
			else
				left = middle
				right = middle
			end
		end
		if left == right then
			return self.sequence:Index(left)
		else
			return self.sequence:Index(left):InterpolateAtTime(self.sequence:Index(right), sampleTime)
		end
	end
end

return InterpolationQueue
