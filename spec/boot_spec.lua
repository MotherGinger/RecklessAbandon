local Loader = require("helpers.loader")

describe("booting", function()
    for _, flavor in ipairs(Loader.FLAVORS) do
        it("initializes on " .. flavor .. " without errors", function()
            local E, Stub = Loader.Boot(flavor)
            assert.is_true(E.initialized)
            assert.are.same({}, Stub.state.errors)
        end)

        it("registers /rab and /reckless on " .. flavor, function()
            local _, Stub = Loader.Boot(flavor)
            local _, rab = Stub.RunSlash("/rab debug")
            local _, reckless = Stub.RunSlash("/reckless debug")
            assert.are.equal("ACECONSOLE_RAB", rab)
            assert.are.equal("ACECONSOLE_RECKLESS", reckless)
        end)
    end

    describe("detects the client", function()
        local EXPECTED = {
            classic = { isClassic = true, isCamelot = false, isBC = false, isMop = false, isRetail = false, hasQuestLogAPI = false, hasQuestMapFrame = false },
            tbc = { isClassic = false, isCamelot = false, isBC = true, isMop = false, isRetail = false, hasQuestLogAPI = false, hasQuestMapFrame = false },
            mists = { isClassic = false, isCamelot = false, isBC = false, isMop = true, isRetail = false, hasQuestLogAPI = false, hasQuestMapFrame = false },
            -- Forever is a 1.x client: Classic rules on top of the modern quest log API and frames.
            forever = { isClassic = true, isCamelot = true, isBC = false, isMop = false, isRetail = false, hasQuestLogAPI = true, hasQuestMapFrame = true },
            retail = { isClassic = false, isCamelot = false, isBC = false, isMop = false, isRetail = true, hasQuestLogAPI = true, hasQuestMapFrame = true },
        }
        for _, flavor in ipairs(Loader.FLAVORS) do
            it("on " .. flavor, function()
                local E = Loader.Boot(flavor)
                local actual = {}
                for key in pairs(EXPECTED[flavor]) do actual[key] = E[key] end
                assert.are.same(EXPECTED[flavor], actual)
            end)
        end

        -- Forever's project ID has changed during the beta, so either signal alone is enough.
        local function forever(adjust)
            local E = Loader.Boot("forever", { before = adjust })
            local actual = {}
            for key in pairs(EXPECTED.forever) do actual[key] = E[key] end
            assert.are.same(EXPECTED.forever, actual)
        end

        it("on Forever builds that report the Retail project ID", function()
            -- Builds up to at least 69913 reported WOW_PROJECT_MAINLINE and had no WOW_PROJECT_CAMELOT.
            forever(function()
                _G.WOW_PROJECT_ID, _G.WOW_PROJECT_CAMELOT = 1, nil
            end)
        end)

        it("on Forever builds whose interface number leaves the 1.x range", function()
            forever(function()
                _G.GetBuildInfo = function() return "2.0.0", "80000", "Jan 1 2027", 20000 end
            end)
        end)

        it("on Forever builds without the WOW_PROJECT_CAMELOT constant", function()
            forever(function()
                _G.WOW_PROJECT_CAMELOT = nil
                _G.GetBuildInfo = function() return "2.0.0", "80000", "Jan 1 2027", 20000 end
            end)
        end)
    end)

    describe("welcome message", function()
        it("shows the version from the TOC", function()
            local _, Stub = Loader.Boot("classic")
            local version = Loader.TocFields(Loader.TOC_FOR.classic).Version
            assert.is_true(Stub.ChatContains("You are running v" .. version))
        end)

        it("stays quiet when the login message is off", function()
            local _, Stub = Loader.Boot("classic", {
                saved = {
                    RecklessAbandonDB = {
                        profileKeys = { ["Frauke - Area 52"] = "Default" },
                        profiles = { Default = { general = { loginMessage = false } } },
                    },
                },
            })
            assert.is_false(Stub.ChatContains("You are running"))
        end)

        it("asks testers of a pre-release for bug reports", function()
            local _, Stub = Loader.Boot("classic", {
                before = function(S) S.state.metadata.Version = "3.2.0-beta.1" end,
            })
            assert.is_true(Stub.ChatContains("pre-release version"))
        end)

        it("doesn't call a release a pre-release", function()
            local _, Stub = Loader.Boot("classic")
            assert.is_false(Stub.ChatContains("pre-release version"))
        end)
    end)

    describe("saved settings", function()
        it("restores the profile and the character's exclusions", function()
            local E = Loader.Boot("classic", {
                saved = {
                    RecklessAbandonDB = {
                        profileKeys = { ["Frauke - Area 52"] = "Default" },
                        profiles = { Default = { general = { confirmIndividual = true } } },
                    },
                    RecklessAbandonPrivateDB = {
                        profileKeys = { ["Frauke - Area 52"] = "Frauke - Area 52" },
                        profiles = { ["Frauke - Area 52"] = { exclusions = { excludedQuests = { [101] = { title = "Kept", source = 0 } } } } },
                    },
                },
            })
            assert.is_true(E.db.general.confirmIndividual)
            assert.is_true(E:IsExcluded(101))
        end)

        it("starts from the defaults on a new character", function()
            local E = Loader.Boot("classic")
            assert.is_false(E.db.general.confirmIndividual)
            assert.is_true(E.db.general.confirmGroup)
            assert.are.equal(LOG_LEVEL_INFO, E.db.general.logLevel)
            assert.is_true(E.private.exclusions.autoPrune)
        end)
    end)

    it("opens the settings from the addon compartment", function()
        local E = Loader.Boot("retail")
        RecklessAbandon_AddonCompartmentFunc()
        local opened = Loader.Calls("AceConfigDialog-3.0", "Open")
        assert.are.equal(1, #opened)
        assert.are.equal(E.name, opened[1].args[1])
    end)
end)
