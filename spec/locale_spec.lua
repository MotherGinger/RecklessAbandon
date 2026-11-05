local Loader = require("helpers.loader")

local LOCALES = { "deDE", "esMX", "frFR", "itIT", "ptBR", "ruRU", "zhCN" }

--- Runs a locale file with a stand-in for AceLocale and returns what it defined.
local function strings(code)
    local captured = {}
    local saved = _G.RecklessAbandon
    _G.RecklessAbandon = { { Libs = { ACL = { NewLocale = function() return captured end } } } }
    assert(loadfile("RecklessAbandon/Locales/" .. code .. ".lua"))()
    _G.RecklessAbandon = saved
    return captured
end

--- Every placeholder in a string, in order: format specifiers, |4 plurals and color codes.
local function placeholders(text)
    local found = {}
    for spec in text:gmatch("%%[%-%d%.]*[%a%%]") do found[#found + 1] = spec end
    for _ in text:gmatch("|4") do found[#found + 1] = "|4" end
    for code in text:gmatch("|c%x%x%x%x%x%x%x%x") do found[#found + 1] = code:lower() end
    for _ in text:gmatch("|r") do found[#found + 1] = "|r" end
    return table.concat(found, " ")
end

--- The strings the addon's own files look up, as "path: string".
local function sourceStrings()
    local found = {}
    for _, path in ipairs(Loader.TocFiles(Loader.TOC_FOR.classic)) do
        if not path:find("/Libraries/", 1, true) and not path:find("/Locales/", 1, true) then
            for key in Loader.ReadFile(path):gmatch('%f[%w_]L%[%s*"(.-)"%s*%]') do
                found[#found + 1] = { path = path, text = assert(loadstring('return "' .. key .. '"'))() }
            end
        end
    end
    return found
end

local function yes(code)
    Loader.Boot("classic", { before = function(Stub) Stub.state.locale = code end })
    return select(2, unpack(_G.RecklessAbandon))["Yes"]
end

describe("locales", function()
    it("ships a file for every locale the load order lists", function()
        local xml = Loader.ReadFile("RecklessAbandon/Locales/load.xml")
        for _, code in ipairs(LOCALES) do
            assert.is_truthy(xml:find(code .. ".lua", 1, true), code)
        end
    end)

    it("defines every string the source uses", function()
        local english = strings("enUS")
        local missing = {}
        for _, used in ipairs(sourceStrings()) do
            if english[used.text] == nil then missing[#missing + 1] = used.path .. ": " .. used.text end
        end
        assert.are.same({}, missing)
    end)

    it("uses every English string", function()
        local used = {}
        for _, entry in ipairs(sourceStrings()) do used[entry.text] = true end
        local unused = {}
        for key in pairs(strings("enUS")) do
            if not used[key] then unused[#unused + 1] = key end
        end
        table.sort(unused)
        assert.are.same({}, unused)
    end)

    it("has no translation for a string English doesn't have", function()
        -- e.g. a key translated along with its value, or English that changed since: the client
        -- never looks those up, so players see English.
        local english = strings("enUS")
        local stale = {}
        for _, code in ipairs(LOCALES) do
            for key in pairs(strings(code)) do
                if english[key] == nil then stale[#stale + 1] = code .. ": " .. key end
            end
        end
        table.sort(stale)
        assert.are.same({}, stale)
    end)

    it("keeps every placeholder in every translation", function()
        local english = strings("enUS")
        local broken = {}
        for _, code in ipairs(LOCALES) do
            for key, value in pairs(strings(code)) do
                local source = english[key] == true and key or english[key]
                -- `true` in a translation means "same as English", which is fine (e.g. "General").
                if value == "" or (type(value) ~= "string" and value ~= true) then
                    broken[#broken + 1] = code .. " (empty): " .. key
                elseif type(value) == "string" and type(source) == "string" and placeholders(value) ~= placeholders(source) then
                    broken[#broken + 1] = code .. ": " .. key
                end
            end
        end
        table.sort(broken)
        assert.are.same({}, broken)
    end)

    it("translates every string in every shipped language", function()
        local english = strings("enUS")
        local missing = {}
        for _, code in ipairs(LOCALES) do
            local translated = strings(code)
            local count = 0
            for key in pairs(english) do
                if translated[key] == nil then count = count + 1 end
            end
            if count > 0 then missing[#missing + 1] = code .. ": " .. count .. " missing" end
        end
        assert.are.same({}, missing)
    end)

    it("loads the translation for a client in a shipped language", function()
        assert.are.equal("Ja", yes("deDE"))
        assert.are.equal("Да", yes("ruRU"))
        assert.are.equal("Yes", yes("enGB"))
    end)

    -- These clients once got a string instead of a locale table, and the addon errored while loading.
    for _, code in ipairs({ "esES", "ptPT", "zhTW", "koKR" }) do
        it("loads on a " .. code .. " client", function()
            local E, Stub = Loader.Boot("classic", { before = function(S) S.state.locale = code end })
            assert.is_true(E.initialized)
            assert.are.same({}, Stub.state.errors)
        end)
    end

    it("shows English on a client with no translation", function()
        assert.are.equal("Yes", yes("koKR"))
    end)

    it("gives sister locales the shipped translation", function()
        assert.are.equal("Sí", yes("esES"))
        assert.are.equal(yes("esMX"), yes("esES"))
        assert.are.equal(yes("ptBR"), yes("ptPT"))
        assert.are.equal(yes("zhCN"), yes("zhTW"))
    end)
end)
