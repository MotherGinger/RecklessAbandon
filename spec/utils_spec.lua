local Loader = require("helpers.loader")

describe("utilities", function()
    local E
    before_each(function()
        E = Loader.Boot("classic")
    end)

    describe("CopyTable", function()
        it("deep copies the defaults onto the target", function()
            local defaults = { a = 1, nested = { b = 2 } }
            local copy = E:CopyTable({}, defaults)
            assert.are.same(defaults, copy)
            assert.are_not.equal(defaults.nested, copy.nested)
        end)

        it("keeps target keys the defaults don't have", function()
            local copy = E:CopyTable({ kept = true, nested = { mine = 1 } }, { nested = { b = 2 } })
            assert.are.same({ kept = true, nested = { mine = 1, b = 2 } }, copy)
        end)

        it("starts a fresh table when the target isn't one", function()
            assert.are.same({ a = 1 }, E:CopyTable(nil, { a = 1 }))
        end)
    end)

    it("IsEmpty tells an empty table from one with any key", function()
        assert.is_true(E:IsEmpty({}))
        assert.is_false(E:IsEmpty({ 1 }))
        assert.is_false(E:IsEmpty({ key = false }))
    end)

    it("Tabulate formats each pair and sorts the lines", function()
        assert.are.equal("a 1\nb 2\n", E:Tabulate({ b = 2, a = 1 }))
        assert.are.equal(" x y", E:Tabulate({ x = "y" }, " %s %s"))
    end)

    it("TableToString and StringToTable round trip nested tables", function()
        local original = { 101, "Title with \"quotes\"", { nested = true, n = 2.5 }, ["key with spaces"] = "v" }
        assert.are.same(original, E:StringToTable(E:TableToString(original)))
    end)

    it("TableContainsValue compares numbers to numeric strings", function()
        assert.is_true(E:TableContainsValue({ "101", "102" }, 102))
        assert.is_true(E:TableContainsValue({ "a", "b" }, "b"))
        assert.is_false(E:TableContainsValue({ "101" }, 103))
    end)

    describe("colors", function()
        it("RGBToHex writes a WoW color code", function()
            assert.are.equal("|cff80528c", E:RGBToHex(128, 82, 140))
        end)

        it("ColorFormat wraps text in a color code", function()
            assert.are.equal("|cFF80528CText|r", E:ColorFormat("cFF80528C", "Text"))
        end)

        it("InterpolateColor blends two colors", function()
            assert.are.same({ 0, 0, 0 }, E:InterpolateColor({ 0, 0, 0 }, { 255, 255, 255 }, 0))
            assert.are.same({ 127, 127, 127 }, E:InterpolateColor({ 0, 0, 0 }, { 255, 255, 255 }, 0.5))
        end)

        it("FormatGradient colors each character and resets at the end", function()
            local text = E:FormatGradient("ab", { { 255, 0, 0 }, nil, { 0, 0, 255 } })
            assert.are.equal("|cffff0000a|cff7f007fb|r", text)
        end)
    end)

    it("Dump hands the table to the client's /dump when asked", function()
        local dumped
        _G.DevTools_Dump = function(value) dumped = value end
        local value = { zone = 1 }
        assert.is_nil(E:Dump(value, true))
        _G.DevTools_Dump = nil
        assert.are.equal(value, dumped)
    end)

    it("SerializeTable marks values it can't write", function()
        assert.are.equal('"[inserializeable datatype:function]"', E:SerializeTable(print, nil, true))
    end)

    it("Dump prints nested tables", function()
        local dumped = E:Dump({ zone = { [101] = "Quest" } })
        assert.is_truthy(dumped:find("['zone'] = {", 1, true))
        assert.is_truthy(dumped:find("[101] = 'Quest'", 1, true))
    end)
end)
