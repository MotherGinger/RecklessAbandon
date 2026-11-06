local Loader = require("helpers.loader")

local function log()
    return {
        { header = "Elwynn Forest" },
        { id = 101, title = "A Threat Within", level = 58 },
        { id = 102, title = "The Fargodeep Mine", level = 60 },
        { id = 103, title = "Hidden Helper", level = 60, hidden = true },
        { header = "Westfall" },
        { id = 201, title = "The Defias Brotherhood", level = 60 },
        { id = 202, title = "Escorted", level = 60, canAbandon = false },
    }
end

local function contains(list, value)
    for _, item in ipairs(list) do
        if item == value then return true end
    end
    return false
end

-- The longest a sweep takes: four rounds with their gaps and settle time.
local SWEEP = 10

for _, flavor in ipairs(Loader.FLAVORS) do
    describe("abandoning on " .. flavor, function()
        local E, Stub
        before_each(function()
            E, Stub = Loader.Boot(flavor, { questLog = log() })
            Stub.ClearChat()
        end)

        it("abandons a quest and says so", function()
            assert.is_true(E:AbandonQuest(101))
            Stub.Advance(SWEEP)
            assert.are.same({ 101 }, Stub.state.abandoned)
            assert.is_true(Stub.ChatContains("Abandoned quest [A Threat Within]"))
        end)

        it("spaces a group of abandons out instead of sending them in one frame", function()
            E:AbandonQuests({ 101, 102, 201 })
            Stub.Advance(0.02)
            assert.are.equal(1, #Stub.state.abandoned)
            Stub.Advance(SWEEP)
            assert.are.same({ 101, 102, 201 }, Stub.state.abandoned)
        end)

        it("retries abandons the server dropped", function()
            Stub.state.dropAbandons = 2
            E:AbandonQuests({ 101, 102, 201 })
            Stub.Advance(SWEEP)
            assert.are.equal(3, #Stub.state.abandoned)
            assert.are.equal(2, #Stub.state.dropped)
            assert.is_false(Stub.ChatContains("Failed to abandon"))
            assert.is_true(E:IsEmpty(E.pendingAbandons))
        end)

        it("gives up after four rounds and remembers the quest", function()
            Stub.state.dropAbandons = 100
            E:AbandonQuest(101)
            Stub.Advance(SWEEP)
            assert.are.equal(4, #Stub.state.dropped)
            assert.is_true(Stub.ChatContains("Failed to abandon [A Threat Within]"))
            assert.is_true(E.failedAbandons[101])
            assert.is_nil(E.pendingAbandons[101])
        end)

        it("doesn't queue a quest that is already being abandoned", function()
            assert.are.equal(1, E:AbandonQuests({ 101 }))
            assert.are.equal(0, E:AbandonQuests({ 101 }))
            Stub.Advance(SWEEP)
            assert.are.same({ 101 }, Stub.state.abandoned)
        end)

        it("leaves a quest alone if it left the log before its turn came", function()
            E:AbandonQuests({ 101, 102 })
            table.remove(Stub.state.questLog, 3) -- 102 turned in meanwhile
            Stub.Advance(SWEEP)
            assert.are.same({ 101 }, Stub.state.abandoned)
        end)

        it("warns about a quest that can't be abandoned", function()
            assert.is_false(E:AbandonQuest(202))
            assert.is_true(Stub.ChatContains("You can't abandon [Escorted]"))
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.abandoned)
        end)

        describe("exclusions", function()
            before_each(function()
                E:ExcludeQuest(101)
            end)

            it("skips excluded quests in group abandons", function()
                E:AbandonQuests({ 101, 102 })
                Stub.Advance(SWEEP)
                assert.are.same({ 102 }, Stub.state.abandoned)
            end)

            it("still abandons an excluded quest on its own, and prunes it from the list", function()
                assert.is_true(E:AbandonQuest(101, true))
                Stub.Advance(SWEEP)
                assert.are.same({ 101 }, Stub.state.abandoned)
                assert.is_false(E:IsExcluded(101))
            end)

            it("keeps the exclusion when automatic pruning is off", function()
                E.private.exclusions.autoPrune = false
                E:AbandonQuest(101, true)
                Stub.Advance(SWEEP)
                assert.is_true(E:IsExcluded(101))
            end)

            it("records the quest title and a manual source", function()
                assert.are.same({ title = "A Threat Within", source = MANUAL }, E.private.exclusions.excludedQuests[101])
            end)

            it("includes the quest again", function()
                E:IncludeQuest(101)
                assert.is_false(E:IsExcluded(101))
            end)
        end)

        it("abandons every visible quest in the log", function()
            E:AbandonAllQuests()
            Stub.Advance(SWEEP)
            assert.is_true(contains(Stub.state.abandoned, 101))
            assert.is_true(contains(Stub.state.abandoned, 102))
            assert.is_true(contains(Stub.state.abandoned, 201))
            assert.is_false(contains(Stub.state.abandoned, 103))
            assert.is_false(contains(Stub.state.abandoned, 202))
        end)

        it("abandons the quests under one zone header", function()
            E:GenerateQuestTable()
            local key
            for name, group in pairs(E.questGroupsByName) do
                if group.title == "Westfall" then key = name end
            end
            E:AbandonZoneQuests(key)
            Stub.Advance(SWEEP)
            assert.are.same({ 201 }, Stub.state.abandoned)
        end)
    end)
end

describe("zone headers", function()
    -- Header keys used to strip everything outside a-z, so every Russian or Chinese header got the
    -- same empty key and one header's group abandon took another header's quests.
    it("keep apart headers written outside the Latin alphabet", function()
        local E, Stub = Loader.Boot("classic", {
            questLog = {
                { header = "Элвиннский лес" },
                { id = 101, title = "Угроза изнутри" },
                { header = "Западный Край" },
                { id = 201, title = "Братство Справедливости" },
            },
        })
        Stub.OpenQuestLog()
        local keys = {}
        for key, group in pairs(E.questGroupsByName) do keys[group.title] = key end
        assert.is_truthy(keys["Элвиннский лес"])
        assert.is_truthy(keys["Западный Край"])
        assert.are_not.equal(keys["Элвиннский лес"], keys["Западный Край"])
        -- The first header's button must take only its own quest.
        Stub.Click(E.buttonStateCache.activeGroupButtons[keys["Элвиннский лес"]], "LeftButton")
        Stub.AcceptPopup()
        Stub.Advance(SWEEP)
        assert.are.same({ 101 }, Stub.state.abandoned)
    end)

    it("match the header text whatever its color, spacing or punctuation", function()
        local E = Loader.Boot("classic", { questLog = { { header = "Stormwind City" }, { id = 101, title = "Q" } } })
        E:GenerateQuestTable()
        assert.is_truthy(E.questGroupsByName["stormwindcity"])
    end)

    it("keep the last known quests of a collapsed header on Classic", function()
        local E, Stub = Loader.Boot("classic", { questLog = { { header = "Duskwood" }, { id = 301, title = "Q" } } })
        E:GenerateQuestTable()
        Stub.SetQuestLog({ { header = "Duskwood", collapsed = true } })
        E:GenerateQuestTable()
        assert.is_truthy(E.questGroupsByName.duskwood.quests[301])
    end)
end)

for _, flavor in ipairs(Loader.FLAVORS) do
    describe("abandoning a zone on " .. flavor, function()
        local E, Stub
        before_each(function()
            E, Stub = Loader.Boot(flavor, { questLog = log() })
            Stub.OpenQuestLog()
        end)

        it("does nothing when its popup is accepted after the zone left the log", function()
            Stub.Click(E.buttonStateCache.activeGroupButtons.westfall, "LeftButton")
            Stub.SetQuestLog({ { header = "Elwynn Forest" }, { id = 101, title = "A Threat Within" } })
            Stub.QuestLogChanged()
            Stub.AcceptPopup()
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.abandoned)
        end)

        it("does nothing when a quest's popup is accepted after it was turned in", function()
            E.db.general.confirmIndividual = true
            Stub.Click(E.buttonStateCache.activeQuestButtons[101], "LeftButton")
            Stub.SetQuestLog({ { header = "Westfall" }, { id = 201, title = "The Defias Brotherhood" } })
            Stub.QuestLogChanged()
            Stub.AcceptPopup()
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.abandoned)
        end)

        it("does nothing for a zone header it never saw expanded", function()
            Stub.SetQuestLog({ { header = "Duskwood", collapsed = true } })
            Stub.OpenQuestLog()
            Stub.Click(Stub.QuestLogRow("Duskwood"), "LeftButton", { alt = true })
            Stub.AcceptPopup()
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.abandoned)
        end)

        it("abandons straight away when group confirmation is off", function()
            E.db.general.confirmGroup = false
            Stub.Click(E.buttonStateCache.activeGroupButtons.westfall, "LeftButton")
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.popups)
            assert.are.same({ 201 }, Stub.state.abandoned)
        end)

        it("forgets a zone header with no quests under it once asked to abandon it", function()
            Stub.SetQuestLog({ { header = "Darkmoon Faire" }, { header = "Westfall" }, { id = 201, title = "Q" } })
            E:GenerateQuestTable()
            assert.is_truthy(E.questGroupsByName.darkmoonfaire)
            E:AbandonZoneQuests("darkmoonfaire")
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.abandoned)
            assert.is_nil(E.questGroupsByName.darkmoonfaire)
        end)
    end)
end
