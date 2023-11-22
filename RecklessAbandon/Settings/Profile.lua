local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

P.general = {
    loginMessage = true,
    logLevel = 4,
    confirmIndividual = false,
    confirmGroup = true,
    individualQuests = {
        showAbandonButton = true,
        completeProtection = true,
        abandonBinding = "ALT-BUTTON1",
        excludeBinding = "ALT-BUTTON2"
    },
    zoneQuests = {
        showAbandonButton = true,
        abandonBinding = "ALT-BUTTON1"
    },
    campaignQuests = {
        showAbandonButton = true
    },
    covenantCallings = {
        showAbandonButton = false
    }
}

P.commands = {
    generic = {
        ["*"] = false
    }
}

P.debugging = {
    debugLogging = false
}
