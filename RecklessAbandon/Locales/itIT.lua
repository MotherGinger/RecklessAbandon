-- Italian localization file for enUS and enGB.
local E = unpack(RecklessAbandon) -- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("RecklessAbandon", "itIT")

if not L then
    return
end

L["Version"] = "Versione"
L["Configuration"] = "Configurazione"
L["Description"] = "Uno strumento per abbandonare rapidamente (e imprudentemente) missioni"

L["You are currently running a pre-release version of %s. Please report any issues on github (|cFFB5FFEB%s|r) so they can be addressed quickly. Thank you for your interest in testing new features!"] = "Stai attualmente utilizzando una versione pre-release di %s. Si prega di segnalare eventuali problemi su GitHub (|cFFB5FFEB%s|r) in modo che possano essere risolti rapidamente. Grazie per il tuo interesse nel testare nuove funzionalità!"

L["Enable"] = "Abilita"
L["Enable/Disable Reckless Abandon"] = "Abilita/Disabilita Reckless Abandon"

L["Yes"] = "Sì"
L["No"] = "No"

L["|cFFFF6B6BThis cannot be undone.|r"] = "|cFFFF6B6BQuesta azione non può essere annullata.|r"
L["Are you sure you want to abandon all quests in |cFFF2E699%s|r?"] = "Sei sicuro di voler abbandonare tutte le missioni in |cFFF2E699%s|r?"
L["Are you sure you want to abandon |cFFF2E699%s|r?"] = "Sei sicuro di voler abbandonare |cFFF2E699%s|r?"
L["Are you sure you want to abandon all of the quests in your questlog?"] = "Sei sicuro di voler abbandonare tutte le missioni nel tuo registro missioni?"
L["Are you sure you want to abandon the following %s quests?"] = "Sei sicuro di voler abbandonare le seguenti missioni %s?"

L["Only show messages for errors"] = "Mostra solo messaggi per gli errori"
L["Only show messages for warnings and errors"] = "Mostra solo messaggi per gli avvisi e gli errori"
L["Only show important messages"] = "Mostra solo messaggi importanti"
L["Show all messages (default)"] = "Mostra tutti i messaggi (predefinito)"

L["Left Click: Abandon quest"] = "Clic sinistro: Abbandona missione"
L["Right Click: Exclude quest from group abandons"] = "Clic destro: Escludi missione dagli abbandoni di gruppo"
L["Right Click: Include quest in group abandons"] = "Clic destro: Includi missione negli abbandoni di gruppo"
L["Left Click: Abandon all quests"] = "Clic sinistro: Abbandona tutte le missioni"

L["covenant callings"] = "chiamate del patto"
L["Left Click: Abandon all covenant calling quests"] = "Clic sinistro: Abbandona tutte le missioni delle chiamate del patto"

L["|cFFFF9C00<Zone Header>|r"] = "|cFFFF9C00<Intestazione zona>|r"
L["    |cFFF2E699<Titolo>|r - |cFFB5FFEB<QuestID>|r"] = "    |cFFF2E699<Titolo>|r - |cFFB5FFEB<QuestID>|r"

L["General"] = "Generale"
L["General Settings"] = "Impostazioni generali"
L["Debugging"] = "Debugging"
L["Commands"] = "Comandi"

L["Individual Quests"] = "Missioni individuali"
L["Zone Quests"] = "Missioni di zona"
L["Campaign Quests"] = "Missioni di campagna"
L["Covenant Callings"] = "Chiamate del patto"
L["Keybindings"] = "Assegnazioni tasti"

