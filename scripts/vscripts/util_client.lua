-- Without that another utilities will not work

function C_DOTA_BaseNPC:HasTalent(talentName)
	talentName = string.lower(talentName) 
	if self:HasModifier("modifier_"..talentName) then
		return true 
	end

	return false
end

--Load ability KVs
local AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

function C_DOTA_BaseNPC:FindTalentValue(talentName, key)
	talentName = string.lower(talentName)
		local value_name = key or "value"
		local specialVal = AbilityKV[talentName]["AbilitySpecial"]
		for l,m in pairs(specialVal) do
			if m[value_name] then
				return m[value_name]
			end
		end
	return 0
end
function C_DOTA_BaseNPC:HasShard()
	return self:HasModifier("modifier_item_aghanims_shard")
end
function C_DOTA_BaseNPC:GetSpecialAghanimValueFor(keyName1, keyName2)
	local variable = keyName1

	if self:HasScepter() then
		variable = keyName2
	end
	return variable
end