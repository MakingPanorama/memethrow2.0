LinkLuaModifier("modifier_super_illusion", "ability/soccer.lua", LUA_MODIFIER_MOTION_NONE)
soccer_call_police = class({})

function soccer_call_police:OnSpellStart()
	local target = self:GetCursorTarget()
	local angles = self:GetCaster():GetAngles()
	local iSpawnVector = {
		Vector( -100, 0, 0 ), Vector( 100, 0, 0 ), Vector( 0, 100, 0 ), Vector( 0, -100, 0 )
	}
	for i=#iSpawnVector, 2, -1 do 
		local int = RandomInt(1, i)
		iSpawnVector[i], iSpawnVector[int] = iSpawnVector[int], iSpawnVector[i]
	end


	self.illusions = {}
	for _, illusion in pairs(self.illusions) do
			if illusion and not illusion:IsNull() then
				illusion:ForceKill(false)
			end
	end

	target:AddNewModifier(self:GetCaster(), self, "modifier_rooted", { duration = self:GetSpecialValueFor("root_duration") })
	table.insert( iSpawnVector, RandomInt(1, 3 + 1), Vector(0,0,0) )

	for i=1,2 do
		local origin = self:GetCaster():GetOrigin() + table.remove( iSpawnVector, 1 )
		local unit = CreateUnitByName(self:GetCaster():GetUnitName(), origin, true, self:GetCaster(), nil, self:GetCaster():GetTeamNumber())
		unit:AddNewModifier(self:GetCaster(), self, "modifier_super_illusion", {})
		unit:SetForceAttackTarget( target )
		unit:SetAngles(angles.x, angles.y, angles.z)
		unit:SetForwardVector( self:GetCaster():GetForwardVector() )
		unit:SetControllableByPlayer(self:GetCaster():GetPlayerID(), false)


		for max=0,8 do
            local item = self:GetCaster():GetItemInSlot(max)
            if item ~= nil then
                local itemName = item:GetName()
                local newItem = CreateItem( itemName, unit, unit )
                unit:AddItem(newItem)
            end
        end
		for i=1, unit:GetAbilityCount() -1 do
			local ability = unit:GetAbilityByIndex( i )
			if ability ~= nil then
				 local abilityIllusion = unit:FindAbilityByName(ability:GetAbilityName())
               	 abilityIllusion:SetLevel( self:GetCaster():GetAbilityByIndex(i):GetLevel() )
			end
		end
		local casterLevel = self:GetCaster():GetLevel()
		for i=1,casterLevel-1 do
			unit:HeroLevelUp(false)
		end

		table.insert(self.illusions, unit)

		Timers:CreateTimer(function()
			if target:IsAlive() == false then
				unit:SetForceAttackTarget(nil)
				unit:ForceKill(false)
			end
			return 0.1
		end)
	end
	EmitSoundOn("Soccer.CallThePolice", self:GetCaster())
end

modifier_super_illusion = class({})

function modifier_super_illusion:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_IS_ILLUSION,
        MODIFIER_PROPERTY_SUPER_ILLUSION,
        MODIFIER_PROPERTY_ILLUSION_LABEL,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_ATTACK
    }
end
function modifier_super_illusion:GetModifierDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("outgoing_damage")
end
function modifier_super_illusion:OnCreated(kv)
	self:SetStackCount( self:GetAbility():GetSpecialValueFor("attacks") )
end
function modifier_super_illusion:GetIsIllusion()                                return true end
function modifier_super_illusion:GetModifierSuperIllusion()                     return true end
function modifier_super_illusion:GetModifierIllusionLabel()                     return true end
function modifier_super_illusion:OnTakeDamage(kv)
    if not IsServer() then return end
    if not kv.unit:IsAlive() then
        if kv.unit == self:GetParent() then
            kv.unit:AddNoDraw()
            kv.unit:MakeIllusion()
        end
    end
end
function modifier_super_illusion:OnAttack( kv )
	if kv.attacker == self:GetParent() then
				if self:GetStackCount() > 1 then
					self:DecrementStackCount()
				else
					self:GetParent():ForceKill( false )
				end
	end