L["Show login message"] = "Mostra messaggio di accesso"
L["Messaging Rate"] = "Frequenza messaggi"
L["Adjust the amount of messages you will receive from actions taken against your quest log."] = "Regola la quantità di messaggi che riceverai dalle azioni eseguite nel tuo registro missioni."
L["|cFF00D1FFNote:|r You will always be notified when a quest is abandoned on your behalf."] = "|cFF00D1FFNota:|r Sarai sempre avvisato quando una missione viene abbandonata per tuo conto."
L["Show Abandon Button"] = "Mostra pulsante Abbandona"
L["Show Group Abandon Button"] = "Mostra pulsante Abbandona di gruppo"
L["Complete Protection"] = "Protezione Completa"
L["Automatically exclude completed quests from group abandons and automation options."] = "Escludi automaticamente le missioni completate dagli abbandoni di gruppo e dalle opzioni di automazione."
L["Show an abandon button for individual quests."] = "Mostra un pulsante Abbandona per le missioni singole."
L["Abandon Quest"] = "Abbandona missione"
L["Use this keybinding on a quest in your quest log to abandon it."] = "Usa questa assegnazione del tasto su una missione nel tuo registro missioni per abbandonarla."
L["Exclude/Include Quest"] = "Escludi/Includi Missione"
L["Use this keybinding on a quest in your quest log to toggle exclusion from group abandons."] = "Usa questa scorciatoia su una missione nel tuo registro missioni per alternare l'esclusione dagli abbandoni di gruppo."
L["Show a group abandon button for zone quests."] = "Mostra un pulsante Abbandona di gruppo per le missioni di zona."
L["Abandon Quests"] = "Abbandona missioni"
L["Use this keybinding on a zone header in your quest log to abandon all quests for that zone that are included in group abandons."] = "Usa questa assegnazione del tasto su un'intestazione di zona nel tuo registro missioni per abbandonare tutte le missioni di quella zona che sono incluse negli abbandoni di gruppo."
L["Are you sure you want to bind %s?"] = "Sei sicuro di voler associare %s?"
L["|cFFFF6B6BCaution: This can cause you to accidentally abandon a quest when trying to select a quest in your quest log.|r"] = "|cFFFF6B6BAvviso: Questo può farti abbandonare accidentalmente una missione quando cerchi di selezionare una missione nel tuo registro missioni.|r"
L["|cFFFF6B6BCaution: This can cause you to accidentally abandon a quest when trying to track a quest in your quest log.|r"] = "|cFFFF6B6BAvviso: Questo può farti abbandonare accidentalmente una missione quando cerchi di seguire una missione nel tuo registro missioni.|r"
L["|cFFFF6B6BCaution: This can cause you to accidently toggle exclusion of a quest from group abandons when trying to select a quest in your quest log.|r"] = "|cFFFF6B6BAttenzione: Questo può farti accidentalmente alternare l'esclusione di una missione dagli abbandoni di gruppo quando cerchi di selezionare una missione nel tuo registro missioni.|r"
L["|cFFFF6B6BCaution: This can cause you to accidently toggle exclusion of a quest from group abandons when trying to track a quest in your quest log.|r"] = "|cFFFF6B6BAttenzione: Questo può farti accidentalmente alternare l'esclusione di una missione dagli abbandoni di gruppo quando cerchi di tracciare una missione nel tuo registro missioni.|r"
L["|cFFFF6B6BCaution: This can cause you to accidentally abandon all quests in a zone when trying to expand a zone header in your quest log.|r"] = "|cFFFF6B6BAvviso: Questo può farti abbandonare accidentalmente tutte le missioni di una zona quando cerchi di espandere un'intestazione di zona nel tuo registro missioni.|r"
L["Show a group abandon button for campaign quests."] = "Mostra un pulsante Abbandona di gruppo per le missioni di campagna."
L["Show a group abandon button for covenant callings."] = "Mostra un pulsante Abbandona di gruppo per le chiamate del patto."
L["|cFF00D1FFNote:|r Blizzard currently does not allow covenant callings to be abandoned. This button will be disabled if shown."] = "|cFF00D1FFNota:|r Attualmente Blizzard non consente di abbandonare le chiamate del patto. Questo pulsante sarà disabilitato se mostrato."

L["Confirm individual abandons"] = "Conferma abbandoni individuali"
L["Prompt for confirmation when abandoning individual quests."] = "Richiedi conferma quando abbandoni missioni individuali."
L["|cFFFF6B6BCaution: Turning this off means a quest will be abandoned instantly. Be careful!|r"] = "|cFFFF6B6BAvviso: Disabilitare questa opzione significa che una missione verrà abbandonata istantaneamente. Fai attenzione!|r"
L["Confirm group abandons"] = "Conferma abbandoni di gruppo"
L["Prompt for confirmation when abandoning multiple quests."] = "Richiedi conferma quando abbandoni più missioni."
L["|cFFFF6B6BCaution: Turning this off means a group of quests will be abandoned instantly. Be careful!|r"] = "|cFFFF6B6BAvviso: Disabilitare questa opzione significa che un gruppo di missioni verrà abbandonato istantaneamente. Fai attenzione!|r"

