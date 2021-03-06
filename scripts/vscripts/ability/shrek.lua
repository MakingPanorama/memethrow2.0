function ExtraData( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:Stop()

	ability.target = target
	ability.traveled_distance = 0
	ability.speed_traveling = 135
	ability.z = 0 
	ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
	ability.move = keys.target:GetOrigin()

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_anim_change", {})
end	

function HorizontalJump( keys )
	local caster = keys.target
	local ability = keys.ability
	local target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local distance = (target_loc - caster_loc):Length2D()
    local direction = (target_loc - caster_loc):Normalized()

 	
    if (target_loc - caster_loc):Length2D() >= 99999 then
    	caster:InterruptMotionControllers(true)
    	caster:RemoveModifierByName("modifier_anim_change")
    end

	if (target_loc - caster_loc):Length2D() > 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.speed_traveling)
        ability.traveled_distance= ability.traveled_distance + ability.speed_traveling
        caster:MoveToPosition(target:GetOrigin())
    else
        caster:InterruptMotionControllers(true)
        caster:RemoveModifierByName("modifier_anim_change")

        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
    end
    if caster:IsStunned() or caster:IsHexed() or caster:IsOutOfGame() then
    	caster:InterruptMotionControllers(true)
    	caster:RemoveModifierByName("modifier_anim_change")
    end
end

function VerticalJump( keys )
	local caster = keys.target
	local ability = keys.ability
	local target = ability.target

    local caster_loc = caster:GetAbsOrigin()
    local caster_loc_ground = GetGroundPosition(caster_loc, caster)


    if caster_loc.z <= caster_loc_ground.z then
    	caster:SetAbsOrigin(caster_loc_ground)
    end

	if ability.traveled_distance < ability.initial_distance / 2 then
		ability.z = ability.z + ability.speed_traveling / 2
		caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.z))
	elseif caster_loc.z > caster_loc_ground.z then
		ability.z = ability.z - ability.speed_traveling / 2
		caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.z))
	end
end

function GlobalSome ( keys )

	EmitGlobalSound("SoundSome")
	
end


function Damage_scepter ( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability	
		
	local dmg = ability:GetLevelSpecialValueFor("damage_scepter", ability:GetLevel() - 1 )	
		
	if caster:HasScepter() then
           ApplyDamage({victim = target, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL})
    end
        
    if caster:HasTalent("special_bonus_memethrow_shrek_2") then
        ability:ApplyDataDrivenModifier(caster, target, "modifier_boloto_deregen", nil)
    end

end

function AcidSpraySound( event )
	local target = event.target
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )

	target:EmitSound("Hero_Alchemist.AcidSpray")

	Timers:CreateTimer(duration-0.1, function() 
		target:StopSound("Hero_Alchemist.AcidSpray") 
	end)

end
---------------------------------
-- Урон от пердежа
---------------------------------
--
-- Current Ability: Shrek Make Puk :)
-------

shrek_bad_smell = shrek_bad_smell or class({})

-- Pukalka
LinkLuaModifier("modifier_pukalka", "ability/shrek.lua", LUA_MODIFIER_MOTION_NONE)

function shrek_bad_smell:GetIntrinsicModifierName()
	return "modifier_pukalka"
end

--
-- Modifiers
------

modifier_pukalka = modifier_pukalka or class({})

function modifier_pukalka:IsHidden() return true end 
function modifier_pukalka:IsPassive() return true end 
function modifier_pukalka:IsPurgable() return false end 
function modifier_pukalka:RemoveOnDeath() return true end

function modifier_pukalka:OnCreated()
	self.enabled = true

	self.damage_in_percent = self:GetAbility():GetSpecialValueFor("aura_damage")
	
	self:StartIntervalThink( 0.1 )
end

function modifier_pukalka:OnIntervalThink()
	
	if self:GetAbility():IsCooldownReady() and self:GetParent():IsAlive() and not self:GetParent():IsIllusion() then
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	if self:GetAbility():IsCooldownReady() then
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		local caster = self:GetCaster()
		self.enabled = true
        
		if #units < 1 then return end
		Timers:CreateTimer(0.2, function()
			for _,target in ipairs( units ) do
				if self:GetCaster():FindAbilityByName("special_bonus_memethrow_shrek"):GetLevel() >= 1 then
					local damage_table = {
						victim = target,
						attacker = self:GetCaster(),
						ability = self,
						damage = target:GetMaxHealth() * self.damage_in_percent / 100,
						damage_type = DAMAGE_TYPE_PURE,
						damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
					}
					ApplyDamage( damage_table )
				else
					local damage_table = {
						victim = target,
						attacker = self:GetCaster(),
						ability = self,
						damage = target:GetMaxHealth() * self.damage_in_percent / 100,
						damage_type = DAMAGE_TYPE_MAGICAL,
						damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
					}
					ApplyDamage( damage_table )
				end
			end
		end)
		self:GetAbility():UseResources(false, false, true)
		caster:EmitSound('SoundShrekPuk'..RandomInt(1, 4)) -- ION fool
		-- PRO TIP: Don't use shit code
			end	
				if caster:HasScepter() then
					local str = self:GetAbility():GetSpecialValueFor("bonus_strange_scepter")
					caster:ModifyStrength(str)
					caster.Additional_str = (caster.Additional_str or 0) + str
					local sila = caster:GetBaseStrength()
				end
	else
		self.enabled = false
	end
