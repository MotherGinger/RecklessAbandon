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
-- TODO: We might want to create custom textures for each type
local questButtonPool = CreateFramePool("Button", QuestMapFrame.QuestsFrame, "RECKLESS_ABANDON_BUTTON")
local groupButtonPool = CreateFramePool("Button", QuestMapFrame.QuestsFrame, "RECKLESS_GROUP_ABANDON_BUTTON")

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

local function getKey(value)
	if value ~= nil then
		return value:lower():gsub("[^a-z]", "")
	end
end

local function RenderAbandonButton(parent, offset, questId, excluded, title, tooltip)
	title = title or parent:GetText()
	tooltip = tooltip or title .. "\n\n" .. L["Left Click: Abandon quest"] .. "\n" .. (excluded and L["Right Click: Include quest in group abandons"] or L["Right Click: Exclude quest from group abandons"])

	local button = questButtonPool:Acquire()
	local texture = button:GetNormalTexture()
	local canAbandon = C_QuestLog.CanAbandonQuest(questId)

	button.title = title
	button.tooltip = tooltip
	button.questId = questId
	button:SetPoint("CENTER", parent, "CENTER", offset, 0)
	button:SetEnabled(canAbandon)
	texture:SetDesaturated(not canAbandon)

	if canAbandon and excluded then
		texture:SetVertexColor(0.5, 0.5, 1, 0.7)
	elseif canAbandon and not excluded then
		texture:SetVertexColor(1, 1, 1, 1)
	end

	button:SetNormalTexture(texture)
	button:Show()
end

local function RenderGroupAbandonButton(parent, offset, title, tooltip, key)
	title = title or parent:GetText()
	tooltip = tooltip or format(L["Left Click: Abandon all '%s' quests"], title)
	key = key or getKey(title)

	if questGroupsByName[key] then
		local button = groupButtonPool:Acquire()
		local texture = button:GetNormalTexture()
		local hasQuests = not E:IsEmpty(questGroupsByName[key].quests)
		local canAbandonAny = E:CanQuestGroupAbandon(questGroupsByName[key].quests)

		button.title = title
		button.tooltip = tooltip
		button.key = key
		button:SetPoint("CENTER", parent, "CENTER", offset, 0)
		button:SetEnabled(hasQuests and canAbandonAny)
		texture:SetDesaturated(not hasQuests or not canAbandonAny)
		button:SetNormalTexture(texture)
		button:Show()
	end
end

local function ShowAbandonButtons()
	questButtonPool:ReleaseAll()
	groupButtonPool:ReleaseAll()

	if (E.db.general.campaignQuests.showAbandonButton) then
		for header in QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
			RenderGroupAbandonButton(header.LoreButton, -25, header.Text:GetText())
		end
	end

	if (E.db.general.covenantCallings.showAbandonButton) then
		for calling in QuestScrollFrame.covenantCallingsHeaderFramePool:EnumerateActive() do
			local title = C_QuestLog.GetInfo(calling.questLogIndex).title
			local key = getKey(title)
			RenderGroupAbandonButton(calling, QuestScrollFrame:GetWidth() - 50, L["covenant callings"], L["Left Click: Abandon all covenant calling quests"], key)
		end
	end

	if (E.db.general.zoneQuests.showAbandonButton) then
		for header in QuestScrollFrame.headerFramePool:EnumerateActive() do
			RenderGroupAbandonButton(header, QuestScrollFrame:GetWidth() - 25)
		end
	end

	if (E.db.general.individualQuests.showAbandonButton) then
		for quest in QuestScrollFrame.titleFramePool:EnumerateActive() do
			local questId = quest.questID
			local text = quest.Text:GetText()
			local excluded = E:IsExcluded(questId)
			RenderAbandonButton(quest.TaskIcon, QuestScrollFrame:GetWidth() - 50, questId, excluded, text)
		end
	end
end

local function HideAbandonButtons()
	questButtonPool:ReleaseAll()
	groupButtonPool:ReleaseAll()
end

function onButtonEnter(self)
	GameTooltip:SetOwner(self)
	GameTooltip:SetText(self.tooltip)
	GameTooltip:Show()
end

function onButtonLeave(self)
	GameTooltip:Hide()
end

function onAbandonButtonClick(self, button)
	if button == "LeftButton" then
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
	elseif button == "RightButton" then
		local texture = self:GetNormalTexture()
		local excluded = E:IsExcluded(self.questId)

		if excluded then
			E:IncludeQuest(self.title, self.questId)
			texture:SetVertexColor(1, 1, 1, 1)
			self.tooltip = self.title .. "\n\n" .. L["Left Click: Abandon quest"] .. "\n" .. L["Right Click: Exclude quest from group abandons"]
		else
			E:ExcludeQuest(self.title, self.questId)
			texture:SetVertexColor(0.5, 0.5, 1, 0.7)
			self.tooltip = self.title .. "\n\n" .. L["Left Click: Abandon quest"] .. "\n" .. L["Right Click: Include quest in group abandons"]
		end

		self:SetNormalTexture(texture)
	end
