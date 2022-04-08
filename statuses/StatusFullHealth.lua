--[[
Status to Blend Health Colors based on their Percentage,

Right now its hardcoded to have five stpes
with thresholds at 0.9, 0.5 and 0.25

TODO:
	* could add some options to let users configure the breakpoints

	* could add a dynamic number of colors?
		(or maybe at leats up to a given max of eg.: 10)
]]--

local L = Grid2Options.L

local HealthFull = Grid2.statusPrototype:new("health-full")


function BlendColor(a, b, t)
	-- Blend the Colors A and B, based on T
	local m = 1.0 - t;
	return {
		r = (a.r * t) + (b.r * m),
		g = (a.g * t) + (b.g * m),
		b = (a.b * t) + (b.b * m),
		a = (a.a * t) + (b.a * m)
	}
end


-- Get Units Health as Percent
function GetPercent(unit)
	local m = UnitHealthMax(unit)
	return m == 0 and 0 or UnitHealth(unit) / m
end


function HealthFull:UpdateUnit(_, unit)
	if unit then
		self:UpdateIndicators(unit)
	end
end


function HealthFull:OnEnable()
	self:RegisterEvent("UNIT_HEALTH", "UpdateUnit")
	self:RegisterEvent("UNIT_MAXHEALTH", "UpdateUnit")
end


function HealthFull:OnDisable()
	self:UnregisterEvent("UNIT_HEALTH", "UNIT_MAXHEALTH")
end


function HealthFull:UpdateDB()
	self.color1 = Grid2:MakeColor(self.dbx.color1)
	self.color2 = Grid2:MakeColor(self.dbx.color2)
	self.color3 = Grid2:MakeColor(self.dbx.color3)
	self.color4 = Grid2:MakeColor(self.dbx.color4)
	self.color5 = Grid2:MakeColor(self.dbx.color5)
end


HealthFull.IsActive  = Grid2.statusLibrary.IsActive


function HealthFull:GetText(unit)
	return ""
end


function HealthFull:GetColor(unit)

	local t -- blend value. Will be normalised between the two breakpoints
	local c = self.color1
	local p = GetPercent(unit)

	-- between 1.0 and 0.9
	if p >= 0.90 then
		t = (p - 0.90) * 10
		c = BlendColor(self.color1, self.color2, t)

	-- between 0.9 and 0.5
	elseif p >= 0.5 then
		t = (p - 0.5) * 2.5
		c = BlendColor(self.color2, self.color3, t)

	-- between 0.5 and 0.25
	elseif p >= 0.25 then
		t = (p - 0.25) * 4
		c = BlendColor(self.color3, self.color4, t)

	-- between 0.25 and 0
	else
		t = p * 4
		c = BlendColor(self.color4, self.color5, t)
	end

	return c.r, c.g, c.b, c.a
end


local function CreateHealthFull(baseKey, dbx)
	Grid2:RegisterStatus(HealthFull, {"color"}, baseKey, dbx)
	HealthFull:UpdateDB()
	return HealthFull
end


Grid2.setupFunc["health-full"] = CreateHealthFull
Grid2:DbSetStatusDefaultValue(
	"health-full",
	{
		type = "health-full",
		colorCount = 5,
		color1 = {r=0, g=1, b=0, a=1},
		color2 = {r=1, g=1, b=0, a=1},
		color3 = {r=1, g=0, b=0, a=1},
		color4 = {r=1, g=0, b=0, a=1},
		color5 = {r=1, g=0, b=0, a=1}
	})


Grid2Options:RegisterStatusOptions(
	"health-full",
	"health",
	Grid2Options.MakeStatusColorOptions,
	{
		titleIcon = "Interface\\Icons\\Spell_holy_layonhands"
	}
)
