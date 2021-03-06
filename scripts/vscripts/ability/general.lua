LinkLuaModifier("modifier_resist", "modifiers/modifier_resist.lua", LUA_MODIFIER_MOTION_NONE)

function patriotizm( keys )
	
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() -1)
	-- аганим
		if caster:HasScepter() then
			caster:EmitSound("SoundAnthem2")
			duration = ability:GetLevelSpecialValueFor("duration_scepter", ability:GetLevel() -1)
		else caster:EmitSound("SoundAnthem1")
		end
	-- талант
	

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_patriot", {duration = duration})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_degen_aura", {duration = duration})
	
		if caster:HasTalent("special_bonus_memethrow_jmishenko_8") then
		caster:AddNewModifier(caster, ability, "modifier_resist", { duration = duration })
		end
	
end

function LandMinesPlant( keys )
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Initialize the count and table
	caster.land_mine_count = caster.land_mine_count or 0
	caster.land_mine_table = caster.land_mine_table or {}

	-- Modifiers
	local modifier_land_mine = keys.modifier_land_mine
	local modifier_tracker = keys.modifier_tracker
	local modifier_caster = keys.modifier_caster
	local modifier_land_mine_invisibility = keys.modifier_land_mine_invisibility

	-- Ability variables
	local activation_time = ability:GetLevelSpecialValueFor("activation_time", ability_level) 
	local max_mines = ability:GetLevelSpecialValueFor("max_mines", ability_level) + caster:FindTalentValue('special_bonus_memethrow_jmishenko_4')
	
	
	local fade_time = ability:GetLevelSpecialValueFor("fade_time", ability_level)
	if caster:HasTalent("special_bonus_memethrow_jmishenko_7") then
		fade_time = 0
		activation_time = 0
	end

	-- Create the land mine and apply the land mine modifier
	local land_mine = CreateUnitByName("npc_dota_techies_land_mine", target_point, false, nil, nil, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, land_mine, modifier_land_mine, {})

	-- Update the count and table
	caster.land_mine_count = caster.land_mine_count + 1
	table.insert(caster.land_mine_table, land_mine)

	-- If we exceeded the maximum number of mines then kill the oldest one
	if caster.land_mine_count > max_mines then
		caster.land_mine_table[1]:ForceKill(true)
	end

	-- Increase caster stack count of the caster modifier and add it to the caster if it doesnt exist
	if not caster:HasModifier(modifier_caster) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier_caster, {})
	end

	caster:SetModifierStackCount(modifier_caster, ability, caster.land_mine_count)

	-- Apply the tracker after the activation time
	Timers:CreateTimer(activation_time, function()
		ability:ApplyDataDrivenModifier(caster, land_mine, modifier_tracker, {})
	end)

	-- Apply the invisibility after the fade time
	Timers:CreateTimer(fade_time, function()
		ability:ApplyDataDrivenModifier(caster, land_mine, modifier_land_mine_invisibility, {})
	end)
end

--[[Author: Pizzalol
	Date: 24.03.2015.
	Stop tracking the mine and create vision on the mine area]]
function LandMinesDeath( keys )
	local caster = keys.caster
	local unit = keys.unit
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local modifier_caster = keys.modifier_caster
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability_level) 
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", ability_level)

	-- Find the mine and remove it from the table
	for i = 1, #caster.land_mine_table do
		if caster.land_mine_table[i] == unit then
			table.remove(caster.land_mine_table, i)
			caster.land_mine_count = caster.land_mine_count - 1
			break
		end
	end

	-- Create vision on the mine position
	ability:CreateVisibilityNode(unit:GetAbsOrigin(), vision_radius, vision_duration)

	-- Update the stack count
	caster:SetModifierStackCount(modifier_caster, ability, caster.land_mine_count)
	if caster.land_mine_count < 1 then
		caster:RemoveModifierByNameAndCaster(modifier_caster, caster) 
	end
end

--[[Author: Pizzalol
	Date: 24.03.2015.
	Tracks if any enemy units are within the mine radius]]
function LandMinesTracker( keys )
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local trigger_radius = ability:GetLevelSpecialValueFor("small_radius", ability_level) 
	local explode_delay = ability:GetLevelSpecialValueFor("explode_delay", ability_level) 

	-- Target variables
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	-- Find the valid units in the trigger radius
	local units = FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, trigger_radius, target_team, target_types, target_flags, FIND_CLOSEST, false) 

	-- If there is a valid unit in range then explode the mine
	if #units > 0 then
		Timers:CreateTimer(explode_delay, function()
			if target:IsAlive() then
				target:ForceKill(true)
			end
		end)
	end
end

function DamageDeal ( keys )


	local unit = keys.unit
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() -1) + caster:FindTalentValue("special_bonus_memethrow_jmishenko_3")

	if  not target:IsMagicImmune() then
	local damage_table = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	}
	
	if caster:HasTalent("special_bonus_memethrow_jmishenko_5") then
	damage_table.damage_type = DAMAGE_TYPE_PURE
	end
	ApplyDamage( damage_table )

	end
	
	
	if not target:IsAlive() and target:IsRealHero() then
		local rand = math.random(1, 70)
		if (rand >=1 and rand <= 10) then
			EmitGlobalSound("SoundKillTrigger1")
				elseif (rand >10 and rand <= 20) then
					EmitGlobalSound("SoundKillTrigger2")
						elseif (rand >20 and rand <= 30) then
							EmitGlobalSound("SoundKillTrigger3")	
								elseif (rand >30 and rand <= 40) then
									EmitGlobalSound("SoundKillTrigger4")
										elseif (rand >40 and rand <= 50) then
											EmitGlobalSound("SoundKillTrigger6")
												elseif (rand >50 and rand <= 60) then
													EmitGlobalSound("SoundKillTrigger6")
														elseif (rand >60 and rand <= 70) then
															EmitGlobalSound("SoundKillTrigger7")
		end
	end
