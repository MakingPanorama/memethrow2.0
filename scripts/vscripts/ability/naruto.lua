LinkLuaModifier("modifier_naruto_sagemode_buff", "ability/naruto.lua", LUA_MODIFIER_MOTION_NONE)
naruto_sagemode = class({})

function naruto_sagemode:GetManaCost(iLevel)
	return self.BaseClass.GetManaCost( self, iLevel)
end

function naruto_sagemode:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown( self, iLevel)
end

function naruto_sagemode:OnSpellStart()
	self.duration = self:GetSpecialValueFor("duration")
	EmitSoundOn("SoundTheme", self:GetCaster())
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_naruto_sagemode_buff", { duration = self.duration })
	
end

function naruto_sagemode:OnUpgrade()
	self.modifier = self:GetCaster():HasModifier("modifier_naruto_sagemode_buff")
	if self.modifer then
		self.modifier:ForceRefresh()
		self.modifier:SetDuration(self.modifier:GetRemainingTime(), false)
	end 
end

modifier_naruto_sagemode_buff = class({})

function modifier_naruto_sagemode_buff:IsHidden() return false end
function modifier_naruto_sagemode_buff:IsPurgable() return false end 
function modifier_naruto_sagemode_buff:IsPassive() return false end
function modifier_naruto_sagemode_buff:RemoveOnDeath() return true end
function modifier_naruto_sagemode_buff:AllowIllusionDuplicate() return false end

