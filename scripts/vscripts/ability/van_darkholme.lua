LinkLuaModifier('modifier_van_darkholme_cumshot_slow', 'ability/van_darkholme.lua', LUA_MODIFIER_MOTION_NONE)
van_cumshot = class({})

function van_cumshot:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasShard() then
		return 750 + 250
	end
	return 750
end

function van_cumshot:OnSpellStart()
	local target = self:GetCursorTarget()
	local sounds = {
		"SoundFuckingCumming",
		"SoundDaxGasm",
		"SoundSwallow",
		"SoundDaxGasm2",
		"SoundDaxGasm3"
	}

	local projectile = {
		Target = target,
		Source = self:GetCaster(), 
		Ability = self,
		EffectName = "particles/bristleback_viscous_nasal_goo.vpcf",
		bDodgeable = true,
		bIsAttack = true,
		iMoveSpeed = 800,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}

	ProjectileManager:CreateTrackingProjectile( projectile )
	EmitSoundOn(sounds[math.random(1,#sounds)], self:GetCaster())
end

function van_cumshot:OnProjectileHit(hTarget, vLocation)
	if hTarget:TriggerSpellAbsorb( self ) then return end
	if not hTarget:IsAlive() then return end
 
	local illusionSettings = {
			outgoing_damage = -70,
			incoming_damage = 300,
			duration = self:GetSpecialValueFor('illusion_duration')
		}
		ApplyDamage({
			victim = hTarget or self:GetCursorTarget(),
			attacker = self:GetCaster(),
			ability = self,
			damage = self:GetSpecialValueFor('damage') + self:GetCaster():FindTalentValue('special_bonus_memethrow_van'),
			damage_type = DAMAGE_TYPE_MAGICAL
		})

		hTarget:AddNewModifier(self:GetCaster(), self, 'modifier_van_darkholme_cumshot_slow', { duration = self:GetSpecialValueFor('slow_duration') + self:GetCaster():FindTalentValue('special_bonus_memethrow_van_3') })
		local illusions = CreateIllusions(self:GetCaster(), self:GetCaster(), illusionSettings, 2, 100, false, true)
		for _, illusion in pairs(illusions) do
			Timers:CreateTimer(function()
				local order = {
					UnitIndex = illusion:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = hTarget:entindex()
				}
				ExecuteOrderFromTable( order )
				return 3
			end)

			illusion:AddNewModifier(self:GetCaster(), self, 'modifier_kill', { duration = self:GetSpecialValueFor('illusion_duration') })
			FindClearSpaceForUnit(illusion, hTarget:GetAbsOrigin() + RandomVector(140), true)
		end
		if self:GetCaster():HasShard() then
			self:GetCaster():SetOrigin(illusions[1]:GetOrigin())
			illusions[1]:ForceKill(true)
			self:GetCaster():SetAggroTarget( hTarget )
			ProjectileManager:ProjectileDodge( self:GetCaster() )
		end
end

modifier_van_darkholme_cumshot_slow = class({})

function modifier_van_darkholme_cumshot_slow:IsHidden() return false end
function modifier_van_darkholme_cumshot_slow:IsPurgable() return true end
function modifier_van_darkholme_cumshot_slow:OnCreated()
	self.slow_movement = self:GetAbility():GetSpecialValueFor('slow') + self:GetCaster():FindTalentValue('special_bonus_memethrow_van_2')
end
function modifier_van_darkholme_cumshot_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end
function modifier_van_darkholme_cumshot_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow_movement
end

LinkLuaModifier('modifier_van_fisting', 'ability/van_darkholme.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_van_fisting_target', 'ability/van_darkholme.lua', LUA_MODIFIER_MOTION_NONE)

van_fisting = class({})

function van_fisting:GetChannelTime()
	return self:GetSpecialValueFor('duration')
end
function van_fisting:OnSpellStart()
	if self:GetCursorTarget():TriggerSpellAbsorb( self ) then 
		self:GetCaster():SetCursorCastTarget( self:GetCaster() )
		self:GetCaster():Stop()
		return
	end

	self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_van_fisting', { duration = 13.5 })
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, 'modifier_van_fisting_target', { duration = 13.5 })

	FindClearSpaceForUnit(self:GetCaster(), self:GetCursorTarget():GetAbsOrigin() - self:GetCursorTarget():GetForwardVector() * 100, true)
	self:GetCaster():SetForwardVector( self:GetCursorTarget():GetForwardVector() )
	self:GetCaster():EmitSound('SoundFisting1')
end
function van_fisting:OnChannelFinish( bInterrupted )
	if bInterrupted then
		self:GetCaster():RemoveModifierByName( 'modifier_van_fisting' )
		self:GetCaster():StopSound('SoundFisting1')
	end
end

modifier_van_fisting = class({})

function modifier_van_fisting:IsHidden() return true end
function modifier_van_fisting:OnDestroy()
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 9999999, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	self.level = self:GetAbility():GetLevel()

	for from, unit in pairs(units) do
		if unit:HasModifier('modifier_van_fisting_target') then
			unit:RemoveModifierByName('modifier_van_fisting_target')
			if self:GetCaster():HasAbility('van_three_hundred_backs') then
				self:GetCaster():EmitSound('SoundFisting2')
				local ability = self:GetCaster():FindAbilityByName('van_three_hundred_backs')
				self:GetCaster():SetCursorCastTarget( unit )
				ability:OnSpellStart( false )
			elseif self:GetAbility():IsStolen() then
				if self:GetCaster():HasAbility('van_three_hundred_backs') then
					self:GetCaster():RemoveAbility('van_three_hundred_backs')
				end
				self:GetCaster():AddAbility('van_three_hundred_backs')
				local ability = self:GetCaster():FindAbilityByName('van_three_hundred_backs')
				ability:SetHidden(true)
				ability:SetLevel(self.level)
				self:GetCaster():SetCursorCastTarget( unit )
				ability:OnSpellStart( false )
				self:GetCaster():RemoveAbility('van_three_hundred_backs')
			end
		end
	end
	self:GetCaster():StopSound('SoundFisting1')
end
function modifier_van_fisting:OnRemoved()
	self:Destroy()
end
function modifier_van_fisting:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true
	}
end
function modifier_van_fisting:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ORDER
	}
