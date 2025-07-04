--- **AceLocale-3.0** manages localization in addons, allowing for multiple locale to be registered with fallback to the base locale for untranslated strings.
-- @class file
-- @name AceLocale-3.0
-- @release $Id: AceLocale-3.0.lua 1284 2022-09-25 09:15:30Z nevcairiel $
local MAJOR,MINOR = "AceLocale-3.0-Reckless", 2

local AceLocale, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceLocale then return end -- no upgrade needed

-- Lua APIs
local assert, tostring, error = assert, tostring, error
local getmetatable, setmetatable, rawset, rawget = getmetatable, setmetatable, rawset, rawget

local gameLocale = GetLocale()
if gameLocale == "enGB" then
	gameLocale = "enUS"
end

AceLocale.apps = AceLocale.apps or {}          -- array of ["AppName"]=localetableref
AceLocale.appnames = AceLocale.appnames or {}  -- array of [localetableref]="AppName"

-- This metatable is used on all tables returned from GetLocale
-- Reckless
local readmeta = {
	__index = function(self, key) -- requesting totally unknown entries: fire off a nonbreaking error and return key
		AceLocale.MissingLinesReckless[key] = true
		rawset(self, key, key) -- only need to see the warning once, really
		geterrorhandler()(MAJOR .. ": " .. tostring(AceLocale.appnames[self]) .. ": Missing entry for '" .. tostring(key) .. "'")
		return key
	end
}
AceLocale.MissingLinesReckless = {}
-- end block

-- This metatable is used on all tables returned from GetLocale if the silent flag is true, it does not issue a warning on unknown keys
local readmetasilent = {
	__index = function(self, key) -- requesting totally unknown entries: return key
		rawset(self, key, key)      -- only need to invoke this function once
		return key
	end
}

-- Remember the locale table being registered right now (it gets set by :NewLocale())
-- NOTE: Do never try to register 2 locale tables at once and mix their definition.
local registering

-- local assert false function
local assertfalse = function() assert(false) end

-- This metatable proxy is used when registering nondefault locales
local writeproxy = setmetatable({}, {
	__newindex = function(self, key, value)
		rawset(registering, key, value == true and key or value) -- assigning values: replace 'true' with key string
	end,
	__index = assertfalse
})

-- This metatable proxy is used when registering the default locale.
-- It refuses to overwrite existing values
-- Reason 1: Allows loading locales in any order
-- Reason 2: If 2 modules have the same string, but only the first one to be
--           loaded has a translation for the current locale, the translation
--           doesn't get overwritten.
--
local writedefaultproxy = setmetatable({}, {
	__newindex = function(self, key, value)
		if not rawget(registering, key) then
			rawset(registering, key, value == true and key or value)
		end
	end,
	__index = assertfalse
})

-- Reckless block
local function BackfillTable(currentTable, defaultTable)
	if type(currentTable) ~= 'table' and type(defaultTable) ~= 'table' then
		return
	end

	for option, value in pairs(defaultTable) do
		if type(value) == 'table' then
			value = BackfillTable(currentTable[option], value)
		end

		if currentTable[option] ~= defaultTable[option] and currentTable[option] == option then
			currentTable[option] = value == true and option or value
		end
	end
end
-- end block

--- Register a new locale (or extend an existing one) for the specified application.
-- :NewLocale will return a table you can fill your locale into, or nil if the locale isn't needed for the players
-- game locale.
-- @paramsig application, locale[, isDefault[, silent]]
-- @param application Unique name of addon / module
-- @param locale Name of the locale to register, e.g. "enUS", "deDE", etc.
-- @param isDefault If this is the default locale being registered (your addon is written in this language, generally enUS)
-- @param silent If true, the locale will not issue warnings for missing keys. Must be set on the first locale registered. If set to "raw", nils will be returned for unknown keys (no metatable used).
-- @usage
-- -- enUS.lua
-- local L = LibStub("AceLocale-3.0"):NewLocale("TestLocale", "enUS", true)
-- L["string1"] = true
--
-- -- deDE.lua
-- local L = LibStub("AceLocale-3.0"):NewLocale("TestLocale", "deDE")
-- if not L then return end
-- L["string1"] = "Zeichenkette1"
-- @return Locale Table to add localizations to, or nil if the current locale is not required.
function AceLocale:NewLocale(application, locale, isDefault, silent)

	-- GAME_LOCALE allows translators to test translations of addons without having that wow client installed
	local activeGameLocale = GAME_LOCALE or gameLocale

	local app = AceLocale.apps[application]

	if silent and app and getmetatable(app) ~= readmetasilent then
		geterrorhandler()("Usage: NewLocale(application, locale[, isDefault[, silent]]): 'silent' must be specified for the first locale registered")
	end

	if not app then
		if silent=="raw" then
			app = {}
		else
			app = setmetatable({}, silent and readmetasilent or readmeta)
		end
		AceLocale.apps[application] = app
		AceLocale.appnames[app] = application
	end

	if locale ~= activeGameLocale and not isDefault then
		return -- nop, we don't need these translations
	end

	-- Reckless block
	if (not app[locale]) or (app[locale] and type(app[locale]) ~= 'table') then
		--	app[locale] = setmetatable({}, silent and readmetasilent or readmeta) -- To find missing keys
		app[locale] = setmetatable({}, readmetasilent)
	end

	registering = app[locale] -- remember globally for writeproxy and writedefaultproxy
	-- end block

	if isDefault and (not app.defaultLocale or app.defaultLocale == 'defaultLocale') then -- Reckless
		app.defaultLocale = locale
		return writedefaultproxy
	end

	return writeproxy
end

--- Returns localizations for the current locale (or default locale if translations are missing).
-- Errors if nothing is registered (spank developer, not just a missing translation)
-- @param application Unique name of addon / module
-- @param silent If true, the locale is optional, silently return nil if it's not found (defaults to false, optional)
-- @return The locale table for the current language.
--- Modified by Reckless Abandon to add `locale` as second arg and the CopyTable section
function AceLocale:GetLocale(application, locale, silent)
	if type(locale) == "boolean" then
		silent = locale
		locale = gameLocale
	end

	if not silent and not AceLocale.apps[application] then
		error("Usage: GetLocale(application[,locale[, silent]]): 'application' - No locales registered for '" .. tostring(application) .. "'", 2)
	end

	if locale ~= AceLocale.apps[application].defaultLocale then
		BackfillTable(AceLocale.apps[application][locale], AceLocale.apps[application][AceLocale.apps[application].defaultLocale])
	end

	return AceLocale.apps[application][locale] or AceLocale.apps[application][gameLocale] -- Just in case the table doesn't exist it reverts to default
end
