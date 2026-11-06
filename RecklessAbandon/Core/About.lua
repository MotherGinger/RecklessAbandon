local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

-- The author's mains, one row per client, shown in a tooltip over the author line
E.authorMains = {
    { client = "WoW Forever", name = "Gotlinde Schatten", realm = "PvE", faction = "horde", class = "paladin" }
}

---@return string icons The faction icon followed by the class icon
local function characterIcons(faction, class)
    return E.factionIcons[faction] .. E.classIcons[class]
end

--- Lists the author's mains on a tooltip.
---@param tooltip table A GameTooltip, already owned
function E:FillAuthorTooltip(tooltip)
    tooltip:AddLine(L["Find me on"])
    for _, main in ipairs(E.authorMains) do
        local character = format("%s %s", E:ColorFormat(E.classColors[main.class].hex, format("%s (%s)", main.name, main.realm)), characterIcons(main.faction, main.class))
        tooltip:AddDoubleLine(main.client, character, 1, 0.82, 0, 1, 1, 1)
    end
end

E.Options.args.about = {
    type = "group",
    name = L["About"],
    order = 2,
    childGroups = "tab",
    get = E.noop,
    set = E.noop,
    args = {
        title = {
            order = 0,
            type = "description",
            fontSize = "large",
            name = E.title
        },
        author = {
            order = 1,
            type = "description",
            fontSize = "medium",
            dialogControl = "RecklessAuthor",
            name = format(L["Written by %s %s"], E:ColorFormat(E.classColors.paladin.hex, E.author), characterIcons("horde", "paladin"))
        },
        space1 = {
            order = 2,
            type = "description",
            name = "\n"
        },
        testers = {
            order = 3,
            type = "group",
            inline = true,
            name = format(L["Testers"]),
            args = {
                rawrhax = {
                    order = 0,
                    type = "description",
                    name = format("%s %s", E:ColorFormat(E.classColors.hunter.hex, "Rawrsnax-Thrall (US)"), characterIcons("horde", "hunter"))
                },
                cob = {
                    order = 1,
                    type = "description",
                    name = format("%s %s", E:ColorFormat(E.classColors.mage.hex, "Cobbeleren-Area52 (US)"), characterIcons("horde", "mage"))
                }
            }
        },
        space2 = {
            order = 4,
            type = "description",
            name = "\n"
        },
        bugs = {
            order = 5,
            type = "input",
            name = L["Please report any bugs or request features on our issue board:"],
            width = "double",
            get = function()
                return E.github
            end,
            set = E.noop
        },
        clientDivider = {
            order = 6,
            type = "header",
            name = ""
        },
        client = {
            order = 7,
            type = "description",
            fontSize = "medium",
            name = function()
                return E:ClientInfo()
            end
        }
    }
}

--- The client details to quote in a bug report, one "Label: value" per line.
---@return string info
function E:ClientInfo()
    local rows = {
        { L["Addon Version"], E.version },
        { L["Detected Client"], E.clientName },
        { L["Game Version"], format("%s (%s)", tostring(E.wowpatch), tostring(E.wowbuild)) },
        { L["Interface Version"], E.interfaceVersion },
        { L["Project ID"], E.projectID },
        { L["Quest Log API"], E.hasQuestLogAPI and "C_QuestLog" or "Legacy" },
        { L["Locale"], GetLocale() }
    }

    local lines = {}
    for i, row in ipairs(rows) do
        lines[i] = format("|cFFFFD100%s:|r %s", row[1], tostring(row[2]))
    end

    return table.concat(lines, "\n")
end
