russian_sergey_home = russian_sergey_home or class({})

AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

function russian_sergey_home:OnSpellStart()
	local target = self:GetCursorTarget()

	if not target == self:GetCaster() then
		if target:TriggerSpellAbsorb( self ) then return end
	end

	local units = FindUnitsInRadius(target:GetTeamNumber(), Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)

	for _,unit in pairs(units) do
		if unit:GetClassname() == "ent_dota_fountain" then
			FindClearSpaceForUnit(target, unit:GetAbsOrigin(), true)
			EmitGlobalSound(AbilityKV[self:GetName()]["AbilityCastSound"])
		end
	end
end



--------------------------------------
-- Heal Хил залечить рану
----------------------------------------
function Heal( keys )

	local caster = keys.caster
	local ability = keys.ability
	local heal = ability:GetLevelSpecialValueFor("heal", ability:GetLevel() -1)

	
	if caster:HasTalent("special_bonus_memethrow_serega") then 
	heal = 1
	end
	
	local regen = caster:GetMaxHealth() * heal
	
	local rand = RandomFloat(1, 40)
	
	if (rand >=1 and rand <= 10) then
				caster:EmitSound("SoundHeal1")
		elseif (rand >10 and rand <= 20) then
				caster:EmitSound("SoundHeal2")
		elseif (rand >20 and rand <= 30) then
				caster:EmitSound("SoundHeal3")
		elseif (rand >30 and rand <= 40) then
				caster:EmitSound("SoundHeal4")
	end
	caster:Heal(regen, caster)
	
end

-------------------------------------------
-- Что это за слово
-------------------------------------------

russian_sergey_what_is_this_word = russian_sergey_what_is_this_word or class({})
LinkLuaModifier("modifier_reflector", "ability/serega.lua", LUA_MODIFIER_MOTION_NONE)

function russian_sergey_what_is_this_word:GetIntrinsicModifierName()
	return "modifier_reflector"
end

function russian_sergey_what_is_this_word:GetCooldown(ilevel)
	if self:GetCaster():HasScepter() then
		return 5
	end

	return self.BaseClass.GetCooldown( self, ilevel )
end

local function SpellReflect(parent, params)
	-- If some spells shouldn't be reflected, enter it into this spell-list
	local exception_spell = {
		["rubick_spell_steal"] = true,
		["duel_datadriven"] = true,
	}

	local reflected_spell_name = params.ability:GetAbilityName()
	local target = params.ability:GetCaster()

	-- Does not reflect allies' projectiles for any reason
	if target:GetTeamNumber() == parent:GetTeamNumber() then
		return nil
	end

	-- FOR NOW, UNTIL LOTUS ORB IS DONE
	-- Do not reflect spells if the target has Lotus Orb on, otherwise the game will die hard.
	if target:HasModifier("modifier_item_lotus_orb_active") or target:HasModifier("modifier_item_mirror_shield") then
		return nil
	end

	if ( not exception_spell[reflected_spell_name] ) then

		-- If this is a reflected ability, do nothing
		if params.ability.spell_shield_reflect then
			return nil
		end

		local reflect_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(reflect_pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(reflect_pfx)

		local old_spell = false
		for _,hSpell in pairs(parent.tOldSpells) do
			if hSpell ~= nil and hSpell:GetAbilityName() == reflected_spell_name then
				old_spell = true
				break
			end
		end
		if old_spell then
			ability = parent:FindAbilityByName(reflected_spell_name)
		else
			ability = parent:AddAbility(reflected_spell_name)
			ability:SetStolen(true)
			ability:SetHidden(true)

			-- Tag ability as a reflection ability
			ability.spell_shield_reflect = true

			-- Modifier counter, and add it into the old-spell list
			ability:SetRefCountsModifiers(true)
			table.insert(parent.tOldSpells, ability)
		end

		ability:SetLevel(params.ability:GetLevel())
		-- Set target & fire spell
		parent:SetCursorCastTarget(target)
		ability:OnSpellStart()
		
		-- This isn't considered vanilla behavior, but at minimum it should resolve any lingering channeled abilities...
		if ability.OnChannelFinish then
			ability:OnChannelFinish(false)
		end	
	end

	return false
end

--
-- Modifiers
---------

-- Modifier Reflector
modifier_reflector = modifier_reflector or class({})

function modifier_reflector:IsHidden() return true end function modifier_reflector:IsPassive() return true end function modifier_reflector:IsPurgable() return false end

function modifier_reflector:OnCreated()
	self.magic_resist = self:GetAbility():GetSpecialValueFor("magic_resistance") -- Magic Resistance
	self.chance_reflect = self:GetAbility():GetSpecialValueFor("chance") -- Chance reflect

	AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

	self:GetParent().tOldSpells = {} -- Table

	self:StartIntervalThink( FrameTime() )
end

function modifier_reflector:OnRefresh()
	self.magic_resist = self:GetAbility():GetSpecialValueFor("magic_resistance")
end

function modifier_reflector:DeclareFunctions()
	local decFunc = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_ABSORB_SPELL,
		MODIFIER_PROPERTY_REFLECT_SPELL
	}
	return decFunc
