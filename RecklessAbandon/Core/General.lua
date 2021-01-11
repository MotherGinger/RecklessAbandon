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
                confirmIndividual = {
                    order = 1,
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
                    order = 2,
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
                    order = 3,
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
                    order = 4,
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
                    order = 5,
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
                    order = 6,
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
                    name = L["The quest exclusion list allows you to exclude quests from group abandons. To use it, simply right click a quest abandon button in the quest log.\n\n|cFF00D1FFEach character has their own exclusion list.|r\n\n"]
                },
                excludedQuests = {
                    order = 2,
                    type = "description",
                    name = function()
                        if (E:IsEmpty(E.private.exclusions.excludedQuests)) then
                            return L["|cFF808080There are currently no quests being excluded.|r"]
                        end

                        local exclusions = format("|cFFF2E699%s|r | %s\n--------------------", L["QuestID"], L["Title"])
                        for questId, title in pairs(E.private.exclusions.excludedQuests) do
                            exclusions = exclusions .. format("\n|cFFF2E699%s|r    | %s", questId, title)
                        end
                        return exclusions
                    end
                },
                space1 = {
                    order = 3,
                    type = "description",
                    name = "\n"
                },
                clearExclusions = {
                    order = 4,
                    type = "execute",
                    name = L["Clear Exclusion List"],
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
                    name = L["Enable |cff888888/reckless abandonall|r"],
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
