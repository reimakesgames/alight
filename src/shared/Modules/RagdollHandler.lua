local RagdollHandler = {}

function RagdollHandler.Activate(character)
	for _, joint: Motor6D in pairs(character:GetDescendants()) do
		local isTool = joint:FindFirstAncestorOfClass("Tool")
		if joint:IsA("Motor6D") and not isTool then
			local socket = Instance.new("BallSocketConstraint")
			local a1 = Instance.new("Attachment")
			local a2 = Instance.new("Attachment")
			a1.Parent = joint.Part0
			a2.Parent = joint.Part1
			socket.Parent = joint.Parent
			socket.Attachment0 = a1
			socket.Attachment1 = a2
			a1.CFrame = joint.C0
			a2.CFrame = joint.C1
			socket.LimitsEnabled = true
			socket.TwistLimitsEnabled = true
			joint:Destroy()
		end
	end
end

return RagdollHandler