end


function RandomSoundPlant( keys )
	local rand = math.random(1, 40)
	if (rand >=1 and rand <= 10) then
			keys.caster:EmitSound("SoundPlant1")
	elseif (rand >10 and rand <= 20) then
			keys.caster:EmitSound("SoundPlant2")
		elseif (rand >20 and rand <= 30) then
				keys.caster:EmitSound("SoundPlant3")	
			elseif (rand >30 and rand <= 40) then
					keys.caster:EmitSound("SoundPlant4")
	end
end

function RandomSoundDetonate( keys )
	local caster = keys.caster
	local rand = math.random(1, 40)
	if (rand >=1 and rand <= 10) then
			EmitGlobalSound("SoundDetonate1")
	elseif (rand >10 and rand <= 20) then
			EmitGlobalSound("SoundDetonate2")
		elseif (rand >20 and rand <= 30) then
				EmitGlobalSound("SoundDetonate3")	
			elseif (rand >30 and rand <= 40) then
					EmitGlobalSound("SoundDetonate4")
	end
end



function SetUnitsMoveForward( event )
	local caster = event.caster
	local target = event.target
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	target:SetForwardVector(fv)
end


function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end


valakas_donbass = class({})
LinkLuaModifier("modifier_donbas_casting", "ability/general.lua", LUA_MODIFIER_MOTION_BOTH)
AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")


function valakas_donbass:OnSpellStart()
	self.caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	if self.caster:HasTalent("special_bonus_memethrow_jmishenko") then
	duration = duration + 5
	end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_donbas_casting", { duration = duration })
	self:GetCaster():EmitSound("SoundKiborg")
	if self.caster:HasTalent("special_bonus_memethrow_jmishenko") then
	EmitGlobalSound("SoundDonbass2")
	else EmitGlobalSound("SoundDonbass")
	end
	
end


modifier_donbas_casting = class({})

function modifier_donbas_casting:IsPassive() return false end 
function modifier_donbas_casting:RemoveOnDeath() return true end 
function modifier_donbas_casting:IsPurgable() return false end

function modifier_donbas_casting:OnCreated()
	self.interval = self:GetAbility():GetSpecialValueFor("interval")
	self:OnIntervalThink()
	self:StartIntervalThink( self.interval )
	
end 

function modifier_donbas_casting:OnIntervalThink()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.damage = self:GetAbility():GetSpecialValueFor("dmg")
	self.target_radius = self:GetAbility():GetSpecialValueFor("target_radius")
	self.maxOrigin = self.target_radius - self.radius

	local x = RandomInt(-self.maxOrigin, self.maxOrigin)
	local y = RandomInt(-self.maxOrigin, self.maxOrigin)

	local point = self:GetCaster():GetAbsOrigin() + Vector(x,y,0)
	local particle = ParticleManager:CreateParticle("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_calldown_second.vpcf", PATTACH_WORLDORIGIN, self.caster)
	ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, point)
	ParticleManager:SetParticleControl(particle, 2, Vector(self.radius, self.radius, self.radius))

	Timers:CreateTimer(3, function()
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), point, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE,	FIND_ANY_ORDER, false)
		for _,unit in pairs(units) do
			local damage_table = {
				victim = unit,
				attacker = self:GetCaster(),
				damage = self.damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
			}
			ApplyDamage( damage_table )

		end
		ScreenShake(self:GetCaster():GetCenter(), 1000, 3, 0.8, 1200, 0, true)
	end)

	if not self:GetCaster():IsAlive() then
		self:Destroy()
		self:DestroyParticle(particle, false)
	end
end

function GiveBan ( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() -1)
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() -1) + caster:FindTalentValue("special_bonus_memethrow_jmishenko_2")
	
	if target:TriggerSpellAbsorb( keys.ability ) then return end
	
	local damage_table = {
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}
	ApplyDamage( damage_table )
	
		if caster:HasTalent("special_bonus_memethrow_jmishenko_6") then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_banned_talent", {duration = duration})
		else ability:ApplyDataDrivenModifier(caster, target, "modifier_banned", {duration = duration})
		end
		
	local rand = math.random(1, 80)
		if (rand >=1 and rand <= 10) then
			caster:EmitSound("SoundBan1")
				elseif (rand >10 and rand <= 20) then
					caster:EmitSound("SoundBan2")
						elseif (rand >20 and rand <= 30) then
							caster:EmitSound("SoundBan3")
								elseif (rand >30 and rand <= 40) then
									caster:EmitSound("SoundBan4")
										elseif (rand >40 and rand <= 50) then
											caster:EmitSound("SoundBan5")
												elseif (rand >50 and rand <= 60) then
													caster:EmitSound("SoundBan6")
														elseif (rand >60 and rand <= 70) then
															caster:EmitSound("SoundBan7")
																elseif (rand >70 and rand <= 80) then
																	caster:EmitSound("SoundBan8")
	end

end
