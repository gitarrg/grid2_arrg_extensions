--[[
Custom Status to Track the Power for Tanks specifically.

Initially I created this to track BDK's Runic Power... but figured later
it could help to see all tanks power-bars for general awareness.

Still I'd not want to clutter my raidframes with DPS Powerbars.

]]--


local L = Grid2Options.L

local UnitGroupRolesAssigned = UnitGroupRolesAssigned or (function() return 'NONE' end)



-- Power status
local powerColors = {}

--------------------------------------------------------------------------------
-- Create Status
--
local PowerTank = Grid2.statusPrototype:new("power-tank")


function PowerTank:UpdateUnitPower(unit, powerType)
    if UnitIsPlayer(unit) then 
		self:UpdateIndicators(unit)
	end
end


local function Frame_OnEvent(self, event, unit, powerType)
	PowerTank:UpdateUnitPower(unit, powerType)
end

-- Dummy Frame to register events
-- (copied this logic from the default StatusHealth)
local frame

function PowerTank:OnEnable()
	if not frame then frame = CreateFrame("Frame", nil, Grid2LayoutFrame) end
	frame:SetScript("OnEvent", Frame_OnEvent)
	frame:RegisterEvent("UNIT_POWER_UPDATE")
	frame:RegisterEvent("UNIT_MAXPOWER")
	frame:RegisterEvent("UNIT_DISPLAYPOWER")

	self:RegisterEvent("PLAYER_ROLES_ASSIGNED", "UpdateAllUnits")
end


function PowerTank:OnDisable()
	if frame then
		frame:SetScript("OnEvent", nil)
		frame:UnregisterEvent("UNIT_POWER_UPDATE")
		frame:UnregisterEvent("UNIT_MAXPOWER")
		frame:UnregisterEvent("UNIT_DISPLAYPOWER")
	end

	self:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
end


function PowerTank:UpdateDB()
	powerColors["MANA"]        = self.dbx.color1 -- ProtPala
	powerColors["RAGE"]        = self.dbx.color2 -- Warrior / Bear
	powerColors["ENERGY"]      = self.dbx.color3 -- Monk
	powerColors["RUNIC_POWER"] = self.dbx.color4 -- Blood DK
	powerColors["FURY"]        = self.dbx.color5 -- VDH
end


function PowerTank:IsActive(unit)

	-- local power_index, power_type = UnitPowerType(unit)
	-- not the primary power (eg.: druid cat form) --> disabled because its 17 for DH.. for w/e reason
	-- if power_index ~= 0 then
	-- 	return false
	-- end

	local role = UnitGroupRolesAssigned(unit)
	return role == "TANK" or role == "NONE"  -- None if Solo Content
	-- if role == "TANK" then
	-- 	return true
	-- end

	-- if unit ==
	-- return power_type=="RAGE" or power_type=="FURY" or power_type=="RUNIC_POWER"

	-- if role == "TANK" then
	-- 	print("tank", role, power_type)
	-- 	return power_type ~= "MANA"
	-- end
end


function PowerTank:GetText(unit)
	local _, power_type = UnitPowerType(unit)

	if power_type == "MANA" then
		return string.format("%.0f%%", self:GetPercent(unit) * 100)
	end

	-- for non mana... lets just show absolute value
	local value
	value = UnitPower(unit)
	if value == 0 then
		return "" -- why this?
	end
	return string.format("%.0f", value)
end


function PowerTank:GetPercent(unit)
	local p = UnitPower(unit) / UnitPowerMax(unit)
	return UnitPower(unit) / UnitPowerMax(unit)
end


function PowerTank:GetColor(unit)
	local _, type= UnitPowerType(unit)
	local c = powerColors[type] or powerColors["RAGE"]
	return c.r, c.g, c.b, c.a
end


--------------------------------------------------------------------------------
-- Register Status
--


local function CreatePowerTank(baseKey, dbx)
	Grid2:RegisterStatus(PowerTank, {"percent", "text", "color"}, baseKey, dbx)
	PowerTank:UpdateDB()
	return PowerTank
end


Grid2.setupFunc["power-tank"] = CreatePowerTank


Grid2:DbSetStatusDefaultValue(
	"power-tank",
	{
		type = "power-tank",
		colorCount = 6,
		color1 = {r=0,g=0.5,b=1  ,a=1},            -- mana
		color2 = {r=1,g=0  ,b=0  ,a=1},            -- rage
		color3 = {r=1,g=1  ,b=0  ,a=1},            -- energy
		color4 = {r=0,g=0.8,b=0.8,a=1},            -- runic power
		color5 = {r=0.788, g=0.259, b=0.992, a=1}, -- fury
		color6 = {r=1.00, g=0.61, b=0.00, a=1}     -- pain
	}
)


Grid2Options:RegisterStatusOptions(
	"power-tank",  -- name?
	"mana",        -- group?


	Grid2Options.MakeStatusColorOptions,
	{
		color1 = L["Mana"],
		color2 = L["Rage"],
		color3 = L["Energy"],
		color4 = L["Runic Power"],
		color5 = L["Fury"],
		color6 = L["Pain"],
		width = "full",
	}
)