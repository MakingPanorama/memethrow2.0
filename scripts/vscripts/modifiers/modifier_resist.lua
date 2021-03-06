modifier_resist = modifier_resist or class({})

function modifier_resist:IsHidden()	return true end

function modifier_resist:IsPurgable()	return false end

function modifier_resist:RemoveOnDeath()	return true end

function modifier_resist:DeclareFunctions()
	return {
	MODIFIER_PROPERTY_STATUS_RESISTANCE
	}
end

function modifier_resist:GetModifierStatusResistance()
	return 100
end