local Loader = require("helpers.loader")

local TOCS = {
    ["RecklessAbandon_Vanilla.toc"] = "11509",
    ["RecklessAbandon_TBC.toc"] = "20506",
    ["RecklessAbandon_Mists.toc"] = "50504",
    ["RecklessAbandon_Camelot.toc"] = "16001", -- WoW Forever reads _Camelot, not _Forever
    ["RecklessAbandon_Mainline.toc"] = "120105",
}
local REQUIRED = { "Title", "Notes", "Author", "Version", "SavedVariables", "SavedVariablesPerCharacter", "X-Curse-Project-ID", "X-Wago-ID" }
local NOTE_LOCALES = { "deDE", "esES", "esMX", "frFR", "itIT", "ptBR", "ruRU", "zhCN", "zhTW" }
-- Clients with the addon compartment (the minimap addon menu).
local COMPARTMENT = { ["RecklessAbandon_Camelot.toc"] = true, ["RecklessAbandon_Mainline.toc"] = true }
-- Clients Questie (and its QuestieDB) is made for. Loading after QuestieDB lets the integration see it.
local QUESTIE = {
    ["RecklessAbandon_Vanilla.toc"] = true, ["RecklessAbandon_TBC.toc"] = true,
    ["RecklessAbandon_Mists.toc"] = true, ["RecklessAbandon_Camelot.toc"] = true,
}

describe("TOC files", function()
    for toc, interface in pairs(TOCS) do
        describe(toc, function()
            local fields = Loader.TocFields(toc)

            it("targets interface " .. interface, function()
                assert.are.equal(interface, fields.Interface)
            end)

            it("declares every required field", function()
                for _, key in ipairs(REQUIRED) do
                    assert.is_truthy(fields[key], key)
                end
            end)

            it("has notes for every shipped locale", function()
                for _, locale in ipairs(NOTE_LOCALES) do
                    assert.is_truthy(fields["Notes-" .. locale], locale)
                end
            end)

            it("lists only files that exist", function()
                for _, path in ipairs(Loader.TocFiles(toc)) do
                    local handle = io.open(path, "rb")
                    assert.is_truthy(handle, path)
                    handle:close()
                end
            end)

            it("saves the variables the addon reads", function()
                assert.are.equal("RecklessAbandonDB, RecklessAbandonPrivateDB", fields.SavedVariables)
                assert.are.equal("RecklessAbandonCharacterDB", fields.SavedVariablesPerCharacter)
            end)

            it(QUESTIE[toc] and "loads after QuestieDB when it's installed" or "doesn't wait for QuestieDB", function()
                assert.are.equal(QUESTIE[toc] and "QuestieDB" or nil, fields.OptionalDeps)
            end)

            if COMPARTMENT[toc] then
                it("points the addon compartment at our global function", function()
                    assert.are.equal("RecklessAbandon_AddonCompartmentFunc", fields.AddonCompartmentFunc)
                end)
            end
        end)
    end

    it("keeps version, IDs and load order identical across flavors", function()
        local first
        for toc in pairs(TOCS) do
            local fields = Loader.TocFields(toc)
            local current = {
                version = fields.Version,
                curse = fields["X-Curse-Project-ID"],
                wago = fields["X-Wago-ID"],
                files = table.concat(Loader.TocFiles(toc), "\n"),
            }
            first = first or current
            assert.are.same(first, current, toc)
        end
    end)

    it("has a TOC for every flavor the tests boot", function()
        for _, flavor in ipairs(Loader.FLAVORS) do
            assert.is_truthy(TOCS[Loader.TOC_FOR[flavor]], flavor)
        end
    end)
end)
