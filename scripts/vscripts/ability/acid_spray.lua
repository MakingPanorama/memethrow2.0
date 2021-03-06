function ApplyDPS(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 ) + caster:FindTalentValue("special_bonus_memethrow_gonshik_4")
	if caster:HasScepter() then
           ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE})
		   else ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
    end
end

function ApplySound(keys)
	local caster = keys.caster
	
	if caster:HasScepter() then
	EmitGlobalSound("SoundAd2")
	else EmitGlobalSound("SoundAd")
	end

end