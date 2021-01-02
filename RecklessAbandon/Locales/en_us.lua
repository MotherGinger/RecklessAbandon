-- English localization file for enUS and enGB.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("RecklessAbandon", "enUS", true, true)
if not L then
    return
end

L["Version"] = true
L["Configuration"] = true
L["Description"] = "A tool for quickly (and recklessly) abandoning quests"

L["Enable"] = true
L["Enable/Disable Reckless Abandon"] = true

L["Yes"] = true
L["No"] = true

L["Are you sure you want to abandon all quests in %s? This cannot be undone."] = true
L["Are you sure you want to abandon %s?. This cannot be undone."] = true
L["Are you sure you want to abandon all of the quests in your questlog?. This cannot be undone."] = true

L["Abandon '%s'"] = true
L["Abandon all '%s' quests"] = true

L["covenant callings"] = true
L["Abandon all covenant calling quests"] = true

L["|cFFFFFF00Abandoned quest '%s'|r"] = true
L["|cFFFFFF00You can't abandon '%s'|r"] = true

L["General"] = true
L["General Settings"] = true
L["Debugging"] = true
L["Commands"] = true

L["Slash Commands"] = true
L["Enable |cff888888/reckless abandonall|r"] = true
L["|cFFFFF569Warning:|r This command abandons all quests in your quest log, use it wisely."] = true

L["|cffffcc00%s Debug:|r"] = true
L["Debug Settings"] = true
L["Enable Debugging"] = true
L["Print debugging statements when this is enabled"] = true

L["Confirm individual abandon"] = true
L["Prompt for confirmation when abandoning individual quests.\n\n|cFFFF6B6BCaution: Turning this off means a quest will be abandoned instantly. Be careful!|r"] = true
L["Confirm group abandon"] = true
L["Prompt for confirmation when abandoning multiple quests.\n\n|cFFFF6B6BCaution: Turning this off means a group of quests will be abandoned instantly. Be careful!|r"] = true

L["Profiles"] = true
L["Reset Profile"] = true
L["|cFFFF6B6BCaution: This will reset all of your settings.|r\n\nThis can often times fix issues. Use at your own risk."] = true

L["About"] = true
L["Testers"] = true
L["Written by |T626001:0|t |cFF3FC7EB%s|r"] = true
L["Please report any bugs on our issue board:"] = true