end
function modifier_super_illusion:CheckState()
    return {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end
function modifier_super_illusion:GetStatusEffectName()
    return "particles/status_fx/status_effect_ancestral_spirit.vpcf"
end

LinkLuaModifier("modifier_delay", "ability/soccer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_infection", "ability/soccer.lua", LUA_MODIFIER_MOTION_NONE)

soccer_drop_bottle = class({})

function soccer_drop_bottle:OnSpellStart()
	if not IsServer() then return end
	local target = self:GetCursorTarget()
	local projectile = {
		Source = self:GetCaster(),
		Ability = self,
		Target = target,
		EffectName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile.vpcf",
		bDodgeable = true,
		iMoveSpeed = 580,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}

	EmitSoundOn("Soccer.TakeUrine", self:GetCaster())
	if target == self:GetCaster() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_delay", { duration = self:GetSpecialValueFor("delay") })
	else
		ProjectileManager:CreateTrackingProjectile( projectile )
	end
end

function soccer_drop_bottle:OnProjectileHit(hTarget, vLocation)
	if hTarget:TriggerSpellAbsorb( self ) then return end
	hTarget:AddNewModifier(self:GetCaster(), self, "modifier_delay", { duration = self:GetSpecialValueFor("delay") })
end

modifier_delay = class({})

function modifier_delay:IsHidden() return true end
function modifier_delay:OnDestroy()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_infection", { duration = self:GetAbility():GetSpecialValueFor("infect_duration") })
	end
end

modifier_infection = class({})

function modifier_infection:IsPurgable() return true end
function modifier_infection:OnCreated()
	self:StartIntervalThink( 1 )
end
function modifier_infection:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end
function modifier_infection:OnIntervalThink()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then return end
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		ability = self:GetAbility(),
		damage = self:GetAbility():GetSpecialValueFor("damage_per_second"),
		damage_type = DAMAGE_TYPE_MAGICAL
	})
end
function modifier_infection:GetModifierAttackSpeedBonus_Constant()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return self:GetAbility():GetSpecialValueFor("attack_speed")
	end
	return self:GetAbility():GetSpecialValueFor("attack_speed") * ( -1 )
end
function modifier_infection:GetModifierMoveSpeedBonus_Percentage()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return self:GetAbility():GetSpecialValueFor("movespeed_percent")
	end
	return self:GetAbility():GetSpecialValueFor("movespeed_percent") * ( -1 )
end

LinkLuaModifier("modifier_soccer_ball_impact", "ability/soccer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_soccer_invulnerable", "ability/soccer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_soccer_model_change", "ability/soccer.lua", LUA_MODIFIER_MOTION_NONE) -- Change model pangoiler ball to custom
soccer_ball = class({})

function soccer_ball:OnSpellStart()
	if not IsServer() then return end

	local duration = self:GetSpecialValueFor("duration")
	local tick_interval = self:GetSpecialValueFor("tick_interval")
	local forward_move_speed = self:GetSpecialValueFor("forward_move_speed")
	local turn_rate_boosted = self:GetSpecialValueFor("turn_rate_boosted")
	local turn_rate = self:GetSpecialValueFor("turn_rate")
	local radius = self:GetSpecialValueFor("radius")
	local hit_radius = self:GetSpecialValueFor("hit_radius")
	local bounce_duration = self:GetSpecialValueFor("bounce_duration")
	local stun_duration = self:GetSpecialValueFor("stun_duration")
	local knockback_radius = self:GetSpecialValueFor("knockback_radius")
	local ability_duration = self:GetSpecialValueFor("duration")
	local jump_recover_time = self:GetSpecialValueFor("jump_recover_time")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pangolier_gyroshell", { duration = duration })
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_soccer_ball_impact", { duration = duration })
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_soccer_invulnerable", { duration = duration })
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_soccer_model_change", { duration = duration })

	self:GetCaster():EmitSound("Soccer.Ball")
end

modifier_soccer_ball_impact = class({})

