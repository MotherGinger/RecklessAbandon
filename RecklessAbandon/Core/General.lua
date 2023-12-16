local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local tostring = tostring
local format, strlen, strrep, strsplit = format, strlen, strrep, strsplit

E.Options.args.general = {
    type = "group",
    name = L["General"],
    order = 0,
    childGroups = "tab",
    get = function(info)
        return E.db[info[#info]]
    end,
    set = function(info, value)
        E.db[info[#info]] = value
    end,
    args = {
        general = {
            order = 0,
            type = "group",
            name = L["General"],
            args = {
                generalHeader = {
                    order = 0,
                    type = "header",
                    name = L["General Settings"]
                },
                loginMessage = {
                    order = 1,
                    type = "toggle",
                    name = L["Show login message"],
                    get = function(info)
                        return E.db.general.loginMessage
                    end,
                    set = function(info, value)
                        E.db.general.loginMessage = value
                    end
                },
                logLevel = {
                    order = 2,
                    type = "select",
                    name = L["Messaging Rate"],
                    desc = table.concat(
                        {
                            L["Adjust the amount of messages you will receive from actions taken against your quest log."],
                            L["|cFF00D1FFNote:|r You will always be notified when a quest is abandoned on your behalf."]
                        },
                        "\n\n"
                    ),
                    values = E.logLevels,
                    width = "double",
                    get = function(info)
                        return E.db.general.logLevel
                    end,
                    set = function(info, value)
                        E.db.general.logLevel = value
                    end
                },
                space1 = {
                    order = 3,
                    type = "description",
                    name = ""
                },
                confirmIndividual = {
                    order = 4,
                    name = L["Confirm individual abandons"],
                    desc = table.concat(
                        {
                            L["Prompt for confirmation when abandoning individual quests."],
                            L["|cFFFF6B6BCaution: Turning this off means a quest will be abandoned instantly. Be careful!|r"]
                        },
                        "\n\n"
                    ),
                    type = "toggle",
                    get = function(info)
                        return E.db.general.confirmIndividual
                    end,
                    set = function(info, value)
                        E.db.general.confirmIndividual = value
                    end
                },
                confirmGroup = {
                    order = 5,
                    name = L["Confirm group abandons"],
                    desc = table.concat(
                        {
                            L["Prompt for confirmation when abandoning multiple quests."],
                            L["|cFFFF6B6BCaution: Turning this off means a group of quests will be abandoned instantly. Be careful!|r"]
                        },
                        "\n\n"
                    ),
                    type = "toggle",
                    get = function(info)
                        return E.db.general.confirmGroup
                    end,
                    set = function(info, value)
                        E.db.general.confirmGroup = value
                    end
                },
                space2 = {
                    order = 6,
                    type = "description",
                    name = "\n\n"
                },
                individualQuests = {
                    order = 7,
                    type = "group",
                    name = L["Individual Quests"],
                    inline = true,
                    args = {
                        showAbandonButton = {
                            order = 0,
                            name = L["Show Abandon Button"],
                            desc = L["Show an abandon button for individual quests."],
                            type = "toggle",
                            get = function(info)
                                return E.db.general.individualQuests.showAbandonButton
                            end,
                            set = function(info, value)
                                E.db.general.individualQuests.showAbandonButton = value
                            end
                        },
                        completeProtection = {
                            order = 1,
                            name = L["Complete Protection"],
                            desc = L["Automatically exclude completed quests from group abandons and automation options."],
                            type = "toggle",
                            get = function(info)
                                return E.db.general.individualQuests.completeProtection
                            end,
                            set = function(info, value)
                                E.db.general.individualQuests.completeProtection = value
                            end
                        },
                        space1 = {
                            order = 2,
                            type = "description",
                            name = "\n"
                        },
                        keybindingsHeader = {
                            order = 3,
                            type = "header",
                            name = L["Keybindings"]
                        },
                        abandonBinding = {
                            order = 4,
                            type = "keybinding",
                            dialogControl = "RecklessKeybinding",
                            name = L["Abandon Quest"],
                            desc = L["Use this keybinding on a quest in your quest log to abandon it."],
                            get = function()
                                return E.db.general.individualQuests.abandonBinding
                            end,
                            set = function(_, value)
                                E.db.general.individualQuests.abandonBinding = value

                                if E.db.general.individualQuests.excludeBinding == value then
                                    E.db.general.individualQuests.excludeBinding = ""
                                end
                            end,
                            confirm = function(_, key)
                                if key == "BUTTON1" or key == "BUTTON2" then
                                    return table.concat(
                                        {
                                            format(L["Are you sure you want to bind %s?"], key),
                                            L["|cFFFF6B6BCaution: This can cause you to accidently abandon a quest when trying to select a quest in your quest log.|r"]
                                        },
                                        "\n\n"
                                    )
                                elseif key == "SHIFT-BUTTON1" or key == "SHIFT-BUTTON2" then
                                    return table.concat(
                                        {
                                            format(L["Are you sure you want to bind %s?"], key),
                                            L["|cFFFF6B6BCaution: This can cause you to accidently abandon a quest when trying to track a quest in your quest log.|r"]
                                        },
                                        "\n\n"
                                    )
                                end

                                return false
                            end
                        },
                        excludeBinding = {
                            order = 5,
                            type = "keybinding",
                            dialogControl = "RecklessKeybinding",
                            name = L["Exclude/Include Quest"],
                            desc = L["Use this keybinding on a quest in your quest log to toggle exclusion from group abandons."],
                            get = function()
                                return E.db.general.individualQuests.excludeBinding
                            end,
                            set = function(_, value)
                                E.db.general.individualQuests.excludeBinding = value

                                if E.db.general.individualQuests.abandonBinding == value then
                                    E.db.general.individualQuests.abandonBinding = ""
                                end
                            end,
                            confirm = function(_, key)
                                if key == "BUTTON1" or key == "BUTTON2" then
                                    return table.concat(
                                        {
                                            format(L["Are you sure you want to bind %s?"], key),
                                            L["|cFFFF6B6BCaution: This can cause you to accidently toggle exclusion of a quest from group abandons when trying to select a quest in your quest log.|r"]
                                        },
                                        "\n\n"
                                    )
                                elseif key == "SHIFT-BUTTON1" or key == "SHIFT-BUTTON2" then
                                    return table.concat(
                                        {
                                            format(L["Are you sure you want to bind %s?"], key),
                                            L["|cFFFF6B6BCaution: This can cause you to accidently toggle exclusion of a quest from group abandons when trying to track a quest in your quest log.|r"]
                                        },
                                        "\n\n"
                                    )
                                end

                                return false
                            end
                        }
                    }
                },
                zoneQuests = {
                    order = 8,
                    type = "group",
                    name = L["Zone Quests"],
                    inline = true,
                    args = {
                        showAbandonButton = {
                            order = 0,
                            name = L["Show Group Abandon Button"],
                            desc = L["Show a group abandon button for zone quests."],
                            type = "toggle",
                            get = function(info)
                                return E.db.general.zoneQuests.showAbandonButton
                            end,
                            set = function(info, value)
                                E.db.general.zoneQuests.showAbandonButton = value
                            end
                        },
                        keybindingsHeader = {
                            order = 1,
                            type = "header",
                            name = L["Keybindings"]
                        },
                        abandonKeybinding = {
                            order = 2,
                            type = "keybinding",
                            dialogControl = "RecklessKeybinding",
                            name = L["Abandon Quests"],
                            desc = L["Use this keybinding on a zone header in your quest log to abandon all quests for that zone that are included in group abandons."],
                            get = function()
                                return E.db.general.zoneQuests.abandonBinding
                            end,
                            set = function(_, value)
                                E.db.general.zoneQuests.abandonBinding = value
                            end,
                            confirm = function(_, key)
                                if key == "BUTTON1" or key == "BUTTON2" then
                                    return table.concat(
                                        {
                                            format(L["Are you sure you want to bind %s?"], key),
                                            L["|cFFFF6B6BCaution: This can cause you to accidently abandon all quests in a zone when trying to expand a zone header in your quest log.|r"]
                                        },
                                        "\n\n"
                                    )
                                end

                                return false
                            end
                        }
                    }
                },
                campaignQuests = {
                    order = 9,
                    type = "group",
                    name = L["Campaign Quests"],
                    inline = true,
                    args = {
                        showAbandonButton = {
                            order = 0,
                            name = L["Show Group Abandon Button"],
                            desc = L["Show a group abandon button for campaign quests."],
                            type = "toggle",
                            get = function(info)
                                return E.db.general.campaignQuests.showAbandonButton
                            end,
                            set = function(info, value)
                                E.db.general.campaignQuests.showAbandonButton = value
                            end
                        }
                    }
                },
                covenantCallings = {
                    order = 10,
                    type = "group",
                    name = L["Covenant Callings"],
                    inline = true,
                    args = {
                        showAbandonButton = {
                            order = 0,
                            name = L["Show Group Abandon Button"],
                            desc = L["Show a group abandon button for covenant callings."] .. "\n\n" .. L["|cFF00D1FFNote:|r Blizzard currently does not allow covenant callings to be abandoned. This button will be disabled if shown."],
                            type = "toggle",
                            get = function(info)
                                return E.db.general.covenantCallings.showAbandonButton
                            end,
                            set = function(info, value)
                                E.db.general.covenantCallings.showAbandonButton = value
                            end
                        }
                    }
                }
            }
        },
        automationOptions = {
            order = 1,
            type = "group",
            name = L["Automation Options"],
            args = {
                automationHeader = {
                    order = 0,
                    type = "header",
                    name = L["Automation Options"]
                },
                automationDescription = {
                    order = 1,
                    type = "description",
                    name = table.concat(
                        {
                            L["These options will act upon your quest log automatically. This can save you time, however, care should be taken when using them."],
                            L["|cFF00D1FFNote:|r Each character has their own automation options."]
                        },
                        "\n\n"
                    )
                },
                space3 = {
                    order = 2,
                    type = "description",
                    name = "\n"
                },
                autoAbandonQuests = {
                    order = 3,
                    type = "group",
                    name = L["Abandon Quests"],
                    args = {
                        questType = {
                            order = 0,
                            name = L["Quest Type"],
                            desc = table.concat(
                                {
                                    L["Automatically abandon quests of the given type if they are included in group abandons."],
                                    L["|cFFFF6B6BCaution:|r These quests will be abandoned for you, confirmation settings will be ignored."]
                                },
                                "\n\n"
                            ),
                            type = "multiselect",
                            values = function()
                                local _, values = E:GetAvailableQualifiers()
                                return values
                            end,
                            get = function(info, value)
                                return E.private.automationOptions.autoAbandonQuests.questType[value]
                            end,
                            set = function(info, value)
                                E.private.automationOptions.autoAbandonQuests.questType[value] = not E.private.automationOptions.autoAbandonQuests.questType[value]
                            end
                        },
                        space4 = {
                            order = 1,
                            type = "description",
                            name = "\n"
                        },
                        ids = {
                            order = 2,
                            type = "input",
                            name = L["Quest IDs"],
                            desc = table.concat(
                                {
                                    L["Enter quest ids separated by a comma. These quests will be abandoned automatically if they are included in group abandons."],
                                    "e.g. 4563,7562,2345"
                                },
                                "\n\n"
                            ),
                            multiline = 5,
                            width = "full",
                            get = function(info, values)
                                return E.private.automationOptions.autoAbandonQuests.ids
                            end,
                            set = function(info, value)
                                -- * Remove all non digit and comma characters
                                -- * Replace all consecutive commas with one comma
                                -- * Remove any trailing comma
                                local ids = value:gsub("[^%d,]+", ""):gsub(",+", ","):gsub("^,+", ""):gsub(",*$", "")
                                E:Debug(L["Auto Abandon: "], E:Dump({strsplit(",", ids)}))
                                E.private.automationOptions.autoAbandonQuests.ids = ids
                            end
                        }
                    }
                }
            }
        },
        exclusions = {
            order = 2,
            type = "group",
            name = L["Exclusions"],
            args = {
                exclusionsHeader = {
                    order = 0,
                    type = "header",
                    name = L["Quest Exclusion List"]
                },
                exclusionDescription = {
                    order = 1,
                    type = "description",
                    width = "full",
                    name = L["The quest exclusion list allows you to exclude quests from group abandons. To use it, simply right click a quest abandon button in the quest log."] .. "\n\n"
                },
                exclusionDescription2 = {
                    order = 2,
                    type = "description",
                    width = "full",
                    name = L["|cFF00D1FFNote:|r Each character has their own exclusion list."] .. "\n\n"
                },
                excludedQuests = {
                    order = 3,
                    type = "description",
                    disabled = true,
                    name = function()
                        local exclusionTable = {{L["QuestID"], L["Source"], L["Title"]}}

                        for questId, meta in pairs(E.private.exclusions.excludedQuests) do
                            local title = meta.title
                            local source = meta.source == MANUAL and L["Manual"] or L["Automation"]
                            local orphaned = C_QuestLog.GetLogIndexForQuestID(questId) == nil

                            -- * Excluded quests are stored with the localized version of the title at time of exclusion
                            -- * This cannot be updated when language changes since the title can only be fetched for quests still in your log
                            -- * It would then be impossible to update titles for abandoned but still excluded quests
                            tinsert(exclusionTable, {questId, source, title, orphaned})
                        end

                        return E:TableToString(exclusionTable)
                    end,
                    dialogControl = "ExclusionTable"
                },
                space1 = {
                    order = 4,
                    type = "description",
                    name = "\n"
                },
                autoPrune = {
                    order = 5,
                    type = "toggle",
                    name = L["Automatic Pruning"],
                    desc = table.concat(
                        {
                            L["Automatically prune quests from the exclusion list when they are abandoned, or when they are no longer in your quest log and were excluded via automation."],
                            L["|cFF00D1FFNote:|r This does not retroactively prune quests that have already been abandoned, but are still in the exclusion list."],
                            L["Use the 'Prune Exclusion List' button below to do this manually."]
                        },
                        "\n\n"
                    ),
                    width = "full",
                    get = function(info)
                        return E.private.exclusions.autoPrune
                    end,
                    set = function(info, value)
                        E.private.exclusions.autoPrune = value
                    end
                },
                pruneOrphans = {
                    order = 6,
                    type = "execute",
                    name = L["Prune Exclusion List"],
                    desc = table.concat(
                        {
                            L["Quests that appear in |cFFFF6B6Bred|r are no longer detected in your quest log."],
                            L["You can prune them by clicking this button, or leave them and they will be excluded again the next time they are picked up."]
                        },
                        "\n\n"
                    ),
                    func = function()
                        E:PruneQuestExclusions()
                    end
                },
                clearExclusions = {
                    order = 7,
                    type = "execute",
                    name = L["Clear Exclusion List"],
                    desc = L["Clear the exclusion list by including quests that are still in your quest log and pruning those that aren't."],
                    func = function()
                        E:ClearQuestExclusions()
                    end
                }
            }
        },
        commands = {
            order = 3,
            type = "group",
            name = L["Commands"],
            args = {
                commandsHeader = {
                    order = 0,
                    type = "header",
                    name = L["Slash Commands"]
                },
                commandsDescription = {
                    order = 1,
                    type = "description",
                    name = L["|cFF00D1FFNote:|r The token |cff888888reckless|r can be replaced by |cff888888rab|r for all commands."]
                },
                space1 = {
                    order = 2,
                    type = "description",
                    name = "\n"
                },
                generic = {
                    order = 3,
                    type = "group",
                    name = L["Generic"],
                    args = {
                        listAll = {
                            order = 0,
                            name = L["Enable |cff888888/reckless list all|r"],
                            desc = L["This command lists all quests in a table."],
                            descStyle = "inline",
                            width = "full",
                            type = "toggle",
                            get = function(info)
                                return E.db.commands.generic[info[#info]]
                            end,
                            set = function(info, value)
                                E.db.commands.generic[info[#info]] = value
                            end
                        },
                        abandonAll = {
                            order = 1,
                            name = L["Enable |cff888888/reckless abandon all|r"],
                            desc = L["|cFFFFF569Warning:|r This command abandons all quests in your quest log that are not excluded from group abandons, use it wisely."],
                            descStyle = "inline",
                            width = "full",
                            type = "toggle",
                            get = function(info)
                                return E.db.commands.generic[info[#info]]
                            end,
                            set = function(info, value)
                                E.db.commands.generic[info[#info]] = value
                            end
                        },
                        abandonByQuestId = {
                            order = 2,
                            name = L["Enable |cff888888/reckless abandon <questID>|r"],
                            desc = L["This command abandons a quest that matches the provided questID."],
                            descStyle = "inline",
                            width = "full",
                            type = "toggle",
                            get = function(info)
                                return E.db.commands.generic[info[#info]]
                            end,
                            set = function(info, value)
                                E.db.commands.generic[info[#info]] = value
                            end
                        },
                        abandonByQualifier = {
                            order = 3,
                            name = L["Enable |cff888888/reckless abandon <qualifier>|r"],
                            desc = format("%s\n\n%s\n\n%s", L["This command abandons all quests that match a given qualifier and are not excluded from group abandons."], L["Available Qualifiers:"], E:Tabulate(E:GetAvailableQualifiers(), "|cFFF2E699%s|r - %s\n")),
                            descStyle = "inline",
                            width = "full",
                            type = "toggle",
                            get = function(info)
                                return E.db.commands.generic[info[#info]]
                            end,
                            set = function(info, value)
                                E.db.commands.generic[info[#info]] = value
                            end
                        },
                        excludeByQuestId = {
                            order = 4,
                            name = L["Enable |cff888888/reckless exclude <questID>|r"],
                            desc = L["This command excludes a quest that matches the provided questID from group abandons."],
                            descStyle = "inline",
                            width = "full",
                            type = "toggle",
                            get = function(info)
                                return E.db.commands.generic[info[#info]]
                            end,
                            set = function(info, value)
                                E.db.commands.generic[info[#info]] = value
                            end
                        },
                        includeByQuestId = {
                            order = 5,
                            name = L["Enable |cff888888/reckless include <questID>|r"],
                            desc = L["This command includes a quest that matches the provided questID in group abandons."],
                            descStyle = "inline",
                            width = "full",
                            type = "toggle",
                            get = function(info)
                                return E.db.commands.generic[info[#info]]
                            end,
                            set = function(info, value)
                                E.db.commands.generic[info[#info]] = value
                            end
                        }
                    }
                }
            }
        },
        debug = {
            order = 4,
            type = "group",
            name = L["Debugging"],
            args = {
                debuggingHeader = {
                    order = 0,
                    type = "header",
                    name = L["Debug Settings"]
                },
                debugLogging = {
                    order = 1,
                    name = L["Enable Debugging"],
                    desc = L["Print debugging statements when this is enabled.\n\n|cFF00D1FFNote:|r You can also toggle this quickly via |cff888888/reckless debug|r"],
                    type = "toggle",
                    get = function(info)
                        return E.db.debugging[info[#info]]
                    end,
                    set = function(info, value)
                        E.db.debugging[info[#info]] = value
                    end
                }
            }
        }
    }
}
