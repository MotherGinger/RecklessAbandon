local Loader = require("helpers.loader")

local CHARACTER = "Frauke - Area 52"

local function profile(general)
    return {
        RecklessAbandonDB = {
            profileKeys = { [CHARACTER] = "Default" },
            profiles = { Default = { general = general } },
        },
    }
end

local function private(values)
    return {
        RecklessAbandonPrivateDB = {
            profileKeys = { [CHARACTER] = CHARACTER },
            profiles = { [CHARACTER] = values },
        },
    }
end

describe("settings", function()
    describe("messaging rate", function()
        it("moves the removed 'errors only' level to 'only show problems'", function()
            local E = Loader.Boot("classic", { saved = profile({ logLevel = 1 }) }) -- the old "errors only"
            assert.are.equal(LOG_LEVEL_WARN, E.db.general.logLevel)
        end)

        it("caps an out of range level at 'show all messages'", function()
            local E = Loader.Boot("classic", { saved = profile({ logLevel = 5 }) })
            assert.are.equal(LOG_LEVEL_VERBOSE, E.db.general.logLevel)
        end)

        it("keeps a level that is still offered", function()
            local E = Loader.Boot("classic", { saved = profile({ logLevel = 4 }) })
            assert.are.equal(LOG_LEVEL_VERBOSE, E.db.general.logLevel)
        end)

        it("offers exactly the remaining levels", function()
            local E = Loader.Boot("classic")
            local levels = {}
            for level in pairs(E.logLevels) do levels[#levels + 1] = level end
            table.sort(levels)
            assert.are.same({ LOG_LEVEL_WARN, LOG_LEVEL_INFO, LOG_LEVEL_VERBOSE }, levels)
        end)

        it("hides detail messages at the default level, and shows them at 'show all'", function()
            local E, Stub = Loader.Boot("classic", { questLog = { { id = 101, title = "Q" } } })
            Stub.ClearChat()
            E:ExcludeQuest(101)
            assert.is_false(Stub.ChatContains("Excluding quest"))
            E.db.general.logLevel = LOG_LEVEL_VERBOSE
            E:IncludeQuest(101)
            assert.is_true(Stub.ChatContains("Including quest"))
        end)

        it("always shows system messages", function()
            local E, Stub = Loader.Boot("classic")
            E.db.general.logLevel = LOG_LEVEL_WARN
            Stub.ClearChat()
            E:System("hello")
            assert.is_true(Stub.ChatContains("hello"))
        end)
    end)

    it("puts back a missing messaging rate and debugging settings", function()
        local E = Loader.Boot("classic")
        E.db.general.logLevel = nil
        E.db.debugging = nil
        E:NormalizeSettings()
        assert.are.equal(LOG_LEVEL_INFO, E.db.general.logLevel)
        assert.are.same({ debugLogging = false }, E.db.debugging)
    end)

    it("restores account-wide settings", function()
        local E = Loader.Boot("classic", { saved = { RecklessAbandonDB = { global = { seen = true } } } })
        assert.is_true(E.global.seen)
    end)

    it("upgrades exclusions saved as a bare title", function()
        local E = Loader.Boot("classic", { saved = private({ exclusions = { excludedQuests = { [101] = "Old Title" } } }) })
        assert.are.same({ title = "Old Title", source = MANUAL }, E.private.exclusions.excludedQuests[101])
    end)

    it("puts back character settings the client dropped while playing", function()
        local E, Stub = Loader.Boot("classic", { questLog = { { id = 101, title = "Q" } } })
        E.private.exclusions = nil
        Stub.QuestLogChanged()
        assert.is_table(E.private.exclusions.excludedQuests)
        assert.is_true(E.private.exclusions.autoPrune)
    end)

    it("normalizes a profile when it is switched to", function()
        local E = Loader.Boot("classic", {
            saved = {
                RecklessAbandonDB = {
                    profileKeys = { [CHARACTER] = "Default" },
                    profiles = { Old = { general = { logLevel = 1 } } },
                },
            },
        })
        E.data:SetProfile("Old")
        assert.are.equal(LOG_LEVEL_WARN, E.db.general.logLevel)
    end)

    describe("automation and command settings", function()
        local function only(t)
            local copy = {}
            for key, value in pairs(t) do copy[key] = value end
            return copy
        end

        local function automation(E) return E.private.automationOptions.autoAbandonQuests end

        it("keep their shape on a new character", function()
            -- AceDB's "*" defaults look empty, and an earlier version took that for the pre-v1.6.0
            -- format and nested the settings one level too deep on every new character.
            local E = Loader.Boot("classic")
            assert.are.same({}, only(automation(E).questType))
            assert.are.equal("", automation(E).ids)
            assert.are.same({}, only(E.db.commands.generic))
        end)

        it("keep their shape when normalized again", function()
            local E = Loader.Boot("classic")
            automation(E).questType.gray = true
            automation(E).ids = "101"
            E.db.commands.generic.listAll = true
            E:NormalizeSettings()
            assert.are.same({ gray = true }, only(automation(E).questType))
            assert.are.equal("101", automation(E).ids)
            assert.are.same({ listAll = true }, only(E.db.commands.generic))
        end)

        it("get back a quest ID list an earlier version moved into the quest types", function()
            local E, Stub = Loader.Boot("classic", {
                questLog = { { id = 101, title = "By ID" }, { id = 102, title = "Kept" } },
                saved = private({ automationOptions = { autoAbandonQuests = { questType = { ids = "101", gray = true } } } }),
            })
            assert.are.equal("101", automation(E).ids)
            assert.are.same({ gray = true }, only(automation(E).questType))
            E:UpdateParsedExclusions()
            Stub.QuestLogChanged()
            Stub.Advance(10)
            assert.are.same({ 101 }, Stub.state.abandoned)
        end)

        it("keep a quest ID list typed since then over the stranded one", function()
            local E = Loader.Boot("classic", {
                saved = private({ automationOptions = { autoAbandonQuests = { questType = { ids = "" }, ids = "202" } } }),
            })
            assert.are.equal("202", automation(E).ids)
            assert.are.same({}, only(automation(E).questType))
        end)

        it("move quest types from the v1.6.0 betas", function()
            local E = Loader.Boot("classic", { saved = private({ general = { autoAbandonQuests = { gray = true, daily = true } } }) })
            assert.are.same({ gray = true, daily = true }, only(automation(E).questType))
            assert.is_nil(E.private.general.autoAbandonQuests)
        end)

        it("move command switches saved before v1.6.0", function()
            local E, Stub = Loader.Boot("classic", {
                questLog = { { id = 101, title = "Listed" } },
                saved = {
                    RecklessAbandonDB = {
                        profileKeys = { [CHARACTER] = "Default" },
                        profiles = { Default = { commands = { listAll = true, abandonAll = false } } },
                    },
                },
            })
            assert.are.same({ listAll = true, abandonAll = false }, only(E.db.commands.generic))
            assert.is_nil(rawget(E.db.commands, "listAll"))
            Stub.ClearChat()
            Stub.RunSlash("/rab list all")
            assert.is_true(Stub.ChatContains("Listed - 101"))
        end)

        it("get back command switches an earlier version nested", function()
            local E = Loader.Boot("classic", {
                saved = {
                    RecklessAbandonDB = {
                        profileKeys = { [CHARACTER] = "Default" },
                        profiles = { Default = { commands = { generic = { listAll = true, generic = { listAll = false, abandonAll = true } } } } },
                    },
                },
            })
            -- The outer switch is the one the player set last.
            assert.are.same({ listAll = true, abandonAll = true }, only(E.db.commands.generic))
        end)
    end)

    describe("exclusion list", function()
        local E
        before_each(function()
            E = Loader.Boot("classic", {
                questLog = { { id = 101, title = "Still Here" } },
                saved = private({
                    exclusions = {
                        excludedQuests = {
                            [101] = { title = "Still Here", source = MANUAL },
                            [102] = { title = "Turned In", source = MANUAL },
                            [103] = { title = "Auto Gone", source = AUTOMATIC },
                        },
                    },
                }),
            })
        end)

        it("shows every exclusion with its source and whether it left the log", function()
            local rows = E:StringToTable(E.Options.args.general.args.exclusions.args.excludedQuests.name())
            table.remove(rows, 1) -- the header row
            table.sort(rows, function(a, b) return a[1] < b[1] end)
            assert.are.same({
                { 101, "Manual", "Still Here", false },
                { 102, "Manual", "Turned In", true },
                { 103, "Automation", "Auto Gone", true },
            }, rows)
        end)

        it("prunes the quests that left the log", function()
            E:PruneQuestExclusions()
            assert.is_true(E:IsExcluded(101))
            assert.is_false(E:IsExcluded(102))
            assert.is_false(E:IsExcluded(103))
        end)

        it("clears the whole list", function()
            E:ClearQuestExclusions()
            assert.is_true(E:IsEmpty(E.private.exclusions.excludedQuests))
        end)
    end)
end)
