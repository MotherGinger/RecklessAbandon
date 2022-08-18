local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

V.automationOptions = {
    autoAbandonQuests = {
        questType = {
            ["*"] = false
        },
        ids = ""
    }
}

V.exclusions = {
    excludedQuests = {},
    autoPrune = true
}
