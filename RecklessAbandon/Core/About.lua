local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

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
            name = format(
                L["Written by %s%s%s%s %s"],
                E.classIcons.paladin,
                E.classIcons.mage,
                E.classIcons.warrior,
                E.classIcons.priest,
                E:FormatGradient(E.author, {
                    E.classColors.paladin.rgb,
                    E.classColors.mage.rgb,
                    E.classColors.warrior.rgb,
                    E.classColors.priest.rgb
                })
            )
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
                    name = format("%s %s", E.classIcons.hunter, E:ColorFormat(E.classColors.hunter.hex, "Rawrsnax"))
                },
                cob = {
                    order = 1,
                    type = "description",
                    name = format(
                        "%s%s%s %s",
                        E.classIcons.hunter,
                        E.classIcons.druid,
                        E.classIcons.evoker,
                        E:FormatGradient("Cob", {
                            E.classColors.hunter.rgb,
                            E.classColors.druid.rgb,
                            E.classColors.evoker.rgb
                        })
                    )
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
        }
    }
}
