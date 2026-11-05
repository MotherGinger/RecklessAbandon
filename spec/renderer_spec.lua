local Loader = require("helpers.loader")

local SWEEP = 10

local LOG = {
    { header = "Elwynn Forest" },
    { id = 101, title = "A Threat Within", level = 58 },
    { id = 102, title = "Escorted", level = 60, canAbandon = false },
    { header = "Westfall" },
    { id = 201, title = "The Defias Brotherhood", level = 60 },
}

local function count(pool)
    local total = 0
    for _ in pool:EnumerateActive() do total = total + 1 end
    return total
end

local function questButton(E, questId) return E.buttonStateCache.activeQuestButtons[questId] end
local function groupButton(E, key) return E.buttonStateCache.activeGroupButtons[key] end

for _, flavor in ipairs(Loader.FLAVORS) do
    describe("quest log buttons on " .. flavor, function()
        local E, Stub
        before_each(function()
            E, Stub = Loader.Boot(flavor, { questLog = LOG })
            Stub.OpenQuestLog()
        end)

        it("puts an abandon button on every quest and every zone header", function()
            assert.are.equal(3, count(E.questButtonPool))
            assert.are.equal(2, count(E.groupButtonPool))
            assert.is_truthy(questButton(E, 101))
            assert.is_truthy(groupButton(E, "elwynnforest"))
            assert.is_truthy(groupButton(E, "westfall"))
        end)

        it("takes the buttons away when the quest log closes", function()
            Stub.CloseQuestLog()
            assert.are.equal(0, count(E.questButtonPool))
            assert.are.equal(0, count(E.groupButtonPool))
        end)

        it("shows only the buttons the settings ask for", function()
            Stub.CloseQuestLog()
            E.db.general.individualQuests.showAbandonButton = false
            Stub.OpenQuestLog()
            assert.are.equal(0, count(E.questButtonPool))
            assert.are.equal(2, count(E.groupButtonPool))
            Stub.CloseQuestLog()
            E.db.general.zoneQuests.showAbandonButton = false
            Stub.OpenQuestLog()
            assert.are.equal(0, count(E.groupButtonPool))
        end)

        it("greys out the button of a quest that can't be abandoned", function()
            local button = questButton(E, 102)
            assert.is_false(button:IsEnabled())
            assert.is_true(button:GetNormalTexture():IsDesaturated())
            assert.is_true(questButton(E, 101):IsEnabled())
        end)

        it("tints the button of an excluded quest", function()
            E:ExcludeQuest(101)
            Stub.OpenQuestLog()
            assert.are.same({ 0.5, 0.5, 1, 0.7 }, { questButton(E, 101):GetNormalTexture():GetVertexColor() })
        end)

        it("shows a tooltip naming the quest", function()
            local button = questButton(E, 101)
            button:GetScript("OnEnter")(button)
            assert.is_truthy(GameTooltip:GetText():find("A Threat Within", 1, true))
            button:GetScript("OnLeave")(button)
            assert.is_false(GameTooltip:IsShown())
        end)

        it("abandons a quest on left click", function()
            Stub.Click(questButton(E, 101), "LeftButton")
            Stub.Advance(SWEEP)
            assert.are.same({ 101 }, Stub.state.abandoned)
        end)

        it("asks first when individual confirmation is on", function()
            E.db.general.confirmIndividual = true
            Stub.Click(questButton(E, 101), "LeftButton")
            assert.are.equal("RECKLESS_ABANDON_CONFIRMATION", Stub.state.popups[1].which)
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.abandoned)
            Stub.AcceptPopup()
            Stub.Advance(SWEEP)
            assert.are.same({ 101 }, Stub.state.abandoned)
        end)

        it("toggles the quest's exclusion on right click", function()
            local button = questButton(E, 101)
            Stub.Click(button, "RightButton")
            assert.is_true(E:IsExcluded(101))
            assert.are.same({ 0.5, 0.5, 1, 0.7 }, { button:GetNormalTexture():GetVertexColor() })
            Stub.Click(button, "RightButton")
            assert.is_false(E:IsExcluded(101))
            assert.are.same({ 1, 1, 1, 1 }, { button:GetNormalTexture():GetVertexColor() })
        end)

        it("abandons a zone's quests from its header button, once confirmed", function()
            E:ExcludeQuest(101)
            Stub.Click(groupButton(E, "elwynnforest"), "LeftButton")
            assert.are.equal("RECKLESS_ABANDON_GROUP_CONFIRMATION", Stub.state.popups[1].which)
            Stub.AcceptPopup()
            Stub.Advance(SWEEP)
            -- 101 is excluded and 102 can't be abandoned; Westfall is untouched.
            assert.are.same({}, Stub.state.abandoned)
            Stub.Click(groupButton(E, "westfall"), "LeftButton")
            Stub.AcceptPopup()
            Stub.Advance(SWEEP)
            assert.are.same({ 201 }, Stub.state.abandoned)
        end)

        describe("click bindings on the quest log rows", function()
            it("abandons a quest on Alt + left click, without the client's own click", function()
                Stub.Click(Stub.QuestLogRow(101), "LeftButton", { alt = true })
                Stub.Advance(SWEEP)
                assert.are.same({ 101 }, Stub.state.abandoned)
                assert.are.same({}, Stub.state.rowClicks)
            end)

            it("excludes a quest on Alt + right click", function()
                Stub.Click(Stub.QuestLogRow(101), "RightButton", { alt = true })
                assert.is_true(E:IsExcluded(101))
                Stub.Click(Stub.QuestLogRow(101), "RightButton", { alt = true })
                assert.is_false(E:IsExcluded(101))
            end)

            it("asks to abandon a zone on Alt + left click on its header", function()
                Stub.Click(Stub.QuestLogRow("Westfall"), "LeftButton", { alt = true })
                assert.are.equal("RECKLESS_ABANDON_GROUP_CONFIRMATION", Stub.state.popups[1].which)
                Stub.AcceptPopup()
                Stub.Advance(SWEEP)
                assert.are.same({ 201 }, Stub.state.abandoned)
            end)

            it("passes other clicks on to the client", function()
                Stub.Click(Stub.QuestLogRow(101), "LeftButton")
                Stub.Click(Stub.QuestLogRow(101), "LeftButton", { shift = true })
                Stub.Advance(SWEEP)
                assert.are.same({}, Stub.state.abandoned)
                assert.are.equal(2, #Stub.state.rowClicks)
            end)

            it("follows a rebound key", function()
                E.db.general.individualQuests.abandonBinding = "CTRL-BUTTON1"
                Stub.Click(Stub.QuestLogRow(101), "LeftButton", { alt = true })
                Stub.Advance(SWEEP)
                assert.are.same({}, Stub.state.abandoned)
                Stub.Click(Stub.QuestLogRow(101), "LeftButton", { ctrl = true })
                Stub.Advance(SWEEP)
                assert.are.same({ 101 }, Stub.state.abandoned)
            end)
        end)
    end)
