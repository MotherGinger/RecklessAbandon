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
local tonumber, pairs, ipairs = tonumber, pairs, ipairs
local strjoin, twipe = strjoin, wipe
local format = format
local type, print = type, print

--WoW API / Variables
local CreateFrame = CreateFrame
local GetQuestLink = GetQuestLink
local UnitGUID = UnitGUID

--Constants
---@return nil
E.noop = function()
end

E.title = format("|cFF80528C%s|r", "Reckless Abandon")
E.version = E.Shim:GetAddOnMetadata("RecklessAbandon", "Version")
E.author = E.Shim:GetAddOnMetadata("RecklessAbandon", "Author")
E.github = "https://github.com/MotherGinger/RecklessAbandon/issues"
E.myfaction, E.myLocalizedFaction = UnitFactionGroup("player")
E.mylevel = UnitLevel("player")
E.myLocalizedClass, E.myclass, E.myClassID = UnitClass("player")
E.myLocalizedRace, E.myrace = UnitRace("player")
E.myname = UnitName("player")
E.myrealm = GetRealmName()
E.mynameRealm = format("%s - %s", E.myname, E.myrealm) -- contains spaces/dashes in realm (for profile keys)
E.screenwidth, E.screenheight = GetPhysicalScreenSize()
E.resolution = format("%dx%d", E.screenwidth, E.screenheight)
E.logLevels = {
	[LOG_LEVEL_ERROR] = L["Only show messages for errors"],
	[LOG_LEVEL_WARN] = L["Only show messages for warnings and errors"],
	[LOG_LEVEL_INFO] = L["Only show important messages"],
	[LOG_LEVEL_VERBOSE] = L["Show all messages (default)"]
}

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
	OnAccept = function(_, quests)
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
	OnAccept = function(_, data)
		E:AbandonQuest(data.questId, true)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3
}

StaticPopupDialogs["RECKLESS_ABANDON_ALL_CONFIRMATION"] = {
	text = table.concat(
		{ L["Are you sure you want to abandon all of the quests in your questlog?"], L["|cFFFF6B6BThis cannot be undone.|r"] },
		"\n\n"
	),
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function()
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
	OnAccept = function(_, data)
		E:AbandonQuests(data.questIds)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3
}

function onButtonEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(self.tooltip)
	GameTooltip.NineSlice:SetBorderColor(255, 255, 255)
	GameTooltip:Show()
end

