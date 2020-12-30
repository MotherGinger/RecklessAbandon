local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

E.Options.args.about = {
    type = "group",
    name = L["About"],
    order = 2,
    childGroups = "tab",
    get = function(info)
        return E.db[info[#info]]
    end,
    set = function(info, value)
        E.db[info[#info]] = value
    end,
    args = {
        author = {
            order = 0,
            type = "description",
            fontSize = "large",
            name = format(L["Written by |T626001:0|t |cFF3FC7EB%s|r"], E.author),
        }
    }
}