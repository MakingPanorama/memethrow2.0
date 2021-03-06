function StoneGaze( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Modifiers
	local modifier_facing = keys.modifier_facing

	-- Ability variables
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)

	-- Locations
	local caster_location = caster:GetAbsOrigin()
	local target_location = target:GetAbsOrigin()	

	-- Angle calculation
	local direction = (caster_location - target_location):Normalized()
	local forward_vector = target:GetForwardVector()
	local angle = math.abs(RotationDelta((VectorToAngles(direction)), VectorToAngles(forward_vector)).y)
	--print("Angle: " .. angle)
	if not target:HasModifier(modifier_stone) then
	ability:ApplyDataDrivenModifier(caster, target, modifier_facing, {Duration = 0.06})
	end
end


function StoneGazeFacing( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local stone_duration = ability:GetLevelSpecialValueFor("stone_duration", ability_level) + caster:FindTalentValue("special_bonus_memethrow_volan_2")
	local modifier_stone = keys.modifier_stone

	ability:ApplyDataDrivenModifier(caster, target, modifier_stone, {Duration = stone_duration})
	
end

function DamageDeal ( keys )
	
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("dmg", ability:GetLevel() -1)
	if caster:HasTalent("special_bonus_memethrow_volan") then
		damage = damage + 1
	end
	
	local damage_table = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	}
	ApplyDamage( damage_table )
	

end