function modifier_soccer_ball_impact:OnCreated()
	if not IsServer() then return end
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self:StartIntervalThink(0.05)
end
function modifier_soccer_ball_impact:OnIntervalThink()
	if not IsServer() then return end
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

	for _,enemy in pairs(units) do
			if not enemy:HasModifier("modifier_pangolier_gyroshell_timeout") then
				ApplyDamage({
					victim = enemy,
					attacker = self:GetCaster(),
					ability = self:GetAbility(),
					damage = self.damage,
					damage_type = DAMAGE_TYPE_MAGICAL
				})
			end
	end
end

modifier_soccer_invulnerable = class({})

function modifier_soccer_invulnerable:IsHidden() return true end
function modifier_soccer_invulnerable:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
end

modifier_soccer_model_change = class({})

function modifier_soccer_model_change:IsHidden() return true end
function modifier_soccer_model_change:OnCreated()
	if not IsServer() then return end
	self:GetParent():StartGesture( ACT_DOTA_IDLE )
	self:GetParent():SetModelScale( 4.3 )
end
function modifier_soccer_model_change:OnDestroy()
	if not IsServer() then return end
	self:GetParent():FadeGesture( ACT_DOTA_IDLE )
	self:GetParent():StartGesture( ACT_DOTA_CAST_ABILITY_4 )
	self:GetParent():SetModelScale( 1.0 )
end
function modifier_soccer_model_change:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}
end
function modifier_soccer_model_change:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end
function modifier_soccer_model_change:GetModifierModelChange()
	return "models/props_gameplay/soccer_ball.vmdl"
end

LinkLuaModifier("modifier_provocated", "ability/soccer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_provocated_caster", "ability/soccer.lua", LUA_MODIFIER_MOTION_NONE)
soccer_provocation = class({})

function soccer_provocation:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasShard() then
		return 450 + self:GetCaster():GetCastRangeBonus()
	end
	return 250 + self:GetCaster():GetCastRangeBonus()
end
function soccer_provocation:OnSpellStart()
	local radius = self:GetCastRange()
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	local duration = self:GetSpecialValueFor("duration")
	for _,enemy in pairs(units) do
		if #units < 1 then return end
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_provocated", { duration = duration })
	end

	local sounds = {
		"Soccer.Provocate",
		"Soccer.Provocate2",
		"Soccer.Provocate3",
		"Soccer.Provocate4",
		"Soccer.Provocate5"
	}

	local effectName = "particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf"
	if self:GetCaster():HasShard() then
		effectName = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_call.vpcf"
	end

	local particle = ParticleManager:CreateParticle(effectName, PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(particle, 1, Vector( radius, radius, radius ))
	ParticleManager:SetParticleControl(particle, 2, Vector( radius, radius, radius ))

	self:GetCaster():EmitSound(sounds[math.random(1,#sounds)])
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_provocated_caster", { duration = duration })
end

modifier_provocated = class({})

function modifier_provocated:IsHidden() return true end
function modifier_provocated:OnCreated(kv)
	self.incoming_damage_percentage = self:GetAbility():GetSpecialValueFor("damage_reduction")
	self:StartIntervalThink( 0.01 )
end
function modifier_provocated:OnIntervalThink()
	if not self:GetCaster():IsAlive() then
		self:Destroy()
	else
		self:GetParent():SetForceAttackTarget( nil )
		self:GetParent():SetForceAttackTarget( self:GetCaster() )

		local order = {
			UnitIndex = self:GetParent():entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = self:GetCaster():entindex()
		}

		ExecuteOrderFromTable( order )
	end
end
function modifier_provocated:OnDestroy()
	self:GetParent():SetForceAttackTarget( nil )
	self:GetParent():Stop()
end

modifier_provocated_caster = class({})

function modifier_provocated_caster:OnCreated(kv)
	self.bonus_per_unit = self:GetAbility():GetSpecialValueFor("bonus_per_unit")
	self.base_physical_armor = self:GetAbility():GetSpecialValueFor("base_armor_bonus")
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	self.totalPhysicalArmor = self.base_physical_armor + #units * self.bonus_per_unit
	self:SetStackCount( self.totalPhysicalArmor )

end
function modifier_provocated_caster:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end
function modifier_provocated_caster:GetModifierPhysicalArmorBonus()
	return self:GetStackCount()
end