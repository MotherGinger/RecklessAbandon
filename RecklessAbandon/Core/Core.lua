local RecklessAbandon = select(2, ...)
RecklessAbandon[2] = RecklessAbandon[1].Libs.ACL:GetLocale("RecklessAbandon", RecklessAbandon[1]:GetLocale()) -- Locale doesn't exist yet, make it exist.
local E, L, V, P, G = unpack(RecklessAbandon) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Lua functions
local _G = _G
local tonumber, pairs, ipairs, error, unpack, select, tostring = tonumber, pairs, ipairs, error, unpack, select, tostring
local gsub, strjoin, twipe, tinsert, tremove, tContains = gsub, strjoin, wipe, tinsert, tremove, tContains
local format, find, strrep, strlen, sub = format, strfind, strrep, strlen, strsub
local assert, type, pcall, xpcall, next, print = assert, type, pcall, xpcall, next, print

--WoW API / Variables
local CreateFrame = CreateFrame
local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local GetSpellInfo = GetSpellInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetSpecialization = GetSpecialization
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local GetAddOnEnableState = GetAddOnEnableState
local IsInGroup = IsInGroup
local IsInGuild = IsInGuild
local IsInRaid = IsInRaid
local SetCVar = SetCVar
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID

local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage

--Constants
E.noop = function()
end
E.title = format("|cFF80528C%s|r", "Reckless Abandon")
E.version = GetAddOnMetadata("RecklessAbandon", "Version")
E.author = GetAddOnMetadata("RecklessAbandon", "Author")
E.myfaction, E.myLocalizedFaction = UnitFactionGroup("player")
E.mylevel = UnitLevel("player")
E.myLocalizedClass, E.myclass, E.myClassID = UnitClass("player")
E.myLocalizedRace, E.myrace = UnitRace("player")
E.myname = UnitName("player")
E.myrealm = GetRealmName()
E.mynameRealm = format("%s - %s", E.myname, E.myrealm) -- contains spaces/dashes in realm (for profile keys)
E.myspec = GetSpecialization()
E.wowpatch, E.wowbuild = GetBuildInfo()
E.wowbuild = tonumber(E.wowbuild)
E.isMacClient = IsMacClient()
E.IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
E.screenwidth, E.screenheight = GetPhysicalScreenSize()
E.resolution = format("%dx%d", E.screenwidth, E.screenheight)

local questGroupsByName = {}
-- TODO: We might want to define multiple xml buttons for each type
local questButtonPool = CreateFramePool("Button", QuestMapFrame.QuestsFrame, "RECKLESS_ABANDON_BUTTON")
local zoneButtonPool = CreateFramePool("Button", QuestMapFrame.QuestsFrame, "RECKLESS_ABANDON_BUTTON")

StaticPopupDialogs["RECKLESS_ABANDON_GROUP_CONFIRMATION"] = {
	text = L["Are you sure you want to abandon all quests in %s? This cannot be undone."],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function(self, quests)
		E:AbandonQuests(quests)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3
}

StaticPopupDialogs["RECKLESS_ABANDON_CONFIRMATION"] = {
	text = L["Are you sure you want to abandon %s?. This cannot be undone."],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function(self, data)
		E:AbandonQuest(data.title, data.questId)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3
}

StaticPopupDialogs["RECKLESS_ABANDON_ALL_CONFIRMATION"] = {
	text = L["Are you sure you want to abandon all of the quests in your questlog?. This cannot be undone."],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function(self, data)
		E:AbandonAllQuests()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3
}

local function Slug(value)
	if value == nil then
		return
	end
	return value:lower():gsub("[^a-z]", "")
end

local function CreateQuestLink(questId, title)
	return format("|cff808080|Hquest:%d|h[%s]|h|r", questId, title)
end

local function RenderButton(parent, offset, questId, title, tooltip)
	title = title or parent:GetText()
	tooltip = tooltip or format(L["Abandon '%s'"], title)

	local button = questButtonPool:Acquire()
	button.title = title
	button.tooltip = tooltip
	button.questId = questId
	button:SetPoint("CENTER", parent, "CENTER", offset, 0)
	button:Show()
end

local function RenderGroupButton(parent, offset, title, tooltip, slug)
	title = title or parent:GetText()
	tooltip = tooltip or format(L["Abandon all '%s' quests"], title)
	slug = slug or Slug(title)

	if questGroupsByName[slug] then
		local button = zoneButtonPool:Acquire()
		local texture = button:GetNormalTexture()
		button.title = title
		button.tooltip = tooltip
		button.slug = slug
		button:SetPoint("CENTER", parent, "CENTER", offset, 0)
		button:SetEnabled(not questGroupsByName[slug].hidden)
		texture:SetDesaturated(questGroupsByName[slug].hidden)
		button:SetNormalTexture(texture)
		button:Show()
	end
end

local function ButtonsShow()
	questButtonPool:ReleaseAll()
	zoneButtonPool:ReleaseAll()

	if (E.db.general.campaignQuests.showAbandonButton) then
		-- TODO: This shows even when there are no quests, but there is a header
		for header in QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
			RenderGroupButton(header.Text, 25)
		end
	end

	if (E.db.general.covenantCallings.showAbandonButton) then
		for calling in QuestScrollFrame.covenantCallingsHeaderFramePool:EnumerateActive() do
			local questId = calling.questID
			RenderButton(calling, QuestScrollFrame:GetWidth() - 50, questId, L["covenant callings"], L["Abandon all covenant calling quests"])
		end
	end

	if (E.db.general.zoneQuests.showAbandonButton) then
		for header in QuestScrollFrame.headerFramePool:EnumerateActive() do
			RenderGroupButton(header, QuestScrollFrame:GetWidth() - 25)
		end
	end

	if (E.db.general.individualQuests.showAbandonButton) then
		-- TODO: C_QuestLog.CanAbandonQuest(questID)
		for quest in QuestScrollFrame.titleFramePool:EnumerateActive() do
			local questId = quest.questID
			local text = quest.Text:GetText()
			local tooltip = format(L["Abandon '%s'"], text)
			RenderButton(quest.TaskIcon, QuestScrollFrame:GetWidth() - 50, questId, text, tooltip, text)
		end
	end

	-- TODO: Find a good place for this button, setup logic
	-- RenderButton(QuestMapFrame, -40, "your quest log", "All quests", "all")