L["Automation Options"] = "Opzioni di automazione"
L["These options will act upon your quest log automatically. This can save you time; however, care should be taken when using them."] = "Queste opzioni agiranno automaticamente sul tuo registro missioni. Questo può risparmiarti tempo; tuttavia, devi fare attenzione quando li usi."
L["|cFF00D1FFNote:|r Each character has their own automation options."] = "|cFF00D1FFNota:|r Ogni personaggio ha le proprie opzioni di automazione."
L["Abandon Quests"] = "Abbandona missioni"
L["Quest Type"] = "Tipo di missione"
L["Automatically abandon quests of the given type if they are included in group abandons."] = "Abbandona automaticamente le missioni del tipo specificato se sono incluse negli abbandoni di gruppo."
L["|cFFFF6B6BCaution:|r These quests will be abandoned for you; confirmation settings will be ignored."] = "|cFFFF6B6BAvviso:|r Queste missioni verranno abbandonate per te; le impostazioni di conferma verranno ignorate."
L["Automatically abandoned %s |4quest:quests;!"] = "%s abbandonate automaticamente |4missione:missioni;!"
L["Green"] = "Verde"
L["Yellow"] = "Giallo"
L["Orange"] = "Arancione"
L["Red"] = "Rosso"
L["Gray"] = "Grigio"
L["Quest IDs"] = "ID missioni"
L["Enter quest IDs separated by a comma. These quests will be abandoned automatically if they are included in group abandons."] = "Inserisci gli ID delle missioni separati da una virgola. Queste missioni verranno abbandonate automaticamente se sono incluse negli abbandoni di gruppo."

L["Slash Commands"] = "Comandi slash"
L["|cFF00D1FFNote:|r The token |cff888888reckless|r can be replaced by |cff888888rab|r for all commands."] = "|cFF00D1FFNota:|r Il token |cff888888reckless|r può essere sostituito con |cff888888rab|r per tutti i comandi."
L["Enable |cff888888/reckless list all|r"] = "Abilita |cff888888/reckless list all|r"
L["This command lists all quests in a table."] = "Questo comando elenca tutte le missioni in una tabella."
L["Enable |cff888888/reckless abandon all|r"] = "Abilita |cff888888/reckless abandon all|r"
L["|cFFFFF569Warning:|r This command abandons all quests in your quest log that are not excluded from group abandons, use it wisely."] = "|cFFFFF569Avviso:|r Questo comando abbandona tutte le missioni nel tuo registro missioni che non sono escluse dagli abbandoni di gruppo, usalo saggiamente."
L["Enable |cff888888/reckless abandon <questID>|r"] = "Abilita |cff888888/reckless abandon <questID>|r"
L["This command abandons a quest that matches the provided questID."] = "Questo comando abbandona una missione che corrisponde all'ID della missione fornito."
L["Enable |cff888888/reckless exclude <questID>|r"] = "Abilita |cff888888/reckless exclude <questID>|r"
L["This command excludes a quest that matches the provided questID from group abandons."] = "Questo comando esclude una missione che corrisponde all'ID della missione fornito dagli abbandoni di gruppo."
L["Enable |cff888888/reckless include <questID>|r"] = "Abilita |cff888888/reckless include <questID>|r"
L["This command includes a quest that matches the provided questID in group abandons."] = "Questo comando include una missione che corrisponde all'ID della missione fornito negli abbandoni di gruppo."
L["Enable |cff888888/reckless abandon <qualifier>|r"] = "Abilita |cff888888/reckless abandon <qualificatore>|r"
L["This command abandons all quests that match a given qualifier and are not excluded from group abandons."] = "Questo comando abbandona tutte le missioni che corrispondono a un dato qualificatore e non sono escluse dagli abbandoni di gruppo."

L["Available Qualifiers:"] = "Qualificatori disponibili:"

