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
