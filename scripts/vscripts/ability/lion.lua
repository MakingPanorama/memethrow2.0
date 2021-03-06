LinkLuaModifier("modifier_delay_damage", "ability/lion.lua", LUA_MODIFIER_MOTION_NONE)


-----------------------------------------------------------------------------------
-- Avada Kedavra
-----------------------------------------------------------------------------------
avada_kedavra = avada_kedavra or class({})

function avada_kedavra:GetManaCost( level )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "mana_cost_scepter" )
	end
	return self.BaseClass.GetManaCost( self, level )
end

function avada_kedavra:CastFilterResultTarget(target) -- Thx Birzha
    if IsServer() then
        local caster = self:GetCaster()

        if not caster:HasScepter() then
            if target:IsMagicImmune() then
                return UF_FAIL_MAGIC_IMMUNE_ENEMY
            end
        end

        local nResult = UnitFilter( target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber() )
        return nResult
    end
end

function avada_kedavra:OnSpellStart()
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb( self ) then return end

	EmitGlobalSound("SoundAvada")
	target:AddNewModifier(self:GetCaster(), self, "modifier_delay_damage", { duration = 1.3 })
end

--
-- Modifiers
------

modifier_delay_damage = modifier_delay_damage or class({})

function modifier_delay_damage:IsHidden() return true end
function modifier_delay_damage:IsPassive() return false end
function modifier_delay_damage:RemoveOnDeath() return true end
function modifier_delay_damage:IsPurgable() return false end

function modifier_delay_damage:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.damage_scepter = self:GetAbility():GetSpecialValueFor("damage_scepter")
end

function modifier_delay_damage:OnDestroy()
	local damage_table = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
	}
	if self:GetCaster():HasScepter() then
		damage_table.damage = self:GetParent():GetMaxHealth() * self.damage_scepter / 100
		damage_table.damage_type = DAMAGE_TYPE_PURE
	else
		damage_table.damage = self.damage
		damage_table.damage_type = DAMAGE_TYPE_MAGICAL
	end

	-- Thx Elfansoer
	local direction = ( self:GetCaster():GetOrigin() - self:GetParent():GetOrigin() ):Normalized()
	local partilce_patronium = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())

	ParticleManager:SetParticleControlEnt(partilce_patronium, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(partilce_patronium, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(partilce_patronium, 2, self:GetParent():GetOrigin())
	ParticleManager:SetParticleControl(partilce_patronium, 3, self:GetParent():GetOrigin() + direction )
	ParticleManager:SetParticleControlForward(partilce_patronium, 3, -direction)



	ParticleManager:ReleaseParticleIndex( partilce_patronium )

	ApplyDamage( damage_table )
end

function CheckTalents( keys )

	local caster = keys.caster
	local ability = keys.ability
	if caster:HasTalent("special_bonus_memethrow_volan_5") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_dark_aura_talent", {})
	end
	
	
end