--[[
	Author: Noya
	Date: 15.01.2015.
	Spawns a unit with different levels of the unit_name passed
	Each level needs a _level unit inside npc_units or npc_units_custom.txt
]]

saveItem = {}

function SpiritBearSpawn( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local level = ability:GetLevel()
	local origin = caster:GetAbsOrigin() + RandomVector(100)

	-- Set the unit name, concatenated with the level number
	local unit_name = "npc_dota_gamahiro"..level
	
	if caster:HasTalent("special_bonus_memethrow_naruto_8") then
			unit_name = "npc_dota_gamahiro5"
	end

	-- Check if the gamahiro is alive, heals and spawns them near the caster if it is
	if caster.gamahiro and IsValidEntity(caster.gamahiro) and caster.gamahiro:IsAlive() then
		FindClearSpaceForUnit(caster.gamahiro, origin, true)
		caster.gamahiro:SetHealth(caster.gamahiro:GetMaxHealth())	
	else
	
	if caster.gamahiro then
			local unit = caster.gamahiro
            item_table = {}
            for i = 0, 8 do
                local item = unit:GetItemInSlot( i )

                if item ~= nil then         
                    table.insert(item_table , item)
                end
                
            end
	end
		caster.gamahiro = CreateUnitByName(unit_name, origin, true, caster, caster, caster:GetTeamNumber())
		caster.gamahiro:SetControllableByPlayer(player, true)
		local items = item_table or {}
             for _,item in pairs(items) do   
                 caster.gamahiro:AddItem(item)
             end

		LearngamahiroAbilities( caster.gamahiro, 1 )
	end

end


function SpiritBearLevel( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local level = ability:GetLevel()
	local unit_name = "npc_dota_gamahiro"..level
	local origin = caster:GetAbsOrigin() + RandomVector(100)
	ability:EndCooldown()
	if caster:HasTalent("special_bonus_memethrow_naruto_8") then
			unit_name = "npc_dota_gamahiro5"
	end
	

	if caster.gamahiro and IsValidEntity(caster.gamahiro) and caster.gamahiro:IsAlive() then
		FindClearSpaceForUnit(caster.gamahiro, origin, true)
		caster.gamahiro:SetHealth(caster.gamahiro:GetMaxHealth())	
	else
	
	if caster.gamahiro then
			local unit = caster.gamahiro
            item_table = {}
            for i = 0, 8 do
                local item = unit:GetItemInSlot( i )

                if item ~= nil then         
                    table.insert(item_table , item)
                end
                
            end
	end
		caster.gamahiro:RemoveSelf()
		caster.gamahiro = CreateUnitByName(unit_name, origin, true, caster, caster, caster:GetTeamNumber())
		caster.gamahiro:SetControllableByPlayer(player, true)
		local items = item_table or {}
             for _,item in pairs(items) do   
                 caster.gamahiro:AddItem(item)
             end

		LearngamahiroAbilities( caster.gamahiro, 1 )
	end
end


-- Auxiliar Function to loop over all the abilities of the unit and set them to a level
function LearngamahiroAbilities( unit, level )

	-- Learn its abilities, for lone_druid_gamahiro its return lvl 2, entangle lvl 3, demolish lvl 4. By Index
	for i=0,15 do
		local ability = unit:GetAbilityByIndex(i)
		if ability then
			ability:SetLevel(level)
			print("Set Level "..level.." on "..ability:GetAbilityName())
		end
	end

end