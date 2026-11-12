local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

E.questGroupsByName = {}

local QuestFrame = E.hasQuestMapFrame and QuestMapFrame.QuestsFrame or QuestLogFrame
E.questButtonPool = CreateFramePool("Button", QuestFrame, "RECKLESS_ABANDON_BUTTON")
E.groupButtonPool = CreateFramePool("Button", QuestFrame, "RECKLESS_GROUP_ABANDON_BUTTON")

-- Button state cache for smart pool management
E.buttonStateCache = {
    activeQuestButtons = {}, -- questId -> button mapping
    activeGroupButtons = {}  -- groupKey -> button mapping
}

E.abandonTooltipFormat = "|cFFFFFAB8%s|r\n\n|cFFFFF569%s|r\n|cFFB5FFEB%s|r"
E.groupAbandonTooltipFormat = "|cFFFFFAB8%s|r\n\n|cFFFFF569%s|r"

-- * Quest log row layout. Our buttons take a fixed spot at the right end of each row,
-- * and the row's own parts (title, tracking check, quest tag) move left to make room.
local CLASSIC_ROW_RESERVED = 50   -- Width taken off the right of each Classic row for our buttons
local CLASSIC_QUEST_GAP = 4       -- Quest button, right of the row's new right edge
local CLASSIC_HEADER_GAP = 29     -- Header button, right of the row's new right edge
local CLASSIC_TAG_INSET = 2       -- The client pins the quest tag this far in from the row's right edge
local CLASSIC_TEXT_GAP = 4        -- Space between the title and the quest tag
local CLASSIC_CHECK_GAP = 2       -- Space between the title and the tracking check
local RETAIL_BUTTON_GAP = 4       -- Space between the tracking checkbox and our button
local RETAIL_SLOT = 16 + RETAIL_BUTTON_GAP -- How far the tracking checkbox moves left: our button plus the gap

-- * Retail quest rows whose tracking checkbox we moved, so the setting can put them back.
E.reservedQuestRows = {}

local function Place(button, ...)
    if button then
        button:ClearAllPoints()
        button:SetPoint(...)
    end
end

-- * Normalizes a header title so the frame text and the quest log title match.
-- * Removes color codes, spaces, digits and ASCII punctuation, but keeps every non-ASCII byte.
-- * Stripping everything outside a-z gave every Russian/Chinese header the same empty key,
-- * so one header's group abandon could take another header's quests.
local function GetKey(value)
    if value ~= nil then
        local key = value:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):lower():gsub("[%s%p%d]", "")
        return key
    end
end

local function GetKeybinding(button)
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

local function onQuestLogEntryClick(self, button, down)
    -- * Retail includes questLogIndex on the title object
    local info = E.Shim:GetInfo(self.questLogIndex or self:GetID())
    local isHeader = info.isHeader
    local abandonQuestBinding = E.db.general.individualQuests.abandonBinding
    local excludeQuestBinding = E.db.general.individualQuests.excludeBinding
    local groupAbandonQuestBinding = E.db.general.zoneQuests.abandonBinding
    local binding = GetKeybinding(button)
    local isBound = (isHeader and binding == groupAbandonQuestBinding) or binding == abandonQuestBinding or binding == excludeQuestBinding

    -- * If the click matches a binding, disable default behaviors
    -- * In retail this prevents things like the right click context menu or the full page quest description
    if self.origOnClick and not isBound then
        self:origOnClick(button, down)
    end
end

local function onQuestLogEntryMouseDown(self, button)
    -- * Retail includes questLogIndex on the title object
    local info = E.Shim:GetInfo(self.questLogIndex or self:GetID())
    local title = info.title
    local isHeader = info.isHeader
    local questId = info.questID
    local abandonQuestBinding = E.db.general.individualQuests.abandonBinding
    local excludeQuestBinding = E.db.general.individualQuests.excludeBinding
    local groupAbandonQuestBinding = E.db.general.zoneQuests.abandonBinding
    local binding = GetKeybinding(button)

    if isHeader and binding == groupAbandonQuestBinding then
        if E.db.general.confirmGroup then
            local dialog = StaticPopup_Show("RECKLESS_ABANDON_GROUP_CONFIRMATION", title)
            if dialog then
                dialog.data = GetKey(title)
            end
        else
            E:AbandonZoneQuests(GetKey(title))
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
            E:AbandonQuest(questId, true)
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

        E:ShowAbandonButtons()
    end

    if self.origOnMouseDown then
        self:origOnMouseDown(button)
    end