end

describe("quest log buttons on Retail", function()
    it("stay hidden while the quest details pane is open", function()
        local E, Stub = Loader.Boot("retail", { questLog = LOG })
        QuestMapFrame.QuestsFrame.DetailsFrame:Show()
        Stub.OpenQuestLog()
        assert.are.equal(0, count(E.questButtonPool))
        QuestMapFrame.QuestsFrame.DetailsFrame:Hide()
        Stub.Advance(0.2)
        assert.are.equal(3, count(E.questButtonPool))
    end)

    it("come back after a search, once typing pauses", function()
        local E, Stub = Loader.Boot("retail", { questLog = LOG })
        Stub.OpenQuestLog()
        E:HideAbandonButtons()
        local search = QuestScrollFrame.SearchBox:GetScript("OnTextChanged")
        search(QuestScrollFrame.SearchBox)
        Stub.Advance(0.2)
        search(QuestScrollFrame.SearchBox)
        Stub.Advance(0.2)
        assert.are.equal(0, count(E.questButtonPool))
        Stub.Advance(0.2)
        assert.are.equal(3, count(E.questButtonPool))
    end)
end)

describe("quest log buttons on Classic", function()
    it("cover only the rows the quest log shows", function()
        local long = {}
        for i = 1, 10 do long[i] = { id = 100 + i, title = "Quest " .. i } end
        local E, Stub = Loader.Boot("classic", { questLog = long })
        Stub.OpenQuestLog()
        assert.are.equal(Stub.QUESTS_DISPLAYED, count(E.questButtonPool))
        QuestLogListScrollFrame.offset = 4
        QuestLogListScrollFrame:GetScript("OnVerticalScroll")(QuestLogListScrollFrame)
        assert.is_truthy(questButton(E, 110))
        assert.is_nil(questButton(E, 101))
    end)
end)