end
function modifier_van_fisting:OnOrder( kv )
	if kv.unit == self:GetParent() then
		self:Destroy()
	end
end

modifier_van_fisting_target = class({})

function modifier_van_fisting_target:IsHidden() return true end
function modifier_van_fisting_target:OnCreated()
	self.damage = self:GetCaster():GetSpecialAghanimValueFor(self:GetAbility():GetSpecialValueFor('damage'), self:GetAbility():GetSpecialValueFor('damage_scepter'))
	Timers:CreateTimer(function()
		if self:GetCaster():HasScepter() then
			self:GetCaster():PerformAttack(self:GetParent(), true, true, true, true, false, false, true)
			return 3.5
		end
	end)
	self:StartIntervalThink( 0.2 ) 
end
function modifier_van_fisting_target:OnIntervalThink()
	if ( self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin() ):Length2D() > 120 then
		self:GetCaster():RemoveModifierByName('modifier_van_fisting')
		self:GetCaster():InterruptChannel()
		self:Destroy()
	end

	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		ability = self:GetAbility(),
		damage = self.damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
	self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_3 )
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), 'modifier_stunned', { duration = 0.2 })
end

LinkLuaModifier('modifier_van_three_hundred_backs_slave', 'ability/van_darkholme.lua', LUA_MODIFIER_MOTION_NONE)

van_three_hundred_backs = class({})

function van_three_hundred_backs:OnSpellStart( bDamage, istealGold )
	local target = self:GetCursorTarget()
	local boolDamage = bDamage
	boolDamage = tostring(bDamage) == "nil" and true or bDamage
	local gold = istealGold or self:GetSpecialValueFor('gold')
	if target:IsRealHero() then
		if target:GetGold() >= gold then
			target:SpendGold(gold, RandomInt(0, 1))
			self:GetCaster():ModifyGold(gold, true or false, RandomInt(0, 1))
		else
			target:AddNewModifier(self:GetCaster(), self, 'modifier_van_three_hundred_backs_slave', { duration = 6 })
		end
	end

	if boolDamage then
		ApplyDamage({
			victim = target,
			attacker = self:GetCaster(),
			ability = self,
			damage = self:GetSpecialValueFor('damage'),
			damage_type = DAMAGE_TYPE_MAGICAL
		})
	end
end

modifier_van_three_hundred_backs_slave = class({})

function modifier_van_three_hundred_backs_slave:IsHidden() return false end
function modifier_van_three_hundred_backs_slave:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end
function modifier_van_three_hundred_backs_slave:GetModifierIncomingDamage_Percentage()
	return 300
end

