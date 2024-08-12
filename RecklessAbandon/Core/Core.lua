local RecklessAbandon = select(2, ...)
RecklessAbandon[2] = RecklessAbandon[1].Libs.ACL:GetLocale("RecklessAbandon", RecklessAbandon[1]:GetLocale()) -- Locale doesn't exist yet, make it exist.
local E, L, V, P, G = unpack(RecklessAbandon)                                                                 --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

-- Globals
LOG_LEVEL_SYSTEM = 0
LOG_LEVEL_ERROR = 1
LOG_LEVEL_WARN = 2
LOG_LEVEL_INFO = 3
LOG_LEVEL_VERBOSE = 4
LOG_LEVEL_DEBUG = 5

MANUAL = 0
AUTOMATIC = 1

--Lua functions
local _G = _G
local tonumber, pairs, ipairs, unpack, tostring = tonumber, pairs, ipairs, unpack, tostring
local gsub, strjoin, twipe = gsub, strjoin, wipe
local format, find = format, strfind
local type, print = type, print

--WoW API / Variables
local CreateFrame = CreateFrame
local GetQuestLink = GetQuestLink
local IsInRaid = IsInRaid
local SetCVar = SetCVar
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID

--Constants
E.noop = function()
end
E.title = format("|cFF80528C%s|r", "Reckless Abandon")
E.version = C_AddOns.GetAddOnMetadata("RecklessAbandon", "Version")
E.author = C_AddOns.GetAddOnMetadata("RecklessAbandon", "Author")
E.github = "https://github.com/MotherGinger/RecklessAbandon/issues"
E.mylevel = UnitLevel("player")
E.myname = UnitName("player")
E.myrealm = GetRealmName()
E.mynameRealm = format("%s - %s", E.myname, E.myrealm) -- contains spaces/dashes in realm (for profile keys)
E.wowpatch, E.wowbuild = GetBuildInfo()
E.wowbuild = tonumber(E.wowbuild)
E.isMacClient = IsMacClient()
E.IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
E.validVersion = WOW_PROJECT_MAINLINE
E.screenwidth, E.screenheight = GetPhysicalScreenSize()
E.resolution = format("%dx%d", E.screenwidth, E.screenheight)
E.wowVersionMatrix = {
	[WOW_PROJECT_MAINLINE] = "Retail"
}
E.logLevels = {
	[LOG_LEVEL_ERROR] = L["Only show messages for errors"],
	[LOG_LEVEL_WARN] = L["Only show messages for warnings and errors"],
	[LOG_LEVEL_INFO] = L["Only show important messages"],
	[LOG_LEVEL_VERBOSE] = L["Show all messages (default)"]
}

local abandonTooltipFormat = "|cFFFFFAB8%s|r\n\n|cFFFFF569%s|r\n|cFFB5FFEB%s|r"
local groupAbandonTooltipFormat = "|cFFFFFAB8%s|r\n\n|cFFFFF569%s|r"
local questGroupsByName = {}
-- TODO: We might want to create custom textures for each type
local questButtonPool = CreateFramePool("Button", QuestMapFrame.QuestsFrame, "RECKLESS_ABANDON_BUTTON")
local groupButtonPool = CreateFramePool("Button", QuestMapFrame.QuestsFrame, "RECKLESS_GROUP_ABANDON_BUTTON")

local MyScanningTooltip = CreateFrame("GameTooltip", "MyScanningTooltip", UIParent, "GameTooltipTemplate")
local QuestTitleFromID =
	setmetatable(
		{},
		{
			__index = function(t, id)
				MyScanningTooltip:SetOwner(UIParent, "ANCHOR_NONE")
				MyScanningTooltip:SetHyperlink("quest:" .. id)
				local title = MyScanningTooltipTextLeft1:GetText()
				MyScanningTooltip:Hide()
				if title and title ~= RETRIEVING_DATA then
					t[id] = title
					return title
				end
			end
		}
	)

