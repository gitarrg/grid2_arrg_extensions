--[[
Status to Display the Units current Health including Shields

eg.: it might show as 130% if someone has 80% + 50% shield

]]--

local fmt   = string.format

local HealthWithShield = Grid2.statusPrototype:new("health-with-shield")


-- Get Units Health, MaxHP and Current Absorb
function GetValues(unit)
    local max = UnitHealthMax(unit) or 0
    local hp = UnitHealth(unit) or 0
    local absorb = UnitGetTotalAbsorbs(unit) or 0

    return hp, max, absorb
end


function HealthWithShield:UpdateUnit(_, unit)
	if unit then
		self:UpdateIndicators(unit)
	end
end


function HealthWithShield:OnEnable()
    self:RegisterEvent("UNIT_HEALTH", "UpdateUnit")
	self:RegisterEvent("UNIT_MAXHEALTH", "UpdateUnit")
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", "UpdateUnit")
end


function HealthWithShield:OnDisable()
    self:UnregisterEvent("UNIT_HEALTH")
	self:UnregisterEvent("UNIT_MAXHEALTH")
	self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
end


function HealthWithShield:GetText(unit)
    local hp, max, absorb = GetValues(unit)
    return fmt("%.1fk", (hp + absorb) / 1000 )
end


function HealthWithShield:GetPercent(unit)
    local hp, max, absorb = GetValues(unit)
    return (hp + absorb) / max
end


HealthWithShield.IsActive  = Grid2.statusLibrary.IsActive


local function CreateHealthWithShield(baseKey, dbx)
	Grid2:RegisterStatus(HealthWithShield, { "text" }, baseKey, dbx)
	return HealthWithShield
end


Grid2.setupFunc["health-with-shield"] = CreateHealthWithShield
Grid2:DbSetStatusDefaultValue(
	"health-with-shield",
	{
		type = "health-with-shield",
	})


Grid2Options:RegisterStatusOptions(
	"health-with-shield",
	"health",
	Grid2Options.MakeStatusColorOptions,
	{
		titleIcon = "Interface\\Icons\\Spell_holy_layonhands"
	}
)
