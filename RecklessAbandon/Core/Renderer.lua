local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

E.questGroupsByName = {}

local QuestFrame = E.isRetail and QuestMapFrame.QuestsFrame or QuestLogFrame
E.questButtonPool = CreateFramePool("Button", QuestFrame, "RECKLESS_ABANDON_BUTTON")
E.groupButtonPool = CreateFramePool("Button", QuestFrame, "RECKLESS_GROUP_ABANDON_BUTTON")

-- Button state cache for smart pool management
E.buttonStateCache = {
    activeQuestButtons = {}, -- questId -> button mapping
    activeGroupButtons = {}  -- groupKey -> button mapping
}

E.abandonTooltipFormat = "|cFFFFFAB8%s|r\n\n|cFFFFF569%s|r\n|cFFB5FFEB%s|r"
E.groupAbandonTooltipFormat = "|cFFFFFAB8%s|r\n\n|cFFFFF569%s|r"

local function GetKey(value)
    if value ~= nil then
        return value:lower():gsub("[^a-z]", "")
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

function E:RenderAbandonButton(parent, offset, questId, excluded, title, tooltip)
    title = title or parent:GetText()
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

    button:SetPoint("CENTER", parent, "CENTER", offset, 0)
    button:SetEnabled(canAbandon)
    button:Show()
end

function E:RenderGroupAbandonButton(parent, offset, title, tooltip, key)
    title = title or parent:GetText()
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

        button:SetPoint("CENTER", parent, "CENTER", offset, 0)
        button:SetEnabled(hasQuests and canAbandonAny)
        button:Show()
    end
end

function E:ShowAbandonButtons()
    if E.isRetail then
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

-- Smart button management: only release buttons no longer needed
function E:SmartReleaseButtons(neededQuestIds, neededGroupKeys)
    -- Release quest buttons that are no longer needed
    for questId, button in pairs(E.buttonStateCache.activeQuestButtons) do
        if not neededQuestIds[questId] then
            E.questButtonPool:Release(button)
            E.buttonStateCache.activeQuestButtons[questId] = nil
        end
    end

    -- Release group buttons that are no longer needed
    for groupKey, button in pairs(E.buttonStateCache.activeGroupButtons) do
        if not neededGroupKeys[groupKey] then
            E.groupButtonPool:Release(button)
            E.buttonStateCache.activeGroupButtons[groupKey] = nil
        end
    end
end

function E:RetailRenderer()
    E:HideAbandonButtons()

    -- Guard against a bad cache (https://github.com/MotherGinger/RecklessAbandon/issues/25)
    if E.db ~= nil and E.db.general ~= nil then
        if E.db.general.campaignQuests ~= nil and E.db.general.campaignQuests.showAbandonButton then
            for header in QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
                E:RenderGroupAbandonButton(header.CollapseButton, -25, header.Text:GetText())
            end
        end

        if E.db.general.covenantCallings ~= nil and E.db.general.covenantCallings.showAbandonButton then
            for calling in QuestScrollFrame.covenantCallingsHeaderFramePool:EnumerateActive() do
                local info = E.Shim:GetInfo(calling.questLogIndex)
                if info then
                    local title = info.title
                    local key = GetKey(title)
                    E:RenderGroupAbandonButton(
                        calling.CollapseButton,
                        -25,
                        L["covenant callings"],
                        L["Left Click: Abandon all covenant calling quests"],
                        key
                    )
                end
            end
        end

        if E.db.general.zoneQuests ~= nil and E.db.general.zoneQuests.showAbandonButton then
            for header in QuestScrollFrame.headerFramePool:EnumerateActive() do
                E:RenderGroupAbandonButton(header.CollapseButton, -25, header.ButtonText:GetText())
            end
        end

        if E.db.general.individualQuests ~= nil and E.db.general.individualQuests.showAbandonButton then
            for quest in QuestScrollFrame.titleFramePool:EnumerateActive() do
                local questId = quest.questID
                local text = quest.Text:GetText()
                local excluded = E:IsExcluded(questId)

                -- * This tag shows up in both the tooltip and the details pane, so lets hide it and collect more real estate for our button
                -- TODO: This is a partial workaround since this will pop back in when hiding the details pane
                quest.TagTexture:Hide()
                E:RenderAbandonButton(quest.Checkbox, -25, questId, excluded, text)
            end
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

                local questLogTitle
                if E.isClassic or E.isBC then
                    -- * Vanilla needs to use _G to access the frame dynamically
                    questLogTitle = _G["QuestLogTitle" .. i]
                else
                    questLogTitle = QuestLogListScrollFrame.buttons[i]
                end

                questLogTitle:SetWidth(QuestLogListScrollFrame:GetWidth() - 50)

                if info.isHeader and E.db.general.zoneQuests.showAbandonButton then
                    E:RenderGroupAbandonButton(questLogTitle, QuestLogListScrollFrame:GetWidth() - 138, info.title)
                elseif not info.isHeader and E.db.general.individualQuests.showAbandonButton then
                    local excluded = E:IsExcluded(info.questID)
                    E:RenderAbandonButton(questLogTitle, QuestLogListScrollFrame:GetWidth() - 163, info.questID, excluded, info.title)
                end
            end
        end
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

    local currentGroup = { quests = {} }

    for i = 1, E.Shim:GetNumQuestLogEntries() do
        local info = E.Shim:GetInfo(i)
        if not info then
            E:Error(format("Failed to get quest info for index %d", i))
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
                if E.isRetail or (not E.isRetail and not info.isCollapsed) then
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
    for i = 1, GetNumQuestLogEntries() do
        local questLogTitle
        if E.isClassic or E.isBC then
            -- * Vanilla needs to use _G to access the frame dynamically
            questLogTitle = _G["QuestLogTitle" .. i]
        else
            questLogTitle = QuestLogListScrollFrame.buttons[i]
        end

        if questLogTitle and not questLogTitle.hasOnMouseDownScript then
            questLogTitle.origOnClick = questLogTitle:GetScript("OnClick")
            questLogTitle.origOnMouseDown = questLogTitle:GetScript("OnMouseDown")

            questLogTitle:SetScript("OnClick", onQuestLogEntryClick)
            questLogTitle:SetScript("OnMouseDown", onQuestLogEntryMouseDown)

            questLogTitle.hasOnMouseDownScript = true
        end
    end
end
