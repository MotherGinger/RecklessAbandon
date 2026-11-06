local Loader = require("helpers.loader")

describe("RecklessKeybinding widget", function()
    it("registers as a stock Keybinding so UI skins style it, then takes its own type back", function()
        Loader.Boot("retail")
        local AceGUI = LibStub("AceGUI-3.0")
        local typeAtRegistration
        AceGUI.GetNextWidgetNum = function() return 1 end
        AceGUI.RegisterAsWidget = function(_, widget)
            typeAtRegistration = widget.type
            return widget
        end

        local widget = AceGUI.widgets.RecklessKeybinding.constructor()

        assert.are.equal("Keybinding", typeAtRegistration)
        assert.are.equal("RecklessKeybinding", widget.type)
        -- The parts ElvUI and AddOnSkins restyle on a Keybinding
        assert.is_truthy(widget.button)
        assert.is_truthy(widget.msgframe)
        assert.is_truthy(widget.msgframe.msg)
    end)
end)

describe("ExclusionTable widget", function()
    local skinned

    --- Builds the table with a UI skin loaded, and returns the scroll bar it handed to the skin.
    local function build(before)
        skinned = nil
        Loader.Boot("retail", { before = before })
        local AceGUI = LibStub("AceGUI-3.0")
        AceGUI.RegisterAsWidget = function(_, widget) return widget end
        local widget = AceGUI.widgets.ExclusionTable.constructor()
        return widget.frame.scrollFrame.ScrollBar
    end

    local function elvui(ace3Enable)
        return function()
            local S = { HandleScrollBar = function(_, bar) skinned = bar end }
            _G.ElvUI = { {
                GetModule = function(_, name) return name == "Skins" and S or nil end,
                private = { skins = { ace3Enable = ace3Enable } },
            } }
        end
    end

    after_each(function()
        _G.ElvUI, _G.AddOnSkins = nil, nil
    end)

    it("hands its scroll bar to ElvUI when ElvUI skins settings windows", function()
        local scrollBar = build(elvui(true))
        assert.is_truthy(scrollBar)
        assert.are.equal(scrollBar, skinned)
    end)

    it("leaves its scroll bar alone when ElvUI's settings window skin is off", function()
        build(elvui(false))
        assert.is_nil(skinned)
    end)

    it("hands its scroll bar to AddOnSkins when ElvUI isn't loaded", function()
        local scrollBar = build(function()
            _G.AddOnSkins = { {
                CheckOption = function(_, option) return option == "Ace3" end,
                SkinScrollBar = function(_, bar) skinned = bar end,
            } }
        end)
        assert.are.equal(scrollBar, skinned)
    end)

    it("builds without a UI skin", function()
        assert.is_truthy(build())
        assert.is_nil(skinned)
    end)
end)

-- What AceGUI's RegisterAsWidget gives every widget, reduced to what these widgets call.
local function asWidget(_, widget)
    widget.fired = {}
    function widget:Fire(event, ...) table.insert(self.fired, { event = event, args = { ... } }) end
    function widget:SetWidth(width) self.frame:SetWidth(width) end
    function widget:SetHeight(height) self.frame:SetHeight(height) end
    function widget:SetFullWidth(full) self.fullWidth = full end
    return widget
end

local function fired(widget, event)
    local found = {}
    for _, call in ipairs(widget.fired) do
        if call.event == event then table.insert(found, call.args) end
    end
    return found
end

--- Builds a widget the way AceGUI hands one to the settings window.
local function construct(type)
    local _, Stub = Loader.Boot("retail")
    local AceGUI = LibStub("AceGUI-3.0")
    AceGUI.GetNextWidgetNum = function() return 1 end
    AceGUI.RegisterAsWidget = asWidget
    local widget = AceGUI.widgets[type].constructor()
    widget:OnAcquire()
    return widget, Stub
end

