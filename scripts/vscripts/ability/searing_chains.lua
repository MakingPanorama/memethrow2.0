function searing_chains_pin_point( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 ) + caster:FindTalentValue("special_bonus_memethrow_gonshik_2")
	local maxTarget = ability:GetLevelSpecialValueFor( "unit_count", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 ) +  caster:FindTalentValue("special_bonus_memethrow_gonshik")
	local modifierName = "modifier_searing_chains_debuff_datadriven"
	local particleName = "particles/ember_spirit_searing_chains_start.vpcf"
	local soundEvent = "Hero_EmberSpirit.SearingChains.Burn"
		
		if caster:HasScepter() then
           maxTarget = ability:GetLevelSpecialValueFor("unit_count_scepter", ability:GetLevel() - 1 )
		end
		
	-- Target stats
	local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local targetFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
	local unitOrder = FIND_ANY_ORDER

	-- Find and apply debuff
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, targetTeam,
		targetType, targetFlag, unitOrder, false
	)
	local count = 0
	for k, v in pairs( units ) do
		if count < maxTarget then
			-- Apply effect
			local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex, 1, v:GetAbsOrigin() )
			StartSoundEvent( soundEvent, v )
			
			-- Properly destroy effect
			Timers:CreateTimer( duration, function()
					ParticleManager:DestroyParticle( fxIndex, false )
					ParticleManager:ReleaseParticleIndex( fxIndex )
					StopSoundEvent( soundEvent, v )
				end
			)
			
			-- Function
			v:Stop()
			ability:ApplyDataDrivenModifier( caster, v, modifierName, {duration = duration} )
			count = count + 1
		end
	end
end

function DamageDeal( keys )

	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local damage = ability:GetLevelSpecialValueFor( "chains_damage", ability:GetLevel() - 1 ) +  caster:FindTalentValue("special_bonus_memethrow_gonshik_3")
	
	local damagetable = {
		victim		= target,
		attacker	= caster,
		damage		= damage,
		damage_type	=  DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage( damagetable )

end

