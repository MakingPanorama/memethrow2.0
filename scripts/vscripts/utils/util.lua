function ApplyFearCustomModifier( caster, target, ability, duration )
	return target:AddNewModifier(caster, ability, "modifier_screamed_custom", { duration = duration  })
end

function ApplyGenericStun( target, caster, ability, duration )
	return target:AddNewModifier( caster, ability, "modifier_stunned", { duration = duration } )
end

function GetAllItemsInSlotAndTableInsert( needTarget, nameTable )
	for i=0,9 do
		local items = needTarget:GetItemInSlot(i)

		if items ~= nil then
			table.insert( nameTable, items )
		end
	end
end
--[[
function C_DOTA_BaseNPC:HasTalent(talentName)
	if self:HasModifier("modifier_"..talentName) then
		return true 
	end

	return false
end

--Load ability KVs
local AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

function C_DOTA_BaseNPC:FindTalentValue(talentName, key)
	if self:HasModifier("modifier_"..talentName) then  
		local value_name = key or "value"
		local specialVal = AbilityKV[talentName]["AbilitySpecial"]
		for l,m in pairs(specialVal) do
			if m[value_name] then
				return m[value_name]
			end
		end
	end    
	return 0
end

function C_DOTABaseAbility:GetTalentSpecialValueFor(value)
	local base = self:GetSpecialValueFor(value)
	local talentName
	local kv = AbilityKV[self:GetName()]
	for k,v in pairs(kv) do -- trawl through keyvalues
		if k == "AbilitySpecial" then
			for l,m in pairs(v) do
				if m[value] then
					talentName = m["LinkedSpecialBonus"]
				end
			end
		end
	end
	if talentName and self:GetCaster():HasModifier("modifier_"..talentName) then 
		base = base + self:GetCaster():FindTalentValue(talentName) 
	end
	return base
end -]]