local Loader = require("helpers.loader")

describe("quest colors", function()
    local E, Stub
    before_each(function()
        E, Stub = Loader.Boot("classic") -- a level 60 player, green range 8
    end)

    it("grades a quest by its level against the player's", function()
        assert.are.equal("red", E:GetQuestColor(65))
        assert.are.equal("orange", E:GetQuestColor(64))
        assert.are.equal("orange", E:GetQuestColor(63))
        assert.are.equal("yellow", E:GetQuestColor(62))
        assert.are.equal("yellow", E:GetQuestColor(58))
        assert.are.equal("green", E:GetQuestColor(57))
        assert.are.equal("green", E:GetQuestColor(52))
        assert.are.equal("gray", E:GetQuestColor(51))
    end)

    it("regrades quests when the player levels up", function()
        E.mylevel = 58
        assert.are.equal("orange", E:GetQuestColor(61))
        Stub.Fire("PLAYER_LEVEL_UP", 60)
        assert.are.equal(60, E.mylevel)
        assert.are.equal("yellow", E:GetQuestColor(61))
    end)
end)

describe("qualifiers", function()
    local COLORS = { "green", "yellow", "orange", "red", "gray" }
    local TAGS = { "failed", "dungeon", "raid", "group", "elite", "heroic", "pvp" }
    local EXPECTED = {
        classic = { daily = false, weekly = false, tags = true },
        tbc = { daily = true, weekly = false, tags = true },
        mists = { daily = true, weekly = false, tags = true },
        forever = { daily = false, weekly = false, tags = true },
        retail = { daily = true, weekly = true, tags = false },
    }

    for _, flavor in ipairs(Loader.FLAVORS) do
        it("offers the quest types " .. flavor .. " has", function()
            local E = Loader.Boot(flavor)
            local qualifiers, selections = E:GetAvailableQualifiers()
            local expected = EXPECTED[flavor]
            for _, color in ipairs(COLORS) do
                assert.is_truthy(qualifiers[color], color)
                assert.is_truthy(selections[color], color)
            end
            assert.are.equal(expected.daily, qualifiers.daily ~= nil, "daily")
            assert.are.equal(expected.daily, selections.daily ~= nil, "daily")
            assert.are.equal(expected.weekly, qualifiers.weekly ~= nil, "weekly")
            for _, tag in ipairs(TAGS) do
                assert.are.equal(expected.tags, qualifiers[tag] ~= nil, tag)
                assert.are.equal(expected.tags, selections[tag] ~= nil, tag)
            end
        end)
    end
end)
