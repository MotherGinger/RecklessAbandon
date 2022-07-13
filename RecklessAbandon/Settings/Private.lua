local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

V.general = {
    autoAbandonQuests = {
        ["*"] = false
    }
}

V.exclusions = {
    excludedQuests = {},
    autoPrune = true
}
