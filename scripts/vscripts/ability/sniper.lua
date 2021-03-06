sniper_assassinate_lua = sniper_assassinate_lua or class({})

LinkLuaModifier("modifier_assassinate_target", "ability/sniper.lua", LUA_MODIFIER_MOTION_NONE)

AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

function sniper_assassinate_lua:OnAbilityPhaseStart()
	local target = self:GetCursorTarget()
	target:AddNewModifier(self:GetCaster(), self, "modifier_assassinate_target", { duration = 4 })
	EmitGlobalSound( AbilityKV[self:GetName()]["AbilityCastSoundPhase"] )
	return true
end

function sniper_assassinate_lua:OnAbilityPhaseInterrupted()
	StopGlobalSound( AbilityKV[self:GetName()]["AbilityCastSoundPhase"] )
	local target = self:GetCursorTarget()
	target:RemoveModifierByName("modifier_assassinate_target")
end

function sniper_assassinate_lua:OnSpellStart()
	local target = self:GetCursorTarget()
	EmitGlobalSound( AbilityKV[self:GetName()]["AbilityCastSoundLaunch"] ) -- Launch

	local projectile = {
		Ability = self,
		Source = self:GetCaster(),
		Target = target,
		iMoveSpeed = 20000,
		bDodgeable = true,
		EffectName = "particles/sniper_assassinate.vpcf",
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( projectile )

end

function sniper_assassinate_lua:OnProjectileHit(hTarget, vLocation)
	local sounds_stop = {
		AbilityKV[self:GetName()]["AbilityCastSoundPhase"],
		AbilityKV[self:GetName()]["AbilityCastSoundLaunch"],
		AbilityKV[self:GetName()]["AbilityCastSoundHit"],
	}

	if hTarget == nil then return end

	for _,sounds in pairs(sounds_stop) do
		self:GetCaster():StopSound( sounds )
	end
	if not self:GetCaster():HasTalent("special_bonus_memethrow_sniper_8") then
		if hTarget:TriggerSpellAbsorb( self ) then return end
	end
	hTarget:Kill( self, self:GetCaster() )

	hTarget:EmitSound(AbilityKV[self:GetName()]["AbilityCastSoundHit"])
end


modifier_assassinate_target = modifier_assassinate_target or class({})

function modifier_assassinate_target:IsHidden() return false end function modifier_assassinate_target:IsPassive() return false end function modifier_assassinate_target:IsPurgable() return false end

function modifier_assassinate_target:GetEffectName()
	return "particles/units/heroes/hero_sniper/sniper_crosshair.vpcf"
end

function modifier_assassinate_target:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function HitDamage ( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor("slow_duration", ability_level) + caster:FindTalentValue("special_bonus_memethrow_sniper_2")
	local chance = ability:GetLevelSpecialValueFor("proc_chance", ability_level) + caster:FindTalentValue("special_bonus_memethrow_sniper_3")
	local damage = ability:GetLevelSpecialValueFor("bonus_damage", ability_level) + caster:FindTalentValue("special_bonus_memethrow_sniper")
	
	local damagetable = {
			victim		= target,
			attacker	= caster,
			damage		= damage,
			damage_type	=  DAMAGE_TYPE_PHYSICAL,
		}
	
	local rand = math.random(1, 100)
	if caster:HasModifier("modifier_enrage_buff_datadriven") and caster:HasTalent("special_bonus_memethrow_sniper_5") then
		chance = 100
	end
	if rand <= chance then

		ApplyDamage( damagetable )
		
		target:EmitSound("SoundHit")
		
		ability:ApplyDataDrivenModifier( caster, target, "modifier_headshot_debuff_datadriven", {duration = duration} )
		if caster:HasTalent("special_bonus_memethrow_sniper_4") then
			ability:ApplyDataDrivenModifier( caster, target, "modifier_microstun", {} )
		end
	end

end

function overpower_init( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_enrage_buff_datadriven"
	local duration = ability:GetLevelSpecialValueFor( "duration_tooltip", ability:GetLevel() - 1 )
	local max_stack = ability:GetLevelSpecialValueFor( "max_attacks", ability:GetLevel() - 1 ) + caster:FindTalentValue("special_bonus_memethrow_sniper_6")
	
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, { } )
	caster:SetModifierStackCount( modifierName, ability, max_stack )
end


function overpower_decrease_stack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_enrage_buff_datadriven"
	local current_stack = caster:GetModifierStackCount( modifierName, ability )
	
	if current_stack > 1 then
		caster:SetModifierStackCount( modifierName, ability, current_stack - 1 )
	else
		caster:RemoveModifierByName( modifierName )
	end
end