describe("RecklessKeybinding widget in use", function()
    local widget, button, Stub

    local function run(script, ...) return button:GetScript(script)(button, ...) end

    before_each(function()
        widget, Stub = construct("RecklessKeybinding")
        button = widget.button
    end)

    it("starts unbound, with no label", function()
        assert.is_nil(widget:GetKey())
        assert.are.equal("Not Bound", button:GetText())
        assert.are.equal("GameFontNormal", button:GetNormalFontObject())
        assert.are.equal(24, widget.frame:GetHeight())
        assert.is_false(widget.msgframe:IsShown())
    end)

    it("listens for a binding after a click, and stops on a second click", function()
        run("OnClick", "LeftButton")
        assert.is_true(widget.waitingForKey)
        assert.is_true(widget.msgframe:IsShown())
        run("OnClick", "RightButton")
        assert.is_nil(widget.waitingForKey)
        assert.is_false(widget.msgframe:IsShown())
    end)

    it("doesn't listen after a middle click", function()
        run("OnClick", "MiddleButton")
        assert.is_nil(widget.waitingForKey)
    end)

    it("binds the next mouse button, with every modifier held", function()
        run("OnClick", "LeftButton")
        Stub.state.modifiers = { shift = true, ctrl = true, alt = true }
        run("OnMouseDown", "LeftButton")
        assert.are.equal("ALT-CTRL-SHIFT-BUTTON1", widget:GetKey())
        assert.are.equal("GameFontHighlight", button:GetNormalFontObject())
        assert.are.same({ { "ALT-CTRL-SHIFT-BUTTON1" } }, fired(widget, "OnKeyChanged"))
        assert.is_nil(widget.waitingForKey)
        assert.is_false(widget.msgframe:IsShown())
    end)

    it("names each mouse button the way the bindings store it", function()
        local names = { RightButton = "BUTTON2", MiddleButton = "BUTTON3", Button4 = "BUTTON4", Button5 = "BUTTON5" }
        for mouseButton, key in pairs(names) do
            run("OnClick", "LeftButton")
            run("OnMouseDown", mouseButton)
            assert.are.equal(key, widget:GetKey())
        end
    end)

    it("clears the binding on Escape", function()
        widget:SetKey("ALT-BUTTON1")
        run("OnClick", "LeftButton")
        run("OnKeyDown", "ESCAPE")
        assert.is_nil(widget:GetKey())
        assert.are.same({ { "" } }, fired(widget, "OnKeyChanged"))
    end)

    it("keeps listening through keyboard keys and the mouse wheel, which it can't bind", function()
        widget:SetKey("ALT-BUTTON1")
        run("OnClick", "LeftButton")
        run("OnKeyDown", "A")
        run("OnMouseWheel", 1)
        run("OnMouseWheel", -1)
        assert.is_true(widget.waitingForKey)
        assert.are.equal("ALT-BUTTON1", widget:GetKey())
        assert.are.same({}, fired(widget, "OnKeyChanged"))
    end)

    it("ignores keys while it isn't listening", function()
        widget:SetKey("ALT-BUTTON1")
        run("OnKeyDown", "ESCAPE")
        assert.are.equal("ALT-BUTTON1", widget:GetKey())
    end)

    it("greys out when disabled, and keeps its binding", function()
        widget:SetKey("ALT-BUTTON1")
        widget:SetDisabled(true)
        assert.is_false(button:IsEnabled())
        assert.are.same({ 0.5, 0.5, 0.5 }, { widget.label:GetTextColor() })
        widget.waitingForKey = true -- left over from before it was disabled
        run("OnMouseDown", "RightButton")
        assert.are.equal("ALT-BUTTON1", widget:GetKey())
        assert.are.same({}, fired(widget, "OnKeyChanged"))
        widget:SetDisabled(false)
        assert.is_true(button:IsEnabled())
        assert.are.same({ 1, 1, 1 }, { widget.label:GetTextColor() })
    end)

    it("makes room for a label", function()
        widget:SetLabel("Abandon Quest")
        assert.are.equal("Abandon Quest", widget.label:GetText())
        assert.are.equal(44, widget.frame:GetHeight())
        assert.are.equal(30, widget.alignoffset)
        widget:SetLabel()
        assert.are.equal(24, widget.frame:GetHeight())
        assert.is_nil(widget.alignoffset)
    end)

    it("tells AceGUI when the mouse is over it, for the option's tooltip", function()
        run("OnEnter")
        run("OnLeave")
        assert.are.equal(1, #fired(widget, "OnEnter"))
        assert.are.equal(1, #fired(widget, "OnLeave"))
    end)

    it("fits its prompt to the text once it's drawn", function()
        local msgframe = widget.msgframe
        msgframe.msg:SetWidth(240)
        msgframe:GetScript("OnUpdate")(msgframe)
        assert.are.equal(250, msgframe:GetWidth())
        assert.is_nil(msgframe:GetScript("OnUpdate"))
    end)
end)

describe("ExclusionTable widget in use", function()
    local E, widget, rows

    local function text(row, column) return rows[row].columns[column]:GetText() end

    before_each(function()
        widget = construct("ExclusionTable")
        E = RecklessAbandon[1]
        rows = widget.content.rows
    end)

    it("starts empty, full width, and doesn't react to the mouse", function()
        assert.are.same({}, rows)
        assert.is_true(widget.fullWidth)
        assert.is_nil(widget.frame:GetScript("OnEnter"))
    end)

    it("draws a header row, then each exclusion, with those that left the log in red", function()
        widget:SetText(E:TableToString({
            { "ID", "Source", "Title" },
            { 101, "Manual", "Still Here", false },
            { 102, "Automation", "Turned In", true },
        }))
        assert.are.equal(3, #rows)
        assert.are.equal("|cFFF2E699ID|r", text(1, 1))
        assert.is_truthy(rows[1].bottom)
        assert.are.equal("|cFFFFFFFF101|r", text(2, 1))
        assert.are.equal("|cFFFFFFFFStill Here|r", text(2, 3))
        assert.are.equal("|cFFFF6B6B102|r", text(3, 1))
        assert.are.equal("|cFFFF6B6BAutomation|r", text(3, 2))
    end)

    it("hides the rows it no longer needs when the list shrinks", function()
        widget:SetText(E:TableToString({ { "ID", "Source", "Title" }, { 101, "Manual", "A" }, { 102, "Manual", "B" } }))
        widget:SetText(E:TableToString({ { "ID", "Source", "Title" }, { 103, "Manual", "C" } }))
        assert.is_true(rows[2]:IsShown())
        assert.are.equal("|cFFFFFFFF103|r", text(2, 1))
        assert.is_false(rows[3]:IsShown())
    end)

    it("tells AceGUI when the mouse is over it once enabled", function()
        widget:SetDisabled(false)
        local frame = widget.frame
        frame:GetScript("OnEnter")(frame)
        frame:GetScript("OnLeave")(frame)
        assert.are.equal(1, #fired(widget, "OnEnter"))
        assert.are.equal(1, #fired(widget, "OnLeave"))
        widget:SetDisabled(true)
        assert.is_nil(frame:GetScript("OnEnter"))
    end)
end)

describe("RecklessAuthor widget", function()
    it("shows the author's mains in a tooltip while the mouse is over it", function()
        Loader.Boot("retail")
        local AceGUI = LibStub("AceGUI-3.0")
        AceGUI.Create = function(_, type) return { type = type, frame = CreateFrame("Frame") } end
        local widget = AceGUI.widgets.RecklessAuthor.constructor()
        assert.are.equal("RecklessAuthor", widget.type)

        local frame = widget.frame
        frame:GetScript("OnEnter")(frame)
        assert.is_true(GameTooltip:IsShown())
        assert.are.equal("Find me on", GameTooltip.__lines[1])
        frame:GetScript("OnLeave")(frame)
        assert.is_false(GameTooltip:IsShown())
    end)
end)

describe("widgets", function()
    it("leave a type alone when the same or a newer version is already registered", function()
        Loader.Boot("retail")
        local AceGUI = LibStub("AceGUI-3.0")
        AceGUI.GetWidgetVersion = function() return 1 end
        AceGUI.widgets = {}
        for _, file in ipairs({ "ExclusionTable", "RecklessAuthor", "RecklessKeybinding" }) do
            assert(loadfile("RecklessAbandon/Widgets/" .. file .. ".lua"))("RecklessAbandon", RecklessAbandon)
        end
        assert.are.same({}, AceGUI.widgets)
    end)
end)
