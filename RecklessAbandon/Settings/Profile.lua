local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

P.general = {
    confirmIndividual = false,
    confirmGroup = true,
    individualQuests = {
        showAbandonButton = true
    },
    zoneQuests = {
        showAbandonButton = true
    },
    campaignQuests = {
        showAbandonButton = true
    },
    covenantCallings = {
        showAbandonButton = true
    }
}

P.commands = {
    abandonAll = false
}

P.debugging = {
    debugLogging = false
}
