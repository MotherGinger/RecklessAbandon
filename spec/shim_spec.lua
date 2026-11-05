local Loader = require("helpers.loader")

local LOG = {
    { header = "Elwynn Forest" },
    { id = 101, title = "A Threat Within", level = 58 },
    { id = 102, title = "The Fargodeep Mine", level = 60, frequency = "daily" },
    { id = 103, title = "Hidden Helper", level = 60, hidden = true },
    { id = 104, title = "Lost in Battle", level = 60, failed = true },
    { id = 105, title = "Done Deal", level = 60, complete = true },
}

describe("Shim", function()
    for _, flavor in ipairs(Loader.FLAVORS) do
        describe("on " .. flavor, function()
            local E
            before_each(function()
                E = Loader.Boot(flavor, { questLog = LOG })
            end)

            it("counts headers and quests", function()
                assert.are.equal(6, E.Shim:GetNumQuestLogEntries())
            end)

            it("describes a header", function()
                local info = E.Shim:GetInfo(1)
                assert.is_true(info.isHeader)
                assert.are.equal("Elwynn Forest", info.title)
            end)

            it("describes a quest", function()
                local info = E.Shim:GetInfo(2)
                assert.is_false(info.isHeader)
                assert.are.equal("A Threat Within", info.title)
                assert.are.equal(101, info.questID)
                assert.are.equal(58, info.level)
                assert.are.equal(0, info.frequency)
                assert.is_false(info.isHidden == true)
            end)

            it("reports a daily quest with frequency 1", function()
                assert.are.equal(1, E.Shim:GetInfo(3).frequency)
            end)

            it("reports a hidden quest", function()
                assert.is_true(E.Shim:GetInfo(4).isHidden)
            end)

            it("finds a quest's log index, and nil for a quest not in the log", function()
                assert.are.equal(2, E.Shim:GetLogIndexForQuestID(101))
                assert.is_nil(E.Shim:GetLogIndexForQuestID(999))
            end)

            it("tells a complete quest from one in progress", function()
                assert.is_true(E.Shim:IsComplete(105))
                assert.is_false(E.Shim:IsComplete(101))
            end)

            it("links a quest in the log, and nothing for one that isn't", function()
                assert.is_truthy(E.Shim:GetQuestLink(101):find("|Hquest:101:%d+|h%[A Threat Within%]|h"))
                assert.is_nil(E.Shim:GetQuestLink(999))
            end)

            -- Mists has GetQuestLink everywhere, so the Shim has no fallback there.
            if flavor ~= "mists" then
                it("builds the link itself, at the player's level, when the client gives none", function()
                    E = Loader.Boot(flavor, { questLog = LOG, before = function(Stub) Stub.state.noQuestLinks = true end })
                    assert.are.equal("|cffffff00|Hquest:101:60|h[A Threat Within]|h|r", E.Shim:GetQuestLink(101))
                end)
            end

            it("reads the green quest range", function()
                assert.are.equal(8, E.Shim:UnitQuestTrivialLevelRange("player"))
            end)

            if flavor ~= "retail" then
                it("marks a failed quest with isComplete -1", function()
                    assert.are.equal(-1, E.Shim:GetInfo(5).isComplete)
                end)
            end
        end)
    end

    describe("quest tags on clients with C_QuestLog", function()
        local function tagFor(flavor, entry)
            entry.id, entry.title = 201, "Tagged"
            local E = Loader.Boot(flavor, { questLog = { entry } })
            return E.Shim:GetInfo(1).questTag
        end

        it("labels tag IDs with the same strings the Classic quest log uses (Forever)", function()
            assert.are.equal("Dungeon", tagFor("forever", { tagID = 81, tag = "Dungeon Quest" }))
            assert.are.equal("Raid", tagFor("forever", { tagID = 62 }))
            assert.are.equal("Group", tagFor("forever", { tagID = 1 }))
            assert.are.equal("PvP", tagFor("forever", { tagID = 41 }))
            assert.are.equal("Heroic", tagFor("forever", { tagID = 85 }))
        end)

        it("falls back to the tag name, then to Elite", function()
            assert.are.equal("Legendary", tagFor("forever", { tagID = 83, tag = "Legendary" }))
            assert.are.equal("Elite", tagFor("forever", { elite = true }))
            assert.is_nil(tagFor("forever", {}))
        end)

        it("leaves Retail quests untagged", function()
            assert.is_nil(tagFor("retail", { tagID = 81 }))
        end)
    end)

    it("passes the Classic quest tag straight through", function()
        local E = Loader.Boot("classic", { questLog = { { id = 201, title = "Tagged", tag = "Elite" } } })
        assert.are.equal("Elite", E.Shim:GetInfo(1).questTag)
    end)
end)
