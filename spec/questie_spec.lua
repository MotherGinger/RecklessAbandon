local Loader = require("helpers.loader")

local SWEEP = 10

-- The clients Questie supports. It has no Retail version.
local CLASSIC_FLAVORS = { "classic", "tbc", "mists", "forever" }

-- What QuestieDB knows about the quests below.
local QUESTS = {
    [201] = { startedBy = { nil, nil, { 9001 } } },          -- started from an item only
    [202] = { startedBy = { { 300 }, nil, { 9002 } } },      -- an item, or an NPC
    [203] = { startedBy = { { 300 } } },                     -- an NPC
    [204] = { breadcrumbForQuestId = 500 },                  -- breadcrumb to a quest already done
    [205] = { breadcrumbForQuestId = 501 },                  -- breadcrumb to a quest not done yet
    [206] = { exclusiveTo = { 206, 502 } },                  -- an alternative (502) is done
    [207] = { exclusiveTo = { 207, 503 } },                  -- no alternative done
    [208] = { breadcrumbForQuestId = 0 },                    -- no target
}

local LOG = {
    { header = "Zone" },
    { id = 201, title = "Item Quest", level = 60 },
    { id = 202, title = "Item or NPC Quest", level = 60 },
    { id = 203, title = "NPC Quest", level = 60 },
    { id = 204, title = "Done Breadcrumb", level = 60 },
    { id = 205, title = "Open Breadcrumb", level = 60 },
    { id = 206, title = "Lost Alternative", level = 60 },
    { id = 207, title = "Open Alternative", level = 60 },
    { id = 208, title = "Untargeted Breadcrumb", level = 60 },
    { id = 209, title = "Unknown to QuestieDB", level = 60 },
}

local function contains(list, value)
    for _, item in ipairs(list) do
        if item == value then return true end
    end
    return false
end

--- Boots with QuestieDB installed (unless opts.questieDB is false) and quests 500 and 502 turned in.
local function boot(flavor, opts)
    opts = opts or {}
    local E, Stub = Loader.Boot(flavor, {
        questLog = opts.questLog or LOG,
        before = function(S)
            S.state.completed[500] = true
            S.state.completed[502] = true
            if opts.questieDB ~= false then S.InstallQuestieDB(opts.quests or QUESTS, opts.questieOptions) end
        end,
    })
    Stub.QuestLogChanged()
    Stub.ClearChat()
    return E, Stub
end

local function integrations(E) return E.Options.args.general.args.integrations end

