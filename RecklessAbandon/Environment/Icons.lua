local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

E.classIcons = {
    death_knight = (not E.isClassic and not E.isBCC) and "|T135771:0|t" or "",
    demon_hunter = E.isRetail and "|T236415:0|t" or "",
    druid = "|T625999:0|t",
    evoker = E.isRetail and "|T4574311:0|t" or "",
    hunter = "|T626000:0|t",
    mage = "|T626001:0|t",
    monk = E.isRetail and "T|626002:0|t" or "",
    paladin = "|T626003:0|t",
    priest = "|T626004:0|t",
    rogue = "|T626005:0|t",
    shaman = "|T626006:0|t",
    warlock = "|T626007:0|t",
    warrior = "|T626008:0|t",
}
