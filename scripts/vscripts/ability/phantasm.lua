function CreateMeIllusion( keys )
	local caster = keys.caster
	local ability = keys.ability
	local images_count = ability:GetLevelSpecialValueFor("images_count", ability:GetLevel() - 1 ) + caster:FindTalentValue("special_bonus_memethrow_naruto")
	local outgoing_damage = ability:GetLevelSpecialValueFor("outgoing_damage", ability:GetLevel() - 1 ) + caster:FindTalentValue("special_bonus_memethrow_naruto_2")
	local duration = ability:GetLevelSpecialValueFor("illusion_duration", ability:GetLevel() - 1 ) + caster:FindTalentValue("special_bonus_memethrow_naruto_3")
	local incoming_damage = ability:GetLevelSpecialValueFor("incoming_damage", ability:GetLevel() - 1 ) + caster:FindTalentValue("special_bonus_memethrow_naruto_4")



	ability.phantasm_illusions = {}

		local modifierKeys = {
		outgoing_damage = outgoing_damage,
		incoming_damage = incoming_damage,
		duration = duration
		}

	local illusions = CreateIllusions( caster, caster, modifierKeys, images_count, duration, true, true )
	
	for _, illusion in pairs( illusions ) do
		table.insert(ability.phantasm_illusions, illusion)
	end

end