function bristleback_takedamage(params)
	-- Create the threshold counter on the unit if it doesn't exist.
	if params.unit.quill_threshold_counter == nil then
		params.unit.quill_threshold_counter = 0.0
	end

	local ability = params.ability
	local back_reduction_percentage = ( ability:GetLevelSpecialValueFor("back_damage_reduction", ability:GetLevel() - 1) + params.unit:FindTalentValue("special_bonus_memethrow_leo_5") ) / 100
	local side_reduction_percentage = ability:GetLevelSpecialValueFor("side_damage_reduction", ability:GetLevel() - 1) / 100


	-- The y value of the angles vector contains the angle we actually want: where units are directionally facing in the world.
	local victim_angle = params.unit:GetAnglesAsVector().y
	local origin_difference = params.unit:GetAbsOrigin() - params.attacker:GetAbsOrigin()
	-- Get the radian of the origin difference between the attacker and Bristleback. We use this to figure out at what angle the attacker is at relative to Bristleback.
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	-- Convert the radian to degrees.
	origin_difference_radian = origin_difference_radian * 180
	local attacker_angle = origin_difference_radian / math.pi
	-- See the opening block comment for why I do this. Basically it's to turn negative angles into positive ones and make the math simpler.
	attacker_angle = attacker_angle + 180.0
	-- Finally, get the angle at which Bristleback is facing the attacker.
	local result_angle = attacker_angle - victim_angle
	result_angle = math.abs(result_angle)

	-- Check for the side angle first. If the attack doesn't pass this check, we don't have to do back angle calculations.
	if result_angle >= (180 - (ability:GetSpecialValueFor("side_angle") / 2)) and result_angle <= (180 + (ability:GetSpecialValueFor("side_angle") / 2)) then 
		-- Check for back angle. If this check doesn't pass, then do side angle "damage reduction".
		if result_angle >= (180 - (ability:GetSpecialValueFor("back_angle") / 2)) and result_angle <= (180 + (ability:GetSpecialValueFor("back_angle") / 2)) then 
			-- Check if the reduced damage is lethal
			if((params.unit:GetHealth() - (params.Damage * (1 - back_reduction_percentage))) >= 1) then
				-- This is the actual "damage reduction".
				params.unit:SetHealth((params.Damage * back_reduction_percentage) + params.unit:GetHealth())
				-- Play the sound on Bristleback.
				EmitSoundOn(params.sound, params.unit)
				-- Create the back particle effect.
				local back_damage_particle = ParticleManager:CreateParticle(params.back_particle, PATTACH_ABSORIGIN_FOLLOW, params.unit) 
				-- Set Control Point 1 for the back damage particle; this controls where it's positioned in the world. In this case, it should be positioned on Bristleback.
				ParticleManager:SetParticleControlEnt(back_damage_particle, 1, params.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", params.unit:GetAbsOrigin(), true) 
				-- Increase the Quill Spray damage counter based on how much damage was done *post-Bristleback mitigation*.
				params.unit.quill_threshold_counter = params.unit.quill_threshold_counter + (params.Damage - (params.Damage * back_reduction_percentage))
			end
		else
			-- Check if the reduced damage is lethal
			if((params.unit:GetHealth() - (params.Damage * (1 - side_reduction_percentage))) >= 1) then
				-- This is the actual "damage reduction".
				params.unit:SetHealth((params.Damage * side_reduction_percentage) + params.unit:GetHealth())
				-- Play the sound on Bristleback.
				EmitSoundOn(params.sound, params.unit)
				-- Create the side particle effect.
				local side_damage_particle = ParticleManager:CreateParticle(params.side_particle, PATTACH_ABSORIGIN_FOLLOW, params.unit) 
				-- Set Control Point 1 for the side damage particle; same stuff as the back damage particle.
				ParticleManager:SetParticleControlEnt(side_damage_particle, 1, params.unit, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", params.unit:GetAbsOrigin(), true) 
				ParticleManager:SetParticleControlEnt(side_damage_particle, 2, params.unit, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0, result_angle, 0), true)
				-- Increase the Quill Spray damage counter based on how much damage was done *post-Bristleback mitigation*.
				params.unit.quill_threshold_counter = params.unit.quill_threshold_counter + (params.Damage - (params.Damage * side_reduction_percentage))
			end
		end
	end
end
