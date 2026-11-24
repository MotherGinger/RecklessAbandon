local Loader = require("helpers.loader")

local SWEEP = 10

local LOG = {
    { header = "Elwynn Forest" },
    { id = 101, title = "A Threat Within", level = 58 },
    { header = "Westfall" },
    { id = 201, title = "The Defias Brotherhood", level = 60 },
}

for _, flavor in ipairs(Loader.FLAVORS) do
    describe("quest row keybinds on " .. flavor, function()
        local E, Stub, row

        before_each(function()
            E, Stub = Loader.Boot(flavor, { questLog = LOG })
            Stub.OpenQuestLog()
            row = Stub.QuestLogRow(101)
        end)

        it("leave the client's row scripts in place", function()
            assert.are.equal(Stub.RowOnClick, row:GetScript("OnClick"))
            assert.is_nil(row:GetScript("OnMouseDown"))
        end)

        it("keep a bound click from reaching the client's row", function()
            Stub.Click(row, "LeftButton", { alt = true })
            Stub.Advance(SWEEP)
            assert.are.same({ 101 }, Stub.state.abandoned)
            assert.are.equal(0, #Stub.state.rowClicks)
        end)

        it("cover the row only while a bound modifier is held", function()
            local catcher = E.rowCatchers[row]
            assert.is_false(catcher:IsShown())
            Stub.SetModifiers({ alt = true })
            assert.is_true(catcher:IsShown())
            Stub.SetModifiers({})
            assert.is_false(catcher:IsShown())
        end)

        it("pass hovering through to the row, from a template so no restricted call runs in combat", function()
            local template = E.rowCatchers[row].__template
            assert.are.equal("RECKLESS_ROW_CATCHER", template)
            local xml = Loader.ReadFile("RecklessAbandon/Core/load.xml")
            local tag = xml:match('<Frame name="' .. template .. '"[^>]*>')
            assert.is_truthy(tag)
            assert.is_truthy(tag:find('virtual="true"', 1, true))
            -- Motion only: "Both" would also send the bound click to the row
            assert.is_truthy(tag:find('propagateMouseInput="Motion"', 1, true))
        end)

        it("let the next plain click through once the modifier is released", function()
            Stub.Click(row, "RightButton", { alt = true })
            Stub.Click(row, "LeftButton")
            assert.are.equal(1, #Stub.state.rowClicks)
        end)

        it("let a modifier nothing is bound to through", function()
            Stub.Click(row, "LeftButton", { ctrl = true })
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.abandoned)
            assert.are.equal(1, #Stub.state.rowClicks)
        end)

        it("don't run a quest binding on a zone header", function()
            E.db.general.zoneQuests.abandonBinding = ""
            local header = Stub.QuestLogRow("Westfall")
            Stub.SetModifiers({ alt = true })
            assert.is_false(E.rowCatchers[header]:IsShown())
            Stub.Click(header, "LeftButton", { alt = true })
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.popups)
            assert.are.same({}, Stub.state.abandoned)
            assert.are.same({}, Stub.state.errors)
        end)

        it("don't run a zone binding on a quest", function()
            E.db.general.individualQuests.abandonBinding = ""
            E.db.general.individualQuests.excludeBinding = ""
            Stub.Click(row, "LeftButton", { alt = true })
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.popups)
            assert.are.same({}, Stub.state.abandoned)
            assert.are.equal(1, #Stub.state.rowClicks)
        end)

        it("do nothing when the modifier was released without the client saying so", function()
            local catcher = E.rowCatchers[row]
            Stub.SetModifiers({ alt = true })
            Stub.state.modifiers = {} -- Alt-Tab can swallow the key release
            catcher:GetScript("OnMouseDown")(catcher, "LeftButton")
            Stub.Advance(SWEEP)
            assert.are.same({}, Stub.state.abandoned)
            assert.is_false(catcher:IsShown())
        end)

        it("step aside when the mouse enters after the modifier was released", function()
            local catcher = E.rowCatchers[row]
            Stub.SetModifiers({ alt = true })
            Stub.state.modifiers = {}
            catcher:GetScript("OnEnter")(catcher)
            assert.is_false(catcher:IsShown())
        end)

        it("clear a plain click binding left in an old profile", function()
            E.db.general.individualQuests.abandonBinding = "BUTTON2"
            E.db.general.zoneQuests.abandonBinding = "BUTTON1"
            E:NormalizeSettings()
            assert.are.equal("", E.db.general.individualQuests.abandonBinding)
            assert.are.equal("", E.db.general.zoneQuests.abandonBinding)
            assert.are.equal("ALT-BUTTON2", E.db.general.individualQuests.excludeBinding)
        end)
    end)
end

for _, flavor in ipairs({ "retail", "forever" }) do
    describe("quest row keybinds around the row's own controls on " .. flavor, function()
        it("stop short of the tracking checkbox and the collapse button", function()
            local E, Stub = Loader.Boot(flavor, { questLog = LOG })
            Stub.OpenQuestLog()
            local quest, header = Stub.QuestLogRow(101), Stub.QuestLogRow("Westfall")

            local point, relativeTo, relativePoint = E.rowCatchers[quest]:GetPoint(3)
            assert.are.same({ "RIGHT", quest.Checkbox, "LEFT" }, { point, relativeTo, relativePoint })

            point, relativeTo, relativePoint = E.rowCatchers[header]:GetPoint(3)
            assert.are.same({ "RIGHT", header.CollapseButton, "LEFT" }, { point, relativeTo, relativePoint })
        end)
    end)
end
