local Loader = require("helpers.loader")

-- Calls visit(option, info, get, set) for every option under a group, the way AceConfig hands them
-- to the settings window: info is the path of keys to the option, and get/set are its own or, when
-- it has none, those of the nearest group above it.
local function eachOption(group, path, inherited, visit)
    local handlers = { get = group.get or inherited.get, set = group.set or inherited.set }
    for key, option in pairs(group.args or {}) do
        local info = {}
        for index, step in ipairs(path) do info[index] = step end
        info[#info + 1] = key
        if option.type == "group" then
            eachOption(option, info, handlers, visit)
        else
            visit(option, info, option.get or handlers.get, option.set or handlers.set)
        end
    end
end

local function generalOptions(E) return E.Options.args.general.args end

describe("settings window", function()
    for _, flavor in ipairs(Loader.FLAVORS) do
        it("reads back every setting it stores on " .. flavor, function()
            local E = Loader.Boot(flavor, { questLog = { { id = 101, title = "Q" } } })
            local checked = {}

            eachOption(E.Options.args.general, { "general" }, {}, function(option, info, get, set)
                local name = table.concat(info, ".")
                if option.type == "toggle" then
                    for _, value in ipairs({ true, false }) do
                        set(info, value)
                        assert.are.equal(value, get(info), name)
                    end
                elseif option.type == "select" then
                    for value in pairs(option.values) do
                        set(info, value)
                        assert.are.equal(value, get(info), name)
                    end
                elseif option.type == "keybinding" then
                    set(info, "CTRL-BUTTON3")
                    assert.are.equal("CTRL-BUTTON3", get(info), name)
                elseif option.type == "multiselect" then
                    for value in pairs(option.values()) do
                        set(info, value)
                        assert.is_true(get(info, value), name .. "." .. value)
                        set(info, value)
                        assert.is_false(get(info, value), name .. "." .. value)
                    end
                elseif option.type == "input" then
                    set(info, "101")
                    assert.are.equal("101", get(info), name)
                else
                    return
                end
                checked[name] = true
            end)

            assert.is_true(checked["general.general.loginMessage"])
            assert.is_true(checked["general.debug.debugLogging"])
            assert.is_true(checked["general.commands.generic.listAll"])
            assert.are.equal(E.isRetail, checked["general.general.campaignQuests.showAbandonButton"] == true)
            assert.are.equal(E.isRetail, checked["general.general.covenantCallings.showAbandonButton"] == true)
        end)
    end

    it("falls back to the profile for a setting with no handlers of its own", function()
        local E = Loader.Boot("classic")
        local group = E.Options.args.general
        group.set({ "general", "custom" }, 7)
        assert.are.equal(7, group.get({ "general", "custom" }))
        assert.are.equal(7, E.db.custom)
    end)

    it("tidies the quest ID list it's given", function()
        local E = Loader.Boot("classic")
        local ids = generalOptions(E).automationOptions.args.autoAbandonQuests.args.ids
        ids.set(nil, ",,4563, 7562,,abc2345,")
        assert.are.equal("4563,7562,2345", ids.get())
    end)

    describe("keybindings", function()
        local E, individual, zone
        before_each(function()
            E = Loader.Boot("classic")
            individual = generalOptions(E).general.args.individualQuests.args
            zone = generalOptions(E).general.args.zoneQuests.args
        end)

        it("unbinds exclude when abandon takes its key", function()
            individual.abandonBinding.set(nil, "ALT-BUTTON2")
            assert.are.equal("ALT-BUTTON2", individual.abandonBinding.get())
            assert.are.equal("", individual.excludeBinding.get())
        end)

        it("unbinds abandon when exclude takes its key", function()
            individual.excludeBinding.set(nil, "ALT-BUTTON1")
            assert.are.equal("ALT-BUTTON1", individual.excludeBinding.get())
            assert.are.equal("", individual.abandonBinding.get())
        end)

        it("leaves the other binding alone when the keys differ", function()
            individual.abandonBinding.set(nil, "CTRL-BUTTON1")
            individual.excludeBinding.set(nil, "CTRL-BUTTON2")
            assert.are.equal("CTRL-BUTTON1", individual.abandonBinding.get())
            assert.are.equal("CTRL-BUTTON2", individual.excludeBinding.get())
        end)

        it("warns before binding a plain click, which selecting a quest also uses", function()
            for _, option in ipairs({ individual.abandonBinding, individual.excludeBinding }) do
                for _, key in ipairs({ "BUTTON1", "BUTTON2" }) do
                    local warning = option.confirm(nil, key)
                    assert.is_truthy(warning:find("Are you sure you want to bind " .. key, 1, true))
                    assert.is_truthy(warning:find("select a quest", 1, true))
                end
            end
        end)

        it("warns before binding Shift + click, which tracking a quest also uses", function()
            for _, option in ipairs({ individual.abandonBinding, individual.excludeBinding }) do
                for _, key in ipairs({ "SHIFT-BUTTON1", "SHIFT-BUTTON2" }) do
                    assert.is_truthy(option.confirm(nil, key):find("track a quest", 1, true))
                end
            end
        end)

        it("warns before binding a plain click on a zone header, which expands it", function()
            assert.is_truthy(zone.abandonBinding.confirm(nil, "BUTTON2"):find("expand a zone header", 1, true))
        end)

        it("binds other keys without asking", function()
            assert.is_false(individual.abandonBinding.confirm(nil, "ALT-BUTTON1"))
            assert.is_false(individual.excludeBinding.confirm(nil, "CTRL-BUTTON2"))
            assert.is_false(zone.abandonBinding.confirm(nil, "SHIFT-BUTTON1"))
        end)
    end)

    describe("exclusion list buttons", function()
        local E, exclusions
        before_each(function()
            local Stub
            E, Stub = Loader.Boot("classic", { questLog = { { id = 101, title = "Still Here" }, { id = 102, title = "Turned In" } } })
            E:ExcludeQuest(101)
            E:ExcludeQuest(102)
            Stub.SetQuestLog({ { id = 101, title = "Still Here" } })
            exclusions = generalOptions(E).exclusions.args
        end)

        it("prunes quests that left the log", function()
            exclusions.pruneOrphans.func()
            assert.is_true(E:IsExcluded(101))
            assert.is_false(E:IsExcluded(102))
        end)

        it("clears the list", function()
            exclusions.clearExclusions.func()
            assert.is_false(E:IsExcluded(101))
            assert.is_false(E:IsExcluded(102))
        end)
    end)

    describe("opening", function()
        it("goes straight to the pages it's given", function()
            local E = Loader.Boot("classic")
            E:ToggleOptionsUI("general,commands")
            assert.are.equal(1, #Loader.Calls("AceConfigDialog-3.0", "Open"))
            local select = Loader.Calls("AceConfigDialog-3.0", "SelectGroup")
            assert.are.same({ "RecklessAbandon", "general", "commands" }, select[1].args)
        end)
    end)

    describe("About page", function()
        it("offers the issue board link to copy", function()
            local E = Loader.Boot("classic")
            local about = E.Options.args.about.args
            assert.are.equal(E.github, about.bugs.get())
            assert.are.equal(E:ClientInfo(), about.client.name())
        end)
    end)
end)
