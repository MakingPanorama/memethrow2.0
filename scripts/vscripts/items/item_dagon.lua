function item_dagon_datadriven_on_spell_start(keys)
	local dagon_level = keys.ability:GetLevel()
	
	if keys.target:TriggerSpellAbsorb( keys.ability ) then return end
	
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 300 + (100 * dagon_level)  --Control Point 2 in Dagon's particle effect takes a number between 400 and 800, depending on its level.
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	
	keys.caster:EmitSound("SoundPew")
	keys.target:EmitSound("SoundPisk")
		
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = keys.Damage, damage_type = DAMAGE_TYPE_MAGICAL})
end