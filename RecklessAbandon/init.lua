--[[
~AddOn Engine~

To load the AddOn engine add this to the top of your file:

	local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

To load the AddOn engine inside another addon add this to the top of your file:

	local E, L, V, P, G = unpack(RecklessAbandon) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
]]
--Lua functions
---@class _G
local _G = _G

local CreateFrame = CreateFrame
local GetLocale = GetLocale
local GetTime = GetTime

-- GLOBALS: RecklessAbandonCharacterDB, RecklessAbandonPrivateDB, RecklessAbandonDB

local AceAddOn, AceAddonMinor = _G.LibStub("AceAddon-3.0")
local CallbackHandler = _G.LibStub("CallbackHandler-1.0")

local AddOnName, Engine = ...
---@class AceAddon
local E = AceAddOn:NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")
E.DF = { profile = {}, global = {} } -- Defaults
E.privateVars = { profile = {} }     -- Defaults
E.Options = { type = "group", args = {} }
E.callbacks = E.callbacks or CallbackHandler:New(E)
E.locale = GetLocale()

Engine[1] = E
Engine[2] = {}
Engine[3] = E.privateVars.profile
Engine[4] = E.DF.profile
Engine[5] = E.DF.global
_G.RecklessAbandon = Engine

do
	function E:AddonCompartmentFunc()
		E:ToggleOptionsUI()
	end

	_G.RecklessAbandon_AddonCompartmentFunc = E.AddonCompartmentFunc
end

do
	local convert = { enGB = "enUS", esES = "esMX", zhTW = "zhCN", ptPT = "ptBR" }
	local gameLocale = convert[E.locale] or E.locale or "enUS"

	function E:GetLocale()
		return gameLocale
	end
end

do
	E.Libs = {}
	E.LibsMinor = {}
	function E:AddLib(name, major, minor)
		if not name then
			return
		end

		-- in this case: `major` is the lib table and `minor` is the minor version
		if type(major) == "table" and type(minor) == "number" then
			E.Libs[name], E.LibsMinor[name] = major, minor
		else -- in this case: `major` is the lib name and `minor` is the silent switch
			E.Libs[name], E.LibsMinor[name] = _G.LibStub(major, minor)
		end
	end

	E:AddLib("AceAddon", AceAddOn, AceAddonMinor)
	E:AddLib("AceDB", "AceDB-3.0")
	E:AddLib("ACL", "AceLocale-3.0-Reckless")
	E:AddLib("AceGUI", "AceGUI-3.0")
	E:AddLib("AceConfig", "AceConfig-3.0")
	E:AddLib("AceConfigDialog", "AceConfigDialog-3.0")
	E:AddLib("AceConfigRegistry", "AceConfigRegistry-3.0")
end

---@diagnostic disable-next-line: duplicate-set-field
function E:OnInitialize()
	if not RecklessAbandonCharacterDB then
		RecklessAbandonCharacterDB = {}
	end

	E.db = E:CopyTable({}, E.DF.profile)
	E.global = E:CopyTable({}, E.DF.global)
	E.private = E:CopyTable({}, E.privateVars.profile)

	if RecklessAbandonDB then
		if RecklessAbandonDB.global then
			E:CopyTable(E.global, RecklessAbandonDB.global)
		end

		local key = RecklessAbandonDB.profileKeys and RecklessAbandonDB.profileKeys[E.mynameRealm]
		if key and RecklessAbandonDB.profiles and RecklessAbandonDB.profiles[key] then
			E:CopyTable(E.db, RecklessAbandonDB.profiles[key])
		end
	end

	if RecklessAbandonPrivateDB then
		local key = RecklessAbandonPrivateDB.profileKeys and RecklessAbandonPrivateDB.profileKeys[E.mynameRealm]
		if key and RecklessAbandonPrivateDB.profiles and RecklessAbandonPrivateDB.profiles[key] then
			E:CopyTable(E.private, RecklessAbandonPrivateDB.profiles[key])
		end
	end

	E:RegisterEvent("PLAYER_ENTERING_WORLD")
	E:RegisterEvent("PLAYER_LEVEL_UP")
	E:RegisterChatCommand("reckless", "ChatCommand")
	E:RegisterChatCommand("rab", "ChatCommand")

	E.loadedtime = GetTime()
end

local LoadUI = CreateFrame("Frame")
LoadUI:RegisterEvent("ADDON_LOADED")
LoadUI:RegisterEvent("PLAYER_LOGIN")
LoadUI:SetScript(
	"OnEvent",
	function(_, event, addon)
		if event == "ADDON_LOADED" and addon == "RecklessAbandon" then
			E:Initialize()
		end
	end
)

function E:RefreshOptions(event, database, _)
	E.db = database.profile

	if event == "OnProfileChanged" or event == "OnProfileCopied" then
		E:NormalizeSettings()
	end
end

function E:ChatCommand(input)
	-- /reckless cmd args
	local cmd, arg1, arg2 = E:GetArgs(input, 3)
	local qualifiers = E:GetAvailableQualifiers()

	-- TODO localize commands
	if cmd == "config" or cmd == nil then
		E:ToggleOptionsUI()
	elseif cmd == "list" and arg1 == "all" then
		E:CliListAllQuests()
	elseif cmd == "abandon" and arg1 == "all" then
		E:CliAbandonAllQuests()
	elseif cmd == "abandon" and tonumber(arg1) ~= nil then
		E:CliAbandonQuestById(arg1)
	elseif cmd == "abandon" and qualifiers[arg1] ~= nil then
		E:CliAbandonByQualifier(arg1)
	elseif cmd == "exclude" and tonumber(arg1) ~= nil then
		E:CliExcludeQuestById(arg1)
	elseif cmd == "include" and tonumber(arg1) ~= nil then
		E:CliIncludeQuestById(arg1)
	elseif cmd == "debug" then
		E:CliToggleDebugging()
	elseif cmd == "dump" and arg1 ~= nil then
		E:CliDump(arg1)
	end

	E:RefreshGUI()
end

function E:PLAYER_ENTERING_WORLD()
	E:PrintWelcomeMessage()
	E:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function E:PLAYER_LEVEL_UP(_, arg2)
	E:UpdatePlayerLevel(arg2)
end
