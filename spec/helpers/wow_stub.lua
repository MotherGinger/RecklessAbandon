-- A minimal World of Warcraft client for running Reckless Abandon under plain Lua 5.1 + busted.
-- It models only what the addon and its embedded Ace3 libraries touch. When a test needs
-- another API, add it here with the real client's behavior on the flavor being stubbed.
local Stub = {}

Stub.rawXpcall = Stub.rawXpcall or xpcall

-- legacy: the GetQuestLogTitle family of globals and QuestLogFrame.
-- modern: C_QuestLog and QuestMapFrame. titleButtons: QuestLogTitleN globals (Classic, TBC)
-- rather than QuestLogListScrollFrame.buttons (Mists).
Stub.FLAVORS = {
    classic = { project = 2, version = "1.15.9", build = "64000", interface = 11509, legacy = true, titleButtons = true },
    tbc = { project = 5, version = "2.5.6", build = "64000", interface = 20506, legacy = true, titleButtons = true },
    -- Mists links quests by ID, like Retail; the older Classic clients link by quest log index.
    mists = { project = 19, version = "5.5.4", build = "64000", interface = 50504, legacy = true, linkById = true },
    -- Forever reports WOW_PROJECT_CAMELOT (18) since build 70245; early betas reported mainline (1).
    forever = { project = 18, version = "1.60.1", build = "70338", interface = 16001, modern = true },
    retail = { project = 1, version = "12.0.5", build = "65000", interface = 120105, modern = true, retail = true },
}

Stub.PLAYER = { name = "Frauke", realm = "Area 52", classFile = "WARRIOR", classId = 1, level = 60, guid = "Player-1-00000001" }

-- How many quest titles the legacy quest log shows at once.
Stub.QUESTS_DISPLAYED = 6

local function noop() end

local FRAME_NOOPS = {
    "SetFrameStrata", "SetFrameLevel", "SetClampedToScreen", "SetMovable", "EnableMouse", "EnableMouseWheel",
    "EnableKeyboard", "RegisterForClicks", "RegisterForDrag", "SetAllPoints", "SetTexCoord", "SetJustifyH",
    "SetJustifyV", "SetFont", "SetFontObject", "SetHighlightTexture", "SetPushedTexture", "LockHighlight",
    "UnlockHighlight", "SetBorderColor", "SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor",
    "SetToplevel",
}

