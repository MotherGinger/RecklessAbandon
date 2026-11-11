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

            it("abandons a zone from its header straight away when group confirmation is off", function()
                E.db.general.confirmGroup = false
                Stub.Click(Stub.QuestLogRow("Westfall"), "LeftButton", { alt = true })
                Stub.Advance(SWEEP)
                assert.are.same({}, Stub.state.popups)
                assert.are.same({ 201 }, Stub.state.abandoned)
            end)

            it("asks first when individual confirmation is on", function()
                E.db.general.confirmIndividual = true
                Stub.Click(Stub.QuestLogRow(101), "LeftButton", { alt = true })
                Stub.Advance(SWEEP)
                assert.are.same({}, Stub.state.abandoned)
                Stub.AcceptPopup()
                Stub.Advance(SWEEP)
                assert.are.same({ 101 }, Stub.state.abandoned)
            end)

            it("says what a binding did when debugging is on", function()
                E.db.debugging.debugLogging = true
                Stub.ClearChat()
                Stub.Click(Stub.QuestLogRow(101), "RightButton", { alt = true })
                assert.is_true(Stub.ChatContains("A Threat Within excluded via keybinding (ALT-BUTTON2)"))
            end)

            it("binds the middle and side mouse buttons", function()
                local names = { MiddleButton = "BUTTON3", Button4 = "BUTTON4", Button5 = "BUTTON5" }
                for mouseButton, key in pairs(names) do
                    E.db.general.individualQuests.excludeBinding = key
                    Stub.Click(Stub.QuestLogRow(101), mouseButton)
                    assert.is_true(E:IsExcluded(101), key)
                    E:IncludeQuest(101)
                end
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

for _, flavor in ipairs(Loader.FLAVORS) do
    it("greys out a zone's button when none of its quests can be abandoned on " .. flavor, function()
        local E, Stub = Loader.Boot(flavor, { questLog = { { header = "Duskwood" }, { id = 301, title = "Escort", canAbandon = false } } })
        Stub.OpenQuestLog()
        local button = groupButton(E, "duskwood")
        assert.is_false(button:IsEnabled())
        assert.is_true(button:GetNormalTexture():IsDesaturated())
    end)
end

describe("quest log buttons on Retail", function()
    it("come back when the quest map handles an event, unless the details pane is open", function()
        local E, Stub = Loader.Boot("retail", { questLog = LOG })
        Stub.OpenQuestLog()
        local onEvent = QuestMapFrame:GetScript("OnEvent")
        E:HideAbandonButtons()
        QuestMapFrame.QuestsFrame.DetailsFrame:Show()
        onEvent(QuestMapFrame, "QUEST_LOG_UPDATE")
        assert.are.equal(0, count(E.questButtonPool))
        QuestMapFrame.QuestsFrame.DetailsFrame.__shown = false -- closed without its OnHide, which redraws on its own
        onEvent(QuestMapFrame, "QUEST_LOG_UPDATE")
        assert.are.equal(3, count(E.questButtonPool))
    end)

    it("hide the buttons scrolled out of view", function()
        local E, Stub = Loader.Boot("retail", { questLog = LOG })
        Stub.OpenQuestLog()
        local scrolledAway = questButton(E, 101)
        scrolledAway.GetTop = function() return 500 end
        local onScroll = QuestScrollFrame:GetScript("OnVerticalScroll")
        onScroll(QuestScrollFrame, 20)
        assert.is_false(scrolledAway:IsShown())
        assert.is_true(questButton(E, 201):IsShown())
        assert.is_true(groupButton(E, "westfall"):IsShown())
    end)

    it("stay put when scrolled behind the details pane", function()
        local E, Stub = Loader.Boot("retail", { questLog = LOG })
        Stub.OpenQuestLog()
        local button = questButton(E, 101)
        button.GetTop = function() return 500 end
        QuestMapFrame.QuestsFrame.DetailsFrame:Show()
        E:HideAbandonButtons()
        QuestScrollFrame:GetScript("OnVerticalScroll")(QuestScrollFrame, 20)
        assert.are.equal(0, count(E.questButtonPool))
    end)

    it("put a group button on campaign headers and on covenant callings, when asked", function()
        local E, Stub = Loader.Boot("retail", {
            questLog = {
                { header = "The War Within", campaign = true },
                { id = 401, title = "Chapter One" },
                { header = "Callings", calling = true },
                { id = 501, title = "A Calling" },
            },
        })
        E.db.general.covenantCallings.showAbandonButton = true
        Stub.OpenQuestLog()
        assert.is_truthy(groupButton(E, "thewarwithin"))
        local calling = groupButton(E, "callings")
        assert.are.equal("covenant callings", calling.title)
        assert.is_truthy(calling.tooltip:find("Abandon all covenant calling quests", 1, true))
    end)

    it("leave covenant callings alone by default", function()
        local E, Stub = Loader.Boot("retail", { questLog = { { header = "Callings", calling = true }, { id = 501, title = "A Calling" } } })
        Stub.OpenQuestLog()
        assert.is_nil(groupButton(E, "callings"))
    end)

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

for _, flavor in ipairs({ "classic", "tbc", "mists" }) do
    it("follow the quest log as it scrolls on " .. flavor, function()
        local long = { { header = "Elwynn Forest" } }
        for i = 1, 10 do long[i + 1] = { id = 100 + i, title = "Quest " .. i } end
        long[12] = { header = "Westfall" }
        long[13] = { id = 201, title = "Last" }
        local E, Stub = Loader.Boot(flavor, { questLog = long })
        Stub.OpenQuestLog()
        assert.is_truthy(groupButton(E, "elwynnforest"))
        assert.is_nil(groupButton(E, "westfall"))

        local scroll = QuestLogListScrollFrame
        scroll.offset = 7
        if flavor == "mists" then
            scroll.scrollBar:GetScript("OnValueChanged")(scroll.scrollBar, 7)
        else
            scroll:GetScript("OnVerticalScroll")(scroll, 7)
        end
        assert.is_truthy(groupButton(E, "westfall"))
        assert.is_truthy(questButton(E, 201))
        assert.is_nil(questButton(E, 101))
    end)
end

describe("quest log rows on Classic", function()
    it("still run the client's own mouse-down handler", function()
        local _, Stub = Loader.Boot("classic", { questLog = LOG })
        local downs = 0
        _G.QuestLogTitle2:SetScript("OnMouseDown", function() downs = downs + 1 end)
        Stub.OpenQuestLog()
        Stub.Click(Stub.QuestLogRow(101), "LeftButton")
        assert.are.equal(1, downs)
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

-- Classic rows are 300 wide; the addon takes 50 off the right for its buttons, leaving 250.
-- Text is Stub.CHAR_WIDTH (6) pixels a character, and the title starts 20 pixels in.
local ROW_WIDTH = 250
local TAG_WIDTH = 7 * 6 -- "(Elite)"
local LONG_TITLE = string.rep("Long Title ", 4) -- 44 characters, 264 pixels: wider than the row

local function rowParts(row)
    local name = row:GetName()
    if name then return _G[name .. "Tag"], _G[name .. "Check"], _G[name .. "NormalText"] end
    return row.tag, row.check, row.normalText
end

for _, flavor in ipairs({ "classic", "tbc", "mists" }) do
    describe("quest log row layout on " .. flavor, function()
        local function boot(log)
            local E, Stub = Loader.Boot(flavor, { questLog = log })
            Stub.OpenQuestLog()
            return E, Stub
        end

        it("puts the abandon buttons just past the narrowed row, where the quest tag can't reach", function()
            local E, Stub = boot({ { header = "Elwynn Forest" }, { id = 101, title = "Hogger", tag = "Elite" } })
            local row, header = Stub.QuestLogRow(101), Stub.QuestLogRow("Elwynn Forest")
            assert.are.equal(ROW_WIDTH, row:GetWidth())
            assert.are.same({ "LEFT", row, "RIGHT", 4, 0 }, { questButton(E, 101):GetPoint(1) })
            assert.are.same({ "LEFT", header, "RIGHT", 29, 0 }, { groupButton(E, "elwynnforest"):GetPoint(1) })
            -- The client pins the tag to the row's right edge, which is now left of the button.
            local tag = rowParts(row)
            assert.are.same({ "RIGHT", row, "RIGHT", -2, 0 }, { tag:GetPoint(1) })
        end)

        it("cuts a long title short of the quest tag", function()
            local _, Stub = boot({ { id = 101, title = LONG_TITLE, tag = "Elite" } })
            local _, _, text = rowParts(Stub.QuestLogRow(101))
            -- The row, less the tag's 2 pixel inset, the tag, a 4 pixel gap, and the title's 20 pixel indent.
            assert.are.equal(ROW_WIDTH - 2 - TAG_WIDTH - 4 - 20, text:GetWidth())
        end)

        it("leaves a short title its own width", function()
            local _, Stub = boot({ { header = "Elwynn Forest" }, { id = 101, title = "Hogger", tag = "Elite" } })
            local _, _, text = rowParts(Stub.QuestLogRow(101))
            assert.are.equal(6 * 6, text:GetWidth())
            local _, _, headerText = rowParts(Stub.QuestLogRow("Elwynn Forest"))
            assert.are.equal(13 * 6, headerText:GetWidth())
        end)

        it("cuts a long untagged title short of the row's edge", function()
            local _, Stub = boot({ { id = 101, title = LONG_TITLE } })
            local _, _, text = rowParts(Stub.QuestLogRow(101))
            assert.are.equal(ROW_WIDTH - 20, text:GetWidth())
        end)

        it("keeps the tracking check right after the title, before the tag", function()
            local _, Stub = boot({ { id = 101, title = LONG_TITLE, tag = "Elite", tracked = true } })
            local _, check, text = rowParts(Stub.QuestLogRow(101))
            assert.are.equal(ROW_WIDTH - 2 - TAG_WIDTH - 4 - 2 - 16 - 20, text:GetWidth())
            assert.are.same({ "LEFT", text, "RIGHT", 2, 0 }, { check:GetPoint(1) })
        end)

        it("measures the title from where the client placed it", function()
            local _, Stub = boot({ { id = 101, title = LONG_TITLE, tag = "Elite" } })
            local row = Stub.QuestLogRow(101)
            local _, _, text = rowParts(row)
            row.__left, text.__left = 100, 130
            QuestLog_Update()
            assert.are.equal(ROW_WIDTH - 2 - TAG_WIDTH - 4 - 30, text:GetWidth())
        end)

        it("lays the rows out again when the client redraws them", function()
            local _, Stub = boot({ { id = 101, title = LONG_TITLE, tag = "Elite", tracked = true } })
            local _, check, text = rowParts(Stub.QuestLogRow(101))
            -- Selecting or tracking a quest redraws the rows, sizing the title for the full row again.
            QuestLog_Update()
            assert.are.equal(ROW_WIDTH - 2 - TAG_WIDTH - 4 - 2 - 16 - 20, text:GetWidth())
            assert.are.same({ "LEFT", text, "RIGHT", 2, 0 }, { check:GetPoint(1) })
        end)
    end)
end

for _, flavor in ipairs({ "forever", "retail" }) do
    describe("quest log row layout on " .. flavor, function()
        local function checkboxPoint(Stub, questId)
            local row = Stub.QuestLogRow(questId)
            return { row.Checkbox:GetPoint(1) }, row
        end

        it("moves the tracking checkbox left and puts the abandon button where it was", function()
            local E, Stub = Loader.Boot(flavor, { questLog = LOG })
            Stub.OpenQuestLog()
            local point, row = checkboxPoint(Stub, 101)
            assert.are.same({ "TOPRIGHT", row, "TOPRIGHT", -20, -8 }, point)
            assert.are.same({ "LEFT", row.Checkbox, "RIGHT", 4, 0 }, { questButton(E, 101):GetPoint(1) })
        end)

        it("makes room as the client hands a row out, before it draws the title", function()
            Loader.Boot(flavor, { questLog = LOG })
            local row = QuestScrollFrame.titleFramePool:Acquire()
            assert.are.same({ "TOPRIGHT", row, "TOPRIGHT", -20, -8 }, { row.Checkbox:GetPoint(1) })
        end)

        it("moves each row's checkbox only once, however often the row is reused", function()
            local _, Stub = Loader.Boot(flavor, { questLog = LOG })
            Stub.OpenQuestLog()
            Stub.CloseQuestLog()
            Stub.OpenQuestLog()
            local point, row = checkboxPoint(Stub, 101)
            assert.are.same({ "TOPRIGHT", row, "TOPRIGHT", -20, -8 }, point)
        end)

        it("puts the checkbox back when quest buttons are turned off, and moves it again when they're on", function()
            local E, Stub = Loader.Boot(flavor, { questLog = LOG })
            Stub.OpenQuestLog()
            E.db.general.individualQuests.showAbandonButton = false
            Stub.OpenQuestLog()
            local point, row = checkboxPoint(Stub, 101)
            assert.are.same({ "TOPRIGHT", row, "TOPRIGHT", 0, -8 }, point)
            E.db.general.individualQuests.showAbandonButton = true
            Stub.OpenQuestLog()
            point, row = checkboxPoint(Stub, 101)
            assert.are.same({ "TOPRIGHT", row, "TOPRIGHT", -20, -8 }, point)
        end)
    end)
end

it("leaves a quest's tag icon showing on Retail", function()
    local _, Stub = Loader.Boot("retail", { questLog = { { header = "Dornogal" }, { id = 101, title = "Elite Quest", tag = "Elite" } } })
    Stub.OpenQuestLog()
    assert.is_true(Stub.QuestLogRow(101).TagTexture:IsShown())
end)
