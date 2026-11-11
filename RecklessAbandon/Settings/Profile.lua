local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

P.general = {
    loginMessage = true,
    logLevel = 3, -- LOG_LEVEL_INFO
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

-- * Integrations/Questie.lua. Does nothing unless QuestieDB is loaded.
P.questie = {
    enabled = true,
    itemProtection = true
}

P.commands = {
    generic = {
        ["*"] = false
    }
}

P.debugging = {
    debugLogging = false
}
