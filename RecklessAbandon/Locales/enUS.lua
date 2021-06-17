-- English localization file for enUS and enGB.
local E = unpack(select(2, ...)) -- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("RecklessAbandon", "enUS", true, true)

L["Version"] = true
L["Configuration"] = true
L["Description"] = "A tool for quickly (and recklessly) abandoning quests"

L["You have installed a version of this addon intended for |cFFFFFAB8%s|r, however you are currently playing |cFFFFFAB8%s|r. You may encounter serious issues with this setup. Please install the proper version from Github, CurseForge, or WoWInterface, and restart the game."] = true

L["Enable"] = true
L["Enable/Disable Reckless Abandon"] = true

L["Yes"] = true
L["No"] = true

L["Are you sure you want to abandon all quests in |cFFF2E699%s|r?\n\n|cFFFF6B6BThis cannot be undone.|r"] = true
L["Are you sure you want to abandon |cFFF2E699%s|r?\n\n|cFFFF6B6BThis cannot be undone.|r"] = true
L["Are you sure you want to abandon all of the quests in your questlog?\n\n|cFFFF6B6BThis cannot be undone.|r"] = true
L["Are you sure you want to abandon the following %s quests?\n\n|cFFF2E699%s|r\n\n|cFFFF6B6BThis cannot be undone.|r"] = true

L["Left Click: Abandon quest"] = true
L["Right Click: Exclude quest from group abandons"] = true
L["Right Click: Include quest in group abandons"] = true
L["Left Click: Abandon all quests"] = true

L["covenant callings"] = true
L["Left Click: Abandon all covenant calling quests"] = true

L["|cFFFF9C00<Zone Header>|r"] = true
L["    |cFFF2E699<Title>|r - |cFFB5FFEB<QuestID>|r"] = true

L["General"] = true
L["General Settings"] = true
L["Debugging"] = true
L["Commands"] = true

L["Individual Quests"] = true
L["Zone Quests"] = true
L["Campaign Quests"] = true
L["Covenant Callings"] = true

L["Show login message"] = true
L["Show Abandon Button"] = true
L["Show Group Abandon Button"] = true
L["Show an abandon button for individual quests."] = true
L["Show a group abandon button for zone quests."] = true
L["Show a group abandon button for campaign quests."] = true
L["Show a group abandon button for covenant callings."] = true
L["|cFF00D1FFNote:|r Blizzard currently does not allow covenant callings to be abandoned. This button will be disabled if shown."] = true

L["Confirm individual abandons"] = true
L["Prompt for confirmation when abandoning individual quests.\n\n|cFFFF6B6BCaution: Turning this off means a quest will be abandoned instantly. Be careful!|r"] = true
L["Confirm group abandons"] = true
L["Prompt for confirmation when abandoning multiple quests.\n\n|cFFFF6B6BCaution: Turning this off means a group of quests will be abandoned instantly. Be careful!|r"] = true

L["Slash Commands"] = true
L["Enable |cff888888/reckless list all|r"] = true
L["This command lists all quests in a table."] = true
L["Enable |cff888888/reckless abandon all|r"] = true
L["|cFFFFF569Warning:|r This command abandons all quests in your quest log that are not excluded from group abandons, use it wisely."] = true
L["Enable |cff888888/reckless abandon <questID>|r"] = true
L["This command abandons a quest that matches the provided questID."] = true
L["Enable |cff888888/reckless exclude <questID>|r"] = true
L["This command excludes a quest that matches the provided questID from group abandons."] = true
L["Enable |cff888888/reckless include <questID>|r"] = true
L["This command includes a quest that matches the provided questID in group abandons."] = true
L["Enable |cff888888/reckless abandon <qualifier>|r"] = true
L["This command abandons all quests that match a given qualifier and are not excluded from group abandons."] = true

L["Available Qualifiers:"] = true

L["daily"] = true
L["Matches all daily quests."] = true
L["weekly"] = true
L["Matches all weekly quests."] = true
L["dungeon"] = true
L["Matches all dungeon quests."] = true
L["raid"] = true
L["Matches all raid quests."] = true
L["group"] = true
L["Matches all group quests."] = true
L["pvp"] = true
L["Matches all pvp quests."] = true
L["gray"] = true
L["Matches all gray quests."] = true
L["green"] = true
L["Matches all green quests."] = true
L["yellow"] = true
L["Matches all yellow quests."] = true
L["orange"] = true
L["Matches all orange quests."] = true
L["red"] = true
L["Matches all red quests."] = true

L["|cffffcc00%s Debug:|r"] = true
L["Debug Settings"] = true
L["Enable Debugging"] = true
L["Print debugging statements when this is enabled"] = true

L["Exclusions"] = true
L["Quest Exclusion List"] = true
L["Prune Exclusion List"] = true
L["Clear Exclusion List"] = true
L["The quest exclusion list allows you to exclude quests from group abandons. To use it, simply right click a quest abandon button in the quest log."] = true
L["|cFF00D1FFNote:|r Each character has their own exclusion list."] = true
L["Quests that appear in |cFFFF6B6Bred|r are no longer detected in your quest log.\n\nYou can prune them by clicking this button, or leave them and they will be excluded again the next time they are picked up."] = true
L["|cFF808080There are currently no quests being excluded.|r"] = true
L["Pruning '%s' from the exclusion list"] = true
L["Pruned %s |4orphan:orphans;!"] = true
L["Clear the exclusion list by including quests that are still in your quest log and pruning those that aren't."] = true
L["Automatic Pruning"] = true
L["Automatically prune quests from the exclusion list when they are abandoned.\n\n|cFF00D1FFNote:|r This does not retroactively prune quests that have already been abandoned, but are still in the exclusion list.\n\nUse the 'Prune Exclusion List' button below to do this manually."] = true

L["About"] = true
L["Testers"] = true
L["Written by |T626001:0|t |cFF3FC7EB%s|r"] = true
L["Please report any bugs or request features on our issue board:"] = true

L["|cFFFFFF00Abandoned quest %s|r"] = true
L["|cFFFFFF00You can't abandon %s|r"] = true

L["Skipping %s since it is excluded from group abandons"] = true
L["Excluding quest %s from group abandons"] = true
L["Including quest %s in group abandons"] = true

L["QuestID"] = true
L["Title"] = true

L["Abandoning all quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"] = true

L["Abandoning quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"] = true
L["Unable to abandon quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."] = true

L["Excluding quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"] = true
L["Unable to exclude quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."] = true
L["%s is already excluded from group abandons!"] = true

L["Including quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"] = true
L["Unable to include quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."] = true
L["%s is alr1eady included in group abandons!"] = true

L["You are running |cFFB5FFEBv%s|r. Type |cff888888/reckless config|r to configure settings."] = true

L["Abandon invoked with qualifier '%s'"] = true
L["Available Qualifiers:%s"] = true
L["|cFF808080There are no quests that match the qualifier '%s'.|r"] = true

L["Debugging is now on."] = true
L["Debugging is now off."] = true
