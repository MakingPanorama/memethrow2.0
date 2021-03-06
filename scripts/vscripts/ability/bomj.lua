bomj_zabuhal = bomj_zabuhal or class({})

LinkLuaModifier("modifier_zabuhal_think", "ability/bomj.lua", LUA_MODIFIER_MOTION_NONE)

AbilityKV = LoadKeyValues( "scripts/npc/npc_abilities_custom.txt" )

function bomj_zabuhal:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local zabuhal = AbilityKV[self:GetName()]["AbilityCastSound"]
	self.zabuhalTarget = AbilityKV[self:GetName()]["AbilityCastSound_Target"]

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)

	for _,unit in pairs( units ) do
		local projectile = {
			Source = caster,
			Ability = self,
			Target = unit,
			iMoveSpeed = 880,
			bDodgeable = true,
			bProvidesVision = false
		}
		ProjectileManager:CreateTrackingProjectile( projectile )
	end

	EmitSoundOn(zabuhal, target)
end

function bomj_zabuhal:OnProjectileHit(hTarget, vLocation)
	if hTarget:TriggerSpellAbsorb( self ) then return end

	if hTarget ~= nil then
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_zabuhal_think", { duration = self:GetSpecialValueFor("duration") })
	end
end

function bomj_zabuhal:OnUpgrade()
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)

	for _,unit in pairs( units ) do 
		if unit:HasModifier("modifier_zabuhal_think") then
			unit:FindModifierByName("modifier_zabuhal_think"):ForceRefresh()
		end
	end
end

modifier_zabuhal_think = modifier_zabuhal_think or class({})

function modifier_zabuhal_think:IsHidden() return false end
function modifier_zabuhal_think:IsPurgable() return true end
function modifier_zabuhal_think:GetAttributes() return MODIFIER_ATTRIBUTE_NONE end

function modifier_zabuhal_think:OnCreated()
	local ability = self:GetAbility()
	self.damage_per_second = ability:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_memethrow_bomj_2")
	self.miss_percentage = ability:GetSpecialValueFor("miss_chance")  + self:GetCaster():FindTalentValue("special_bonus_memethrow_bomj_2")
	self.movement_speed_slow = ability:GetSpecialValueFor("movement_slow")

	self:StartIntervalThink( 1.0 )
end

function modifier_zabuhal_think:OnRefresh()
	local ability = self:GetAbility()
	self.damage_per_second = ability:GetSpecialValueFor("damage") + self:GetCaster():FindTalentValue("special_bonus_memethrow_bomj_2")
	self.miss_percentage = ability:GetSpecialValueFor("miss_chance") + self:GetCaster():FindTalentValue("special_bonus_memethrow_bomj_2")
	self.movement_speed_slow = ability:GetSpecialValueFor("movement_slow")

	self:StartIntervalThink( 1.0 )
end

function modifier_zabuhal_think:OnIntervalThink()
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		ability = self:GetAbility(),
		damage = self.damage_per_second,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
end

function modifier_zabuhal_think:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_zabuhal_think:GetModifierMiss_Percentage()
	return self.miss_percentage
end

function modifier_zabuhal_think:GetModifierMoveSpeedBonus_Percentage()
	return self.movement_speed_slow
end

--BOMJ PEREGAR
function DamageDeal( keys )

	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local damage = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 ) +  caster:FindTalentValue("special_bonus_memethrow_bomj")
	
	local damagetable = {
		victim		= target,
		attacker	= caster,
		damage		= damage,
		damage_type	=  DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage( damagetable )

end

-- JINADA
function JinadaStart(keys)

	local ability = keys.ability
    local level = ability:GetLevel() - 1
    local cooldown = ability:GetCooldown(level)
    local caster = keys.caster
	local target = keys.target
    local modifier = keys.modifier
	
	local get_gold = (target:GetGold() * keys.GetGoldSelf / 100)
	local steal_gold = 0 - get_gold
	
		if caster:HasScepter() then
			local steal_gold = 0 - (target:GetGold() * keys.StealGoldScepter / 100)
			local get_gold = (target:GetGold() * keys.GetGoldScepter / 100)
		end
		
    local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
   
   if caster:IsRealHero() then
	  if target:IsRealHero() then
        ability:StartCooldown(cooldown)
        target:ModifyGold(steal_gold, true, 1)
        caster:ModifyGold(get_gold, true, 1)
		print("Enemy has " ..keys.target:GetGold())
        caster:RemoveModifierByName(modifier)
        ParticleManager:SetParticleControlEnt(midas_particle, 1, keys.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.caster:GetAbsOrigin(), false)
        keys.target:EmitSound("Hero_BountyHunter.Jinata")
        keys.target:EmitSound("DOTA_Item.Hand_Of_Midas")
		 print("You get gold" ..steal_gold)
    end
		else caster:RemoveModifierByName(modifier)
  end
    if target:IsCreep() then
        caster:RemoveModifierByName(modifier)
        keys.target:EmitSound("Hero_BountyHunter.Jinada")
        ability:StartCooldown(cooldown)
        ParticleManager:DestroyParticle(midas_particle, true)
    end
    Timers:CreateTimer(cooldown, function()
        ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
        end)
end