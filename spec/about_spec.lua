local Loader = require("helpers.loader")

local CLIENT_NAMES = {
    classic = "Classic Era",
    tbc = "Burning Crusade Classic",
    mists = "Mists of Pandaria Classic",
    forever = "WoW Forever",
    retail = "Retail",
}

describe("About page", function()
    it("credits the author from the TOC in paladin pink, then the Horde and paladin icons", function()
        local E = Loader.Boot("classic")
        local line = E.Options.args.about.args.author.name
        local name = "|" .. E.classColors.paladin.hex .. "Frauke Betz|r"
        assert.is_truthy(line:find(name .. " " .. E.factionIcons.horde .. E.classIcons.paladin, 1, true))
    end)

    it("credits the testers in their class colors, then the Horde and class icons", function()
        local E = Loader.Boot("classic")
        local testers = E.Options.args.about.args.testers.args
        local horde = E.factionIcons.horde
        assert.are.equal("|" .. E.classColors.hunter.hex .. "Rawrsnax-Thrall (US)|r " .. horde .. E.classIcons.hunter,
            testers.rawrhax.name)
        assert.are.equal("|" .. E.classColors.mage.hex .. "Cobbeleren-Area52 (US)|r " .. horde .. E.classIcons.mage,
            testers.cob.name)
    end)

    it("shows the author's mains in a tooltip over the author line", function()
        local E = Loader.Boot("retail")
        assert.are.equal("RecklessAuthor", E.Options.args.about.args.author.dialogControl)
        assert.is_truthy(LibStub("AceGUI-3.0").widgets.RecklessAuthor)

        GameTooltip:SetOwner(UIParent)
        E:FillAuthorTooltip(GameTooltip)
        local lines = GameTooltip.__lines
        assert.are.equal("Find me on", lines[1])
        assert.are.equal(1 + #E.authorMains, #lines)

        local forever = "WoW Forever\t|" .. E.classColors.paladin.hex .. "Gotlinde Schatten (PvE)|r "
            .. E.factionIcons.horde .. E.classIcons.paladin
        assert.are.equal(forever, lines[2])
    end)

    it("has an icon and color for every main's faction and class", function()
        local E = Loader.Boot("classic")
        for _, main in ipairs(E.authorMains) do
            assert.is_truthy(E.factionIcons[main.faction], main.name)
            assert.is_truthy(E.classColors[main.class].hex, main.name)
            assert.are_not.equal("", E.classIcons[main.class], main.name)
        end
    end)

    for _, flavor in ipairs(Loader.FLAVORS) do
        it("writes every class and faction icon as a texture escape on " .. flavor, function()
            local E = Loader.Boot(flavor)
            local bad = {}
            for _, icons in ipairs({ E.classIcons, E.factionIcons }) do
                for key, icon in pairs(icons) do
                    if icon ~= "" and not icon:match("^|T[^|]+:0|t$") then bad[#bad + 1] = key .. ": " .. icon end
                end
            end
            table.sort(bad)
            assert.are.same({}, bad)
        end)

        it("lists the client details on " .. flavor, function()
            local E, Stub = Loader.Boot(flavor)
            local info = E:ClientInfo()
            assert.are.equal(CLIENT_NAMES[flavor], E.clientName)
            assert.is_truthy(info:find(E.clientName, 1, true))
            assert.is_truthy(info:find(E.version, 1, true))
            assert.is_truthy(info:find(tostring(Stub.flavor.project), 1, true))
            assert.is_truthy(info:find(tostring(Stub.flavor.interface), 1, true))
            assert.is_truthy(info:find(Stub.flavor.version .. " (" .. Stub.flavor.build .. ")", 1, true))
        end)
    end

    it("sits under a divider below the issue board link", function()
        local args = Loader.Boot("retail").Options.args.about.args
        assert.are.equal("header", args.clientDivider.type)
        assert.is_true(args.bugs.order < args.clientDivider.order)
        assert.is_true(args.clientDivider.order < args.client.order)
    end)
end)
