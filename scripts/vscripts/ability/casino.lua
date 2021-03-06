function FaithSound ( keys )
	
	local caster = keys.caster
	local rand = math.random(1, 60)
	
	
	if (rand >=1 and rand <= 20) then
			caster:EmitSound("SoundRotCasino")
	elseif (rand >20 and rand <= 40) then
			caster:EmitSound("SoundRotEbal")
		elseif (rand >40 and rand <= 60) then
				caster:EmitSound("SoundSukaPadla")	
	end

end	

function FaithDamage ( keys)
	
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage_min = ability:GetLevelSpecialValueFor("damage_min", ability:GetLevel() -1) + caster:FindTalentValue("special_bonus_memethrow_casino_8")
	local damage_max = ability:GetLevelSpecialValueFor("damage_max", ability:GetLevel() -1) + caster:FindTalentValue("special_bonus_memethrow_casino_8")

	if target:TriggerSpellAbsorb( keys.ability ) then return end
			
	local random = RandomFloat(0, 1)
	local damage = damage_min + (damage_max - damage_min) * (1 - random)


	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = damage

	ApplyDamage(damage_table)

end

function RandomSound ( keys )
	local caster = keys.caster
	local target = keys.target
	
	local rand = math.random(1, 100)
	
	if (rand >=1 and rand <= 20) then
			caster:EmitSound("SoundTvoyRot")
	elseif (rand >20 and rand <= 40) then
			caster:EmitSound("SoundDebil")
		elseif (rand >40 and rand <= 60) then
				caster:EmitSound("SoundPadla")
			elseif (rand >60 and rand <= 80) then
					caster:EmitSound("SoundTiMudila")
				elseif rand >80 then
						caster:EmitSound("SoundHuilo")
	
	end
end	

function ChaosBolt( keys )
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local stun_min = ability:GetLevelSpecialValueFor("stun_min", ability_level)
	local stun_max = ability:GetLevelSpecialValueFor("stun_max", ability_level) 
	local damage_min = ability:GetLevelSpecialValueFor("damage_min", ability_level) + caster:FindTalentValue("special_bonus_memethrow_casino_6")
	local damage_max = ability:GetLevelSpecialValueFor("damage_max", ability_level) + caster:FindTalentValue("special_bonus_memethrow_casino_7")
	local chaos_bolt_particle = keys.chaos_bolt_particle

	if target:TriggerSpellAbsorb( ability ) then return end

	-- Calculate the stun and damage values
	local random = RandomFloat(0, 1)
	local stun = stun_min + (stun_max - stun_min) * random
	local damage = damage_min + (damage_max - damage_min) * (1 - random)
		
	-- Random Sound Effect
		local rand = math.random(1, 100)
		
		if (rand>=0 and rand<25) then
			target:EmitSound("SoundBlyat")
			elseif (rand>=25 and rand<50) then
					target:EmitSound("SoundDegenerat")
				elseif (rand>=50 and rand<75) then
						target:EmitSound("SoundKakogoHuya")
					elseif rand>=75 then
							target:EmitSound("SoundMudila")
		end	
		
	-- Calculate the number of digits needed for the particle
	local stun_digits = string.len(tostring(math.floor(stun))) + 1
	local damage_digits = string.len(tostring(math.floor(damage))) + 1

	-- Create the stun and damage particle for the spell
	local particle = ParticleManager:CreateParticle(chaos_bolt_particle, PATTACH_OVERHEAD_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, target_location) 

	-- Damage particle
	ParticleManager:SetParticleControl(particle, 1, Vector(9,damage,4)) -- prefix symbol, number, postfix symbol
	ParticleManager:SetParticleControl(particle, 2, Vector(2,damage_digits,0)) -- duration, digits, 0

	-- Stun particle
	ParticleManager:SetParticleControl(particle, 3, Vector(8,stun,0)) -- prefix symbol, number, postfix symbol
	ParticleManager:SetParticleControl(particle, 4, Vector(2,stun_digits,0)) -- duration, digits, 0
	ParticleManager:ReleaseParticleIndex(particle)

	-- Apply the stun duration
	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun})

	-- Initialize the damage table and deal the damage
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = damage

	ApplyDamage(damage_table)
end

function GetGold(keys)
	local caster = keys.caster
	local ability = keys.ability
	local talentj = caster:FindAbilityByName("special_bonus_unique_ogre_magi_3")
	local gold_min = ability:GetLevelSpecialValueFor("gold_gain_min", ability:GetLevel() - 1 )
	local gold_max = ability:GetLevelSpecialValueFor("gold_gain_max", ability:GetLevel() - 1 ) + caster:FindTalentValue("special_bonus_memethrow_casino_5")
	
	

-- Игра в Джекпот	
	
	
	local jackchance = ability:GetLevelSpecialValueFor("jackpot", ability:GetLevel() - 1 ) + caster:FindTalentValue("special_bonus_memethrow_casino") + caster:FindTalentValue("special_bonus_memethrow_casino_2") + caster:FindTalentValue("special_bonus_memethrow_casino_3") + caster:FindTalentValue("special_bonus_memethrow_casino_4")
	local rand = RandomFloat(1, 200)
	if rand <= jackchance then
		caster:ModifyGold(99999, true, 1)
		EmitGlobalSound("SoundJackPot")
	end
		
-- Игра в казино
	
		local random = RandomFloat(0, 1)
		local gold = gold_min + (gold_max - gold_min) * random
		
		if caster:HasScepter() then
			gold = (gold_max) * random
		end
		
		
		caster:ModifyGold(gold, true, 1)
		if gold <= 0 then 
		caster:EmitSound("SoundLose")
			else caster:EmitSound("SoundWin")
		end
end