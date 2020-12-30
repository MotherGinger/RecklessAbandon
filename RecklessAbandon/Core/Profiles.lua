local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

E.Options.args.profiles = {
    type = "group",
    name = L["Profiles"],
    order = 1,
    childGroups = "tab",
    get = function(info)
        return E.db[info[#info]]
    end,
    set = function(info, value)
        E.db[info[#info]] = value
    end,
    args = {
        reset = {
            order = 1,
            name = L["Reset Profile"],
            desc = L["|cFFFF6B6BCaution: This will reset all of your settings.|r\n\nThis can often times fix issues. Use at your own risk."],
            type = "execute",
            func = function()
                E:ResetProfile()
            end
        }
    }
}
