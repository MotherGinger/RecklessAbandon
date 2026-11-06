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
