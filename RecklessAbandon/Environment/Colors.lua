local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

E.classColors = {
    death_knight = (not E.isClassic and not E.isBC) and { hex = "cFFC41E3A", rgb = { 196, 30, 58 } } or {},
    demon_hunter = { hex = "cFFA330C9", rgb = { 163, 48, 201 } },
    druid = { hex = "cFFFF7C0A", rgb = { 255, 124, 10 } },
    evoker = E.isRetail and { hex = "cFF33937F", rgb = { 51, 147, 127 } } or {},
    hunter = { hex = "cFFAAD372", rgb = { 170, 211, 114 } },
    mage = { hex = "cFF3FC7EB", rgb = { 63, 199, 235 } },
    monk = (E.isRetail or E.isMop) and { hex = "cFF00FF98", rgb = { 0, 255, 152 } } or {},
    paladin = { hex = "cFFF48CBA", rgb = { 244, 140, 186 } },
    priest = { hex = "cFFFFFFFF", rgb = { 255, 255, 255 } },
    rogue = { hex = "cFFFFF468", rgb = { 255, 244, 104 } },
    shaman = { hex = "cFF0070DD", rgb = { 0, 112, 221 } },
    warlock = { hex = "cFF8788EE", rgb = { 135, 136, 238 } },
    warrior = { hex = "cFFC69B6D", rgb = { 198, 155, 109 } }
}
