function Fatality( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local HPPercentage = (target:GetHealth()/target:GetMaxHealth())*100
	local kill_pct = ability:GetLevelSpecialValueFor("kill_pct", ability:GetLevel() - 1 )
	
	
		if caster:HasScepter() then
           kill_pct = ability:GetLevelSpecialValueFor("kill_pct_scepter", ability:GetLevel() - 1 )
		end

	if(HPPercentage<=kill_pct) then
		if target:IsRealHero() then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_fatality_datadriven", {})
		end

	end	
end

function Kill( keys )

	local target = keys.target
	local caster = keys.caster
	
	if caster:HasTalent("special_bonus_memethrow_scorpion_8") then
		caster:Heal(target:GetHealth(), caster)
	end
	
	target:Kill( ability, caster )
	if not caster:HasModifier("modifier_duel_datadriven") then
		caster:EmitSound("SoundFatality")
	end
end