L["Matches all daily quests."] = "Corrisponde a tutte le missioni giornaliere."
L["Matches all failed quests."] = "Corrisponde a tutte le missioni fallite."
L["Matches all dungeon quests."] = "Corrisponde a tutte le missioni in dungeon."
L["Matches all raid quests."] = "Corrisponde a tutte le missioni in incursione."
L["Matches all group quests."] = "Corrisponde a tutte le missioni di gruppo."
L["Matches all heroic quests."] = "Corrisponde a tutte le missioni eroiche."
L["Matches all elite quests."] = "Corrisponde a tutte le missioni elite."
L["Matches all pvp quests."] = "Corrisponde a tutte le missioni PvP."
L["Matches all weekly quests."] = "Corrisponde a tutte le missioni settimanali."
L["gray"] = "Grigia"
L["Matches all gray quests."] = "Corrisponde a tutte le missioni grigie."
L["green"] = "Verde"
L["Matches all green quests."] = "Corrisponde a tutte le missioni verdi."
L["yellow"] = "Gialla"
L["Matches all yellow quests."] = "Corrisponde a tutte le missioni gialle."
L["orange"] = "Arancione"
L["Matches all orange quests."] = "Corrisponde a tutte le missioni arancioni."
L["red"] = "Rossa"
L["Matches all red quests."] = "Corrisponde a tutte le missioni rosse."

L["Generic"] = "Generica"

L["|cffffcc00%s Debug:|r"] = "|cffffcc00%s Debug:|r"
L["Debug Settings"] = "Impostazioni di Debug"
L["Enable Debugging"] = "Abilita Debug"
L["Print debugging statements when this is enabled."] = "Stampa dichiarazioni di debug quando questa opzione è abilitata."
L["|cFF00D1FFNote:|r You can also toggle this quickly via |cff888888/reckless debug|r"] = "|cFF00D1FFNota:|r Puoi attivare o disattivare rapidamente questa opzione anche tramite |cff888888/reckless debug|r."

L["Exclusions"] = "Esclusioni"
L["Quest Exclusion List"] = "Lista di Esclusioni Missioni"
L["Prune Exclusion List"] = "Pulisci Lista di Esclusioni"
L["Clear Exclusion List"] = "Cancella Lista di Esclusioni"
L["The quest exclusion list allows you to exclude quests from group abandons. To use it, simply right click a quest abandon button in the quest log."] = "La lista di esclusione delle missioni consente di escludere missioni dagli abbandoni di gruppo. Per usarla, basta fare clic destro su un pulsante di abbandono missione nel registro missioni."
L["|cFF00D1FFNote:|r Each character has their own exclusion list."] = "|cFF00D1FFNota:|r Ogni personaggio ha la propria lista di esclusione."
L["Quests that appear in |cFFFF6B6Bred|r are no longer detected in your quest log."] = "Le missioni che appaiono in |cFFFF6B6Brosso|r non vengono più rilevate nel tuo registro missioni."
L["You can prune them by clicking this button, or leave them and they will be excluded again the next time they are picked up."] = "Puoi eliminarle facendo clic su questo pulsante, oppure lasciale e saranno nuovamente escluse la prossima volta che le prendi."
L["|cFF808080There are currently no quests being excluded.|r"] = "|cFF808080Attualmente non ci sono missioni escluse.|r"
L["Pruning '%s' from the exclusion list"] = "Eliminazione di '%s' dalla lista di esclusione"
L["Pruned %s |4orphan:orfani;!"] = "Eliminate %s |4orphan:orfani;!"
L["Pruned %s |4orphan:orfani; from source '%s'!"] = "Eliminate %s |4orphan:orfani; dalla fonte '%s'!"
L["Clear the exclusion list by including quests that are still in your quest log and pruning those that aren't."] = "Cancella la lista di esclusione includendo le missioni che sono ancora nel tuo registro missioni e eliminando quelle che non lo sono."
L["Automatic Pruning"] = "Pulizia Automatica"
L["Automatically prune quests from the exclusion list when they are abandoned, or when they are no longer in your quest log and were excluded via automation."] = "Elimina automaticamente le missioni dalla lista di esclusione quando vengono abbandonate, o quando non sono più nel tuo registro missioni e sono state escluse tramite automazione."
L["|cFF00D1FFNote:|r This does not retroactively prune quests that have already been abandoned, but are still in the exclusion list."] = "|cFF00D1FFNota:|r Questo non elimina retroattivamente le missioni che sono già state abbandonate, ma che sono ancora nella lista di esclusione."
L["Use the 'Prune Exclusion List' button below to do this manually."] = "Usa il pulsante 'Pulisci Lista di Esclusioni' qui sotto per farlo manualmente."
L["Unable to prune quests from the exclusion list from source '%s'"] = "Impossibile eliminare le missioni dalla lista di esclusione dalla fonte '%s'"