end

local function ButtonsHide()
	questButtonPool:ReleaseAll()
	zoneButtonPool:ReleaseAll()
end

function ButtonEnter(self)
	GameTooltip:SetOwner(self)
	GameTooltip:SetText(self.tooltip)
	GameTooltip:Show()
end

function ButtonLeave(self)
	GameTooltip:Hide()
end

function ButtonClick(self)
	if self.questId then
		if E.db.general.confirmIndividual then
			local dialog = StaticPopup_Show("RECKLESS_ABANDON_CONFIRMATION", self.title)
			if dialog then
				dialog.data = {
					title = self.title,
					questId = self.questId
				}
			end
		else
			E:AbandonQuest(self.title, self.questId)
		end
	else
		if E.db.general.confirmGroup then
			local dialog = StaticPopup_Show("RECKLESS_ABANDON_GROUP_CONFIRMATION", self.title)
			if dialog then
				dialog.data = self.slug
			end
		else
			E:AbandonQuests(self.slug)
		end
	end
end

function ButtonUpdate(self)
	local buffer = 10
	if self:GetBottom() > QuestScrollFrame:GetBottom() - buffer and self:GetTop() < QuestScrollFrame:GetTop() + buffer then
		self:Show()
	else
		self:Hide()
	end
end

function E:Print(...)
	print(strjoin("", E.title, ": ", ...))
end

function E:Debug(...)
	if (self.db.debugging.debugLogging) then
		print(strjoin("", format(L["|cffffcc00%s Debug:|r"], E.title), " ", ...))
	end
end

function E:GenerateQuestTable()
	-- This generates a table of quests
	-- {
	-- 	[<zone_header_id>] = {
	-- 		["quests"] = {
	-- 			[<quest_id>] = "some-zone-header",
	-- 		} ,
	-- 		["title"] = "some-title",
	-- 		["hidden"] = false,
	-- 	},
	-- }

	local all = {quests = {}}
	questGroupsByName = {all = all}
	local currentGroup
	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local info = C_QuestLog.GetInfo(i)
		if info.isHeader then
			currentGroup = {
				title = info.title,
				hidden = true,
				quests = {}
			}
			questGroupsByName[Slug(info.title)] = currentGroup
		else
			currentGroup.hidden = currentGroup.hidden and info.isHidden
			currentGroup.quests[info.questID] = info.title
			all.quests[info.questID] = info.title
		end
	end
	
	self:Debug(self:Dump(questGroupsByName))
end

function E:AbandonAllQuests()
	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local info = C_QuestLog.GetInfo(i)
		self:AbandonQuest(info.title, info.questID)
	end
end

function E:AbandonQuests(slug)
	local group = questGroupsByName[slug] or {}
	for questId, title in pairs(group.quests or {}) do
		self:AbandonQuest(title, questId)
	end
	questGroupsByName[slug] = nil
end

function E:AbandonQuest(title, questId)
	if C_QuestLog.CanAbandonQuest(questId) then
		self:Print(format(L["|cFFFFFF00Abandoned quest %s|r"], CreateQuestLink(questId, title)))
		C_QuestLog.SetSelectedQuest(questId)
		C_QuestLog.SetAbandonQuest()
		C_QuestLog.AbandonQuest()
	else
		self:Print(format(L["|cFFFFFF00You can't abandon %s|r"], CreateQuestLink(questId, title)))
	end
end

function E:CopyTable(currentTable, defaultTable)
	if type(currentTable) ~= "table" then
		currentTable = {}
	end

	if type(defaultTable) == "table" then
		for option, value in pairs(defaultTable) do
			if type(value) == "table" then
				value = E:CopyTable(currentTable[option], value)
			end

			currentTable[option] = value
		end
	end

	return currentTable
end

function E:ResetProfile()
	E.db = E:CopyTable({}, E.DF.profile)
	self:Debug("Profile Reset!")
end

function E:Initialize()
	twipe(E.db)
	twipe(E.global)
	twipe(E.private)

	E.myguid = UnitGUID("player")
	E.data = E.Libs.AceDB:New("RecklessAbandonDB", E.DF)
	E.charSettings = E.Libs.AceDB:New("RecklessAbandonPrivateDB", E.privateVars)

	E.private = E.charSettings.profile
	E.db = E.data.profile
	E.global = E.data.global

	QuestMapFrame:HookScript("OnShow", ButtonsShow)
	QuestMapFrame:HookScript("OnEvent", ButtonsShow)
	QuestMapFrame:HookScript("OnHide", ButtonsHide)

	QuestScrollFrame:HookScript(
		"OnVerticalScroll",
		function()
			for button in questButtonPool:EnumerateInactive() do
				ButtonUpdate(button)
			end

			for button in questButtonPool:EnumerateActive() do
				ButtonUpdate(button)
			end

			for button in zoneButtonPool:EnumerateInactive() do
				ButtonUpdate(button)
			end

			for button in zoneButtonPool:EnumerateActive() do
				ButtonUpdate(button)
			end
		end
	)

	E.initialized = true
end
