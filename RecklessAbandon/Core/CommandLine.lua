local E, L = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local _G = _G

----------------------------------------------------------------
----------------------- Commands -------------------------------
----------------------------------------------------------------

function E:CliDump(obj)
    local val = _G[obj]

    if val == nil then
        E:Info(obj)

        return
    end

    if type(val) == "table" then
        E:Info(E:Dump(val))
    else
        E:Info(val)
    end
end

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
        for i = 1, Shim:GetNumQuestLogEntries() do
            local info = Shim:GetInfo(i)
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
        local index = Shim:GetLogIndexForQuestID(questId)
        if index ~= nil then
            if self.db.general.confirmIndividual then
                local info = Shim:GetInfo(index)
                local dialog = StaticPopup_Show("RECKLESS_ABANDON_CONFIRMATION", info.title)
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
        for i = 1, Shim:GetNumQuestLogEntries() do
            local info = Shim:GetInfo(i)

            if not info.isHeader and not info.isHidden then
                local color = self:GetQuestColor(info.level)
                local lowerTag = info.questTag and strlower(info.questTag) or nil

                local isColor = qualifier == color
                local isQualifier = qualifier == lowerTag
                local isFailed = qualifier == strlower(FAILED) and info.isComplete == -1
                local isDaily = qualifier == strlower(DAILY) and info.frequency == 1
                local isWeekly = qualifier == strlower(WEEKLY) and info.frequency == 2

                if (isColor or isQualifier or isFailed or isDaily or isWeekly) and qualifiers[qualifier] ~= nil then
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
        local index = Shim:GetLogIndexForQuestID(questId)
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
        local index = Shim:GetLogIndexForQuestID(questId)
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