end

function modifier_reflector:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_reflector:GetAbsorbSpell( params )
	if IsServer() then
	if self:GetCaster():IsRealHero() then
		if ( not self:GetParent():PassivesDisabled()) and self:GetAbility():IsFullyCastable() or self:GetAbility():IsCooldownReady() then
			-- use resources
			self:GetAbility():UseResources( false, false, true )

			self:PlayEffects( true )

			EmitSoundOn(AbilityKV[self:GetAbility():GetName()]["AbilityCastSound"], self:GetCaster())
			return 1
		end
	end
	end
end




modifier_reflector.reflected_spell = nil
function modifier_reflector:GetReflectSpell( params )
	if self:GetCaster():IsRealHero() then
	if self:GetAbility():IsCooldownReady() and self:GetCaster():IsRealHero() then
		return SpellReflect(self:GetParent(), params)
	end
	end
end

function modifier_reflector:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		for i=#caster.tOldSpells,1,-1 do
			local hSpell = caster.tOldSpells[i]
			if hSpell:NumModifiersUsingAbility() == 0 and not hSpell:IsChanneling() then
				hSpell:RemoveSelf()
				table.remove(caster.tOldSpells,i)
			end
		end
	end
end

--------------------------------------------------------------------------------
function modifier_reflector:PlayEffects( bBlock )
	-- Get Resources
	if self:GetCaster():IsRealHero() then
	local particle_cast = ""

	if bBlock then
		particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield.vpcf"
	else
		particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf"
	end

	-- Play particles
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Play sounds
	EmitSoundOn( sound_cast, self:GetParent() )
	end
end

modifier_reflector.reflect_exceptions = {
	["rubick_spell_steal_lua"] = true
}


--------------------------------------
-- Vsego Horoshego
--------------------------------------

