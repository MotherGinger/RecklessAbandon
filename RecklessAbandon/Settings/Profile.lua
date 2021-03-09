local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

P.general = {
    loginMessage = true,
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
        showAbandonButton = false
    }
}

P.commands = {
    abandonAll = false,
    abandonByQuestId = false,
    excludeByQuestId = false,
    includeByQuestId = false
}

P.debugging = {
    debugLogging = false
}