function modifier_slark_essence_shift_datadriven_on_attack_landed(keys)
	if keys.target:IsRealHero() and keys.target:IsOpposingTeam(keys.caster:GetTeam()) and keys.caster:IsRealHero() then
		--For the affected enemy, increment their visible counter modifier's stack count.
		local previous_stack_count = 0
		if keys.target:HasModifier("modifier_slark_essence_shift_datadriven_debuff_counter") then
			previous_stack_count = keys.target:GetModifierStackCount("modifier_slark_essence_shift_datadriven_debuff_counter", keys.caster)
			
			--We have to remove and replace the modifier so the duration will refresh (so it will show the duration of the latest Essence Shift).
			keys.target:RemoveModifierByNameAndCaster("modifier_slark_essence_shift_datadriven_debuff_counter", keys.caster)
		end
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_slark_essence_shift_datadriven_debuff_counter", nil)
		keys.target:SetModifierStackCount("modifier_slark_essence_shift_datadriven_debuff_counter", keys.caster, previous_stack_count + 1)		
		
		--Apply a stat debuff to the target StatLoss number of times.  Attributes bottom out at 0, so we do not need to worry about
		--applying more debuffs than attribute points the target currently has.  This is the way the stock Essence Shift works.
		local i = 0
		local stat_loss_abs = math.abs(keys.StatLoss)
		while i < stat_loss_abs do
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_slark_essence_shift_datadriven_debuff", nil)
			i = i + 1
		end
		
		--For Slark, update his visible counter modifier's stack count and duration, and raise his Agility.  The full amount of Agility is gained
		--even if the target does not have any more attributes to steal.
		previous_stack_count = 0
		if keys.caster:HasModifier("modifier_slark_essence_shift_datadriven_buff_counter") then
			previous_stack_count = keys.caster:GetModifierStackCount("modifier_slark_essence_shift_datadriven_buff_counter", keys.caster)
			
			--We have to remove and replace the modifier so the duration will refresh (so it will show the duration of the latest Essence Shift).
			keys.caster:RemoveModifierByNameAndCaster("modifier_slark_essence_shift_datadriven_buff_counter", keys.caster)
		end
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_slark_essence_shift_datadriven_buff_counter", nil)
		keys.caster:SetModifierStackCount("modifier_slark_essence_shift_datadriven_buff_counter", keys.caster, previous_stack_count + 3)
		
		--Apply an Agility buff for Slark.
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_slark_essence_shift_datadriven_buff", nil)
	end
end


function modifier_slark_essence_shift_datadriven_debuff_on_destroy(keys)
	if keys.target:HasModifier("modifier_slark_essence_shift_datadriven_debuff_counter") then
		local previous_stack_count = keys.target:GetModifierStackCount("modifier_slark_essence_shift_datadriven_debuff_counter", keys.caster)
		if previous_stack_count > 1 then
			keys.target:SetModifierStackCount("modifier_slark_essence_shift_datadriven_debuff_counter", keys.caster, previous_stack_count - 1)
		else
			keys.target:RemoveModifierByNameAndCaster("modifier_slark_essence_shift_datadriven_debuff_counter", keys.caster)
		end
	end
end


function modifier_slark_essence_shift_datadriven_buff_on_destroy(keys)
	if keys.caster:HasModifier("modifier_slark_essence_shift_datadriven_buff_counter") then
		local previous_stack_count = keys.caster:GetModifierStackCount("modifier_slark_essence_shift_datadriven_buff_counter", keys.caster)
		if previous_stack_count > 1 then
			keys.caster:SetModifierStackCount("modifier_slark_essence_shift_datadriven_buff_counter", keys.caster, previous_stack_count - 1)
		else
			keys.caster:RemoveModifierByNameAndCaster("modifier_slark_essence_shift_datadriven_buff_counter", keys.caster)
		end
	end
end

function VanShlepok ( keys )
	
	if keys.ability:IsCooldownReady() and keys.caster:IsRealHero() then

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("bonus_damage", ability:GetLevel() - 1) + caster:FindTalentValue("special_bonus_memethrow_van_6")
	
	if caster:HasTalent("special_bonus_memethrow_van_5") then ability:ApplyDataDrivenModifier(caster, target, "modifier_microstun_shlepok", {}) end
	local damagetable = {
			victim		= target,
			attacker	= caster,
			damage		= damage,
			damage_type	=  DAMAGE_TYPE_PHYSICAL,
		}
	if caster:HasTalent("special_bonus_memethrow_van_7") then damagetable.damage_type = DAMAGE_TYPE_PURE end
	ApplyDamage(damagetable)
	local rand = RandomInt(1, 2)
	if rand == 1 then target:EmitSound("SoundAh1") end
	if rand == 2 then target:EmitSound("SoundAh2") end
	caster:RemoveModifierByName("modifier_van_shlepok_crit")
	ability:UseResources(false, false, true)
	end
	
end

function ShlepokCrit ( keys )
	
	if keys.ability:IsCooldownReady() and keys.caster:IsRealHero() and keys.caster:HasTalent("special_bonus_memethrow_van_4") then

	local caster = keys.caster
	local ability = keys.ability
	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_van_shlepok_crit", {})
	end
end