function Von( event ) -- всего хорошего
	local caster = event.caster
	local attacker = event.attacker
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor("duration_fear", ability:GetLevel() -1) + caster:FindTalentValue("special_bonus_memethrow_serega_5")
	local chance = ability:GetLevelSpecialValueFor("triger_chance", ability:GetLevel() -1) + caster:FindTalentValue("special_bonus_memethrow_serega_2")
	local damage = ability:GetLevelSpecialValueFor( "damage" , ability:GetLevel() - 1  )
	local damageType = ability:GetAbilityDamageType()
		

	local rand = math.random(1, 100)
	if rand <= chance then
		
	if caster:IsRealHero() and not attacker:IsMagicImmune() then
		if caster:HasTalent("special_bonus_memethrow_serega_3") then
		ApplyDamage({ victim = attacker, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
		else ApplyDamage({ victim = attacker, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL })
		end
				caster:EmitSound("SoundVsegoHoroshego")
				ApplyFearCustomModifier( caster, attacker, ability, duration )
		end
	end
	
end

sergey_krik = class({})

LinkLuaModifier("modifier_scream_debuff", "ability/serega.lua", LUA_MODIFIER_MOTION_NONE)

function sergey_krik:GetManaCost( level )
	return self.BaseClass.GetManaCost( self, level )
end

function sergey_krik:GetCooldown( level )
	return self.BaseClass.GetCooldown( self, level )
end

function sergey_krik:GetAbilityDamage()
	return self.BaseClass.GetAbilityDamage( self )
end

function sergey_krik:GetCastPoint()
	return self.BaseClass.GetCastPoint( self )
end

function sergey_krik:GetCastRange(vLocation, hTarget)
	return self.BaseClass.GetCastRange( self, vLocation, hTarget )
end

function sergey_krik:OnSpellStart()
	local pos = self:GetCursorTarget():GetAbsOrigin()
	local cas_pos = self:GetCaster():GetAbsOrigin()
	local knockbackProperties = {
		center_x = cas_pos.x,
		center_y = cas_pos.y,
		center_z = cas_pos.z,
		duration = 0.6,
		knockback_duration = 0.6,
		knockback_distance = self:GetSpecialValueFor("push_distance"),
		knockback_height = 0
	}

	local scream_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_primal_roar.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	local endOrigin = pos + self:GetCaster():GetForwardVector() * 200
	endOrigin = GetGroundPosition(endOrigin, nil)
	endOrigin.z = endOrigin.z + 92
	ParticleManager:SetParticleControlEnt(scream_particle, 0, self:GetCaster(), PATTACH_ABSORIGIN, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(scream_particle, 1, nil, PATTACH_ABSORIGIN, "attach_hitloc", endOrigin, true)
	local sound = 'SoundSKrik'..RandomInt(1, 5)
	
	self:GetCaster():EmitSound(sound)

	local units = FindUnitsInLine(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), endOrigin, nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0)
	for _,unit in pairs(units) do
		if unit:HasModifier("modifier_knockback") then
			unit:RemoveModifierByName("modifier_knockback")
		end

		unit:AddNewModifier(self:GetCaster(), self, "modifier_knockback", knockbackProperties)
		unit:AddNewModifier(self:GetCaster(), self, "modifier_scream_debuff", { duration = self:GetSpecialValueFor("duration") })
		unit:AddNewModifier(self:GetCaster(), self, "modifier_stunned", { duration = self:GetSpecialValueFor("slow_duration")  })

		local damage_table = {
			victim = unit,
			attacker = self:GetCaster(),
			ability = self,
			damage = self:GetSpecialValueFor("damage")
		}
		if unit == self:GetCursorTarget() then
			unit:RemoveModifierByName("modifier_knockback")
		elseif unit then
			unit:RemoveModifierByName("modifier_stunned")
			damage_table.damage = self:GetSpecialValueFor('damage') / 2
		end



		if self:GetCaster():HasTalent("special_bonus_unique_silencer_4") then
			damage_table.damage_type = DAMAGE_TYPE_PURE
		else
			damage_table.damage_type = self.BaseClass.GetAbilityDamageType( self )
		end


		ApplyDamage( damage_table )
	end
end

modifier_scream_debuff = class({})

function modifier_scream_debuff:IsHidden() return false end
function modifier_scream_debuff:IsPassive() return false end
function modifier_scream_debuff:IsPurgable() return true end
function modifier_scream_debuff:RemoveOnDeath() return true end

function modifier_scream_debuff:OnCreated()
	self.movespeed_slow = self:GetAbility():GetSpecialValueFor("slow_movement_speed_pcts")
	self.attackspeed_slow = self:GetAbility():GetSpecialValueFor("slow_attack_speed_pct")
end

function modifier_scream_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_scream_debuff:GetModifierMoveSpeedBonus_Constant()
	return self.movespeed_slow
end
function modifier_scream_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed_slow
end



