local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local ipairs, pcall, type = ipairs, pcall, type

-- * Reads quest facts from QuestieDB, the quest database addon Questie depends on. Only its
-- * versioned public API (LibQuestieDB) is used, never Questie's own modules, which change often.
-- * Everything here is guarded by the "Questie integration" option (E.db.questie.enabled).

---@class QuestieIntegration
local Questie = {}
E.Questie = Questie

-- * The QuestieDB API version this file is written against. Newer QuestieDB releases keep supporting it.
Questie.CONTRACT = 4

--- Whether QuestieDB is loaded and supports the API version this file uses.
---@return boolean
function Questie:IsAvailable()
    if self.available == nil then
        local lib = _G.LibQuestieDB
        local usable = type(lib) == "table" and type(lib.RequireContract) == "function"
            and type(lib.Quest) == "table" and type(lib.Quest.Get) == "function"
        local ok, supported = false, false
        if usable then
            ok, supported = pcall(lib.RequireContract, self.CONTRACT)
        end
        self.available = ok and supported == true
    end

    return self.available
end

--- Whether QuestieDB is available and the "Questie integration" option is on.
---@return boolean
function Questie:IsEnabled()
    return self:IsAvailable() and E.db.questie.enabled == true
end

--- One field of a quest from QuestieDB, or nil when it has none or the read fails.
---@param questId number
---@param field string A QuestieDB quest field, e.g. "startedBy"
function Questie:Get(questId, field)
    local ok, value = pcall(_G.LibQuestieDB.Quest.Get, questId, field)
    if ok then
        return value
    end
end

--- Whether the quest can only be started from an item, so abandoning it may mean finding that item again.
---@param questId number
---@return boolean
function Questie:IsStartedByItem(questId)
    local startedBy = self:Get(questId, "startedBy")
    if type(startedBy) ~= "table" then
        return false
    end

    local npcs, objects, items = startedBy[1], startedBy[2], startedBy[3]
    local function any(list) return type(list) == "table" and #list > 0 end

    -- * A quest an NPC or object also gives out is easy to pick up again
    return any(items) and not any(npcs) and not any(objects)
end

--- Whether "Item Quest Protection" should keep this quest out of group abandons.
---@param questId number
---@return boolean
function Questie:ShouldProtect(questId)
    return self:IsEnabled() and E.db.questie.itemProtection == true and self:IsStartedByItem(questId)
end

--- Whether the quest can no longer be turned in: a breadcrumb to a quest already done, or a quest
--- that can't be done alongside one already done.
---@param questId number
---@return boolean
function Questie:IsObsolete(questId)
    local target = self:Get(questId, "breadcrumbForQuestId")
    if type(target) == "number" and target ~= 0 and E.Shim:IsQuestFlaggedCompleted(target) then
        return true
    end

    local exclusiveTo = self:Get(questId, "exclusiveTo")
    if type(exclusiveTo) == "table" then
        for _, otherId in ipairs(exclusiveTo) do
            if otherId ~= questId and E.Shim:IsQuestFlaggedCompleted(otherId) then
                return true
            end
        end
    end

    return false
end

--- Turns the "Questie integration" option on or off and applies it to the quest log.
---@param enabled boolean
function Questie:SetEnabled(enabled)
    E.db.questie.enabled = enabled == true
    E:OnQuestLogChanged()
end

--- Turns "Item Quest Protection" on or off and applies it to the quest log.
---@param enabled boolean
function Questie:SetItemProtection(enabled)
    E.db.questie.itemProtection = enabled == true
    E:OnQuestLogChanged()
end
