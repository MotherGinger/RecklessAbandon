-- Boots the real addon files, in the order the client loads them, inside the WoW stub.
local Stub = require("helpers.wow_stub")

local Loader = {}
local ADDON = "RecklessAbandon"
local ROOT = "RecklessAbandon/"

Loader.TOC_FOR = {
    classic = "RecklessAbandon_Vanilla.toc",
    tbc = "RecklessAbandon_TBC.toc",
    mists = "RecklessAbandon_Mists.toc",
    forever = "RecklessAbandon_Camelot.toc", -- WoW Forever reads _Camelot
    retail = "RecklessAbandon_Mainline.toc",
}

Loader.FLAVORS = { "classic", "tbc", "mists", "forever", "retail" }

-- Libraries that need a real UI (dialogs, widgets). Tests replace them with recorders.
local FAKED = { "AceGUI%-3%.0", "AceConfig", "AceDBOptions%-3%.0" }

function Loader.ReadFile(path)
    local file = assert(io.open(path, "rb"), "missing file: " .. path)
    local content = file:read("*a")
    file:close()
    return content
end

-- Compiled addon files, kept across boots. Calling a chunk again runs the file afresh, so this
-- only saves reading and compiling them for every test (slow on a Windows drive under WSL).
local chunks = {}
local function compiled(path)
    chunks[path] = chunks[path] or assert(loadfile(path))
    return chunks[path]
end

local function isFaked(path)
    for _, pattern in ipairs(FAKED) do
        if path:find("/Libraries/" .. pattern) then return true end
    end
    return false
end

-- Script handlers of the virtual frames an XML file defines, e.g. templates.X = { OnClick = "body" }.
local function readTemplates(xml, templates)
    for _, name, attributes, body in xml:gmatch("<(%a+)%s+name%s*=%s*\"([^\"]+)\"([^>]*)>(.-)</%1>") do
        if attributes:find("virtual%s*=%s*\"true\"") then
            templates[name] = {}
            local scripts = body:match("<Scripts>(.-)</Scripts>") or ""
            for event, script in scripts:gmatch("<(On%a+)>(.-)</On%a+>") do
                templates[name][event] = script
            end
        end
    end
end

local function expandXml(xmlPath, files, templates)
    -- Faked libraries are never loaded, so their XML (which may name files we don't ship) isn't read either.
    if isFaked(xmlPath) then return end
    local dir = xmlPath:match("^(.*/)") or ""
    local xml = Loader.ReadFile(xmlPath)
    readTemplates(xml, templates)
    for tag, file in xml:gmatch("<(%a+)%s+file%s*=%s*[\"']([^\"']+)[\"']") do
        local path = dir .. file:gsub("\\", "/")
        -- The client also accepts <Include file="x.lua"/> and runs it as a script (Utils/load.xml does this).
        if tag == "Script" or (tag == "Include" and path:match("%.lua$")) then
            table.insert(files, path)
        elseif tag == "Include" then
            expandXml(path, files, templates)
        end
    end
end

--- Ordered list of Lua files the TOC loads, plus the script handlers of the XML templates it defines.
function Loader.TocFiles(tocName)
    local files, templates = {}, {}
    for line in Loader.ReadFile(ROOT .. tocName):gmatch("[^\r\n]+") do
        local entry = line:match("^%s*(.-)%s*$")
        if entry ~= "" and not entry:match("^#") then
            local path = ROOT .. entry:gsub("\\", "/")
            if path:match("%.xml$") then
                expandXml(path, files, templates)
            else
                table.insert(files, path)
            end
        end
    end
    return files, templates
end

function Loader.TocFields(tocName)
    local fields = {}
    for line in Loader.ReadFile(ROOT .. tocName):gmatch("[^\r\n]+") do
        local key, value = line:match("^##%s*([%w%-_]+)%s*:%s*(.-)%s*$")
        if key then fields[key] = value end
    end
    return fields
end

-- A library whose every method call is recorded in lib.calls and returns an empty table.
local function recorder(major, fields)
    local lib = LibStub:NewLibrary(major, 1)
    lib.calls = {}
    for key, value in pairs(fields or {}) do lib[key] = value end
    return setmetatable(lib, {
        __index = function(self, method)
            return function(_, ...)
                table.insert(self.calls, { method = method, args = { ... } })
                return {}
            end
        end,
    })
end

local function installFakes()
    recorder("AceGUI-3.0", {
        widgets = {},
        GetWidgetVersion = function() return nil end,
        RegisterWidgetType = function(self, name, constructor, version)
            self.widgets[name] = { constructor = constructor, version = version }
        end,
    })
    recorder("AceConfig-3.0")
    recorder("AceConfigRegistry-3.0")
    recorder("AceDBOptions-3.0")
    recorder("AceConfigDialog-3.0", { OpenFrames = {} })
end

--- Calls recorded on a faked library, optionally only those of one method.
function Loader.Calls(major, method)
    local found = {}
    for _, call in ipairs(LibStub(major).calls) do
        if not method or call.method == method then table.insert(found, call) end
    end
    return found
end

--- Loads the addon into a fresh stubbed client and runs it through login.
-- opts.saved: SavedVariables to restore, e.g. { RecklessAbandonPrivateDB = {...} }
-- opts.questLog: quest log entries the character logs in with (see wow_stub.lua)
-- opts.before(Stub): adjust the client (level, locale, metadata) before files load
function Loader.Boot(flavorName, opts)
    opts = opts or {}
    Stub.Install(flavorName)
    local toc = opts.toc or Loader.TOC_FOR[flavorName]
    local files, templates = Loader.TocFiles(toc)
    Stub.state.templates = templates
    for key, value in pairs(Loader.TocFields(toc)) do Stub.state.metadata[key] = value end
    Stub.SetQuestLog(opts.questLog or {})
    if opts.before then opts.before(Stub) end

    local engine = {}
    for _, path in ipairs(files) do
        if not isFaked(path) then
            compiled(path)(ADDON, engine)
        end
        if path:match("LibStub%.lua$") then installFakes() end
    end

    -- The client restores SavedVariables after the addon's files run, right before ADDON_LOADED.
    for name, value in pairs(opts.saved or {}) do _G[name] = value end

    Stub.Fire("ADDON_LOADED", ADDON)
    Stub.state.loggedIn = true
    Stub.Fire("PLAYER_LOGIN")
    Stub.Fire("PLAYER_ENTERING_WORLD", true, false)
    return engine[1], Stub
end

return Loader
