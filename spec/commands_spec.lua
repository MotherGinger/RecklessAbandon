local Loader = require("helpers.loader")

local SWEEP = 10

local LOG = {
    { header = "Elwynn Forest" },
    { id = 101, title = "A Threat Within", level = 40 },
    { id = 102, title = "The Fargodeep Mine", level = 60 },
    { id = 103, title = "Hidden Helper", level = 60, hidden = true },
}

local function enable(E, ...)
    for _, command in ipairs({ ... }) do E.db.commands.generic[command] = true end
end

describe("slash commands", function()
    local E, Stub
    before_each(function()
        E, Stub = Loader.Boot("classic", { questLog = LOG })
        Stub.ClearChat()
    end)

    it("opens the settings with no arguments, and with 'config'", function()
        Stub.RunSlash("/rab")
        Stub.RunSlash("/reckless config")
        assert.are.equal(2, #Loader.Calls("AceConfigDialog-3.0", "Open"))
    end)

    it("doesn't open the settings in combat", function()
        Stub.state.inCombat = true
        Stub.RunSlash("/rab")
        assert.are.equal(0, #Loader.Calls("AceConfigDialog-3.0", "Open"))
        assert.is_true(Stub.ChatContains("You can't do that while in combat."))
    end)

    describe("dump", function()
        it("prints a global table", function()
            _G.RecklessDumpSample = { zone = "Elwynn" }
            Stub.RunSlash("/rab dump RecklessDumpSample")
            _G.RecklessDumpSample = nil
            assert.is_true(Stub.ChatContains("['zone'] = 'Elwynn'"))
        end)

        it("prints a global value", function()
            _G.RecklessDumpSample = 42
            Stub.RunSlash("/rab dump RecklessDumpSample")
            _G.RecklessDumpSample = nil
            assert.is_true(Stub.ChatContains("42"))
        end)

        it("echoes a name that isn't set", function()
            Stub.RunSlash("/rab dump NoSuchGlobal")
            assert.is_true(Stub.ChatContains("NoSuchGlobal"))
        end)
    end)

    it("toggles debugging", function()
        Stub.RunSlash("/rab debug")
        assert.is_true(E.db.debugging.debugLogging)
        assert.is_true(Stub.ChatContains("Debugging is now on."))
        Stub.RunSlash("/rab debug")
        assert.is_false(E.db.debugging.debugLogging)
    end)

    describe("list all", function()
        it("does nothing until it's enabled", function()
            Stub.RunSlash("/rab list all")
            assert.are.same({}, Stub.state.chat)
        end)

        it("lists headers and visible quests with their IDs", function()
            enable(E, "listAll")
            Stub.RunSlash("/rab list all")
            assert.is_true(Stub.ChatContains("Elwynn Forest"))
            assert.is_true(Stub.ChatContains("A Threat Within - 101"))
            assert.is_false(Stub.ChatContains("Hidden Helper"))
        end)
    end)

    describe("abandon all", function()
        it("says how to enable it", function()
            Stub.RunSlash("/rab abandon all")
            assert.is_true(Stub.ChatContains("Abandoning all quests from the command line is currently disabled"))
        end)

        it("asks first, then abandons every visible quest", function()
            enable(E, "abandonAll")
            Stub.RunSlash("/rab abandon all")
            assert.are.equal("RECKLESS_ABANDON_ALL_CONFIRMATION", Stub.state.popups[1].which)
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.abandoned)
            Stub.AcceptPopup()
            Stub.Advance(SWEEP)
            assert.are.same({ 101, 102 }, Stub.state.abandoned)
        end)

        it("abandons straight away when group confirmation is off", function()
            enable(E, "abandonAll")
            E.db.general.confirmGroup = false
            Stub.RunSlash("/rab abandon all")
            Stub.Advance(SWEEP)
            assert.are.same({ 101, 102 }, Stub.state.abandoned)
        end)
    end)

    describe("abandon by ID", function()
        it("says how to enable it", function()
            Stub.RunSlash("/rab abandon 101")
            assert.is_true(Stub.ChatContains("Abandoning quests from the command line is currently disabled"))
        end)

        it("abandons the quest", function()
            enable(E, "abandonByQuestId")
            Stub.RunSlash("/rab abandon 101")
            Stub.Advance(SWEEP)
            assert.are.same({ 101 }, Stub.state.abandoned)
        end)

        it("asks first when individual confirmation is on", function()
            enable(E, "abandonByQuestId")
            E.db.general.confirmIndividual = true
            Stub.RunSlash("/rab abandon 101")
            assert.is_truthy(Stub.state.popups[1].text:find("A Threat Within", 1, true))
            Stub.AcceptPopup()
            Stub.Advance(SWEEP)
            assert.are.same({ 101 }, Stub.state.abandoned)
        end)

        it("explains an ID that isn't in the quest log", function()
            enable(E, "abandonByQuestId")
            Stub.RunSlash("/rab abandon 999")
            assert.is_true(Stub.ChatContains("Unable to abandon quest, '999' is not recognized."))
        end)
    end)

    describe("abandon by qualifier", function()
        it("lists the matching quests and abandons them once confirmed", function()
            enable(E, "abandonByQualifier")
            Stub.RunSlash("/rab abandon gray")
            local popup = Stub.state.popups[1]
            assert.are.equal("RECKLESS_QUALIFIER_ABANDON_CONFIRMATION", popup.which)
            assert.is_truthy(popup.text:find("A Threat Within", 1, true))
            assert.is_nil(popup.text:find("Fargodeep", 1, true))
            Stub.AcceptPopup()
            Stub.Advance(SWEEP)
            assert.are.same({ 101 }, Stub.state.abandoned)
        end)

        it("says when nothing matches", function()
            enable(E, "abandonByQualifier")
            Stub.RunSlash("/rab abandon red")
            assert.is_true(Stub.ChatContains("There are no quests that match the qualifier 'red'."))
        end)

        it("says how to enable it", function()
            Stub.RunSlash("/rab abandon gray")
            assert.is_true(Stub.ChatContains("Abandoning quests from the command line is currently disabled"))
        end)
    end)

    describe("exclude and include", function()
        it("say how to enable them", function()
            Stub.RunSlash("/rab exclude 101")
            Stub.RunSlash("/rab include 101")
            assert.is_true(Stub.ChatContains("Excluding quests from the command line is currently disabled"))
            assert.is_true(Stub.ChatContains("Including quests from the command line is currently disabled"))
        end)

        it("toggle a quest's exclusion", function()
            enable(E, "excludeByQuestId", "includeByQuestId")
            Stub.RunSlash("/rab exclude 101")
            assert.is_true(E:IsExcluded(101))
            Stub.RunSlash("/rab exclude 101")
            assert.is_true(Stub.ChatContains("is already excluded from group abandons!"))
            Stub.RunSlash("/rab include 101")
            assert.is_false(E:IsExcluded(101))
            Stub.RunSlash("/rab include 101")
            assert.is_true(Stub.ChatContains("is already included in group abandons!"))
        end)

        it("explain an ID that isn't in the quest log", function()
            enable(E, "excludeByQuestId", "includeByQuestId")
            Stub.RunSlash("/rab exclude 999")
            Stub.RunSlash("/rab include 999")
            assert.is_true(Stub.ChatContains("Unable to exclude quest, '999' is not recognized."))
            assert.is_true(Stub.ChatContains("Unable to include quest, '999' is not recognized."))
        end)
    end)
end)