function modifier_naruto_sagemode_buff:OnCreated()
	self.bonus_movement_speed = self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
	self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
	self.particle = ParticleManager:CreateParticle("particles/ursa_enrage_buff2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())	
	if self:GetCaster():HasScepter() then
		self.bonus_movement_speed = self:GetAbility():GetSpecialValueFor("bonus_movement_speed_scepter")
		self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed_scepter")
		self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage_scepter")
		self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction_scepter")
	end
end
function modifier_naruto_sagemode_buff:OnDestroy()
	ParticleManager:DestroyParticle(self.particle,false)
end
function modifier_naruto_sagemode_buff:OnRefresh()
	self.bonus_movement_speed = self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
	self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
	if self:GetCaster():HasScepter() then
		self.bonus_movement_speed = self:GetAbility():GetSpecialValueFor("bonus_movement_speed_scepter")
		self.bonus_attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed_scepter")
		self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage_scepter")
		self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction_scepter")
	end
end

function modifier_naruto_sagemode_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_naruto_sagemode_buff:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_movement_speed
end

function modifier_naruto_sagemode_buff:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attack_speed
end

function modifier_naruto_sagemode_buff:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_naruto_sagemode_buff:GetModifierIncomingDamage_Percentage()
	return self.damage_reduction
end

--function modifier_naruto_sagemode_buff:GetModifierModelChange()
--	return "models/narutosage.vmdl"
--end

function CreateTimeRasengan( keys )
	keys.ability.createTime = GameRules:GetGameTime()
end

function RasenganDamage( keys )

	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local dmgmp = ability:GetLevelSpecialValueFor( "mp_damage", ability:GetLevel() - 1 ) + caster:FindTalentValue("special_bonus_memethrow_naruto_6")
	
	local damageconst = ability:GetLevelSpecialValueFor( "damage_const", ability:GetLevel() - 1 ) + caster:FindTalentValue("special_bonus_memethrow_naruto_5")
	local damage = (caster:GetMana() * (dmgmp / 100)) + damageconst
	local time = GameRules:GetGameTime() - keys.ability.createTime
	time = math.min( time / 5.5, 1 )
	print(360 * time)
	
	local damagetable = {
		victim		= target,
		attacker	= caster,
		damage		= damage * time,
		damage_type	=  DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage( damagetable )
	
	if caster:HasTalent("special_bonus_memethrow_naruto_7") then
		ability:ApplyDataDrivenModifier( caster, target, "modifier_rasengan_stun", {duration = caster:FindTalentValue("special_bonus_memethrow_naruto_7")} )
	end
	
end

naruto_gamahiro = class({})

function naruto_gamahiro:SpawnUnit()
	self.unit = CreateUnitByName('npc_dota_gamahiro'..self:GetLevel() + self:GetCaster():FindTalentValue('special_bonus_memethrow_naruto_8'), self:GetCaster():GetAbsOrigin() + RandomVector( 150 ), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_osel_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)	
	self.unit:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
	self.unit:SetHealth( self.unit:GetMaxHealth() )

	for i=0, self.unit:GetAbilityCount() -1 do
		local ability = self.unit:GetAbilityByIndex( i )
		if ability then
			ability:SetLevel(1)
		end
	end

	return self.unit
end
function naruto_gamahiro:SaveItems( hTable, unit)
	for i=0, 8 do
		local itemName = unit:GetItemInSlot(i)

		if itemName ~= nil then 
			table.insert(hTable, { name = itemName:GetAbilityName(), purchaser = itemName:GetPurchaser() })
		end
	end
	return hTable
end

-- Naruto: Summon Gamahiro

function naruto_gamahiro:OnAbilityPhaseStart()
	self:GetCaster():EmitSound('SoundJaba1')
	return true
end
function naruto_gamahiro:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound('SoundJaba1')
end

function naruto_gamahiro:OnSpellStart()
	self.savedItems = {}

	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	for from, unit in pairs( units ) do
		if unit:GetUnitName() == 'npc_dota_gamahiro'..self:GetLevel() then
			self:SaveItems( self.savedItems, unit)
			unit:RemoveSelf()
		end
	end
	self.unit = self:SpawnUnit()
	for _, item in pairs( self.savedItems ) do
		local name = item.name
		local purchaser = item.purchaser
		local item = CreateItem(name, purchaser, purchaser )
		self.unit:AddItem(item)
	end

	self.unit:EmitSound('SoundJaba2')
end

function naruto_gamahiro:OnUpgrade()
	if not self.unit then return end
	self:SaveItems( self.savedItems, self.unit )
	self.unit:RemoveSelf()
	self:SpawnUnit()

	for _, item in pairs( self.savedItems ) do
		local name = item.name
		local purchaser = item.purchaser
		local item = CreateItem(name, purchaser, purchaser )
		self.unit:AddItem(item)
	end

end

LinkLuaModifier('modifier_on_gamahiro', 'ability/naruto', LUA_MODIFIER_MOTION_NONE)
gamahiro_sit = class({})

function gamahiro_sit:GetCustomCastErrorTarget(hTarget)
	if hTarget then
		if hTarget:IsIllusion() then
			return UF_FAIL_ILLUSION
		end
		if hTarget == self:GetCaster() then
			return UF_FAIL_CUSTOM
		end
	end
	return UF_SUCCESS
end

function gamahiro_sit:GetCustomCastError()
	return "#dota_hud_error_cant_cast_on_self"
end

function gamahiro_sit:OnSpellStart()
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)

	for _, unit in pairs( units ) do
		if unit:HasModifier('modifier_on_gamahiro') then
			unit:RemoveModifierByName('modifier_on_gamahiro')
		end
	end
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, 'modifier_on_gamahiro', {})
end

modifier_on_gamahiro = class({})

function modifier_on_gamahiro:IsHidden() return true end
function modifier_on_gamahiro:OnCreated()
	self:StartIntervalThink( 0 ) 
end
function modifier_on_gamahiro:OnIntervalThink()
	self:GetParent():SetAbsOrigin( self:GetCaster():GetAbsOrigin() )
	self:GetParent():SetForwardVector( self:GetCaster():GetForwardVector() )
end
function modifier_on_gamahiro:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end
function modifier_on_gamahiro:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
end
function modifier_on_gamahiro:OnOrder(kv)
	if kv.unit == self:GetParent() then
		self:Destroy()
	end
end
function modifier_on_gamahiro:GetVisualZDelta()
	return 70
end
function modifier_on_gamahiro:GetModifierIncomingDamage_Percentage()
	return -40
end