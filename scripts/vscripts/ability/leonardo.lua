function Damagedeal( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("base_damage") + caster:FindTalentValue("special_bonus_memethrow_leo")
	local damage_pct = ability:GetSpecialValueFor("bonus_damage") + caster:FindTalentValue("special_bonus_memethrow_leo_2")
	
	if target:TriggerSpellAbsorb( ability ) then return end
	
	local cdamage = caster:GetAttackDamage()

		local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.damage_type = DAMAGE_TYPE_MAGICAL
		damage_table.ability = ability
		damage_table.damage = damage + ( cdamage / 100 * damage_pct)

		ApplyDamage(damage_table)
	if caster:HasTalent("special_bonus_memethrow_leo_3") then
	 ability:ApplyDataDrivenModifier(caster, target, "modifier_microstun_suriken", {} )
	end
	
end

leonardo_slash = leonardo_slash or class({})

AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

function leonardo_slash:OnSpellStart(recastVector, warpVector, bInterrupted)

	if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
		self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
	end
	save_position = self:GetCaster():GetAbsOrigin()
	local original_position	= self:GetCaster():GetAbsOrigin()
	local final_position = self:GetCaster():GetAbsOrigin() + ((self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * math.max(math.min(((self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()) * Vector(1, 1, 0)):Length2D(), self:GetSpecialValueFor("max_travel_distance") + self:GetCaster():GetCastRangeBonus()), self:GetSpecialValueFor("min_travel_distance")))
		
	if recastVector then
		final_position	= self:GetCaster():GetAbsOrigin() + recastVector
	end
		
	if warpVector then
		final_position	= GetGroundPosition(self:GetCaster():GetAbsOrigin() + warpVector, nil)
	end
	
	self.original_vector	= (final_position - self:GetCaster():GetAbsOrigin()):Normalized() * (self:GetSpecialValueFor("max_travel_distance") + self:GetCaster():GetCastRangeBonus())
		
	self:GetCaster():SetForwardVector(self.original_vector:Normalized())
		
	self:GetCaster():EmitSound("Hero_VoidSpirit.AstralStep.Start")
		
	local step_particle = ParticleManager:CreateParticle("particles/void_spirit_astral_step.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(step_particle, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(step_particle, 1, final_position)
	ParticleManager:ReleaseParticleIndex(step_particle)

		
	local bHeroHit	= false

	EmitSoundOn(AbilityKV[self:GetName()]["AbilityCastSound"], self:GetCaster())
		
	for _, enemy in pairs(FindUnitsInLine(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), final_position, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do		
		self.impact_particle = ParticleManager:CreateParticle("particles/void_spirit_astral_step_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
		ParticleManager:SetParticleControlEnt(self.impact_particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(self.impact_particle)
		
		self:GetCaster():SetAbsOrigin(enemy:GetAbsOrigin() - self:GetCaster():GetForwardVector())
			
		if warpVector and not bInterrupted then
			ApplyDamage({
				victim = enemy,
				attacker = self:GetCaster(),
				damage = self:GetSpecialValueFor("pop_damage"),
				damage_type = DAMAGE_TYPE_PHYSICAL
			})
		end
		
		self:GetCaster():PerformAttack(enemy, false, true, true, false, false, false, true)

		if enemy:IsHero() and not bHeroHit then
			bHeroHit = true
		end
	end
	FindClearSpaceForUnit(self:GetCaster(), final_position, false)

	ProjectileManager:ProjectileDodge( self:GetCaster() )

end