describe("Questie integration", function()
    describe("without QuestieDB", function()
        it("is unavailable and does nothing", function()
            local E = boot("classic", { questieDB = false })
            assert.is_false(E.Questie:IsAvailable())
            assert.is_false(E.Questie:IsEnabled())
            assert.is_false(E:IsExcluded(201))
            local qualifiers, selections = E:GetAvailableQualifiers()
            assert.is_nil(qualifiers["obsolete"])
            assert.is_nil(selections.obsolete)
        end)

        it("says so in the settings and greys the options out", function()
            local E = boot("classic", { questieDB = false })
            local args = integrations(E).args
            assert.is_truthy(args.questieDescription.name():find("QuestieDB isn't loaded", 1, true))
            assert.is_true(args.questieEnabled.disabled())
            assert.is_true(args.itemProtection.disabled())
        end)

        it("treats a QuestieDB without the API version it needs as missing", function()
            local E = boot("classic", { questieOptions = { contract = 3 } })
            assert.is_false(E.Questie:IsAvailable())
        end)

        it("treats something else named LibQuestieDB as missing", function()
            local E = Loader.Boot("classic", { before = function() _G.LibQuestieDB = { RequireContract = function() return true end } end })
            assert.is_false(E.Questie:IsAvailable())
        end)

        it("treats a QuestieDB whose version check fails as missing", function()
            local E = Loader.Boot("classic", {
                before = function(S)
                    S.InstallQuestieDB(QUESTS)
                    _G.LibQuestieDB.RequireContract = function() error("broken") end
                end,
            })
            assert.is_false(E.Questie:IsAvailable())
        end)
    end)

    describe("with QuestieDB", function()
        it("is on by default", function()
            local E = boot("classic")
            assert.is_true(E.Questie:IsEnabled())
            local args = integrations(E).args
            assert.is_false(args.questieEnabled.disabled())
            assert.is_false(args.itemProtection.disabled())
            assert.is_nil(args.questieDescription.name():find("isn't loaded", 1, true))
        end)

        it("ignores a QuestieDB read that fails", function()
            local E = boot("classic", { questieOptions = { broken = true } })
            assert.is_nil(E.Questie:Get(201, "startedBy"))
            assert.is_false(E:IsExcluded(201))
            assert.is_false(E.Questie:IsObsolete(204))
        end)

        it("shows its settings on the Classic clients only", function()
            assert.is_false(integrations((boot("classic"))).hidden())
            assert.is_true(integrations(Loader.Boot("retail")).hidden())
        end)
    end)

    describe("Item Quest Protection", function()
        for _, flavor in ipairs(CLASSIC_FLAVORS) do
            it("excludes quests only an item starts from group abandons on " .. flavor, function()
                local E = boot(flavor)
                assert.are.equal(QUESTIE_PROTECTION, E.private.exclusions.excludedQuests[201].source)
                assert.is_false(E:IsExcluded(202))
                assert.is_false(E:IsExcluded(203))
                assert.is_false(E:IsExcluded(209))
            end)
        end

        it("keeps them out of a zone abandon", function()
            local E, Stub = boot("classic")
            E:AbandonZoneQuests("zone")
            Stub.Advance(SWEEP)
            assert.is_false(contains(Stub.state.abandoned, 201))
            assert.is_true(contains(Stub.state.abandoned, 203))
        end)

        it("still lets a single abandon through", function()
            local E, Stub = boot("classic")
            E:AbandonQuest(201, true)
            Stub.Advance(SWEEP)
            assert.are.same({ 201 }, Stub.state.abandoned)
        end)

        it("lists them with Questie as the source", function()
            local E = boot("classic")
            local rows = E:StringToTable(E.Options.args.general.args.exclusions.args.excludedQuests.name())
            assert.are.same({ 201, "Questie", "Item Quest", false }, rows[2])
        end)

        it("leaves an exclusion of another kind alone", function()
            local E, Stub = boot("classic")
            E:IncludeQuest(201)
            E:ExcludeQuest(201, MANUAL)
            E.Questie:SetItemProtection(false)
            Stub.QuestLogChanged()
            assert.are.equal(MANUAL, E.private.exclusions.excludedQuests[201].source)
        end)

        it("includes them again when it's turned off", function()
            local E = boot("classic")
            integrations(E).args.itemProtection.set(nil, false)
            assert.is_false(E.db.questie.itemProtection)
            assert.is_false(E:IsExcluded(201))
            integrations(E).args.itemProtection.set(nil, true)
            assert.is_true(E:IsExcluded(201))
        end)

        it("includes them again when the integration is turned off", function()
            local E = boot("classic")
            integrations(E).args.questieEnabled.set(nil, false)
            assert.is_false(E.Questie:IsEnabled())
            assert.is_false(E:IsExcluded(201))
            assert.is_true(integrations(E).args.itemProtection.disabled())
        end)

        it("prunes the exclusion once the quest leaves the log", function()
            local E, Stub = boot("classic")
            assert.is_true(E:IsExcluded(201))
            Stub.SetQuestLog({ { id = 203, title = "NPC Quest", level = 60 } })
            Stub.Advance(6) -- pruning runs at most every five seconds
            Stub.QuestLogChanged()
            assert.is_false(E:IsExcluded(201))
        end)

        it("leaves a completed quest to Complete Protection", function()
            local E = boot("classic", { questLog = { { id = 201, title = "Item Quest", level = 60, complete = true } } })
            assert.are.equal(AUTOMATIC, E.private.exclusions.excludedQuests[201].source)
        end)
    end)

    describe("obsolete quests", function()
        it("are breadcrumbs to quests already done, and quests whose alternative is done", function()
            local E = boot("classic")
            local obsolete = {}
            for id = 201, 209 do
                if E.Questie:IsObsolete(id) then obsolete[#obsolete + 1] = id end
            end
            assert.are.same({ 204, 206 }, obsolete)
        end)

        for _, flavor in ipairs(CLASSIC_FLAVORS) do
            it("are abandoned by automation when chosen on " .. flavor, function()
                local E, Stub = boot(flavor)
                E.private.automationOptions.autoAbandonQuests.questType.obsolete = true
                Stub.QuestLogChanged()
                Stub.Advance(SWEEP)
                table.sort(Stub.state.abandoned)
                assert.are.same({ 204, 206 }, Stub.state.abandoned)
            end)
        end

        it("are a quest type in the automation settings while the integration is on", function()
            local E = boot("classic")
            local questType = E.Options.args.general.args.automationOptions.args.autoAbandonQuests.args.questType
            assert.are.equal("Obsolete", questType.values().obsolete)
            E.Questie:SetEnabled(false)
            assert.is_nil(questType.values().obsolete)
        end)

        it("are left alone while the integration is off, even when chosen", function()
            local E, Stub = boot("classic")
            E.private.automationOptions.autoAbandonQuests.questType.obsolete = true
            E.Questie:SetEnabled(false)
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.abandoned)
        end)

        it("are listed by the qualifier command's help", function()
            local E = boot("classic")
            local desc = E.Options.args.general.args.commands.args.generic.args.abandonByQualifier.desc()
            assert.is_truthy(desc:find("obsolete", 1, true))
        end)

        it("can be abandoned with /reckless abandon obsolete", function()
            local E, Stub = boot("classic")
            E.db.commands.generic.abandonByQualifier = true
            Stub.RunSlash("/reckless abandon obsolete")
            local popup = Stub.state.popups[1]
            assert.is_truthy(popup.text:find("Done Breadcrumb", 1, true))
            assert.is_truthy(popup.text:find("Lost Alternative", 1, true))
            assert.is_nil(popup.text:find("Open Breadcrumb", 1, true))
            Stub.AcceptPopup()
            Stub.Advance(SWEEP)
            table.sort(Stub.state.abandoned)
            assert.are.same({ 204, 206 }, Stub.state.abandoned)
        end)

        it("don't include an item quest Item Quest Protection excluded", function()
            local quests = { [201] = { startedBy = { nil, nil, { 9001 } }, breadcrumbForQuestId = 500 } }
            local E, Stub = boot("classic", { quests = quests })
            E.private.automationOptions.autoAbandonQuests.questType.obsolete = true
            Stub.QuestLogChanged()
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.abandoned)
        end)

        it("isn't a command while the integration is off", function()
            local E, Stub = boot("classic", { questieDB = false })
            E.db.commands.generic.abandonByQualifier = true
            Stub.RunSlash("/reckless abandon obsolete")
            assert.are.same({}, Stub.state.popups)
        end)
    end)
end)

describe("turned-in quests", function()
    it("count as not turned in on a client that can't say", function()
        local E = Loader.Boot("classic", { before = function(S) S.state.completed[500] = true end })
        assert.is_true(E.Shim:IsQuestFlaggedCompleted(500))
        _G.IsQuestFlaggedCompleted = nil
        assert.is_false(E.Shim:IsQuestFlaggedCompleted(500))
    end)

    it("are read from C_QuestLog on the newer clients", function()
        local E = Loader.Boot("forever", { before = function(S) S.state.completed[500] = true end })
        assert.is_true(E.Shim:IsQuestFlaggedCompleted(500))
        assert.is_false(E.Shim:IsQuestFlaggedCompleted(501))
    end)
end)
