local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

E.classColors = {
    mage = "cFF3FC7EB",
    warrior = "cFFC69B6D",
    paladin = "cFFF48CBA",
    hunter = "cFFABD473"
}

function E:ColorFormat(color, str)
    return format("|%s%s|r", color, str)
end
