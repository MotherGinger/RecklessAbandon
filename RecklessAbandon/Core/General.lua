local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

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
                            name = L["Show Abandon Button"],
                            desc = L["Show an abandon button for zone quests."],
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
                            name = L["Show Abandon Button"],
                            desc = L["Show an abandon button for campaign quests."],
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
                            name = L["Show Abandon Button"],
                            desc = L["Show an abandon button for covenant callings."],
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
        commands = {
            order = 1,
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
            order = 2,
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
