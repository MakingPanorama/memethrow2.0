function CDOTA_BaseNPC:HasTalent(talentName)
	if self and not self:IsNull() and self:HasAbility(talentName) then
		if self:FindAbilityByName(talentName):GetLevel() > 0 then return true end
	end
	return false
end

function CDOTA_BaseNPC:FindTalentValue(talentName, key)
	if self:HasAbility(talentName) then
		local value_name = key or "value"
		return self:FindAbilityByName(talentName):GetSpecialValueFor(value_name)
	end
	return 0
end
function CDOTA_BaseNPC:HasShard()
	return self:HasModifier("modifier_item_aghanims_shard")
end
function CDOTA_BaseNPC:GetSpecialAghanimValueFor(keyName1, keyName2)
	local variable = keyName1

	if self:HasScepter() then
		variable = keyName2
	end
	return variable
end