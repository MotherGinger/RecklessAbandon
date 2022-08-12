local E, L = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

----------------------------------------------------------------
----------------------- Commands -------------------------------
----------------------------------------------------------------

function E:CliToggleDebugging()
    self.db.debugging.debugLogging = not self.db.debugging.debugLogging
    self:Info(self.db.debugging.debugLogging and L["Debugging is now on."] or L["Debugging is now off."])
end

function E:CliListAllQuests()
    if self.db.commands.generic.listAll then
        self:Info("-------------------------------------------")
        self:Info(L["|cFFFF9C00<Zone Header>|r"])
        self:Info(L["    |cFFF2E699<Title>|r - |cFFB5FFEB<QuestID>|r"])
        self:Info("-------------------------------------------")
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(i)
            -- * Some quest headers still exist in your quest log, but have no children and are not hidden
            -- * These are usually event quests that trigger when entering the zone
            -- * These will still be printed, but without any quests underneath them
            -- * It might be possible to filter these out by checking for two consecutive headers
            if not info.isHidden then
                if info.isHeader then
                    self:Info("|cFFFF9C00" .. info.title .. "|r")
                else
                    self:Info("    |cFFF2E699" .. info.title .. "|r" .. " - " .. "|cFFB5FFEB" .. info.questID .. "|r")
                end
            end
        end
    end
end

function E:CliAbandonAllQuests()
    if self.db.commands.generic.abandonAll then
        if self.db.general.confirmGroup then
            StaticPopup_Show("RECKLESS_ABANDON_ALL_CONFIRMATION")
        else
            self:AbandonAllQuests()
        end
    else
        self:Warn(L["Abandoning all quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"])
    end
end

function E:CliAbandonQuestById(questId)
    if self.db.commands.generic.abandonByQuestId then
        local index = C_QuestLog.GetLogIndexForQuestID(questId)
        if index ~= nil then
            if self.db.general.confirmIndividual then
                local title = C_QuestLog.GetInfo(index).title
                local dialog = StaticPopup_Show("RECKLESS_ABANDON_CONFIRMATION", title)
                if dialog then
                    dialog.data = {
                        questId = questId
                    }
                end
            else
                self:AbandonQuest(questId)
            end
        else
            self:Error(format(L["Unable to abandon quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."], questId))
        end
    else
        self:Warn(L["Abandoning quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"])
    end
end

function E:CliAbandonByQualifier(qualifier)
    local qualifiers = self:GetAvailableQualifiers()

    self:Debug(format(L["Abandon invoked with qualifier '%s'"], qualifier))
    self:Debug(format(L["Available Qualifiers:%s"], self:Tabulate(qualifiers, " %s")))

    if self.db.commands.generic.abandonByQualifier then
        local questIds = {}
        local questTitles = {}
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(i)

            if not info.isHeader and not info.isHidden then
                local levelDiff = info.level - E.mylevel
                local color
                if levelDiff >= 5 then
                    color = L["red"]
                elseif levelDiff >= 3 then
                    color = L["orange"]
                elseif levelDiff >= -2 then
                    color = L["yellow"]
                elseif -levelDiff <= UnitQuestTrivialLevelRange("player") then
                    color = L["green"]
                else
                    color = L["gray"]
                end

                local isDaily = qualifier == L["daily"] and info.frequency == 1
                local isWeekly = qualifier == L["weekly"] and info.frequency == 2

                if (qualifier == color or isDaily or isWeekly) and qualifiers[qualifier] ~= nil then
                    tinsert(questIds, info.questID)
                    tinsert(questTitles, info.title)
                end
            end
        end

        if #questIds > 0 then
            local dialog = StaticPopup_Show("RECKLESS_QUALIFIER_ABANDON_CONFIRMATION", qualifier, table.concat(questTitles, "\n"))
            if dialog then
                dialog.data = {
                    questIds = questIds
                }
            end
        else
            self:Error(format(L["|cFF808080There are no quests that match the qualifier '%s'.|r"], qualifier))
        end
    else
        self:Warn(L["Abandoning quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"])
    end
end

function E:CliExcludeQuestById(questId)
    if self.db.commands.generic.excludeByQuestId then
        local index = C_QuestLog.GetLogIndexForQuestID(questId)
        if index ~= nil then
            if not self:IsExcluded(questId) then
                self:ExcludeQuest(questId)
            else
                self:Warn(format(L["%s is already excluded from group abandons!"], GetQuestLink(questId)))
            end
        else
            self:Error(format(L["Unable to exclude quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."], questId))
        end
    else
        self:Warn(L["Excluding quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"])
    end
end

function E:CliIncludeQuestById(questId)
    if self.db.commands.generic.includeByQuestId then
        local index = C_QuestLog.GetLogIndexForQuestID(questId)
        if index ~= nil then
            if self:IsExcluded(questId) then
                self:IncludeQuest(questId)
            else
                self:Warn(format(L["%s is already included in group abandons!"], GetQuestLink(questId)))
            end
        else
            self:Error(format(L["Unable to include quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."], questId))
        end
    else
        self:Warn(L["Including quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"])
    end
end