end

function onGroupAbandonButtonClick(self, button)
	if button == "LeftButton" then
		if E.db.general.confirmGroup then
			local dialog = StaticPopup_Show("RECKLESS_ABANDON_GROUP_CONFIRMATION", self.title)
			if dialog then
				dialog.data = self.key
			end
		else
			E:AbandonQuests(self.key)
		end
	end
end

function onButtonUpdate(self)
	local buffer = 10
	local bottom = self:GetBottom()
	local top = self:GetTop()

	if (bottom ~= nil and top ~= nil) then
		if bottom > QuestScrollFrame:GetBottom() - buffer and top < QuestScrollFrame:GetTop() + buffer then
			self:Show()
		else
			self:Hide()
		end
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

function E:CreateQuestLink(questId, title)
	return format("|cff808080|Hquest:%d|h[%s]|h|r", questId, title)
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

	local currentGroup

	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local info = C_QuestLog.GetInfo(i)
		if info.isHeader then
			currentGroup = {
				title = info.title,
				hidden = true,
				quests = {}
			}
			questGroupsByName[getKey(info.title)] = currentGroup
		else
			currentGroup.hidden = currentGroup.hidden and info.isHidden
			currentGroup.quests[info.questID] = info.title
		end
	end

	self:Debug(self:Dump(questGroupsByName))
end

function E:AbandonAllQuests()
	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local info = C_QuestLog.GetInfo(i)
		local questId = info.questID
		local title = info.title

		if (not self.private.exclusions.excludedQuests[questId]) then
			self:AbandonQuest(title, questId)
		else
			self:Print(format(L["Skipping %s since it is excluded from group abandons"], self:CreateQuestLink(questId, title)))
		end
	end
end

function E:AbandonQuests(key)
	local group = questGroupsByName[key] or {}
	self:Print(self:Dump(group))
	for questId, title in pairs(group.quests or {}) do
		if (not self.private.exclusions.excludedQuests[questId]) then
			self:AbandonQuest(title, questId)
		else
			self:Print(format(L["Skipping %s since it is excluded from group abandons"], self:CreateQuestLink(questId, title)))
		end
	end

	if self:IsEmpty(group.quests) then
		questGroupsByName[key] = nil
	end
end

function E:AbandonQuest(title, questId)
	if C_QuestLog.CanAbandonQuest(questId) then
		self:Print(format(L["|cFFFFFF00Abandoned quest %s|r"], self:CreateQuestLink(questId, title)))
		C_QuestLog.SetSelectedQuest(questId)
		C_QuestLog.SetAbandonQuest()
		C_QuestLog.AbandonQuest()
	else
		self:Print(format(L["|cFFFFFF00You can't abandon %s|r"], self:CreateQuestLink(questId, title)))
	end
end

function E:ExcludeQuest(title, questId)
	self:Print(format(L["Excluding quest %s from group abandons"], self:CreateQuestLink(questId, title)))
	self.private.exclusions.excludedQuests[questId] = title
end

function E:IncludeQuest(title, questId)
	self:Print(format(L["Including quest %s in group abandons"], self:CreateQuestLink(questId, title)))
	self.private.exclusions.excludedQuests[questId] = nil
end

function E:IsExcluded(questId)
	return self.private.exclusions.excludedQuests[questId] ~= nil
end

function E:CanQuestGroupAbandon(quests)
	for questId, _ in pairs(quests) do
		if C_QuestLog.CanAbandonQuest(questId) then
			return true
		end
	end

	return false
end

function E:ClearQuestExclusions()
	for questId, title in pairs(E.private.exclusions.excludedQuests) do
		self:IncludeQuest(title, questId)
	end
end

function E:Initialize()
	twipe(E.db)
	twipe(E.global)
	twipe(E.private)

	E.myguid = UnitGUID("player")
	E.data = E.Libs.AceDB:New("RecklessAbandonDB", E.DF, true)
	E.charSettings = E.Libs.AceDB:New("RecklessAbandonPrivateDB", E.privateVars)

	E.private = E.charSettings.profile
	E.db = E.data.profile
	E.global = E.data.global

	E.Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(E.data)
	E.Options.args.profiles.order = 1

	QuestMapFrame:HookScript("OnShow", ShowAbandonButtons)
	QuestMapFrame:HookScript("OnEvent", ShowAbandonButtons)
	QuestMapFrame:HookScript("OnHide", HideAbandonButtons)

	QuestScrollFrame:HookScript(
		"OnVerticalScroll",
		function()
			for button in questButtonPool:EnumerateActive() do
				onButtonUpdate(button)
			end

			for button in groupButtonPool:EnumerateActive() do
				onButtonUpdate(button)
			end
		end
	)

	E.initialized = true
end
