-- Удар мечом
function SwordAttack(keys )
	if keys.target:TriggerSpellAbsorb( keys.ability ) then return end
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1) + caster:FindTalentValue("special_bonus_memethrow_vader")
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1)
	local damagetable = {
		victim		= target,
		attacker	= caster,
		damage		= damage,
		damage_type	=  DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damagetable)
	if caster:HasTalent("special_bonus_memethrow_vader_2") then ability:ApplyDataDrivenModifier(caster, target, "modifier_silence_talent", {duration = duration}) end
	ability:ApplyDataDrivenModifier(caster, target, "modifier_laser_debuff_datadriven", {duration = duration})
	
end
function StartSound(keys)
	local rand = RandomInt(1, 3)
	if rand == 1 then keys.caster:EmitSound("SoundSwordAttack1") end
	if rand == 2 then keys.caster:EmitSound("SoundSwordAttack2") end
	if rand == 3 then keys.caster:EmitSound("SoundSwordAttack3") end
end
-- Притягивание
function ToVader(keys)
	------------------------------------------
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)
	------------------------------------------
	local remaining_duration = duration - (GameRules:GetGameTime() - target.start_time)
	local target_location = target:GetAbsOrigin()
	local caster_location = caster:GetAbsOrigin()
	local vector_distance = caster_location - target_location
	local distance = (vector_distance):Length2D()
	local direction = (vector_distance):Normalized()
	local pull_speed = distance * 1/duration * 1/30
	
	
	ability:ApplyDataDrivenModifier(caster, target, "modifier_comesleep", {duration = remaining_duration})
	target:SetAbsOrigin(target_location + direction * pull_speed)
	
end
function RemoveParticle(keys)
	ParticleManager:DestroyParticle(keys.caster.LifeDrainParticle,false)
end
function ComeToVaderStart(keys)
	local target = keys.target
	local caster = keys.caster
	local damage = keys.ability:GetLevelSpecialValueFor("damage", keys.ability:GetLevel() - 1) + caster:FindTalentValue("special_bonus_memethrow_vader_5")
	caster:EmitSound("SoundComeToVader")
	target.start_time = GameRules:GetGameTime()
	local particleName = "particles/pugna_life_drain.vpcf"
	caster.LifeDrainParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(caster.LifeDrainParticle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	local damagetable = {
		victim		= target,
		attacker	= caster,
		damage		= damage,
		damage_type	=  DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damagetable)
	
end
function StealStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration_steal = ability:GetLevelSpecialValueFor("duration_steal", ability:GetLevel() - 1) + caster:FindTalentValue("special_bonus_memethrow_vader_3")
	ability:ApplyDataDrivenModifier(caster, target, "modifier_vader_steal", {duration = duration_steal})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_vader_steal_caster", {duration = duration_steal})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_vader_steal_as_target", {duration = duration_steal})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_vader_steal_as_caster", {duration = duration_steal})
	
end
function ToVaderStealStr(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local steal_pct = ability:GetLevelSpecialValueFor("str_steal", ability:GetLevel() - 1) + caster:FindTalentValue("special_bonus_memethrow_vader_4")
	local str = target:GetStrength()
	target.modifiedStr = (str/100) * steal_pct
	caster.StrCount = (str/100) * steal_pct
	
	caster:ModifyStrength(target.modifiedStr)
	target:ModifyStrength(-target.modifiedStr)
	
	--caster:SetModifierStackCount("modifier_vader_steal_caster", ability, StrCount) какоготохуянеработает
	target:SetModifierStackCount("modifier_vader_steal", ability, target.modifiedStr)
end
function StealStrStacks(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SetModifierStackCount("modifier_vader_steal_caster", ability, caster.StrCount)

end
function ToVaderReturnStr(keys)
	local caster = keys.caster
	local target = keys.target
	caster:ModifyStrength(-target.modifiedStr)
	target:ModifyStrength(target.modifiedStr)
end
--месть
function AuraDeath( keys )
	local ability = keys.ability
	local caster = keys.caster
	local attacker = keys.attacker
	local revenge_damage = ability:GetLevelSpecialValueFor("revenge_damage", ability:GetLevel() - 1) + caster:FindTalentValue("special_bonus_memethrow_vader_6")
	local damage = attacker:GetMaxHealth()/100*revenge_damage

	local damagetable = {
		victim		= attacker,
		attacker	= caster,
		damage		= damage,
		damage_type	=  DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damagetable)
	
	caster.aura_target = attacker
end
function AuraRespawn( keys )
	local caster = keys.caster
	local modifier = keys.modifier

	caster.aura_target:RemoveModifierByName(modifier)
end
function ChekScepter(keys)
	local caster = keys.caster
	if caster:HasScepter() then
		if not caster:HasAbility("vader_star_of_the_death") then
			local abilitys = caster:AddAbility("vader_star_of_the_death")
			caster:SwapAbilities("vader_star_of_the_death", "empty_1", true, false)
			
			abilitys:SetLevel(1)
		end
	else
		caster:RemoveAbility("vader_star_of_the_death")
		caster:SwapAbilities("vader_star_of_the_death", "empty_1", false, true)
	end
end
-- удар звезды
function StarDamage(keys)
	local base_damage = keys.ability:GetLevelSpecialValueFor("damage", keys.ability:GetLevel() - 1)
	local bonus_damage = keys.ability:GetLevelSpecialValueFor("damage_pct", keys.ability:GetLevel() - 1)
	local damage = base_damage + keys.target:GetHealth() / 100 * bonus_damage
	local damagetable = {
		victim		= keys.target,
		attacker	= keys.caster,
		damage		= damage,
		damage_type	=  DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damagetable)
end
-- удушье
function FiendsGripStopSound( keys )
	local target = keys.target
	local sound = keys.sound

	StopSoundEvent(sound, target)
end
function ManaDrain( keys )	
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local mana_drain = ability:GetLevelSpecialValueFor("fiend_grip_mana_drain", (ability:GetLevel() -1)) / 100

	local max_mana_drain = target:GetMaxMana() * mana_drain
	local current_mana = target:GetMana()

	
	if current_mana >= max_mana_drain then
		caster:GiveMana(max_mana_drain)
	else
		caster:GiveMana(current_mana)
	end

	target:ReduceMana(max_mana_drain)
end
function FiendsGripInvisCheck( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier

	if target:IsInvisible() then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {})
	end
end
function Damage(keys)
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("fiend_grip_damage", ability:GetLevel() - 1) + keys.caster:FindTalentValue("special_bonus_memethrow_vader_7")
	local damagetable = {
		victim		= keys.target,
		attacker	= keys.caster,
		damage		= damage,
		damage_type	=  DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damagetable)
end