-- Fields the real frames only have on some clients (Retail's DetailsFrame, TagTexture, SearchBox...).
-- Reading one that isn't there gives nil, like on the client, instead of the "not stubbed" error.
local OPTIONAL_FIELDS = {
    DetailsFrame = true, TagTexture = true, SearchBox = true, QuestsFrame = true,
    campaignHeaderFramePool = true, covenantCallingsHeaderFramePool = true,
}

local NewFrame

local function compileScript(body, event)
    local params = ({ OnClick = "self, button, down", OnEnter = "self, motion", OnLeave = "self, motion", OnUpdate = "self, elapsed" })[event]
        or "self"
    return assert(loadstring("local " .. params .. " = ...\n" .. body, event))
end

NewFrame = function(kind, name, parent)
    local frame = {
        __kind = kind, __name = name, __parent = parent, __scripts = {}, __events = {},
        __shown = true, __points = {}, __lines = {}, __enabled = true, __id = 0,
    }
    for _, method in ipairs(FRAME_NOOPS) do frame[method] = noop end

    function frame:SetScript(event, handler) self.__scripts[event] = handler end
    function frame:GetScript(event) return self.__scripts[event] end
    function frame:HookScript(event, handler)
        local previous = self.__scripts[event]
        self.__scripts[event] = function(...)
            if previous then previous(...) end
            return handler(...)
        end
    end
    function frame:RegisterEvent(event) self.__events[event] = true end
    function frame:UnregisterEvent(event) self.__events[event] = nil end
    function frame:UnregisterAllEvents() self.__events = {} end
    function frame:IsEventRegistered(event) return self.__events[event] == true end

    function frame:Show()
        local wasShown = self.__shown
        self.__shown = true
        if not wasShown and self.__scripts.OnShow then self.__scripts.OnShow(self) end
    end
    function frame:Hide()
        local wasShown = self.__shown
        self.__shown = false
        if wasShown and self.__scripts.OnHide then self.__scripts.OnHide(self) end
    end
    function frame:SetShown(shown) if shown then self:Show() else self:Hide() end end
    function frame:IsShown() return self.__shown end
    function frame:IsVisible()
        local current = self
        while current do
            if not rawget(current, "__shown") then return false end
            current = rawget(current, "__parent")
        end
        return true
    end

    function frame:SetPoint(...) table.insert(self.__points, { ... }) end
    function frame:ClearAllPoints() self.__points = {} end
    function frame:GetPoint(index)
        local point = self.__points[index or 1]
        if point then return unpack(point) end
    end
    function frame:SetWidth(width) self.__width = width end
    function frame:SetHeight(height) self.__height = height end
    function frame:SetSize(width, height) self.__width, self.__height = width, height end
    function frame:GetWidth() return self.__width or 0 end
    function frame:GetHeight() return self.__height or 0 end
    -- Every frame sits at the same place, so buttons always count as inside the quest log's scroll area.
    function frame:GetTop() return 0 end
    function frame:GetBottom() return 0 end

    function frame:GetName() return self.__name end
    function frame:GetParent() return self.__parent end
    function frame:SetID(id) self.__id = id end
    function frame:GetID() return self.__id end
    function frame:SetText(text) self.__text = text end
    function frame:GetText() return self.__text end
    function frame:SetEnabled(enabled) self.__enabled = enabled and true or false end
    function frame:Enable() self.__enabled = true end
    function frame:Disable() self.__enabled = false end
    function frame:IsEnabled() return self.__enabled end

    -- Textures.
    function frame:SetTexture(texture) self.__texture = texture end
    function frame:GetTexture() return self.__texture end
    function frame:SetVertexColor(r, g, b, a) self.__vertexColor = { r, g, b, a } end
    function frame:GetVertexColor() if self.__vertexColor then return unpack(self.__vertexColor) end end
    function frame:SetDesaturated(desaturated) self.__desaturated = desaturated and true or false end
    function frame:IsDesaturated() return self.__desaturated == true end
    function frame:CreateTexture() return NewFrame("Texture", nil, self) end
    function frame:CreateFontString() return NewFrame("FontString", nil, self) end

    -- Buttons own their normal/pushed/highlight textures, like ones built from an XML template that sets them.
    if kind == "Button" then
        frame.__normal = NewFrame("Texture", nil, frame)
        frame.__pushed = NewFrame("Texture", nil, frame)
        frame.__highlight = NewFrame("Texture", nil, frame)
    end
    function frame:GetNormalTexture() return self.__normal end
    function frame:GetPushedTexture() return self.__pushed end
    function frame:GetHighlightTexture() return self.__highlight end
    function frame:SetNormalTexture(texture) self.__normal = texture end
    -- A button's label, like the one UIPanelButtonTemplate gives it.
    function frame:GetFontString()
        self.__fontString = self.__fontString or NewFrame("FontString", nil, self)
        return self.__fontString
    end

    -- Tooltips.
    function frame:SetOwner() self.__lines = {} end
    function frame:ClearLines() self.__lines = {} end
    function frame:AddLine(text) table.insert(self.__lines, text) end
    function frame:AddDoubleLine(left, right) table.insert(self.__lines, left .. "\t" .. right) end
    function frame:SetHyperlink(link)
        local id = tonumber(link:match("^quest:(%d+)"))
        local line = _G[(self.__name or "") .. "TextLeft1"]
        if line then line:SetText(id and Stub.QuestTitle(id) or _G.RETRIEVING_DATA) end
    end

    -- Unknown capitalized keys are missing WoW methods: fail loudly so the stub gets extended.
    -- Lowercase keys are addon-defined fields and read as nil, like on a real frame.
    return setmetatable(frame, {
        __index = function(_, key)
            if type(key) == "string" and key:match("^[A-Z]") and not OPTIONAL_FIELDS[key] then
                error("wow_stub: frame method '" .. key .. "' is not stubbed; add it to spec/helpers/wow_stub.lua", 2)
            end
        end,
    })
end

local function CreateFrame(kind, name, parent, template)
    local frame = NewFrame(kind, name, parent)
    -- Scripts from the addon's own XML templates (Loader reads them from the .xml files).
    for templateName in (template or ""):gmatch("[^,%s]+") do
        for event, body in pairs(Stub.state.templates[templateName] or {}) do
            frame:SetScript(event, compileScript(body, event))
        end
    end
    if kind == "GameTooltip" and name then
        _G[name .. "TextLeft1"] = NewFrame("FontString", name .. "TextLeft1", frame)
        table.insert(Stub.state.frames, _G[name .. "TextLeft1"])
    end
    if name then _G[name] = frame end
    table.insert(Stub.state.frames, frame)
    return frame
end

local function CreateFramePool(kind, parent, template)
    local pool = { active = {}, inactive = {} }
    function pool:Acquire()
        local frame = table.remove(self.inactive)
        local new = frame == nil
        frame = frame or CreateFrame(kind, nil, parent, template)
        self.active[frame] = true
        return frame, new
    end
    function pool:Release(frame)
        frame:Hide()
        frame:ClearAllPoints()
        self.active[frame] = nil
        table.insert(self.inactive, frame)
    end
    function pool:ReleaseAll()
        for frame in pairs(self.active) do self:Release(frame) end
    end
    function pool:EnumerateActive() return pairs(self.active) end
    function pool:GetNumActive()
        local count = 0
        for _ in pairs(self.active) do count = count + 1 end
        return count
    end
    return pool
end

local function strsplit(delimiters, text, limit)
    local parts, position = {}, 1
    local set = "[" .. delimiters:gsub("[%]%^%-%%]", "%%%0") .. "]"
    while true do
        if limit and #parts == limit - 1 then parts[#parts + 1] = text:sub(position); break end
        local first, last = text:find(set, position)
        if not first then parts[#parts + 1] = text:sub(position); break end
        parts[#parts + 1] = text:sub(position, first - 1)
        position = last + 1
    end
    return unpack(parts)
end

----------------------------------------------------------------
-- Quest log
----------------------------------------------------------------

-- Entries are { header = "Zone" [, collapsed = true] } or a quest:
-- { id =, title =, level = (60), tag = "Elite", tagID =, elite =, frequency = "daily" | "weekly",
--   complete = true, failed = true, hidden = true, canAbandon = false }

local function questIndex(id)
    for index, entry in ipairs(Stub.state.questLog) do
        if not entry.header and entry.id == id then return index end
    end
end

function Stub.QuestTitle(id)
    local index = questIndex(id)
    if index then return Stub.state.questLog[index].title end
    return Stub.state.questTitles[id]
end

local function legacyFrequency(entry)
    if entry.frequency == "daily" then return 2 end
    return 1
end

local function modernFrequency(entry)
    if entry.frequency == "daily" then return 1 end
    if entry.frequency == "weekly" then return 2 end
    return 0
end

local function completion(entry)
    if entry.failed then return -1 end
    if entry.complete then return 1 end
    return nil
end

local function questLink(entry)
    return ("|cffffff00|Hquest:%d:%d|h[%s]|h|r"):format(entry.id, entry.level or 60, entry.title)
end

-- The server's side of an abandon: the selected quest leaves the log, unless the test made the
-- server drop the next few abandons (S.dropAbandons), which is what happens when many are sent at once.
local function abandonSelected()
    local S = Stub.state
    if not S.abandonArmed then error("wow_stub: AbandonQuest without SetAbandonQuest", 2) end
    S.abandonArmed = false
    local entry = S.questLog[S.selectedIndex or 0]
    if not entry or entry.header then return end
    if S.dropAbandons > 0 then
        S.dropAbandons = S.dropAbandons - 1
        table.insert(S.dropped, entry.id)
        return
    end
    table.remove(S.questLog, S.selectedIndex)
    table.insert(S.abandoned, entry.id)
    S.selectedIndex = nil
end

local function installQuestLog(flavor)
    local S = Stub.state

    if flavor.legacy then
        _G.C_QuestLog = nil
        _G.GetNumQuestLogEntries = function()
            local quests = 0
            for _, entry in ipairs(S.questLog) do
                if not entry.header then quests = quests + 1 end
            end
            return #S.questLog, quests
        end
        _G.GetQuestLogTitle = function(index)
            local entry = S.questLog[index]
            if not entry then return nil end
            if entry.header then
                return entry.header, 0, nil, true, entry.collapsed == true, nil, 1, nil
            end
            return entry.title, entry.level or 60, entry.tag, false, false, completion(entry), legacyFrequency(entry),
                entry.id, nil, nil, nil, nil, nil, nil, nil, entry.hidden == true
        end
        _G.GetQuestLogIndexByID = function(id) return questIndex(tonumber(id)) or 0 end
        _G.CanAbandonQuest = function(id)
            local index = questIndex(tonumber(id))
            return index ~= nil and S.questLog[index].canAbandon ~= false
        end
        _G.SelectQuestLogEntry = function(index) S.selectedIndex = index end
        _G.SetAbandonQuest = function() S.abandonArmed = true end
        _G.AbandonQuest = abandonSelected
        _G.GetQuestLink = function(indexOrId)
            local entry = S.questLog[flavor.linkById and (questIndex(indexOrId) or 0) or indexOrId]
            if entry and not entry.header and not S.noQuestLinks then return questLink(entry) end
        end
        _G.GetQuestGreenRange = function() return S.greenRange end
        _G.UnitQuestTrivialLevelRange = nil
    else
        _G.GetNumQuestLogEntries, _G.GetQuestLogTitle, _G.GetQuestLogIndexByID = nil, nil, nil
        _G.CanAbandonQuest, _G.SelectQuestLogEntry, _G.SetAbandonQuest, _G.AbandonQuest = nil, nil, nil, nil
        _G.GetQuestGreenRange = nil
        _G.UnitQuestTrivialLevelRange = function() return S.greenRange end
        local function entryFor(id)
            local index = questIndex(tonumber(id))
            return index and S.questLog[index], index
        end
        _G.C_QuestLog = {
            GetNumQuestLogEntries = function()
                local quests = 0
                for _, entry in ipairs(S.questLog) do
                    if not entry.header then quests = quests + 1 end
                end
                return #S.questLog, quests
            end,
            GetInfo = function(index)
                local entry = S.questLog[index]
                if not entry then return nil end
                if entry.header then
                    return { title = entry.header, questLogIndex = index, level = 0, isHeader = true, isCollapsed = entry.collapsed == true, isHidden = false, frequency = 0 }
                end
                return {
                    title = entry.title, questLogIndex = index, questID = entry.id, level = entry.level or 60,
                    isHeader = false, isCollapsed = false, isHidden = entry.hidden == true, frequency = modernFrequency(entry),
                }
            end,
            GetLogIndexForQuestID = function(id) return questIndex(tonumber(id)) end,
            IsOnQuest = function(id) return questIndex(tonumber(id)) ~= nil end,
            CanAbandonQuest = function(id)
                local entry = entryFor(id)
                return entry ~= nil and entry.canAbandon ~= false
            end,
            IsComplete = function(id)
                local entry = entryFor(id)
                return entry ~= nil and entry.complete == true
            end,
            IsFailed = function(id)
                local entry = entryFor(id)
                return entry ~= nil and entry.failed == true
            end,
            GetQuestTagInfo = function(id)
                local entry = entryFor(id)
                if not entry or not (entry.tag or entry.tagID or entry.elite) then return nil end
                return { tagID = entry.tagID, tagName = entry.tag, isElite = entry.elite == true }
            end,
            SetSelectedQuest = function(id)
                local _, index = entryFor(id)
                S.selectedIndex = index
            end,
            SetAbandonQuest = function() S.abandonArmed = true end,
            AbandonQuest = abandonSelected,
        }
        -- Retail links quests by ID. Forever's GetQuestLink isn't relied on, so the Shim builds the link itself.
        if flavor.retail then
            _G.GetQuestLink = function(id)
                local entry = entryFor(id)
                if entry and not S.noQuestLinks then return questLink(entry) end
            end
        else
            _G.GetQuestLink = nil
        end
    end
end

----------------------------------------------------------------
-- Quest log frames
----------------------------------------------------------------

-- The client's own click handler on a quest log row. Clicks that reach it land in S.rowClicks.
local function rowOnClick(self, button)
    table.insert(Stub.state.rowClicks, { row = self, button = button })
end

local function installQuestFrames(flavor)
    if flavor.legacy then
        _G.QuestMapFrame, _G.QuestScrollFrame = nil, nil
        _G.QUESTS_DISPLAYED = Stub.QUESTS_DISPLAYED
        _G.QuestLogFrame = CreateFrame("Frame", "QuestLogFrame", _G.UIParent)
        _G.QuestLogFrame:Hide()
        local scroll = CreateFrame("ScrollFrame", "QuestLogListScrollFrame", _G.QuestLogFrame)
        scroll.offset = 0
        scroll:SetWidth(300)
        if flavor.titleButtons then
            for i = 1, Stub.QUESTS_DISPLAYED do CreateFrame("Button", "QuestLogTitle" .. i, scroll):SetScript("OnClick", rowOnClick) end
        else
            scroll.buttons = {}
            for i = 1, Stub.QUESTS_DISPLAYED do
                scroll.buttons[i] = CreateFrame("Button", nil, scroll)
                scroll.buttons[i]:SetScript("OnClick", rowOnClick)
            end
            scroll.scrollBar = CreateFrame("Slider", nil, scroll)
        end
    else
        _G.QuestLogFrame, _G.QuestLogListScrollFrame, _G.QUESTS_DISPLAYED = nil, nil, nil
        local map = CreateFrame("Frame", "QuestMapFrame", _G.UIParent)
        map:Hide()
        map.QuestsFrame = CreateFrame("Frame", nil, map)
        if flavor.retail then
            map.QuestsFrame.DetailsFrame = CreateFrame("Frame", nil, map.QuestsFrame)
            map.QuestsFrame.DetailsFrame:Hide()
        end
        local scroll = CreateFrame("ScrollFrame", "QuestScrollFrame", map.QuestsFrame)
        scroll.SearchBox = flavor.retail and CreateFrame("EditBox", nil, scroll) or nil
        scroll.headerFramePool = CreateFramePool("Button", scroll)
        scroll.titleFramePool = CreateFramePool("Button", scroll)
        if flavor.retail then
            scroll.campaignHeaderFramePool = CreateFramePool("Frame", scroll)
            scroll.covenantCallingsHeaderFramePool = CreateFramePool("Frame", scroll)
        end
    end
end

-- Lays the quest log's rows out the way the client does when it draws the log.
local function layoutQuestLog()
    local S = Stub.state
    if Stub.flavor.legacy then
        local scroll = _G.QuestLogListScrollFrame
        for i = 1, Stub.QUESTS_DISPLAYED do
            local button = scroll.buttons and scroll.buttons[i] or _G["QuestLogTitle" .. i]
            local index = i + scroll.offset
            local entry = S.questLog[index]
            button:SetID(index)
            button:SetText(entry and (entry.header or entry.title) or nil)
            button:SetShown(entry ~= nil)
        end
        return
    end

    local scroll = _G.QuestScrollFrame
    scroll.headerFramePool:ReleaseAll()
    scroll.titleFramePool:ReleaseAll()
    local collapsed = false
    for index, entry in ipairs(S.questLog) do
        if entry.header then
            collapsed = entry.collapsed == true
            local header = scroll.headerFramePool:Acquire()
            header.questLogIndex = index
            header.ButtonText = rawget(header, "ButtonText") or header:CreateFontString()
            header.ButtonText:SetText(entry.header)
            header.CollapseButton = rawget(header, "CollapseButton") or CreateFrame("Button", nil, header)
            header:Show()
        elseif not collapsed and not entry.hidden then
            local title, new = scroll.titleFramePool:Acquire()
            if new then title:SetScript("OnClick", rowOnClick) end
            title.questID = entry.id
            title.questLogIndex = index
            title.Text = rawget(title, "Text") or title:CreateFontString()
            title.Text:SetText(entry.title)
            title.Checkbox = rawget(title, "Checkbox") or CreateFrame("Button", nil, title)
            if Stub.flavor.retail then title.TagTexture = rawget(title, "TagTexture") or title:CreateTexture() end
            title:Show()
        end
    end
end

----------------------------------------------------------------
-- Install
----------------------------------------------------------------

function Stub.Install(flavorName)
    local flavor = assert(Stub.FLAVORS[flavorName], "unknown flavor " .. tostring(flavorName))
    -- Named frames are globals: clear the last boot's, so a test can't see another test's frames.
    for _, frame in ipairs(Stub.state and Stub.state.frames or {}) do
        local name = rawget(frame, "__name")
        if name and _G[name] == frame then _G[name] = nil end
    end
    Stub.flavorName, Stub.flavor = flavorName, flavor
    Stub.state = {
        loggedIn = false, inCombat = false, now = 1000, seq = 0, locale = "enUS",
        frames = {}, chat = {}, errors = {}, timers = {}, templates = {}, popups = {}, rowClicks = {},
        questLog = {}, questTitles = {}, abandoned = {}, dropped = {}, dropAbandons = 0, greenRange = 8,
        modifiers = {}, metadata = {},
        player = {},
    }
    local S = Stub.state
    -- A per-boot copy, so a test that changes the player (level) can't leak into the next one.
    for key, value in pairs(Stub.PLAYER) do S.player[key] = value end

    -- A fresh library registry per boot, so each test gets new Ace3 instances.
    _G.LibStub = nil
    _G.RecklessAbandon, _G.RecklessAbandonDB, _G.RecklessAbandonPrivateDB, _G.RecklessAbandonCharacterDB = nil, nil, nil, nil
    _G.RecklessAbandon_AddonCompartmentFunc = nil
    _G.SlashCmdList, _G.hash_SlashCmdList = {}, {}
    for key in pairs(_G) do
        if type(key) == "string" and key:match("^SLASH_") then _G[key] = nil end
    end

    -- Lua helpers the WoW client exposes as globals.
    _G.format, _G.gsub, _G.strfind, _G.strmatch, _G.strsub = string.format, string.gsub, string.find, string.match, string.sub
    _G.strlower, _G.strupper, _G.strlen, _G.strrep, _G.strbyte = string.lower, string.upper, string.len, string.rep, string.byte
    _G.tinsert, _G.tremove, _G.sort = table.insert, table.remove, table.sort
    _G.floor, _G.ceil, _G.max, _G.min, _G.abs = math.floor, math.ceil, math.max, math.min, math.abs
    _G.wipe = function(t) for key in pairs(t) do t[key] = nil end return t end
    table.wipe = _G.wipe
    _G.strtrim = function(text) return (text:gsub("^%s+", ""):gsub("%s+$", "")) end
    _G.strjoin = function(separator, ...) return table.concat({ ... }, separator) end
    _G.strsplit = strsplit
    _G.strlenutf8 = function(text)
        local count = 0
        for index = 1, #text do
            local byte = text:byte(index)
            if byte < 128 or byte >= 192 then count = count + 1 end
        end
        return count
    end
    _G.tContains = function(t, value) for _, item in pairs(t) do if item == value then return true end end return false end

    -- WoW's xpcall forwards extra arguments to the called function; Lua 5.1's does not.
    _G.xpcall = function(func, handler, ...)
        local count, args = select("#", ...), { ... }
        return Stub.rawXpcall(function() return func(unpack(args, 1, count)) end, handler)
    end
    -- Errors that Ace3's safecall swallows land here so tests can assert on them.
    _G.geterrorhandler = function()
        return function(err) table.insert(S.errors, tostring(err)); return err end
    end
    _G.securecallfunction = function(func, ...)
        local results = { _G.xpcall(func, _G.geterrorhandler(), ...) }
        if results[1] then return unpack(results, 2, table.maxn(results)) end
    end
    _G.print = function(...)
        local parts = {}
        for i = 1, select("#", ...) do parts[i] = tostring(select(i, ...)) end
        table.insert(S.chat, table.concat(parts, " "))
    end
    _G.DEFAULT_CHAT_FRAME = { AddMessage = function(_, message) table.insert(S.chat, message) end }

    -- Client identity.
    _G.WOW_PROJECT_MAINLINE, _G.WOW_PROJECT_CLASSIC, _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 1, 2, 5
    _G.WOW_PROJECT_WRATH_CLASSIC, _G.WOW_PROJECT_CATACLYSM_CLASSIC, _G.WOW_PROJECT_MISTS_CLASSIC = 11, 14, 19
    -- WOW_PROJECT_CAMELOT only exists on the Forever client.
    _G.WOW_PROJECT_CAMELOT = flavor.project == 18 and 18 or nil
    _G.WOW_PROJECT_ID = flavor.project
    _G.GetBuildInfo = function() return flavor.version, flavor.build, "Sep 1 2026", flavor.interface end
    _G.Enum = flavor.modern and { QuestTag = { Group = 1, PvP = 41, Raid = 62, Dungeon = 81, Heroic = 85 } } or {}
    _G.C_GameRules = nil
    if flavor.interface > 16000 and flavor.interface < 20000 then
        -- Forever picks a ruleset instead of a named realm; AceDB keys profiles by it.
        _G.Enum.GameRule = { HardcoreRuleset = 1, RPRuleset = 2, PvPRuleset = 3 }
        _G.C_GameRules = { IsGameRuleActive = function() return false end }
    end
    _G.GetLocale = function() return S.locale end
    _G.date, _G.time = os.date, os.time
    _G.GetCurrentRegion = function() return 1 end
    _G.GetCurrentRegionName = function() return "US" end
    _G.GetRealmName = function() return S.player.realm end
    _G.IsLoggedIn = function() return S.loggedIn end
    _G.InCombatLockdown = function() return S.inCombat end
    _G.GetTime = function() return S.now end
    _G.GetPhysicalScreenSize = function() return 1920, 1080 end
    _G.C_AddOns = { GetAddOnMetadata = function(_, field) return S.metadata[field] end }
    _G.GetAddOnMetadata = nil

    -- Units.
    _G.UnitName = function(unit) if unit == "player" then return S.player.name end end
    _G.UnitClass = function(unit) if unit == "player" then return "Warrior", S.player.classFile, S.player.classId end end
    _G.UnitLevel = function(unit) return unit == "player" and S.player.level or 0 end
    _G.UnitGUID = function(unit) if unit == "player" then return S.player.guid end end
    _G.UnitRace = function() return "Human", "Human" end
    _G.UnitFactionGroup = function() return "Alliance", "Alliance" end

    -- Global strings the addon reads.
    _G.DAILY, _G.WEEKLY, _G.FAILED = "Daily", "Weekly", "Failed"
    _G.LFG_TYPE_DUNGEON, _G.RAID, _G.GROUP, _G.ELITE, _G.PLAYER_DIFFICULTY2, _G.PVP = "Dungeon", "Raid", "Group", "Elite", "Heroic", "PvP"
    _G.RETRIEVING_DATA = "Retrieving item information"
    _G.ERR_NOT_IN_COMBAT = "You can't do that while in combat."

    -- Timers. AceTimer schedules through C_Timer.After and checks GetTime when the callback runs.
    local function schedule(delay, callback)
        S.seq = S.seq + 1
        local timer = { due = S.now + math.max(delay or 0, 0), callback = callback, seq = S.seq }
        function timer:Cancel() self.cancelled = true end
        function timer:IsCancelled() return self.cancelled == true end
        table.insert(S.timers, timer)
        return timer
    end
    _G.C_Timer = {
        After = function(delay, callback) schedule(delay, callback) end,
        NewTimer = function(delay, callback) return schedule(delay, callback) end,
    }

    -- Modifier keys, for click bindings like ALT-BUTTON1.
    _G.IsShiftKeyDown = function() return S.modifiers.shift == true end
    _G.IsControlKeyDown = function() return S.modifiers.ctrl == true end
    _G.IsAltKeyDown = function() return S.modifiers.alt == true end

    -- Static popups: StaticPopup_Show returns the shown dialog; Stub.AcceptPopup clicks its first button.
    _G.StaticPopupDialogs = {}
    _G.StaticPopup_Show = function(which, textArg1, textArg2, data)
        local info = assert(_G.StaticPopupDialogs[which], "wow_stub: unknown popup " .. tostring(which))
        local dialog = { which = which, text = info.text:format(textArg1, textArg2), data = data }
        table.insert(S.popups, dialog)
        return dialog
    end

    -- UI.
    _G.CreateFrame = CreateFrame
    _G.CreateFramePool = CreateFramePool
    _G.UIParent = CreateFrame("Frame", "UIParent")
    _G.GameTooltip = CreateFrame("GameTooltip", "GameTooltip", _G.UIParent)
    _G.GameTooltip.NineSlice = CreateFrame("Frame", nil, _G.GameTooltip)
    _G.GameTooltip:Hide()

    installQuestLog(flavor)
    installQuestFrames(flavor)
end

----------------------------------------------------------------
-- Driving the client
----------------------------------------------------------------

--- Delivers an event to every frame registered for it, like the client does.
function Stub.Fire(event, ...)
    for _, frame in ipairs(Stub.state.frames) do
        local handler = frame.__events[event] and frame.__scripts.OnEvent
        if handler then handler(frame, event, ...) end
    end
end

--- Moves the clock forward, running every C_Timer callback that comes due on the way, in order.
function Stub.Advance(seconds)
    local S = Stub.state
    local target = S.now + seconds
    for _ = 1, 10000 do
        local nextTimer, position
        for index, timer in ipairs(S.timers) do
            if timer.due <= target and (not nextTimer or timer.due < nextTimer.due
                or (timer.due == nextTimer.due and timer.seq < nextTimer.seq)) then
                nextTimer, position = timer, index
            end
        end
        if not nextTimer then
            S.now = target
            return
        end
        table.remove(S.timers, position)
        S.now = math.max(S.now, nextTimer.due)
        if not nextTimer.cancelled then nextTimer.callback(nextTimer) end
    end
    error("wow_stub: timers kept rescheduling themselves")
end

--- Replaces the quest log with a copy of `entries` (abandons change the log, and a spec's table
-- shouldn't change with it). See the comment above questIndex for the entry format.
function Stub.SetQuestLog(entries)
    local log = {}
    for index, entry in ipairs(entries) do
        log[index] = {}
        for key, value in pairs(entry) do log[index][key] = value end
    end
    Stub.state.questLog = log
end

--- Tells the addon the quest log changed, the way the client does, and lets its event buckets fire.
function Stub.QuestLogChanged()
    Stub.Fire("QUEST_LOG_UPDATE")
    Stub.Fire("UNIT_QUEST_LOG_CHANGED", "player")
    Stub.Advance(1)
end

--- Opens the quest log: lays out its rows, then shows the frame (which runs the addon's OnShow hooks).
function Stub.OpenQuestLog()
    layoutQuestLog()
    local frame = Stub.flavor.legacy and _G.QuestLogFrame or _G.QuestMapFrame
    frame:Hide()
    frame:Show()
end

function Stub.CloseQuestLog()
    local frame = Stub.flavor.legacy and _G.QuestLogFrame or _G.QuestMapFrame
    frame:Hide()
end

--- The quest log row showing a quest or header, as the client drew it last.
function Stub.QuestLogRow(questIdOrHeader)
    if Stub.flavor.legacy then
        local scroll = _G.QuestLogListScrollFrame
        for i = 1, Stub.QUESTS_DISPLAYED do
            local button = scroll.buttons and scroll.buttons[i] or _G["QuestLogTitle" .. i]
            local entry = Stub.state.questLog[button:GetID()]
            if entry and (entry.id == questIdOrHeader or entry.header == questIdOrHeader) then return button end
        end
        return nil
    end
    local scroll = _G.QuestScrollFrame
    for title in scroll.titleFramePool:EnumerateActive() do
        if title.questID == questIdOrHeader then return title end
    end
    for header in scroll.headerFramePool:EnumerateActive() do
        if header.ButtonText:GetText() == questIdOrHeader then return header end
    end
end

--- A mouse click on a frame: OnMouseDown, then OnClick. modifiers = { alt =, ctrl =, shift = }.
function Stub.Click(frame, mouseButton, modifiers)
    mouseButton = mouseButton or "LeftButton"
    Stub.state.modifiers = modifiers or {}
    local down = frame.__scripts.OnMouseDown
    if down then down(frame, mouseButton) end
    local click = frame.__scripts.OnClick
    if click then click(frame, mouseButton, false) end
    Stub.state.modifiers = {}
end

--- Clicks the first button of the last popup shown (or of the one given).
function Stub.AcceptPopup(dialog)
    dialog = dialog or Stub.state.popups[#Stub.state.popups]
    assert(dialog, "wow_stub: no popup is showing")
    local info = _G.StaticPopupDialogs[dialog.which]
    info.OnAccept(dialog, dialog.data)
end

--- Runs a slash command the way the chat box does, e.g. Stub.RunSlash("/rab list all").
function Stub.RunSlash(line)
    local command, rest = line:match("^(/%S+)%s*(.-)$")
    command = command:lower()
    for key, handler in pairs(_G.SlashCmdList) do
        for index = 1, 20 do
            local slash = _G["SLASH_" .. key .. index]
            if not slash then break end
            if slash:lower() == command then return handler(rest), key end
        end
    end
    error("wow_stub: no handler for " .. command)
end

--- Chat lines with color codes, textures and links reduced to their text.
function Stub.PlainChat()
    local lines = {}
    for index, line in ipairs(Stub.state.chat) do
        lines[index] = line:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|H.-|h(.-)|h", "%1")
    end
    return lines
end

function Stub.ChatContains(fragment)
    for _, line in ipairs(Stub.PlainChat()) do
        if line:find(fragment, 1, true) then return true end
    end
    return false
end

function Stub.ClearChat()
    Stub.state.chat = {}
end

return Stub