StaticPopupDialogs["RECKLESS_ABANDON_GROUP_CONFIRMATION"] = {
	text = table.concat(
		{
			L["Are you sure you want to abandon all quests in |cFFF2E699%s|r?"],
			L["|cFFFF6B6BThis cannot be undone.|r"]
		},
		"\n\n"
	),
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function(self, quests)
		E:AbandonZoneQuests(quests)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3
}

StaticPopupDialogs["RECKLESS_ABANDON_CONFIRMATION"] = {
	text = table.concat(
		{
			L["Are you sure you want to abandon |cFFF2E699%s|r?"],
			L["|cFFFF6B6BThis cannot be undone.|r"]
		},
		"\n\n"
	),
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function(self, data)
		E:AbandonQuest(data.questId, true)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3
}

StaticPopupDialogs["RECKLESS_ABANDON_ALL_CONFIRMATION"] = {
	text = table.concat(
		{ L["Are you sure you want to abandon all of the quests in your questlog?"], L
			["|cFFFF6B6BThis cannot be undone.|r"] },
		"\n\n"
	),
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

StaticPopupDialogs["RECKLESS_QUALIFIER_ABANDON_CONFIRMATION"] = {
	text = table.concat(
		{
			L["Are you sure you want to abandon the following %s quests?"],
			"|cFFF2E699%s|r",
			L["|cFFFF6B6BThis cannot be undone.|r"]
		},
		"\n\n"
	),
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function(self, data)
		E:AbandonQuests(data.questIds)
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

local function getKeybinding(button)
	if button == "LeftButton" then
		button = "BUTTON1"
	elseif button == "RightButton" then
		button = "BUTTON2"
	elseif button == "MiddleButton" then
		button = "BUTTON3"
	elseif button == "Button4" then
		button = "BUTTON4"
	elseif button == "Button5" then
		button = "BUTTON5"
	end

	if IsShiftKeyDown() then
		button = "SHIFT-" .. button
	end

	if IsControlKeyDown() then
		button = "CTRL-" .. button
	end

	if IsAltKeyDown() then
		button = "ALT-" .. button
	end

	return button
end

local function RenderAbandonButton(parent, offset, questId, excluded, title, tooltip)
	title = title or parent:GetText()
	tooltip =
		tooltip or
		format(
			abandonTooltipFormat,
			title,
			L["Left Click: Abandon quest"],
			(excluded and L["Right Click: Include quest in group abandons"] or
				L["Right Click: Exclude quest from group abandons"])
		)

	local button = questButtonPool:Acquire()
	local canAbandon = C_QuestLog.CanAbandonQuest(questId)

	local ntex = button:GetNormalTexture()
	local ptex = button:GetPushedTexture()
	local htex = button:GetHighlightTexture()

	ntex:SetTexCoord(0.25, 0.80, 0.20, 0.75)
	ptex:SetTexCoord(0.25, 0.80, 0.20, 0.75)
	htex:SetTexCoord(0.25, 0.80, 0.20, 0.75)

	button.title = title
	button.tooltip = tooltip
	button.questId = questId

	ntex:SetDesaturated(not canAbandon)

	if canAbandon and excluded then
		ntex:SetVertexColor(0.5, 0.5, 1, 0.7)
	else
		ntex:SetVertexColor(1, 1, 1, 1)
	end

	button:SetPoint("CENTER", parent, "CENTER", offset, 0)
	button:SetEnabled(canAbandon)
	button:SetNormalTexture(ntex)
	button:SetPushedTexture(ptex)
	button:SetHighlightTexture(htex)
	button:Show()
end

local function RenderGroupAbandonButton(parent, offset, title, tooltip, key)
	title = title or parent:GetText()
	tooltip = tooltip or format(groupAbandonTooltipFormat, title, L["Left Click: Abandon all quests"], title)
	key = key or getKey(title)

	if questGroupsByName[key] then
		local button = groupButtonPool:Acquire()
		local hasQuests = not E:IsEmpty(questGroupsByName[key].quests)
		local canAbandonAny = E:CanQuestGroupAbandon(questGroupsByName[key].quests)

		local ntex = button:GetNormalTexture()
		local ptex = button:GetPushedTexture()
		local htex = button:GetHighlightTexture()

		ntex:SetTexCoord(0.25, 0.80, 0.20, 0.75)
		ptex:SetTexCoord(0.25, 0.80, 0.20, 0.75)
		htex:SetTexCoord(0.25, 0.80, 0.20, 0.75)

		button.title = title
		button.tooltip = tooltip
		button.key = key

		ntex:SetDesaturated(not hasQuests or not canAbandonAny)

		button:SetPoint("CENTER", parent, "CENTER", offset, 0)
		button:SetEnabled(hasQuests and canAbandonAny)
		button:SetNormalTexture(ntex)
		button:SetPushedTexture(ptex)
		button:SetHighlightTexture(htex)
		button:Show()
	end
end

local function ShowAbandonButtons()
	questButtonPool:ReleaseAll()
	groupButtonPool:ReleaseAll()

	-- Guard against a bad cache (https://github.com/MotherGinger/RecklessAbandon/issues/25)
	if E.db ~= nil and E.db.general ~= nil then
		if E.db.general.campaignQuests.showAbandonButton then
			for header in QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
				RenderGroupAbandonButton(header.CollapseButton, -25, header.Text:GetText())
			end
		end

		if E.db.general.covenantCallings.showAbandonButton then
			for calling in QuestScrollFrame.covenantCallingsHeaderFramePool:EnumerateActive() do
				local info = C_QuestLog.GetInfo(calling.questLogIndex)
				if info then
					local title = info.title
					local key = getKey(title)
					RenderGroupAbandonButton(
						calling.CollapseButton,
						-25,
						L["covenant callings"],
						L["Left Click: Abandon all covenant calling quests"],
						key
					)
				end
			end
		end

		if E.db.general.zoneQuests.showAbandonButton then
			for header in QuestScrollFrame.headerFramePool:EnumerateActive() do
				RenderGroupAbandonButton(header.CollapseButton, -25, header.ButtonText:GetText())
			end
		end

		if E.db.general.individualQuests.showAbandonButton then
			for quest in QuestScrollFrame.titleFramePool:EnumerateActive() do
				local questId = quest.questID
				local text = quest.Text:GetText()
				local excluded = E:IsExcluded(questId)

				-- * This tag shows up in both the tooltip and the details pane, so lets hide it and collect more real estate for our button
				-- TODO: This is a partial workaround since this will pop back in when hiding the details pane
				quest.TagTexture:Hide()
				RenderAbandonButton(quest.Checkbox, -25, questId, excluded, text)
			end
		end
	end
end

local function HideAbandonButtons()
	questButtonPool:ReleaseAll()
	groupButtonPool:ReleaseAll()
end

local function onQuestLogEntryClick(self, button, down)
	local abandonQuestBinding = E.db.general.individualQuests.abandonBinding
	local excludeQuestBinding = E.db.general.individualQuests.excludeBinding
	local binding = getKeybinding(button)
	local isBound =
		(isHeader and binding == groupAbandonQuestBinding) or binding == abandonQuestBinding or
		binding == excludeQuestBinding

	-- * If the click matches a binding, disable default behaviors
	-- * In retail this prevents things like the right click context menu or the full page quest description
	if self.origOnClick and not isBound then
		self:origOnClick(button, down)
	end
end

local function onQuestLogEntryMouseDown(self, button)
	local info = C_QuestLog.GetInfo(self.questLogIndex)
	local title = info.title
	local isHeader = info.isHeader
	local questId = info.questID
	local abandonQuestBinding = E.db.general.individualQuests.abandonBinding
	local excludeQuestBinding = E.db.general.individualQuests.excludeBinding
	local groupAbandonQuestBinding = E.db.general.zoneQuests.abandonBinding
	local binding = getKeybinding(button)

	if isHeader and binding == groupAbandonQuestBinding then
		if E.db.general.confirmGroup then
			local dialog = StaticPopup_Show("RECKLESS_ABANDON_GROUP_CONFIRMATION", title)
			if dialog then
				dialog.data = getKey(title)
			end
		else
			E:AbandonZoneQuests(getKey(title))
		end
		E:Debug(format(L["%s abandoned via keybinding (%s)"], title, binding))
	elseif binding == abandonQuestBinding then
		if E.db.general.confirmIndividual then
			local dialog = StaticPopup_Show("RECKLESS_ABANDON_CONFIRMATION", title)
			if dialog then
				dialog.data = {
					questId = questId
				}
			end
		else
			E:AbandonQuest(questId)
		end
		E:Debug(format(L["%s abandoned via keybinding (%s)"], title, binding))
	elseif binding == excludeQuestBinding then
		local excluded = E:IsExcluded(questId)

		if excluded then
			E:IncludeQuest(questId)
			E:Debug(format(L["%s included via keybinding (%s)"], title, binding))
		else
			E:ExcludeQuest(questId, MANUAL)
			E:Debug(format(L["%s excluded via keybinding (%s)"], title, binding))
		end

		ShowAbandonButtons()
	end

	if self.origOnMouseDown then
		self:origOnMouseDown(button)
	end
end

function onButtonEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(self.tooltip)
	GameTooltip.NineSlice:SetBorderColor(255, 255, 255)
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
					questId = self.questId
				}
			end
		else
			E:AbandonQuest(self.questId, true)
		end
	elseif button == "RightButton" then
		local texture = self:GetNormalTexture()
		local excluded = E:IsExcluded(self.questId)

		if excluded then
			E:IncludeQuest(self.questId)
			texture:SetVertexColor(1, 1, 1, 1)
			self.tooltip =
				format(
					abandonTooltipFormat,
					self.title,
					L["Left Click: Abandon quest"],
					L["Right Click: Exclude quest from group abandons"]
				)
		else
			E:ExcludeQuest(self.questId, MANUAL)
			texture:SetVertexColor(0.5, 0.5, 1, 0.7)
			self.tooltip =
				format(
					abandonTooltipFormat,
					self.title,
					L["Left Click: Abandon quest"],
					L["Right Click: Include quest in group abandons"]
				)
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
			E:AbandonZoneQuests(self.key)
		end
	end
end

function onButtonUpdate(self)
	local buffer = 10
	local bottom = self:GetBottom()
	local top = self:GetTop()

	if bottom ~= nil and top ~= nil then
		if bottom > QuestScrollFrame:GetBottom() - buffer and top < QuestScrollFrame:GetTop() + buffer then
			self:Show()
		else
			self:Hide()
		end
	end
end

function E:Print(logLevel, ...)
	if (logLevel <= E.db.general.logLevel) then
		print(strjoin("", E.title, ": ", ...))
	end
end

function E:Verbose(...)
	self:Print(LOG_LEVEL_VERBOSE, ...)
end

function E:Info(...)
	self:Print(LOG_LEVEL_INFO, ...)
end

function E:Warn(...)
	self:Print(LOG_LEVEL_WARN, ...)
end

function E:Error(...)
	self:Print(LOG_LEVEL_ERROR, ...)
end

function E:System(...)
	self:Print(LOG_LEVEL_SYSTEM, ...)
end

function E:Critical(...)
	print(strjoin("", E.title, format("|cFFFF6B6B: %s|r", ...)))
end

function E:Debug(...)
	if self.db.debugging.debugLogging then
		print(strjoin("", format(L["|cffffcc00%s Debug:|r"], E.title), " ", ...))
	end
end

function E:UpdatePlayerLevel(level)
	self:Debug(format("%s leveled up (%d -> %d)!", E.myname, E.mylevel, level))
	E.mylevel = level
end

function E:GetQuestColor(level)
	local levelDiff = level - E.mylevel

	if levelDiff >= 5 then
		return L["red"]
	elseif levelDiff >= 3 then
		return L["orange"]
	elseif levelDiff >= -2 then
		return L["yellow"]
	elseif -levelDiff <= UnitQuestTrivialLevelRange("player") then
		return L["green"]
	else
		return L["gray"]
	end
end

function E:GetAvailableQualifiers()
	local qualifiers = {
		[L["daily"]] = L["Matches all daily quests."],
		[L["weekly"]] = L["Matches all weekly quests."],
		[L["green"]] = L["Matches all green quests."],
		[L["yellow"]] = L["Matches all yellow quests."],
		[L["orange"]] = L["Matches all orange quests."],
		[L["red"]] = L["Matches all red quests."],
		[L["gray"]] = L["Matches all gray quests."]
	}

	local selections = {
		["daily"] = DAILY,
		["weekly"] = WEEKLY,
		["green"] = L["Green"],
		["yellow"] = L["Yellow"],
		["orange"] = L["Orange"],
		["red"] = L["Red"],
		["gray"] = L["Gray"]
	}

	return qualifiers, selections
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
		if info.isHeader then -- ! caused an issue, info undefined
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

	self:Debug(L["Quest Table: "] .. self:Dump(questGroupsByName))
	self:Debug(L["Excluded Quests: "] .. self:Dump(self.private.exclusions.excludedQuests))
end

function E:AbandonAllQuests()
	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local info = C_QuestLog.GetInfo(i)
		local questId = info.questID

		if not info.isHeader and not info.isHidden then
			self:AbandonQuest(questId)
		end
	end
end

function E:AbandonZoneQuests(key)
	local group = questGroupsByName[key] or {}
	for questId, _ in pairs(group.quests or {}) do
		self:AbandonQuest(questId)
	end

	if self:IsEmpty(group.quests) then
		questGroupsByName[key] = nil
	end
end

function E:AbandonQuests(questIds)
	for _, questId in ipairs(questIds) do
		self:AbandonQuest(questId)
	end
end

function E:AbandonQuest(questId, exclusionBypass)
	if exclusionBypass or not self.private.exclusions.excludedQuests[questId] then
		if C_QuestLog.CanAbandonQuest(questId) then
			C_QuestLog.SetSelectedQuest(questId)
			C_QuestLog.SetAbandonQuest()
			C_QuestLog.AbandonQuest()

			self:System(format(L["|cFFFFFF00Abandoned quest %s|r"], GetQuestLink(questId)))

			if E.private.exclusions.autoPrune and self:IsExcluded(questId) then
				self:PruneQuestExclusion(questId)
			end
		else
			self:Warn(format(L["|cFFFFFF00You can't abandon %s|r"], GetQuestLink(questId)))
		end
	else
		self:Verbose(format(L["Skipping %s since it is excluded from group abandons"], GetQuestLink(questId)))
	end
end

function E:ExcludeQuest(questId, source)
	local source = source or MANUAL
	self:Verbose(format(L["Excluding quest %s from group abandons"], GetQuestLink(questId)))
	self.private.exclusions.excludedQuests[tonumber(questId)] = {
		["title"] = QuestTitleFromID[questId],
		["source"] = source
	}

	E:RefreshGUI()
end

function E:IncludeQuest(questId)
	self:Verbose(format(L["Including quest %s in group abandons"], GetQuestLink(questId)))
	self.private.exclusions.excludedQuests[tonumber(questId)] = nil

	E:RefreshGUI()
end

function E:IsExcluded(questId)
	return self.private.exclusions.excludedQuests[tonumber(questId)] ~= nil
end

function E:CanQuestGroupAbandon(quests)
	for questId, _ in pairs(quests) do
		if C_QuestLog.CanAbandonQuest(questId) then
			return true
		end
	end

	return false
end

function E:PruneQuestExclusionsFromAutomation()
	if E.private.exclusions.autoPrune then
		local count = 0
		for questId, meta in pairs(E.private.exclusions.excludedQuests) do
			local orphaned = C_QuestLog.GetLogIndexForQuestID(questId) == nil
			local source = meta.source
			if orphaned and source == AUTOMATIC then
				count = count + 1
				self:PruneQuestExclusion(questId)
			end
		end

		self:Debug(format(L["Pruned %s automation |4orphan:orphans;!"], count))
	end
end

function E:PruneQuestExclusion(questId)
	local title = E.private.exclusions.excludedQuests[tonumber(questId)]["title"]
	self:Verbose(format(L["Pruning '%s' from the exclusion list"], title))
	E.private.exclusions.excludedQuests[tonumber(questId)] = nil

	E:RefreshGUI()
end

function E:ClearQuestExclusions()
	for questId, _ in pairs(E.private.exclusions.excludedQuests) do
		local orphaned = C_QuestLog.GetLogIndexForQuestID(questId) == nil
		if orphaned then
			self:PruneQuestExclusion(questId)
		else
			self:IncludeQuest(questId)
		end
	end
end

function E:PruneQuestExclusions()
	local count = 0
	for questId, _ in pairs(E.private.exclusions.excludedQuests) do
		local orphaned = C_QuestLog.GetLogIndexForQuestID(questId) == nil
		if orphaned then
			count = count + 1
			self:PruneQuestExclusion(questId)
		end
	end

	self:Info(format(L["Pruned %s |4orphan:orphans;!"], count))
end

function E:AutoAbandonQuests()
	-- * This will abandon all quests of types that have been elected for automatic abandons
	-- * This is O(n)

	local count = 0

	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local info = C_QuestLog.GetInfo(i)
		local title = info.title
		local questId = info.questID
		local level = info.level
		local isDaily = info.frequency == 1
		local isWeekly = info.frequency == 2
		local isComplete = C_QuestLog.IsComplete(questId)

		if not info.isHeader then
			local levelDiff = level - E.mylevel
			local color = self:GetQuestColor(level)

			local autoAbandonQuests = self.private.automationOptions.autoAbandonQuests
			local ids = autoAbandonQuests.ids or "" -- These should never be nil, but lets guard against a corrupt config

			local abandonQuestId = E:TableContainsValue({ strsplit(",", ids) }, questId)
			local gray = autoAbandonQuests.questType.gray and L["gray"] == color
			local green = autoAbandonQuests.questType.green and L["green"] == color
			local orange = autoAbandonQuests.questType.orange and L["orange"] == color
			local red = autoAbandonQuests.questType.red and L["red"] == color
			local daily = autoAbandonQuests.questType.daily and isDaily
			local weekly = autoAbandonQuests.questType.weekly and isWeekly
			local yellow = autoAbandonQuests.questType.yellow and L["yellow"] == color

			if abandonQuestId or gray or green or orange or red or daily or yellow or weekly then
				-- ! This triggers a second UNIT_QUEST_LOG_CHANGED event which reattempts to abandon excluded quests
				-- ! This is a bit spammy and needs to be throttled somehow
				if self:AbandonQuest(questId) then
					count = count + 1
				end
			end
		end
	end

	if count > 0 then
		self:Info(format("Automatically abandoned %s |4quest:quests;!", count))
	end
end

-- TODO: Provide an auto exclude option under automation options, and perform similar evaluations as AutoAbandonQuests
function E:AutoExcludeQuests()
	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local info = C_QuestLog.GetInfo(i)
		local questId = info.questID
		local isComplete = C_QuestLog.IsComplete(questId)

		if not info.isHeader then
			if self.db.general.individualQuests.completeProtection and isComplete and not self:IsExcluded(questId) then
				self:ExcludeQuest(questId, AUTOMATIC)
			end
		end
	end
end

function E:PrintWelcomeMessage()
	if self.db.general.loginMessage then
		self:System(format(L["You are running |cFFB5FFEBv%s|r. Type |cff888888/rab|r to configure settings."], E.version))
	end

	if not WOW_PROJECT_ID == E.validVersion then
		self:Critical(
			format(
				L[
				"You have installed a version of this addon intended for |cFFFFFAB8%s|r, however you are currently playing |cFFFFFAB8%s|r. You may encounter serious issues with this setup. Please install the proper version from Github, CurseForge, Wago, or WoWInterface, and restart the game."
				],
				E.wowVersionMatrix[E.validVersion],
				E.wowVersionMatrix[WOW_PROJECT_ID]
			)
		)
	end

	if strfind(E.version, "alpha") or strfind(E.version, "beta") then
		self:System(
			format(
				L[
				"You are currently running a pre-release version of %s. Please report any issues on github (|cFFB5FFEB%s|r) so they can be addressed quickly. Thank you for your interest in testing new features!"
				],
				E.title,
				E.github
			)
		)
	end
end

function E:NormalizeSettings()
	-- * Verify default settings and guard against corrupted tables

	-- Set log level if not set
	if E.db.general.logLevel == nil then
		E.db.general.logLevel = LOG_LEVEL_VERBOSE
	end

	-- Rebuild exclusion list
	if E.private.exclusions.excludedQuests ~= nil then
		for k, v in pairs(E.private.exclusions.excludedQuests) do
			if (type(v) == "string") then
				E.private.exclusions.excludedQuests[k] = { ["title"] = v, ["source"] = MANUAL }
			end
		end
	end

	-- Rebuild automation options
	if
		E.private.automationOptions.autoAbandonQuests.questType == nil or
		E:IsEmpty(E.private.automationOptions.autoAbandonQuests.questType)
	then
		E.private.automationOptions.autoAbandonQuests.questType = nil
		E.private.automationOptions.autoAbandonQuests = {
			["questType"] = E.private.automationOptions.autoAbandonQuests
		}
	end

	-- Rebuild command settings
	if E.db.commands.generic == nil or E:IsEmpty(E.db.commands.generic) then
		E.db.commands = {
			["generic"] = E.db.commands
		}
	end
end

function E:RegisterHotkeys()
	for quest in QuestScrollFrame.titleFramePool:EnumerateActive() do
		if not quest.hasOnMouseDownScript then
			quest.origOnClick = quest:GetScript("OnClick")
			quest.origOnMouseDown = quest:GetScript("OnMouseDown")

			quest:SetScript("OnClick", onQuestLogEntryClick)
			quest:SetScript("OnMouseDown", onQuestLogEntryMouseDown)

			quest.hasOnMouseDownScript = true
		end
	end

	for header in QuestScrollFrame.headerFramePool:EnumerateActive() do
		if not header.hasOnMouseDownScript then
			header.origOnMouseDown = header:GetScript("OnMouseDown")

			header:SetScript("OnMouseDown", onQuestLogEntryMouseDown)

			header.hasOnMouseDownScript = true
		end
	end
end

function E:Initialize()
	twipe(E.db)
	twipe(E.global)
	twipe(E.private)

	E.myguid = UnitGUID("player")
	E.data = E.Libs.AceDB:New("RecklessAbandonDB", E.DF, true)
	E.data.RegisterCallback(E, "OnProfileChanged", "RefreshOptions")
	E.data.RegisterCallback(E, "OnProfileCopied", "RefreshOptions")
	E.data.RegisterCallback(E, "OnProfileReset", "RefreshOptions")
	E.charSettings = E.Libs.AceDB:New("RecklessAbandonPrivateDB", E.privateVars)
	E.charSettings.RegisterCallback(E, "OnProfileReset", "RefreshOptions")

	E.private = E.charSettings.profile
	E.db = E.data.profile
	E.global = E.data.global

	E.Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(E.data)
	E.Options.args.profiles.order = 1

	E:NormalizeSettings()

	QuestMapFrame:HookScript(
		"OnShow",
		function()
			E:GenerateQuestTable()
			ShowAbandonButtons()
			E:RegisterHotkeys()
		end
	)
	QuestMapFrame:HookScript(
		"OnEvent",
		function()
			E:GenerateQuestTable()
			ShowAbandonButtons()
			E:RegisterHotkeys()
		end
	)
	QuestMapFrame:HookScript("OnHide", HideAbandonButtons)

	QuestMapFrame.QuestsFrame.SearchBox:HookScript(
		"OnTextChanged",
		function()
			-- * This is inefficient since these really only need to be adjusted when search results change
			-- * However, there does not appear to be an exposed API to hook into to do this
			ShowAbandonButtons()
		end
	)

	QuestScrollFrame:HookScript(
		"OnVerticalScroll",
		function()
			E:RegisterHotkeys()

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