end

-- Datadriven must to die
-- ION can't understand copypaste is bad :(
shrek_osel_lua = class({})

function shrek_osel_lua:SpawnUnit()
	self.unit = CreateUnitByName('npc_dota_shrek_osel'..self:GetLevel(), self:GetCaster():GetAbsOrigin() + RandomVector( 150 ), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_osel_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)	
	self.unit:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
	self.unit:SetMaxHealth( self:GetSpecialValueFor('bear_hp') + self:GetCaster():FindTalentValue('special_bonus_memethrow_shrek_8') )
	self.unit:SetHealth( self.unit:GetMaxHealth() )

	for i=0, self.unit:GetAbilityCount() -1 do
		local ability = self.unit:GetAbilityByIndex( i )
		if ability then
			ability:SetLevel(1)
		end
	end

	return self.unit
end

-- Shrek: Spawn Donkey

function shrek_osel_lua:OnSpellStart()
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for from, unit in pairs( units ) do
		if unit:GetUnitName() == 'npc_dota_shrek_osel'..self:GetLevel() then
			unit:RemoveSelf()
		end
	end
	self.unit = self:SpawnUnit()
	self:GetCaster():EmitSound('SoundShrekHello')
end

function shrek_osel_lua:OnUpgrade()
	self.unit:RemoveSelf()
	self:SpawnUnit()
end

-- Осёл : доебатся
function ExtraDataD( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:Stop()

	ability.target = target
	ability.traveled_distance = 0
	ability.speed_traveling = 30
	ability.z = 0 
	ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
	ability.move = keys.target:GetOrigin()

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_anim_change", {})
end	

function GoHorizontal( keys )
	local caster = keys.target
	local ability = keys.ability
	local target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local distance = (target_loc - caster_loc):Length2D()
    local direction = (target_loc - caster_loc):Normalized()

 	
    if (target_loc - caster_loc):Length2D() >= 4000 then
    	caster:InterruptMotionControllers(true)
    	caster:RemoveModifierByName("modifier_anim_change")
    end

	if (target_loc - caster_loc):Length2D() > 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.speed_traveling)
        ability.traveled_distance= ability.traveled_distance + ability.speed_traveling
        caster:MoveToPosition(target:GetOrigin())
    else
        caster:InterruptMotionControllers(true)
        caster:RemoveModifierByName("modifier_anim_change")

        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
    end
    if caster:IsStunned() or caster:IsHexed() or caster:IsOutOfGame() then
    	caster:InterruptMotionControllers(true)
    	caster:RemoveModifierByName("modifier_anim_change")
    end
end
--
-- Current Ability: Shrek Osel ZaebaAura
------

function ZaebaAura( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local target_max_hp = target:GetMaxHealth() / 100
	local aura_damage = 2
	local aura_damage_interval = 0.2


	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = target_max_hp * aura_damage * aura_damage_interval

	ApplyDamage(damage_table)
end

-- scream lua
--
-- Current Ability: Shrek Scream
------------

shrek_scream = shrek_scream or class({})

function shrek_scream:OnSpellStart()
	local radius = self:GetSpecialValueFor("scream_radius") + self:GetCaster():FindTalentValue("special_bonus_memethrow_shrek_5")
	local duration = self:GetSpecialValueFor("scream_duration") + self:GetCaster():FindTalentValue("special_bonus_memethrow_shrek_3")
	local damage = self:GetSpecialValueFor("scream_damage") + self:GetCaster():FindTalentValue("special_bonus_memethrow_shrek_4")
	local screamer = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	local caster = self:GetCaster()
	
	local scream_particle = ParticleManager:CreateParticle("particles/queen_scream_of_pain_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())

	ParticleManager:SetParticleControl(scream_particle, PATTACH_ABSORIGIN_FOLLOW, Vector( radius, radius, 0 ))
	
	
	Timers:CreateTimer(duration, function()
		ParticleManager:DestroyParticle(scream_particle, false)
	end)
	
	for _,screamed in pairs( screamer ) do
		caster:EmitSound("SoundShrekWhat")
		screamed:AddNewModifier(self:GetCaster(), self, "modifier_screamed_custom", { duration = duration })
		ApplyDamage({
			victim = screamed,
			attacker = self:GetCaster(),
			ability = self, -- optional
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL
		})
	end
	
	
end

function VonFromBoloto ( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("von_duration")
	
	if not target:HasModifier("modifier_screamed_custom") then
	target:AddNewModifier(caster, target, "modifier_screamed_custom", { duration = duration })
	EmitGlobalSound("SoundShrekWhat")
	end
	
end

function DamageDeal ( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local duration = ability:GetLevelSpecialValueFor("stun_duration", ability:GetLevel() -1)  + caster:FindTalentValue("special_bonus_memethrow_shrek_7")
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() -1)  + caster:FindTalentValue("special_bonus_memethrow_shrek_6")
	
	local damage_table = {
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}
	ApplyDamage( damage_table )
	
	ability:ApplyDataDrivenModifier(caster, target, "modifier_stun", {duration = duration})
	ScreenShake(caster:GetCenter(), 1000, 3, 0.8, 1200, 0, true)
	
end