end

-- * Sets up a quest's abandon button and returns it; the caller places it on the row.
function E:RenderAbandonButton(questId, excluded, title, tooltip)
    tooltip = tooltip or format(
        E.abandonTooltipFormat,
        title,
        L["Left Click: Abandon quest"],
        (excluded and L["Right Click: Include quest in group abandons"] or
            L["Right Click: Exclude quest from group abandons"])
    )

    -- Try to reuse existing button from cache, or acquire new one
    local button = E.buttonStateCache.activeQuestButtons[questId]
    if not button then
        button = E.questButtonPool:Acquire()
        E.buttonStateCache.activeQuestButtons[questId] = button
    end

    local canAbandon = E.Shim:CanAbandonQuest(questId)

    E:SetupButtonTextures(button)

    local ntex = button:GetNormalTexture()

    button.title = title
    button.tooltip = tooltip
    button.questId = questId

    ntex:SetDesaturated(not canAbandon)

    if canAbandon and excluded then
        ntex:SetVertexColor(0.5, 0.5, 1, 0.7)
    else
        ntex:SetVertexColor(1, 1, 1, 1)
    end

    button:SetEnabled(canAbandon)
    button:Show()
    return button
end

-- * Sets up a quest group's abandon button and returns it (nil for an unknown group); the caller places it.
function E:RenderGroupAbandonButton(title, tooltip, key)
    tooltip = tooltip or format(E.groupAbandonTooltipFormat, title, L["Left Click: Abandon all quests"], title)
    key = key or GetKey(title)

    if E.questGroupsByName[key] then
        -- Try to reuse existing button from cache, or acquire new one
        local button = E.buttonStateCache.activeGroupButtons[key]
        if not button then
            button = E.groupButtonPool:Acquire()
            E.buttonStateCache.activeGroupButtons[key] = button
        end

        local hasQuests = not E:IsEmpty(E.questGroupsByName[key].quests)
        local canAbandonAny = E:CanQuestGroupAbandon(E.questGroupsByName[key].quests)

        E:SetupButtonTextures(button)

        local ntex = button:GetNormalTexture()

        button.title = title
        button.tooltip = tooltip
        button.key = key

        ntex:SetDesaturated(not hasQuests or not canAbandonAny)

        button:SetEnabled(hasQuests and canAbandonAny)
        button:Show()
        return button
    end
end

function E:ShowAbandonButtons()
    if E.hasQuestMapFrame then
        E:RetailRenderer()
    else
        E:ClassicRenderer()
    end
end

function E:HideAbandonButtons()
    E.questButtonPool:ReleaseAll()
    E.groupButtonPool:ReleaseAll()
    -- Clear cache when doing full release
    E.buttonStateCache.activeQuestButtons = {}
    E.buttonStateCache.activeGroupButtons = {}
end

-- * Retail lays a quest row out right to left from its tracking checkbox: the checkbox, then the tag icon,
-- * then the storyline icon, then the title, each anchored to the one on its right. Moving the checkbox left
-- * frees the row's right end for our button, and everything anchored to it moves along.
-- * The client never re-anchors the checkbox, so the move lasts while the row is reused for other quests.
local function ReserveRetailRow(quest, reserve)
    local checkbox = quest.Checkbox

    if reserve and not quest.raCheckboxPoint then
        local point, relativeTo, relativePoint, x, y = checkbox:GetPoint(1)
        if point then
            quest.raCheckboxPoint = { point, relativeTo, relativePoint, x or 0, y or 0 }
            checkbox:ClearAllPoints()
            checkbox:SetPoint(point, relativeTo, relativePoint, (x or 0) - RETAIL_SLOT, y or 0)
            E.reservedQuestRows[quest] = true
        end
    elseif not reserve and quest.raCheckboxPoint then
        checkbox:ClearAllPoints()
        checkbox:SetPoint(unpack(quest.raCheckboxPoint))
        quest.raCheckboxPoint = nil
        E.reservedQuestRows[quest] = nil
    end
end

