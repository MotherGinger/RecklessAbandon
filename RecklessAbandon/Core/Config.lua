local E, L = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local _G = _G

local DEFAULT_WIDTH = 900
local DEFAULT_HEIGHT = 700

local EnableAddOn = EnableAddOn
local LoadAddOn = LoadAddOn
local GetAddOnInfo = GetAddOnInfo
local GameTooltip = GameTooltip
local InCombatLockdown = InCombatLockdown
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT

E:AddLib("AceGUI", "AceGUI-3.0")
E:AddLib("AceConfig", "AceConfig-3.0")
E:AddLib("AceConfigDialog", "AceConfigDialog-3.0")
E:AddLib("AceConfigRegistry", "AceConfigRegistry-3.0")
E:AddLib("AceDBOptions", "AceDBOptions-3.0")

function E:ToggleOptionsUI(msg)
	if InCombatLockdown() then
		self:Warn(ERR_NOT_IN_COMBAT)
		self.ShowOptionsUI = true
		return
	end

	local ACD = E.Libs.AceConfigDialog

	local pages
	if (msg and msg ~= "") then
		pages = {strsplit(",", msg)}
	end

	local mode = "Close"
	if not ACD.OpenFrames[E.name] or (pages ~= nil) then
		mode = "Open"
	end

	if ACD then
		ACD[mode](ACD, E.name)
	end

	if pages then
		ACD:SelectGroup(E.name, unpack(pages))
	end

	GameTooltip:Hide() --Just in case you're mouseovered something and it closes.
end

-- Function we can call on profile change to update GUI
function E:RefreshGUI()
	E.Libs.AceConfigRegistry:NotifyChange(E.name)
end

E.Libs.AceConfig:RegisterOptionsTable(E.name, E.Options)
E.Libs.AceConfigDialog:SetDefaultSize(E.name, DEFAULT_WIDTH, DEFAULT_HEIGHT)
E.Options.name = format("Reckless Abandon %s", L["Configuration"])
E.Options.args = {
	header = {
		type = "header",
		order = 1,
		name = L["Version"] .. format(": |cff99ff33%s|r", E.version),
		width = "full"
	},
	description = {
		type = "description",
		order = 2,
		name = L["Description"] .. "\n",
		width = "full"
	},
	space1 = {
		order = 4,
		type = "description",
		name = ""
	}
}
