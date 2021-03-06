item_satans_armor = item_satans_armor or class({})

AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

LinkLuaModifier('modifier_satans_armor_passive', 'items/item_satans_armor.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_satans_armor_active', 'items/item_satans_armor.lua', LUA_MODIFIER_MOTION_NONE)

function item_satans_armor:GetIntrinsicModifierName()
	return "modifier_satans_armor_passive"
end

function item_satans_armor:GetAbilityTextureName()
	return "demonic_armor"
end

function item_satans_armor:OnSpellStart()
	local radius = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_satans_armor_active", { duration = self:GetSpecialValueFor('duration') })
	
	local caster = self:GetCaster()
	local caster_loc = caster:GetAbsOrigin()
	local active_radius = self:GetSpecialValueFor("active_radius")
	local cast_pfx = ParticleManager:CreateParticle("particles/items2_fx/vanguard_active_launch.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(cast_pfx, 0, caster_loc)
	ParticleManager:SetParticleControl(cast_pfx, 1, caster_loc)
	ParticleManager:SetParticleControl(cast_pfx, 2, Vector(active_radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(cast_pfx)
	
	self:GetCaster():EmitSound("SoundDemonic")
	for _,units in pairs(radius) do
		units:AddNewModifier(self:GetCaster(), self, "modifier_satans_armor_active", { duration = self:GetSpecialValueFor('duration') })
	end
end

modifier_satans_armor_passive = modifier_satans_armor_passive or class({})

function modifier_satans_armor_passive:IsHidden() return true end 
function modifier_satans_armor_passive:IsPassive() return true end 
function modifier_satans_armor_passive:IsPurgable() return false end
function modifier_satans_armor_passive:RemoveOnDeath() return false end

function modifier_satans_armor_passive:OnCreated()
	self.health_regen_bonus = self:GetAbility():GetSpecialValueFor('health_regen_bonus')
	self.health_bonus = self:GetAbility():GetSpecialValueFor('bonus_health')
	self.armor_bonus = self:GetAbility():GetSpecialValueFor('armor_bonus')
	self.attack_damage_bonus = self:GetAbility():GetSpecialValueFor('attack_damage_bonus')
	-- для бма
	self.parent = self:GetParent()
	self.return_damage = self:GetAbility():GetSpecialValueFor("passive_return_damage")
	self.return_damage_pct = self:GetAbility():GetSpecialValueFor("passive_return_damage")
	-- блок урона
	self.block_passive = self:GetAbility():GetSpecialValueFor("block_passive")
	self.block_chance = self:GetAbility():GetSpecialValueFor("block_chance")
end

function modifier_satans_armor_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
	}
end

function modifier_satans_armor_passive:GetModifierHealthBonus()
	return self.health_bonus
end
function modifier_satans_armor_passive:GetModifierConstantHealthRegen()
	return self.health_regen_bonus
end
function modifier_satans_armor_passive:GetModifierPhysicalArmorBonus()
	return self.armor_bonus
end
function modifier_satans_armor_passive:GetModifierPreAttack_BonusDamage()
	return self.attack_damage_bonus
end

function modifier_satans_armor_passive:GetModifierPhysical_ConstantBlock()

local rand = math.random(1, 100)

if rand <= self.block_chance then
	return self.block_passive
end

end

function modifier_satans_armor_passive:OnTakeDamage(params)
	if not IsServer() then return end

	if params.unit == self:GetParent() and not params.attacker:IsBuilding() and params.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION and params.damage_type == 1 then
		local damage = self.return_damage + (params.damage / 100 * self.return_damage_pct)
		print("Return damage:", damage)
		ApplyDamage({
			victim = params.attacker,
			attacker = params.unit,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		})
	end
end

-----------
---Активка
-----------
modifier_satans_armor_active = modifier_satans_armor_active or class({})

function modifier_satans_armor_active:IsHidden() return false end function modifier_satans_armor_active:IsPassive() return false end function modifier_satans_armor_active:IsPurgable() return false end
function modifier_satans_armor_active:GetAbilityTextureName() return "demonic_armor" end

function modifier_satans_armor_active:OnCreated()

	self.active_armor = self:GetAbility():GetSpecialValueFor('armor_bonus_active')
	self.block_damage = -66.6
	self.active_return = self:GetAbility():GetSpecialValueFor('active_return_damage')
	self.block_active = self:GetAbility():GetSpecialValueFor("block_active")
	
end

function modifier_satans_armor_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_satans_armor_active:OnTakeDamage(keys)
	if not IsServer() then return end
	
	local attacker = keys.attacker
	local target = keys.unit
	local original_damage = keys.original_damage
	local damage_type = keys.damage_type
	local damage_flags = keys.damage_flags

	if keys.unit == self:GetParent() and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then		
	local damage = keys.damage / 100 * self.active_return
		print("Return damage active:", damage)
		ApplyDamage({
				victim			= keys.attacker,
				damage			= keys.original_damage,
				damage_type		= keys.damage_type,
				damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				attacker		= self:GetParent(),
				ability			= self:GetAbility()
		})
	end

end

function modifier_satans_armor_active:GetModifierPhysicalArmorBonus()
	return self.active_armor
end

function modifier_satans_armor_active:GetModifierIncomingDamage_Percentage()
	return self.block_damage
end

function modifier_satans_armor_active:GetEffectName()
	return "particles/blademail.vpcf"
end