function onButtonLeave()
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
					E.abandonTooltipFormat,
					self.title,
					L["Left Click: Abandon quest"],
					L["Right Click: Exclude quest from group abandons"]
				)
		else
			E:ExcludeQuest(self.questId, MANUAL)
			texture:SetVertexColor(0.5, 0.5, 1, 0.7)
			self.tooltip =
				format(
					E.abandonTooltipFormat,
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
	local ScrollFrame = E.isRetail and QuestScrollFrame or QuestLogListScrollFrame

	if bottom ~= nil and top ~= nil then
		if bottom > ScrollFrame:GetBottom() - buffer and top < ScrollFrame:GetTop() + buffer then
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
	E:Print(LOG_LEVEL_VERBOSE, ...)
end

function E:Info(...)
	E:Print(LOG_LEVEL_INFO, ...)
end

function E:Warn(...)
	E:Print(LOG_LEVEL_WARN, ...)
end

function E:Error(...)
	E:Print(LOG_LEVEL_ERROR, ...)
end

function E:System(...)
	E:Print(LOG_LEVEL_SYSTEM, ...)
end

function E:Critical(...)
	print(strjoin("", E.title, format("|cFFFF6B6B: %s|r", ...)))
end

function E:Debug(...)
	if E.db.debugging ~= nil and E.db.debugging.debugLogging then
		print(strjoin("", format(L["|cffffcc00%s Debug:|r"], E.title), " ", ...))
	end
end

function E:UpdatePlayerLevel(level)
	E:Debug(format("%s leveled up (%d -> %d)!", E.myname, E.mylevel, level))
	E.mylevel = level
end

function E:GetQuestColor(level)
	local levelDiff = level - E.mylevel
	local QuestRange = E.Shim:UnitQuestTrivialLevelRange("player")

	if levelDiff >= 5 then
		return L["red"]
	elseif levelDiff >= 3 then
		return L["orange"]
	elseif levelDiff >= -2 then
		return L["yellow"]
	elseif -levelDiff <= QuestRange then
		return L["green"]
	else
		return L["gray"]
	end
end

function E:GetAvailableQualifiers()
	local qualifiers = {
		[L["green"]] = L["Matches all green quests."],
		[L["yellow"]] = L["Matches all yellow quests."],
		[L["orange"]] = L["Matches all orange quests."],
		[L["red"]] = L["Matches all red quests."],
		[L["gray"]] = L["Matches all gray quests."]
	}

	local selections = {
		["green"] = L["Green"],
		["yellow"] = L["Yellow"],
		["orange"] = L["Orange"],
		["red"] = L["Red"],
		["gray"] = L["Gray"]
	}

	if not E.isClassic then
		qualifiers[strlower(DAILY)] = L["Matches all daily quests."]
		selections["daily"] = DAILY
	end

	if E.isRetail then
		qualifiers[strlower(WEEKLY)] = L["Matches all weekly quests."]
		selections["weekly"] = WEEKLY
	else
		qualifiers[strlower(FAILED)] = L["Matches all failed quests."]
		qualifiers[strlower(LFG_TYPE_DUNGEON)] = L["Matches all dungeon quests."]
		qualifiers[strlower(RAID)] = L["Matches all raid quests."]
		qualifiers[strlower(GROUP)] = L["Matches all group quests."]
		qualifiers[strlower(ELITE)] = L["Matches all elite quests."]
		qualifiers[strlower(PLAYER_DIFFICULTY2)] = L["Matches all heroic quests."]
		qualifiers[strlower(PVP)] = L["Matches all pvp quests."]

		selections["failed"] = FAILED
		selections["dungeon"] = LFG_TYPE_DUNGEON
		selections["raid"] = RAID
		selections["group"] = GROUP
		selections["elite"] = ELITE
		selections["heroic"] = PLAYER_DIFFICULTY2
		selections["pvp"] = PVP
	end

	return qualifiers, selections
end

function E:AbandonAllQuests()
	for i = 1, E.Shim:GetNumQuestLogEntries() do
		local info = E.Shim:GetInfo(i)
		local questId = info.questID

		if not info.isHeader and not info.isHidden then
			E:AbandonQuest(questId)
		end
	end
end

function E:AbandonZoneQuests(key)
	local group = E.questGroupsByName[key] or {}
	for questId, _ in pairs(group.quests or {}) do
		E:AbandonQuest(questId)
	end

	if E:IsEmpty(group.quests) then
		E.questGroupsByName[key] = nil
	end
end

function E:AbandonQuests(questIds)
	for _, questId in ipairs(questIds) do
		E:AbandonQuest(questId)
	end
end

function E:AbandonQuest(questId, exclusionBypass)
	if exclusionBypass or not E.private.exclusions.excludedQuests[questId] then
		if E.Shim:CanAbandonQuest(questId) then
			E.Shim:SetSelectedQuest(questId)
			E.Shim:SetAbandonQuest()
			E.Shim:AbandonQuest()

			E:System(format(L["|cFFFFFF00Abandoned quest %s|r"], GetQuestLink(questId)))

			if E.private.exclusions.autoPrune and E:IsExcluded(questId) then
				E:PruneQuestExclusion(questId)
			end
		else
			E:Warn(format(L["|cFFFFFF00You can't abandon %s|r"], GetQuestLink(questId)))
		end
	else
		E:Verbose(format(L["Skipping %s since it is excluded from group abandons"], GetQuestLink(questId)))
	end
end

function E:ExcludeQuest(questId, source)
	E:Verbose(format(L["Excluding quest %s from group abandons"], GetQuestLink(questId)))
	E.private.exclusions.excludedQuests[tonumber(questId)] = {
		["title"] = QuestTitleFromID[questId],
		["source"] = source or MANUAL
	}

	E:RefreshGUI()
end

function E:IncludeQuest(questId)
	E:Verbose(format(L["Including quest %s in group abandons"], GetQuestLink(questId)))
	E.private.exclusions.excludedQuests[tonumber(questId)] = nil

	E:RefreshGUI()
end

function E:IsExcluded(questId)
	return E.private.exclusions.excludedQuests[tonumber(questId)] ~= nil
end

function E:CanQuestGroupAbandon(quests)
	for questId, _ in pairs(quests) do
		if E.Shim:CanAbandonQuest(questId) then
			return true
		end
	end

	return false
end

function E:PruneQuestExclusionsFromAutomation()
	if E.private.exclusions.autoPrune then
		local count = 0
		for questId, meta in pairs(E.private.exclusions.excludedQuests) do
			local orphaned = E.Shim:GetLogIndexForQuestID(questId) == nil
			local source = meta.source
			if orphaned and source == AUTOMATIC then
				count = count + 1
				E:PruneQuestExclusion(questId)
			end
		end

		E:Debug(format(L["Pruned %s automation |4orphan:orphans;!"], count))
	end
end

function E:PruneQuestExclusion(questId)
	local title = E.private.exclusions.excludedQuests[tonumber(questId)]["title"]
	E:Verbose(format(L["Pruning '%s' from the exclusion list"], title))
	E.private.exclusions.excludedQuests[tonumber(questId)] = nil

	E:RefreshGUI()
end

function E:ClearQuestExclusions()
	for questId, _ in pairs(E.private.exclusions.excludedQuests) do
		local orphaned = E.Shim:GetLogIndexForQuestID(questId) == nil
		if orphaned then
			E:PruneQuestExclusion(questId)
		else
			E:IncludeQuest(questId)
		end
	end
end

function E:PruneQuestExclusions()
	local count = 0
	for questId, _ in pairs(E.private.exclusions.excludedQuests) do
		local orphaned = E.Shim:GetLogIndexForQuestID(questId) == nil
		if orphaned then
			count = count + 1
			E:PruneQuestExclusion(questId)
		end
	end

	E:Info(format(L["Pruned %s |4orphan:orphans;!"], count))
end

-- Pre-parse the exclusion CSV into a lookup table for O(1) access
function E:UpdateParsedExclusions()
	local ids = self.private.automationOptions.autoAbandonQuests.ids
	self.parsedExclusions = {}

	if ids and ids ~= "" then
		for questId in string.gmatch(ids, "([^,]+)") do
			local numId = tonumber(questId)
			if numId then
				self.parsedExclusions[numId] = true
			end
		end
	end
end

-- Cache color map to avoid repeated localization lookups
function E:InitializeColorMap()
	self.COLOR_MAP = {
		gray = strlower(L["gray"]),
		green = strlower(L["green"]),
		yellow = strlower(L["yellow"]),
		orange = strlower(L["orange"]),
		red = strlower(L["red"])
	}
end

-- Cache tag constants to avoid repeated strlower() calls
function E:InitializeTagCache()
	if not E.isRetail then
		self.TAG_CACHE = {
			dungeon = strlower(LFG_TYPE_DUNGEON or "Dungeon"),
			heroic = strlower(PLAYER_DIFFICULTY2 or "Heroic"),
			raid = strlower(RAID or "Raid"),
			elite = strlower(ELITE or "Elite"),
			group = strlower(GROUP or "Group"),
			pvp = strlower(PVP or "PvP")
		}
	end
end

function E:AutoAbandonQuests()
	-- * This will abandon all quests of types that have been elected for automatic abandons
	-- * Now optimized with pre-parsed exclusions and cached lookups

	local count = 0

	for i = 1, E.Shim:GetNumQuestLogEntries() do
		local info = E.Shim:GetInfo(i)
		if not info then
			E:Error(format("Failed to get quest info for index %d in AutoAbandonQuests", i))
		elseif not info.isHeader then
			local questId = info.questID
			local level = info.level
			local isDaily = info.frequency == 1
			local isWeekly = info.frequency == 2

			local color = strlower(E:GetQuestColor(level))
			local lowerTag = info.questTag and strlower(info.questTag) or nil

			local autoAbandonQuests = E.private.automationOptions.autoAbandonQuests
			local eligible = false

			-- Check quest ID match using pre-parsed lookup table (O(1) instead of O(n))
			if self.parsedExclusions and self.parsedExclusions[questId] then
				eligible = true
			end

			-- Check color using cached color map
			if not eligible and self.COLOR_MAP then
				if (autoAbandonQuests.questType.gray and self.COLOR_MAP.gray == color) or
				   (autoAbandonQuests.questType.green and self.COLOR_MAP.green == color) or
				   (autoAbandonQuests.questType.yellow and self.COLOR_MAP.yellow == color) or
				   (autoAbandonQuests.questType.orange and self.COLOR_MAP.orange == color) or
				   (autoAbandonQuests.questType.red and self.COLOR_MAP.red == color) then
					eligible = true
				end
			end

			-- Check frequency-based types
			if not eligible and not E.isClassic and autoAbandonQuests.questType.daily and isDaily then
				eligible = true
			end

			if not eligible and E.isRetail and autoAbandonQuests.questType.weekly and isWeekly then
				eligible = true
			end

			-- Check tag-based types using cached tag constants
			if not eligible and not E.isRetail and lowerTag and self.TAG_CACHE then
				if (autoAbandonQuests.questType.dungeon and self.TAG_CACHE.dungeon == lowerTag) or
				   (autoAbandonQuests.questType.heroic and self.TAG_CACHE.heroic == lowerTag) or
				   (autoAbandonQuests.questType.raid and self.TAG_CACHE.raid == lowerTag) or
				   (autoAbandonQuests.questType.elite and self.TAG_CACHE.elite == lowerTag) or
				   (autoAbandonQuests.questType.group and self.TAG_CACHE.group == lowerTag) or
				   (autoAbandonQuests.questType.pvp and self.TAG_CACHE.pvp == lowerTag) then
					eligible = true
				end
			end

			-- Check failed quests (non-Retail only)
			if not eligible and not E.isRetail and autoAbandonQuests.questType.failed and info.isComplete == -1 then
				eligible = true
			end

			-- Abandon if eligible
			if eligible and E:AbandonQuest(questId) then
				count = count + 1
			end
		end
	end

	if count > 0 then
		E:Info(format("Automatically abandoned %s |4quest:quests;!", count))
	end
end

function E:AutoExcludeQuests()
	for i = 1, E.Shim:GetNumQuestLogEntries() do
		local info = E.Shim:GetInfo(i)
		if not info then
			E:Error(format("Failed to get quest info for index %d in AutoExcludeQuests", i))
		else
			local questId = info.questID
			local isComplete = E.Shim:IsComplete(questId)

			if not info.isHeader then
				if E.db.general.individualQuests.completeProtection and isComplete and not E:IsExcluded(questId) then
					E:ExcludeQuest(questId, AUTOMATIC)
				end
			end
		end
	end
end

-- Consolidated event handler for UNIT_QUEST_LOG_CHANGED
function E:OnQuestLogChanged()
	-- Auto-abandon if enabled
	if self.private.automationOptions.autoAbandonQuests then
		local hasAnyEnabled = false
		for _, enabled in pairs(self.private.automationOptions.autoAbandonQuests.questType) do
			if enabled then
				hasAnyEnabled = true
				break
			end
		end
		if hasAnyEnabled or (self.private.automationOptions.autoAbandonQuests.ids and self.private.automationOptions.autoAbandonQuests.ids ~= "") then
			self:AutoAbandonQuests()
		end
	end

	-- Auto-exclude (has its own internal check for completeProtection)
	self:AutoExcludeQuests()

	-- Prune exclusions every 5 seconds instead of every event
	local currentTime = GetTime()
	if (currentTime - self.lastPruneTime) > 5 then
		self:PruneQuestExclusionsFromAutomation()
		self.lastPruneTime = currentTime
	end

	-- Always refresh GUI
	self:RefreshGUI()
end

function E:PrintWelcomeMessage()
	if E.db.general.loginMessage then
		E:System(format(L["You are running |cFFB5FFEBv%s|r. Type |cff888888/rab|r to configure settings."], E.version))
	end

	if strfind(E.version, "alpha") or strfind(E.version, "beta") then
		E:System(
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

	-- Set debugging if not set
	if E.db.debugging == nil then
		E.db.debugging.debugLogging = false
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
	if E.isRetail then
		E:RegisterRetailHotkeys()
	else
		E:RegisterClassicHotkeys()
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

	E:RegisterBucketEvent("QUEST_LOG_UPDATE", 1, "GenerateQuestTable")
	E:RegisterBucketEvent("UNIT_QUEST_LOG_CHANGED", 0.5, "OnQuestLogChanged")

	-- Initialize prune throttle timer
	E.lastPruneTime = 0

	E.private = E.charSettings.profile
	E.db = E.data.profile
	E.global = E.data.global

	E.Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(E.data)
	E.Options.args.profiles.order = 1

	E:NormalizeSettings()

	local QuestFrame = E.isRetail and QuestMapFrame or QuestLogFrame

	QuestFrame:HookScript(
		"OnShow",
		function()
			E:GenerateQuestTable()

			-- * Added in Retail 11.1.0: Avoid showing render buttons in quest detail pane
			if E.isRetail and QuestFrame.QuestsFrame.DetailsFrame:IsVisible() then return end

			E:ShowAbandonButtons()
			E:RegisterHotkeys()
		end
	)
	QuestFrame:HookScript(
		"OnEvent",
		function()
			E:GenerateQuestTable()

			-- * Added in Retail 11.1.0: Avoid showing render buttons in quest detail pane
			if E.isRetail and QuestFrame.QuestsFrame.DetailsFrame:IsVisible() then return end

			E:ShowAbandonButtons()
			E:RegisterHotkeys()
		end
	)
	QuestFrame:HookScript(
		"OnHide",
		function()
			E:HideAbandonButtons()
		end
	)

	if E.isRetail then
		-- Initialize debounce timer
		E.searchDebounceTimer = nil

		QuestScrollFrame.SearchBox:HookScript(
			"OnTextChanged",
			function()
				-- Cancel existing timer if present
				if E.searchDebounceTimer then
					E.searchDebounceTimer:Cancel()
				end

				-- Create new timer with 0.3s delay to reduce unnecessary renders
				E.searchDebounceTimer = C_Timer.NewTimer(0.3, function()
					E:ShowAbandonButtons()
					E.searchDebounceTimer = nil
				end)
			end
		)


		QuestScrollFrame:HookScript(
			"OnVerticalScroll",
			function()
				E:RegisterHotkeys()

				-- * Added in Retail 11.1.0: Avoid showing render buttons in quest detail pane
				if QuestFrame.QuestsFrame.DetailsFrame:IsVisible() then return end

				for button in E.questButtonPool:EnumerateActive() do
					onButtonUpdate(button)
				end

				for button in E.groupButtonPool:EnumerateActive() do
					onButtonUpdate(button)
				end
			end
		)

		-- * Added in Retail 11.1.0: Avoid showing render buttons in quest detail pane
		QuestFrame.QuestsFrame.DetailsFrame:HookScript("OnShow", function()
			E:HideAbandonButtons()
		end)

		QuestFrame.QuestsFrame.DetailsFrame:HookScript("OnHide", function()
			E:ShowAbandonButtons()
		end)
	elseif E.isClassic then
		QuestLogListScrollFrame:HookScript(
			"OnVerticalScroll",
			function()
				-- Render the next set of buttons. This is needed because the classic quest log only shows QUESTS_DISPLAYED titles at a time
				E:ShowAbandonButtons()
				E:RegisterHotkeys()

				for button in E.questButtonPool:EnumerateActive() do
					onButtonUpdate(button)
				end

				for button in E.groupButtonPool:EnumerateActive() do
					onButtonUpdate(button)
				end
			end
		)
	else
		QuestLogListScrollFrame.scrollBar:HookScript(
			"OnValueChanged",
			function()
				-- Render the next set of buttons. This is needed because the classic quest log only shows QUESTS_DISPLAYED titles at a time
				E:ShowAbandonButtons()
				E:RegisterHotkeys()

				for button in E.questButtonPool:EnumerateActive() do
					onButtonUpdate(button)
				end

				for button in E.groupButtonPool:EnumerateActive() do
					onButtonUpdate(button)
				end
			end
		)
	end

	E.initialized = true
end
