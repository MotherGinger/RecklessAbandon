local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

E.wowpatch, E.wowbuild = GetBuildInfo()
E.wowbuild = tonumber(E.wowbuild)
E.isRetail = WOW_PROJECT_ID == (WOW_PROJECT_MAINLINE or 1)
E.isClassic = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2)
E.isBC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
E.isWrath = WOW_PROJECT_ID == (WOW_PROJECT_WRATH_CLASSIC or 11)
E.isCata = WOW_PROJECT_ID == (WOW_PROJECT_CATACLYSM_CLASSIC or 14)
E.isMop = WOW_PROJECT_ID == (WOW_PROJECT_MISTS_CLASSIC or 19)

---@class Shim
E.Shim = {}

---@param unit string A unitid
---@return number levelRange The difference the unit's current level and the level at which quests are trivial
function E.Shim:UnitQuestTrivialLevelRange(unit)
    return E.isRetail and UnitQuestTrivialLevelRange(unit) or GetQuestGreenRange(unit)
end

---@param questId number The quest id to check
---@return boolean canAbandon If the quest can be abandoned
function E.Shim:CanAbandonQuest(questId)
    if E.isRetail then
        return C_QuestLog.CanAbandonQuest(questId)
    else
        return CanAbandonQuest(questId)
    end
end

---@param questIndex number The quest log index
---@return Info? info The quest information
function E.Shim:GetInfo(questIndex)
    ---@class Info
    ---@field title string The quest title
    ---@field questLogIndex number The quest log index
    ---@field questID number The quest ID
    ---@field level number The level of the quest
    ---@field isHeader boolean If the entry is a header
    ---@field isCollapsed boolean If the entry is a collapsed header
    ---@field isHidden boolean If the quest is not visible when inside the quest log
    ---@field questTag string Quest type label (Classic)
    ---@field frequency number Indicates if a quest is a daily (1) or a weekly (2)
    ---@field isComplete number Indicates if a quest is completed (1) or failed (-1) (Classic)
    local Info = {}

    if E.isRetail then
        local info = C_QuestLog.GetInfo(questIndex)

        Info.title = info.title
        Info.level = info.level
        Info.isHeader = info.isHeader
        Info.isCollapsed = info.isCollapsed
        Info.questID = info.questID
        Info.isHidden = info.isHidden
        Info.questLogIndex = info.questLogIndex
        Info.frequency = info.frequency
    else
        local title, level, questTag, isHeader, isCollapsed, isComplete, isDaily, questID,
        _, _, _, _, _, _, _, isHidden = GetQuestLogTitle(questIndex)

        Info.title = title
        Info.level = level
        Info.questTag = questTag
        Info.isHeader = isHeader
        Info.isCollapsed = isCollapsed
        Info.questID = questID
        Info.questLogIndex = questIndex
        Info.isHidden = isHidden
        Info.isComplete = isComplete

        -- Normalize
        Info.frequency = isDaily == 2 and 1 or 0
    end

    return Info
end

---@return number numEntries Number of entries in the quest log, including collapsible zone headers
---@return number numQuests Number of actual quests in the quest log, not counting zone headers
function E.Shim:GetNumQuestLogEntries()
    if E.isRetail then
        return C_QuestLog.GetNumQuestLogEntries()
    else
        return GetNumQuestLogEntries()
    end
end

---@param questId number The quest ID
---@return boolean isComplete Whether the quest is both in the quest log and is complete
function E.Shim:IsComplete(questId)
    if E.isRetail then
        return C_QuestLog.IsComplete(questId)
    else
        local questLogIndex = GetQuestLogIndexByID(questId)
        local _, _, _, _, _, isComplete, _, _ = GetQuestLogTitle(questLogIndex)

        return isComplete == 1
    end
end

---@param name number|string The name or index of the addon, case insensitive
---@param variable string The variable name, case insensitive
---@return string? value The value of the vvariable
function E.Shim:GetAddOnMetadata(name, variable)
    if E.isRetail or E.isBC then
        return C_AddOns.GetAddOnMetadata(name, variable)
    else
        return GetAddOnMetadata(name, variable)
    end
end

---@param questId number The quest ID
function E.Shim:SetSelectedQuest(questId)
    if E.isRetail then
        C_QuestLog.SetSelectedQuest(questId)
    else
        local logIndex = GetQuestLogIndexByID(questId)
        SelectQuestLogEntry(logIndex)
    end
end

function E.Shim:SetAbandonQuest()
    if E.isRetail then
        C_QuestLog.SetAbandonQuest()
    else
        SetAbandonQuest()
    end
end

function E.Shim:AbandonQuest()
    if E.isRetail then
        C_QuestLog.AbandonQuest()
    else
        AbandonQuest()
    end
end

---@param questId number The quest ID
---@return number? questLogIndex The quest log index
function E.Shim:GetLogIndexForQuestID(questId)
    if E.isRetail then
        return C_QuestLog.GetLogIndexForQuestID(questId)
    else
        local idx = GetQuestLogIndexByID(questId)

        -- Normalize: Classic returns 0 for "not found", Retail returns nil
        if idx == 0 then
            return nil
        end

        return idx
    end
end

---@param questId number The quest ID
---@return string? link The quest link, or nil if the quest is not in the quest log
function E.Shim:GetQuestLink(questId)
    if not (E.isClassic or E.isBC or E.isWrath) then
        return GetQuestLink(questId)
    end

    -- Classic, BC, and Wrath use quest log index instead of questId
    local questLogIndex = GetQuestLogIndexByID(questId)
    if not questLogIndex or questLogIndex == 0 then
        return nil
    end

    -- Try using GetQuestLink first
    local questLink = GetQuestLink(questLogIndex)
    if questLink then
        return questLink
    end

    -- Fallback: Manually construct the link (BC might not support GetQuestLink)
    local title, level = GetQuestLogTitle(questLogIndex)
    if not title then
        return nil
    end

    -- Quest link format: |cffRRGGBB|Hquest:questID:level|h[title]|h|r
    local playerLevel = UnitLevel("player")
    return format("|cffffff00|Hquest:%d:%d|h[%s]|h|r", questId, playerLevel, title)
end
