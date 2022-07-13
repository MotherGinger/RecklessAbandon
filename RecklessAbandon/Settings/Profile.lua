local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

P.general = {
    loginMessage = true,
    logLevel = LOG_LEVEL_VERBOSE,
    confirmIndividual = false,
    confirmGroup = true,
    individualQuests = {
        showAbandonButton = true,
        completeProtection = true
    },
    zoneQuests = {
        showAbandonButton = true
    },
    campaignQuests = {
        showAbandonButton = true
    },
    covenantCallings = {
        showAbandonButton = false
    }
}

P.commands = {
    ["*"] = false
}

P.debugging = {
    debugLogging = false
}
