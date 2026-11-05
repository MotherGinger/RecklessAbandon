local Loader = require("helpers.loader")

local SWEEP = 10

local function contains(list, value)
    for _, item in ipairs(list) do
        if item == value then return true end
    end
    return false
end

--- Boots with the given quest log and automation rules, then lets the quest log events run.
local function bootWith(flavor, questLog, questTypes, ids)
    local E, Stub = Loader.Boot(flavor, { questLog = questLog })
    for questType, enabled in pairs(questTypes or {}) do
        E.private.automationOptions.autoAbandonQuests.questType[questType] = enabled
    end
    E.private.automationOptions.autoAbandonQuests.ids = ids or ""
    E:UpdateParsedExclusions()
    Stub.ClearChat()
    Stub.QuestLogChanged()
    Stub.Advance(SWEEP)
    return E, Stub
end

describe("automatic abandons", function()
    local LOG = {
        { header = "Zone" },
        { id = 101, title = "Gray Quest", level = 40 },
        { id = 102, title = "Green Quest", level = 55 },
        { id = 103, title = "Yellow Quest", level = 60 },
    }

    for _, flavor in ipairs(Loader.FLAVORS) do
        describe("on " .. flavor, function()
            it("abandons quests of a chosen color and keeps the rest", function()
                local _, Stub = bootWith(flavor, LOG, { gray = true })
                assert.are.same({ 101 }, Stub.state.abandoned)
            end)

            it("abandons quests by ID", function()
                local _, Stub = bootWith(flavor, LOG, {}, "103,999")
                assert.are.same({ 103 }, Stub.state.abandoned)
            end)

            it("does nothing with no rules", function()
                local _, Stub = bootWith(flavor, LOG)
                assert.are.same({}, Stub.state.abandoned)
            end)

            it("skips excluded quests and quests that can't be abandoned, without a word", function()
                local E, Stub = Loader.Boot(flavor, {
                    questLog = {
                        { id = 101, title = "Gray Quest", level = 40 },
                        { id = 104, title = "Gray Escort", level = 40, canAbandon = false },
                    },
                })
                E:ExcludeQuest(101)
                E.private.automationOptions.autoAbandonQuests.questType.gray = true
                Stub.ClearChat()
                Stub.QuestLogChanged()
                Stub.Advance(SWEEP)
                assert.are.same({}, Stub.state.abandoned)
                assert.are.same({}, Stub.state.chat)
            end)

            it("doesn't try a quest again after it failed to abandon", function()
                local E, Stub = Loader.Boot(flavor, { questLog = { { id = 101, title = "Gray Quest", level = 40 } } })
                Stub.state.dropAbandons = 100
                E.private.automationOptions.autoAbandonQuests.questType.gray = true
                Stub.QuestLogChanged()
                Stub.Advance(SWEEP)
                local attempts = #Stub.state.dropped
                Stub.QuestLogChanged()
                Stub.Advance(SWEEP)
                assert.are.equal(attempts, #Stub.state.dropped)
            end)

            it("abandons a quest that turns gray when the player levels up", function()
                local E, Stub = bootWith(flavor, { { id = 102, title = "Green Quest", level = 55 } }, { gray = true })
                assert.are.same({}, Stub.state.abandoned)
                Stub.Fire("PLAYER_LEVEL_UP", 64)
                Stub.Advance(SWEEP)
                assert.are.same({ 102 }, Stub.state.abandoned)
                assert.are.equal(64, E.mylevel)
            end)
        end)
    end

    it("abandons dailies where the client has them", function()
        local daily = { { id = 101, title = "Daily", level = 60, frequency = "daily" }, { id = 102, title = "Normal", level = 60 } }
        assert.are.same({ 101 }, (select(2, bootWith("tbc", daily, { daily = true }))).state.abandoned)
        assert.are.same({ 101 }, (select(2, bootWith("retail", daily, { daily = true }))).state.abandoned)
        assert.are.same({}, (select(2, bootWith("classic", daily, { daily = true }))).state.abandoned)
    end)

    it("abandons weeklies on Retail", function()
        local weekly = { { id = 101, title = "Weekly", level = 60, frequency = "weekly" }, { id = 102, title = "Normal", level = 60 } }
        assert.are.same({ 101 }, (select(2, bootWith("retail", weekly, { weekly = true }))).state.abandoned)
    end)

    describe("by quest tag", function()
        it("on Classic, from the quest log's tag text", function()
            local _, Stub = bootWith("classic", {
                { id = 101, title = "Dungeon Quest", level = 60, tag = "Dungeon" },
                { id = 102, title = "Elite Quest", level = 60, tag = "Elite" },
                { id = 103, title = "Plain Quest", level = 60 },
            }, { dungeon = true, elite = true })
            assert.are.same({ 101, 102 }, Stub.state.abandoned)
        end)

        it("on Forever, from C_QuestLog's tag info", function()
            local _, Stub = bootWith("forever", {
                { id = 101, title = "Dungeon Quest", level = 60, tagID = 81, tag = "Dungeon" },
                { id = 102, title = "Elite Quest", level = 60, elite = true },
                { id = 103, title = "Raid Quest", level = 60, tagID = 62 },
                { id = 104, title = "Plain Quest", level = 60 },
            }, { dungeon = true, elite = true })
            assert.are.same({ 101, 102 }, Stub.state.abandoned)
        end)

        it("not on Retail, which has no tag qualifiers", function()
            local _, Stub = bootWith("retail", { { id = 101, title = "Dungeon Quest", level = 60, tagID = 81 } }, { dungeon = true })
            assert.are.same({}, Stub.state.abandoned)
        end)
    end)

    for _, flavor in ipairs({ "classic", "forever" }) do
        it("abandons failed quests on " .. flavor, function()
            local _, Stub = bootWith(flavor, {
                { id = 101, title = "Failed Escort", level = 60, failed = true },
                { id = 102, title = "Going Fine", level = 60 },
            }, { failed = true })
            assert.are.same({ 101 }, Stub.state.abandoned)
        end)
    end

    describe("settings", function()
        local function option(E, name)
            return E.Options.args.general.args.automationOptions.args.autoAbandonQuests.args[name]
        end

        it("applies a newly chosen quest type to the quests already in the log", function()
            local E, Stub = bootWith("classic", LOG)
            option(E, "questType").set(nil, "gray")
            Stub.Advance(SWEEP)
            assert.are.same({ 101 }, Stub.state.abandoned)
        end)

        it("cleans up typed quest IDs and applies them", function()
            local E, Stub = bootWith("classic", LOG)
            option(E, "ids").set(nil, " ,101, ,abc,,103,")
            assert.are.equal("101,103", E.private.automationOptions.autoAbandonQuests.ids)
            Stub.Advance(SWEEP)
            assert.is_true(contains(Stub.state.abandoned, 101))
            assert.is_true(contains(Stub.state.abandoned, 103))
        end)

        it("lists the quest types of the client", function()
            local E = Loader.Boot("retail")
            local values = option(E, "questType").values()
            assert.are.equal("Weekly", values.weekly)
            assert.is_nil(values.failed)
        end)
    end)
end)

describe("complete protection", function()
    local LOG = {
        { id = 101, title = "Ready to Turn In", level = 60, complete = true },
        { id = 102, title = "Still Going", level = 60 },
    }

    for _, flavor in ipairs(Loader.FLAVORS) do
        it("excludes completed quests from group abandons on " .. flavor, function()
            local E = bootWith(flavor, LOG)
            assert.are.equal(AUTOMATIC, E.private.exclusions.excludedQuests[101].source)
            assert.is_false(E:IsExcluded(102))
        end)
    end

    it("leaves completed quests alone when it's off", function()
        local E, Stub = Loader.Boot("classic", { questLog = LOG })
        E.db.general.individualQuests.completeProtection = false
        Stub.QuestLogChanged()
        assert.is_false(E:IsExcluded(101))
    end)

    it("prunes an automatic exclusion once the quest leaves the log", function()
        local E, Stub = bootWith("classic", LOG)
        assert.is_true(E:IsExcluded(101))
        Stub.SetQuestLog({ { id = 102, title = "Still Going", level = 60 } }) -- turned in
        Stub.Advance(6) -- pruning runs at most every five seconds
        Stub.QuestLogChanged()
        assert.is_false(E:IsExcluded(101))
    end)

    it("keeps a manual exclusion after the quest leaves the log", function()
        local E, Stub = Loader.Boot("classic", { questLog = { { id = 102, title = "Still Going", level = 60 } } })
        E:ExcludeQuest(102)
        Stub.SetQuestLog({})
        Stub.Advance(6)
        Stub.QuestLogChanged()
        assert.is_true(E:IsExcluded(102))
    end)
end)
