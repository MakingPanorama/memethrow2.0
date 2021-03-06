--
-- Current Ability: Scorpion Crash
---------

scorpion_crash = scorpion_crash or class({})
LinkLuaModifier("modifier_chance_crash", "ability/scorpion_abilities.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_crashed", "ability/scorpion_abilities.lua", LUA_MODIFIER_MOTION_NONE)


function scorpion_crash:GetIntrinsicModifierName()
	return "modifier_chance_crash"
end

--
-- Modifiers
---------

modifier_chance_crash = modifier_chance_crash or class({})

function modifier_chance_crash:IsPassive() return true end
function modifier_chance_crash:IsHidden() return true end
function modifier_chance_crash:RemoveOnDeath() return false end
function modifier_chance_crash:IsPurgable() return false end

function modifier_chance_crash:OnCreated()
end

function modifier_chance_crash:OnIntervalThink()
end

function modifier_chance_crash:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_chance_crash:OnAttackLanded( kv )
	local ability = self:GetAbility()
	self.chance = ability:GetLevelSpecialValueFor("chance", ability:GetLevel() -1) + kv.attacker:FindTalentValue("special_bonus_memethrow_scorpion_3")
	self.damage = ability:GetLevelSpecialValueFor("crash_damage", ability:GetLevel() -1) + kv.attacker:FindTalentValue("special_bonus_memethrow_scorpion")
	self.duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() -1)
	if kv.attacker == self:GetParent() then
	local rand = math.random(1, 100)
	
	local damage_table = {
		victim = kv.target,
		attacker = kv.attacker,
		damage = self.damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	}
	
	if kv.attacker:HasTalent("special_bonus_memethrow_scorpion_2") then
		damage_table.damage_type = DAMAGE_TYPE_PURE
	end
		if rand <= self.chance then
			kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_crashed", { duration = self.duration  })
			kv.target:EmitSound("SoundCrush")
			ApplyDamage( damage_table )
		end
	end
end

modifier_crashed = modifier_crashed or class({})

function modifier_crashed:IsPassive() return true end
function modifier_crashed:IsHidden() return false end
function modifier_crashed:RemoveOnDeath() return false end
function modifier_crashed:IsPurgable() return false end

function modifier_crashed:OnCreated()
	local ability = self:GetAbility()
	self.slow_movespeed = ability:GetLevelSpecialValueFor("slow_movespeed", ability:GetLevel() -1)
	self.slow_attackspeed = ability:GetLevelSpecialValueFor("slow_attackspeed", ability:GetLevel() -1)
	
end

function modifier_crashed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_crashed:GetModifierMoveSpeedBonus_Constant()
	return self.slow_movespeed
end

function modifier_crashed:GetModifierAttackSpeedBonus_Constant() 
	return self.slow_attackspeed 
end

--
-- Current Ability: Scorpion Teleport(Aghanim)
------

scorpion_teleport = scorpion_teleport or class({})

function scorpion_teleport:OnInventoryContentsChanged()
	if self:GetCaster():HasShard() then
		self:SetHidden( false )
		self:SetLevel( 1 )
	else
		self:SetHidden( true )
		self:SetLevel( 1 )
	end
end


function scorpion_teleport:OnSpellStart()
	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber() , self:GetCaster():GetAbsOrigin(), nil, 1100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	local ability = self:GetCaster():FindAbilityByName("scorpion_teleport")
	if #units ~= nil then 
		FindClearSpaceForUnit(self:GetCaster(), units[1]:GetAbsOrigin() - units[1]:GetForwardVector() * 100, false)
		ParticleManager:CreateParticle("particles/clinkz_windwalk.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:CreateParticle("particles/clinkz_windwalk.vpcf", PATTACH_ABSORIGIN_FOLLOW,units[1])	
		self:GetCaster():EmitSound("SoundTeleport")
	end
	--print("unit near"..#units)
end