-- * Makes room on Retail quest rows while individual abandon buttons are on, and gives it back when they're off.
-- * Runs as the client hands out each row too, so the title wraps to the narrower width the first time it's drawn.
function E:UpdateQuestRowSpace()
    local general = E.db and E.db.general
    if general and general.individualQuests and general.individualQuests.showAbandonButton then
        for quest in QuestScrollFrame.titleFramePool:EnumerateActive() do
            ReserveRetailRow(quest, true)
        end
    else
        for quest in pairs(E.reservedQuestRows) do
            ReserveRetailRow(quest, false)
        end
    end
end

function E:RetailRenderer()
    E:HideAbandonButtons()
    E:UpdateQuestRowSpace()

    -- Guard against a bad cache (https://github.com/MotherGinger/RecklessAbandon/issues/25)
    if E.db ~= nil and E.db.general ~= nil then
        if E.db.general.campaignQuests ~= nil and E.db.general.campaignQuests.showAbandonButton and QuestScrollFrame.campaignHeaderFramePool then
            for header in QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
                local button = E:RenderGroupAbandonButton(header.Text:GetText())
                Place(button, "CENTER", header.CollapseButton, "CENTER", -25, 0)
            end
        end

        if E.db.general.covenantCallings ~= nil and E.db.general.covenantCallings.showAbandonButton and QuestScrollFrame.covenantCallingsHeaderFramePool then
            for calling in QuestScrollFrame.covenantCallingsHeaderFramePool:EnumerateActive() do
                local info = E.Shim:GetInfo(calling.questLogIndex)
                if info then
                    local title = info.title
                    local key = GetKey(title)
                    local button = E:RenderGroupAbandonButton(
                        L["covenant callings"],
                        L["Left Click: Abandon all covenant calling quests"],
                        key
                    )
                    Place(button, "CENTER", calling.CollapseButton, "CENTER", -25, 0)
                end
            end
        end

        if E.db.general.zoneQuests ~= nil and E.db.general.zoneQuests.showAbandonButton then
            for header in QuestScrollFrame.headerFramePool:EnumerateActive() do
                local button = E:RenderGroupAbandonButton(header.ButtonText:GetText())
                Place(button, "CENTER", header.CollapseButton, "CENTER", -25, 0)
            end
        end

        if E.db.general.individualQuests ~= nil and E.db.general.individualQuests.showAbandonButton then
            for quest in QuestScrollFrame.titleFramePool:EnumerateActive() do
                local questId = quest.questID
                local excluded = E:IsExcluded(questId)

                -- * Our button takes the space the tracking checkbox moved out of (see ReserveRetailRow)
                local button = E:RenderAbandonButton(questId, excluded, quest.Text:GetText())
                Place(button, "LEFT", quest.Checkbox, "RIGHT", RETAIL_BUTTON_GAP, 0)
            end
        end
    end
end

local function GetClassicRow(i)
    if E.isClassic or E.isBC then
        -- * Vanilla needs to use _G to access the frame dynamically
        return _G["QuestLogTitle" .. i]
    end
    return QuestLogListScrollFrame.buttons[i]
end

-- * Mists names the row's parts by key; Vanilla and TBC only by global name.
local function GetClassicRowParts(row)
    local name = row:GetName()
    local tag = row.tag or (name and _G[name .. "Tag"])
    local check = row.check or (name and _G[name .. "Check"])
    local text = row.normalText or (name and _G[name .. "NormalText"])
    return tag, check, text
end

-- * How far a region's left edge sits from the row's left edge
local function GetLeftInRow(region, row)
    local left, rowLeft = region:GetLeft(), row:GetLeft()
    if left and rowLeft then
        return left - rowLeft
    end
    local _, _, _, x = region:GetPoint(1)
    return x or 0
end

-- * A Classic row is a fixed-width button. The title and the tracking check run left to right from its
-- * left edge, and the client pins the quest tag ("(Elite)", "(Daily)") to its right edge.
-- * Narrowing the row moves the tag left, clear of our button. The client sizes the title for the full
-- * width (Vanilla and TBC assume 275 pixels), so the title is cut down to end before the tag and the
-- * check is moved back to the title's end.
function E:LayoutClassicRow(row)
    row:SetWidth(QuestLogListScrollFrame:GetWidth() - CLASSIC_ROW_RESERVED)

    local tag, check, text = GetClassicRowParts(row)

    local right = row:GetWidth()
    if tag:IsShown() and (tag:GetText() or "") ~= "" then
        right = right - CLASSIC_TAG_INSET - tag:GetStringWidth() - CLASSIC_TEXT_GAP
    end

    local checkShown = check:IsShown()
    if checkShown then
        right = right - CLASSIC_CHECK_GAP - check:GetWidth()
    end

    local available = math.max(right - GetLeftInRow(text, row), 0)
    text:SetWidth(math.min(text:GetStringWidth(), available))

    if checkShown then
        check:ClearAllPoints()
        check:SetPoint("LEFT", text, "RIGHT", CLASSIC_CHECK_GAP, 0)
    end
end

-- * Lays out every row the quest log shows. The client redraws the rows on its own (selecting a quest,
-- * tracking one), which sizes the titles for the full row again, so this also runs after QuestLog_Update.
function E:LayoutClassicRows()
    for i = 1, QUESTS_DISPLAYED do
        local row = GetClassicRow(i)
        if row and row:IsShown() then
            E:LayoutClassicRow(row)
        end
    end
end

function E:ClassicRenderer()
    E:HideAbandonButtons()

    -- Guard against a bad cache (https://github.com/MotherGinger/RecklessAbandon/issues/25)
    if E.db ~= nil and E.db.general ~= nil then
        local numEntries = E.Shim:GetNumQuestLogEntries()
        for i = 1, QUESTS_DISPLAYED do
            local questIndex = floor(i + QuestLogListScrollFrame.offset)
            if questIndex <= numEntries then
                local info = E.Shim:GetInfo(questIndex)
                local questLogTitle = GetClassicRow(i)

                E:LayoutClassicRow(questLogTitle)

                -- * Our buttons sit just past the row's right edge, which the layout moved left to make room
                if info.isHeader and E.db.general.zoneQuests.showAbandonButton then
                    local button = E:RenderGroupAbandonButton(info.title)
                    Place(button, "LEFT", questLogTitle, "RIGHT", CLASSIC_HEADER_GAP, 0)
                elseif not info.isHeader and E.db.general.individualQuests.showAbandonButton then
                    local excluded = E:IsExcluded(info.questID)
                    local button = E:RenderAbandonButton(info.questID, excluded, info.title)
                    Place(button, "LEFT", questLogTitle, "RIGHT", CLASSIC_QUEST_GAP, 0)
                end
            end
        end
    end
end

function E:GenerateQuestTable()
    E:EnsurePrivateDefaults()

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

    -- * Catches quests listed before the first header, which belong to no group
    local currentGroup = { quests = {} } -- luacheck: ignore 331

    for i = 1, E.Shim:GetNumQuestLogEntries() do
        local info = E.Shim:GetInfo(i)
        if not info then
            E:Debug(format("Failed to get quest info for index %d", i))
        else
            if info.isHeader then
                currentGroup = {
                    title = info.title,
                    hidden = true,
                    quests = {}
                }

                -- * In classic, collapsing a zone header "removes" the quests from the log since they aren't rendered
                -- * If the header is collapsed, don't overwrite the last known quests under it to work around this
                -- * This should always work as long as the headers are expanded at least once which tends to happen on initial load anyways
                if E.hasQuestLogAPI or not info.isCollapsed then
                    E.questGroupsByName[GetKey(info.title)] = currentGroup
                end
            else
                currentGroup.hidden = currentGroup.hidden and info.isHidden
                currentGroup.quests[info.questID] = info.title
            end
        end
    end

    self:Debug(L["Quest Table: "] .. self:Dump(E.questGroupsByName))
    self:Debug(L["Excluded Quests: "] .. self:Dump(self.private.exclusions.excludedQuests))
end

function E:RegisterRetailHotkeys()
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

function E:RegisterClassicHotkeys()
    for i = 1, E.Shim:GetNumQuestLogEntries() do
        local questLogTitle = GetClassicRow(i)

        if questLogTitle and not questLogTitle.hasOnMouseDownScript then
            questLogTitle.origOnClick = questLogTitle:GetScript("OnClick")
            questLogTitle.origOnMouseDown = questLogTitle:GetScript("OnMouseDown")

            questLogTitle:SetScript("OnClick", onQuestLogEntryClick)
            questLogTitle:SetScript("OnMouseDown", onQuestLogEntryMouseDown)

            questLogTitle.hasOnMouseDownScript = true
        end
    end
end
