local gunVfx = {}

function gunVfx:EmitMuzzleParticles(attachment: Attachment)
	for _, object in attachment:GetChildren() do
		if not object:IsA("ParticleEmitter") then continue end

		if object.Name == "Flash" or object.Name == "Shockwave" then
			object:Emit(1)
		elseif object.Name == "Smoke" then
			object:Emit(8)
		end
	end
end

return gunVfx