L["About"] = "Informazioni"
L["Testers"] = "Tester"
L["Written by %s%s%s%s %s"] = "Scritto da %s%s%s%s %s"
L["Please report any bugs or request features on our issue board:"] = "Segnala eventuali bug o richieste di funzionalità sulla nostra bacheca delle segnalazioni:"

L["|cFFFFFF00Abandoned quest %s|r"] = "|cFFFFFF00Missione abbandonata %s|r"
L["|cFFFFFF00You can't abandon %s|r"] = "|cFFFFFF00Non puoi abbandonare %s|r"

L["Skipping %s since it is excluded from group abandons"] = "Ignorando %s poiché è escluso dagli abbandoni di gruppo"
L["Excluding quest %s from group abandons"] = "Esclusione missione %s dagli abbandoni di gruppo"
L["Including quest %s in group abandons"] = "Inclusione missione %s negli abbandoni di gruppo"

L["QuestID"] = "ID Missione"
L["Title"] = "Titolo"
L["Source"] = "Fonte"
L["Manual"] = "Manuale"
L["Automation"] = "Automazione"

L["Abandoning all quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"] = "L'abbandono di tutte le missioni da riga di comando è attualmente |cFFFF6B6Bdisabilitato|r. Puoi abilitarlo nelle impostazioni di configurazione |cff888888/reckless config|r"

L["Abandoning quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"] = "L'abbandono di missioni da riga di comando è attualmente |cFFFF6B6Bdisabilitato|r. Puoi abilitarlo nelle impostazioni di configurazione |cff888888/reckless config|r"
L["Unable to abandon quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."] = "Impossibile abbandonare la missione, '%s' non è riconosciuta. La missione potrebbe non essere nel tuo registro missioni o potresti aver inserito l'ID errato."

L["Excluding quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"] = "L'esclusione di missioni da riga di comando è attualmente |cFFFF6B6Bdisabilitata|r. Puoi abilitarla nelle impostazioni di configurazione |cff888888/reckless config|r"
L["Unable to exclude quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."] = "Impossibile escludere la missione, '%s' non è riconosciuta. La missione potrebbe non essere nel tuo registro missioni o potresti aver inserito l'ID errato."
L["%s is already excluded from group abandons!"] = "%s è già escluso dagli abbandoni di gruppo!"

L["Including quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"] = "L'inclusione di missioni da riga di comando è attualmente |cFFFF6B6Bdisabilitata|r. Puoi abilitarla nelle impostazioni di configurazione |cff888888/reckless config|r"
L["Unable to include quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."] = "Impossibile includere la missione, '%s' non è riconosciuta. La missione potrebbe non essere nel tuo registro missioni o potresti aver inserito l'ID errato."
L["%s is alr1eady included in group abandons!"] = "%s è già incluso negli abbandoni di gruppo!"

L["You are running |cFFB5FFEBv%s|r. Type |cff888888/reckless config|r to configure settings."] = "Stai utilizzando la versione |cFFB5FFEBv%s|r. Digita |cff888888/reckless config|r per configurare le impostazioni."

L["Abandon invoked with qualifier '%s'"] = "Abbandono invocato con qualificatore '%s'"
L["Available Qualifiers:%s"] = "Qualificatori disponibili:%s"
L["|cFF808080There are no quests that match the qualifier '%s'.|r"] = "|cFF808080Non ci sono missioni che corrispondono al qualificatore '%s'.|r"

L["Debugging is now on."] = "Il debug è ora attivato."
L["Debugging is now off."] = "Il debug è ora disattivato."
L["Auto Abandon: "] = "Auto Abbandono: "
L["%s leveled up (%d -> %d)!"] = "%s ha livellato su (%d -> %d)!"
L["Quest Table: "] = "Tabella Missioni: "
L["Excluded Quests: "] = "Missioni Escluse: "

L["%s abandoned via keybinding (%s)"] = "%s abbandonato tramite scorciatoia (%s)"
L["%s excluded via keybinding (%s)"] = "%s escluso tramite scorciatoia (%s)"
L["%s included via keybinding (%s)"] = "%s incluso tramite scorciatoia (%s)"
