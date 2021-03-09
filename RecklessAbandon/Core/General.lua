local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local format = format

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
                space1 = {
                    order = 2,
                    type = "description",
                    name = ""
                },
                confirmIndividual = {
                    order = 3,
                    name = L["Confirm individual abandon"],
                    desc = L["Prompt for confirmation when abandoning individual quests.\n\n|cFFFF6B6BCaution: Turning this off means a quest will be abandoned instantly. Be careful!|r"],
                    type = "toggle",
                    get = function(info)
                        return E.db.general.confirmIndividual
                    end,
                    set = function(info, value)
                        E.db.general.confirmIndividual = value
                    end
                },
                confirmGroup = {
                    order = 4,
                    name = L["Confirm group abandon"],
                    desc = L["Prompt for confirmation when abandoning multiple quests.\n\n|cFFFF6B6BCaution: Turning this off means a group of quests will be abandoned instantly. Be careful!|r"],
                    type = "toggle",
                    get = function(info)
                        return E.db.general.confirmGroup
                    end,
                    set = function(info, value)
                        E.db.general.confirmGroup = value
                    end
                },
                individualQuests = {
                    order = 5,
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
                        }
                    }
                },
                zoneQuests = {
                    order = 6,
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
                        }
                    }
                },
                campaignQuests = {
                    order = 7,
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
                    order = 8,
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
        exclusions = {
            order = 1,
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
                    name = function()
                        if (E:IsEmpty(E.private.exclusions.excludedQuests)) then
                            return L["|cFF808080There are currently no quests being excluded.|r"]
                        end

                        local exclusions = format("|cFFF2E699%s|r | %s\n--------------------", L["QuestID"], L["Title"])
                        local titleFormat = "\n|cFFF2E699%s|r    | %s"
                        local orphanTitleFormat = "\n|cFFF2E699%s|r    | |cFFFF6B6B%s|r"
                        for questId, title in pairs(E.private.exclusions.excludedQuests) do
                            local orphaned = C_QuestLog.GetLogIndexForQuestID(questId) == nil
                            exclusions = exclusions .. format(orphaned and orphanTitleFormat or titleFormat, questId, title)
                        end
                        return exclusions
                    end
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
                    desc = L["Automatically prune quests from the exclusion list when they are abandoned.\n\n|cFF00D1FFNote:|r This does not retroactively prune quests that have already been abandoned, but are still in the exclusion list.\n\nUse the 'Prune Exclusion List' button below to do this manually."],
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
                    desc = L["Quests that appear in |cFFFF6B6Bred|r are no longer detected in your quest log.\n\nYou can prune them by clicking this button, or leave them and they will be excluded again the next time they are picked up."],
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
            order = 2,
            type = "group",
            name = L["Commands"],
            args = {
                commandsHeader = {
                    order = 0,
                    type = "header",
                    name = L["Slash Commands"]
                },
                abandonAll = {
                    order = 1,
                    name = L["Enable |cff888888/reckless abandon all|r"],
                    desc = L["|cFFFFF569Warning:|r This command abandons all quests in your quest log, use it wisely."],
                    descStyle = "inline",
                    width = "full",
                    type = "toggle",
                    get = function(info)
                        return E.db.commands[info[#info]]
                    end,
                    set = function(info, value)
                        E.db.commands[info[#info]] = value
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
                        return E.db.commands[info[#info]]
                    end,
                    set = function(info, value)
                        E.db.commands[info[#info]] = value
                    end
                },
                excludeByQuestId = {
                    order = 3,
                    name = L["Enable |cff888888/reckless exclude <questID>|r"],
                    desc = L["This command excludes a quest that matches the provided questID from group abandons."],
                    descStyle = "inline",
                    width = "full",
                    type = "toggle",
                    get = function(info)
                        return E.db.commands[info[#info]]
                    end,
                    set = function(info, value)
                        E.db.commands[info[#info]] = value
                    end
                },
                includeByQuestId = {
                    order = 4,
                    name = L["Enable |cff888888/reckless include <questID>|r"],
                    desc = L["This command includes a quest that matches the provided questID in group abandons."],
                    descStyle = "inline",
                    width = "full",
                    type = "toggle",
                    get = function(info)
                        return E.db.commands[info[#info]]
                    end,
                    set = function(info, value)
                        E.db.commands[info[#info]] = value
                    end
                }
            }
        },
        debug = {
            order = 3,
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
                    desc = L["Print debugging statements when this is enabled"],
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
