-- Spanish localization file for esMX and esES.
local E = unpack(RecklessAbandon) -- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("RecklessAbandon", "esMX")

if not L then
    return
end

L["Version"] = "Versión"
L["Configuration"] = "Configuración"
L["Description"] = "Una herramienta para abandonar misiones de forma rápida (e imprudente)"

L["You have installed a version of this addon intended for |cFFFFFAB8%s|r, however you are currently playing |cFFFFFAB8%s|r. You may encounter serious issues with this setup. Please install the proper version from Github, CurseForge, Wago, or WoWInterface, and restart the game."] =
    "Ha instalado una versión de este complemento destinada a |cFFFFFAB8%s|r, sin embargo, actualmente está jugando a |cFFFFFAB8%s|r. Puede encontrar problemas graves con esta configuración. Instale la versión adecuada de Github, CurseForge, Wago o WoWInterface y reinicie el juego."
L["You are currently running a pre-release version of %s. Please report any issues on github (|cFFB5FFEB%s|r) so they can be addressed quickly. Thank you for your interest in testing new features!"] = "Actualmente estás usando una versión preliminar de %s. Por favor, informa cualquier problema en GitHub (|cFFB5FFEB%s|r) para que puedan solucionarse rápidamente. ¡Gracias por tu interés en probar nuevas características!"

L["Enable"] = "Habilitar"
L["Enable/Disable Reckless Abandon"] = "Habilitar / deshabilitar el Reckless Abandon"

L["Yes"] = "Sí"
L["No"] = "No"

L["|cFFFF6B6BThis cannot be undone.|r"] = "|cFFFF6B6BEsto no se puede deshacer.|r"
L["Are you sure you want to abandon all quests in |cFFF2E699%s|r?"] = "¿Estás segura de que quieres abandonar todas las misiones en |cFFF2E699%s|r?"
L["Are you sure you want to abandon |cFFF2E699%s|r?"] = "¿Estás seguro de que quieres abandonar a |cFFF2E699%s|r?"
L["Are you sure you want to abandon all of the quests in your questlog?"] = "¿Estás seguro de que deseas abandonar todas las misiones de tu registro de misiones?"
L["Are you sure you want to abandon the following %s quests?"] = "¿Estás seguro de que deseas abandonar las siguientes %s misiones?"

L["Only show messages for errors"] = "Solo mostrar mensajes de error"
L["Only show messages for warnings and errors"] = "Solo mostrar mensajes para advertencias y errores"
L["Only show important messages"] = "Mostrar solo mensajes importantes"
L["Show all messages (default)"] = "Mostrar todos los mensajes (predeterminado)"

L["Left Click: Abandon quest"] = "Clic izquierdo: Abandonar misión"
L["Right Click: Exclude quest from group abandons"] = "Clic derecho: excluir misiones de abandonos grupales"
L["Right Click: Include quest in group abandons"] = "Clic derecho: Incluir misión en abandonos grupales"
L["Left Click: Abandon all quests"] = "Clic izquierdo: abandona todas las misiones"

L["covenant callings"] = "llamamientos del pacto"
L["Left Click: Abandon all covenant calling quests"] = "Clic izquierdo: abandona todas las misiones de llamadas del pacto."

L["|cFFFF9C00<Zone Header>|r"] = "|cFFFF9C00<Encabezado de zona>|r"
L["    |cFFF2E699<Title>|r - |cFFB5FFEB<QuestID>|r"] = "    |cFFF2E699<Título>|r - |cFFB5FFEB<ID de misión>|r"

L["General"] = true
L["General Settings"] = "Configuración general"
L["Debugging"] = "Depuración"
L["Commands"] = "Comandos"

L["Individual Quests"] = "Misiones individuales"
L["Zone Quests"] = "Misiones de zona"
L["Campaign Quests"] = "Misiones de campaña"
L["Covenant Callings"] = "Llamamientos del pacto"
L["Keybindings"] = "Atajos de teclado"

L["Show login message"] = "Mostrar mensaje de inicio de sesión"
L["Messaging Rate"] = "Tasa de mensajería"
L["Adjust the amount of messages you will receive from actions taken against your quest log."] = "Ajusta la cantidad de mensajes que recibirás de las acciones realizadas en tu registro de misiones."
L["|cFF00D1FFNote:|r You will always be notified when a quest is abandoned on your behalf."] = "|cFF00D1FFNota:|r Siempre se te notificará cuando se abandone una misión en tu nombre."
L["Show Abandon Button"] = "Mostrar botón de abandono"
L["Show Group Abandon Button"] = "Mostrar botón de abandono de grupo"
L["Complete Protection"] = "Protección Completa"
L["Automatically exclude completed quests from group abandons and automation options."] = "Excluir automáticamente las misiones completadas de las abandonos grupales y opciones de automatización."
L["Show an abandon button for individual quests."] = "Muestra un botón de abandono para misiones individuales."
L["Abandon Quest"] = "Abandonar misión"
L["Use this keybinding on a quest in your quest log to abandon it."] = "Usa esta combinación de teclas en una misión de tu registro de misiones para abandonarla."
L["Exclude/Include Quest"] = "Excluir/Incluir Misión"
L["Use this keybinding on a quest in your quest log to toggle exclusion from group abandons."] = "Usa este atajo en una misión de tu registro de misiones para alternar la exclusión de los abandonos en grupo."
L["Show a group abandon button for zone quests."] = "Muestra un botón de abandono de grupo para misiones de zona."
L["Abandon Quests"] = "Abandonar misiones"
L["Use this keybinding on a zone header in your quest log to abandon all quests for that zone that are included in group abandons."] = "Usa esta combinación de teclas en un encabezado de zona en tu registro de misiones para abandonar todas las misiones de esa zona que están incluidas en abandonos grupales."
L["Are you sure you want to bind %s?"] = "¿Estás seguro/a de que quieres vincular %s?"
L["|cFFFF6B6BCaution: This can cause you to accidentally abandon a quest when trying to select a quest in your quest log.|r"] = "|cFFFF6B6B¡Precaución! Esto puede hacer que abandones una misión accidentalmente al intentar seleccionar una misión en tu registro de misiones.|r"
L["|cFFFF6B6BCaution: This can cause you to accidentally abandon a quest when trying to track a quest in your quest log.|r"] = "|cFFFF6B6B¡Precaución! Esto puede hacer que abandones una misión accidentalmente al intentar hacer un seguimiento de una misión en tu registro de misiones.|r"
L["|cFFFF6B6BCaution: This can cause you to accidently toggle exclusion of a quest from group abandons when trying to select a quest in your quest log.|r"] = "|cFFFF6B6B¡Precaución: Esto puede hacer que accidentalmente alternes la exclusión de una misión de los abandonos de grupo al intentar seleccionar una misión en tu registro de misiones!|r"
L["|cFFFF6B6BCaution: This can cause you to accidently toggle exclusion of a quest from group abandons when trying to track a quest in your quest log.|r"] = "|cFFFF6B6B¡Precaución: Esto puede hacer que accidentalmente alternes la exclusión de una misión de los abandonos de grupo al intentar rastrear una misión en tu registro de misiones!|r"
L["|cFFFF6B6BCaution: This can cause you to accidentally abandon all quests in a zone when trying to expand a zone header in your quest log.|r"] = "|cFFFF6B6B¡Precaución! Esto puede hacer que abandones accidentalmente todas las misiones en una zona al intentar expandir un encabezado de zona en tu registro de misiones.|r"
L["Show a group abandon button for campaign quests."] = "Muestra un botón de abandono de grupo para misiones de campaña."
L["Show a group abandon button for covenant callings."] = "Muestre un botón de abandono de grupo para los llamamientos del pacto."
L["|cFF00D1FFNote:|r Blizzard currently does not allow covenant callings to be abandoned. This button will be disabled if shown."] = "|cFF00D1FFNota:|r Actualmente, Blizzard no permite que se abandonen los llamamientos del pacto. Este botón se desactivará si se muestra."

L["Confirm individual abandons"] = "Confirmar abandonos individuales"
L["Prompt for confirmation when abandoning individual quests."] = "Solicitar confirmación al abandonar misiones individuales."
L["|cFFFF6B6BCaution: Turning this off means a quest will be abandoned instantly. Be careful!|r"] = "|cFFFF6B6BPrecaución: Desactivar esto significa que una misión se abandonará instantáneamente. ¡Ten cuidado!|r"
L["Confirm group abandons"] = "Confirmar abandonos del grupo"
L["Confirm group abandons"] = "Confirmar abandonos del grupo"
L["Prompt for confirmation when abandoning multiple quests."] = "Solicitar confirmación al abandonar múltiples misiones."
L["|cFFFF6B6BCaution: Turning this off means a group of quests will be abandoned instantly. Be careful!|r"] = "|cFFFF6B6BPrecaución: Desactivar esto significa que un grupo de misiones se abandonará instantáneamente. ¡Ten cuidado!|r"

L["Automation Options"] = "Opciones de automatización"
L["These options will act upon your quest log automatically. This can save you time, however care should be taken when using them."] = "Estas opciones actuarán sobre tu registro de misiones automáticamente. Esto puede ahorrarte tiempo, sin embargo, debes tener cuidado al usarlas."
L["|cFF00D1FFNote:|r Each character has their own automation options."] = "|cFF00D1FFNote:|r Cada personaje tiene sus propias opciones de automatización."
L["Abandon Quests"] = "Abandonar misiones"
L["Quest Type"] = "Tipo de misión"
L["Automatically abandon quests of the given type if they are included in group abandons."] = "Abandonar automáticamente las misiones del tipo dado si están incluidas en los abandonos grupales."
L["|cFFFF6B6BCaution:|r These quests will be abandoned for you, confirmation settings will be ignored."] = "|cFFFF6B6BCaution:|r Estas misiones se abandonarán por ti, la configuración de confirmación se ignorará"
L["Automatically abandoned %s |4quest:quests;!"] = "¡Abandonó automáticamente %s |4misión:misiones; %s!"
L["Green"] = "Verde"
L["Yellow"] = "Amarillo"
L["Orange"] = "Naranja"
L["Red"] = "Rojo"
L["Gray"] = "Gris"
L["Quest IDs"] = "Identificadores de misiones"
L["Enter quest ids separated by a comma. These quests will be abandoned automatically if they are included in group abandons."] = "Ingrese los ID de búsqueda separados por una coma. Estas misiones se abandonarán automáticamente si se incluyen en los abandonos grupales."

L["Slash Commands"] = "Comandos de barra"
L["|cFF00D1FFNote:|r The token |cff888888reckless|r can be replaced by |cff888888rab|r for all commands."] = "|cFF00D1FFNota:|r El token |cff888888reckless|r se puede reemplazar por |cff888888rab|r para todos los comandos."
L["Enable |cff888888/reckless list all|r"] = "Habilitar |cff888888/reckless list all|r"
L["This command lists all quests in a table."] = "Este comando enumera todas las misiones en una tabla."
L["Enable |cff888888/reckless abandon all|r"] = "Habilitar |cff888888/reckless abandon all|r"
L["|cFFFFF569Warning:|r This command abandons all quests in your quest log that are not excluded from group abandons, use it wisely."] = "|cFFFFF569Advertencia:|r Este comando abandona todas las misiones en su registro de misiones que no están excluidas de los abandonos grupales, utilícelo con prudencia."
L["Enable |cff888888/reckless abandon <questID>|r"] = "Habilitar |cff888888/reckless abandon <ID de misión>|r"
L["This command abandons a quest that matches the provided questID."] = "Este comando abandona una misión que coincide con el ID de misión proporcionado."
L["Enable |cff888888/reckless exclude <questID>|r"] = "Habilitar |cff888888/reckless exclude <ID de misión>|r"
L["This command excludes a quest that matches the provided questID from group abandons."] = "Este comando excluye una misión que coincide con el ID de misión proporcionado de los abandonos del grupo."
L["Enable |cff888888/reckless include <questID>|r"] = "Habilitar |cff888888/reckless include <ID de misión>|r"
L["This command includes a quest that matches the provided questID in group abandons."] = "Este comando incluye una misión que coincide con el ID de misión proporcionado en abandonos grupales."
L["Enable |cff888888/reckless abandon <qualifier>|r"] = "Habilitar |cff888888/reckless abandon <calificatorio>|r"
L["This command abandons all quests that match a given qualifier and are not excluded from group abandons."] = "Este comando abandona todas las misiones que coinciden con un calificador determinado y no se excluyen de los abandonos grupales."

L["Available Qualifiers:"] = "Calificadores disponibles:"

L["Matches all daily quests."] = "Coincide con todas las misiones diarias."
L["Matches all weekly quests."] = "Coincide con todas las misiones semanales."
L["gray"] = "gris"
L["Matches all gray quests."] = "Coincide con todas las misiones grises."
L["green"] = "verde"
L["Matches all green quests."] = "Coincide con todas las misiones verdes."
L["yellow"] = "amarillo"
L["Matches all yellow quests."] = "Coincide con todas las misiones amarillas."
L["orange"] = "naranja"
L["Matches all orange quests."] = "Coincide con todas las misiones naranjas."
L["red"] = "rojo"
L["Matches all red quests."] = "Coincide con todas las misiones rojas."

L["Generic"] = "Genérica"

L["|cffffcc00%s Debug:|r"] = "|cffffcc00%s Depurar:|r"
L["Debug Settings"] = "Configuración de depuración"
L["Enable Debugging"] = "Habilitar la depuración"
L["Print debugging statements when this is enabled."] = "Imprimir declaraciones de depuración cuando está habilitado."
L["|cFF00D1FFNote:|r You can also toggle this quickly via |cff888888/reckless debug|r"] = "|cFF00D1FFNota:|r También puede alternar esto rápidamente a través de |cff888888/reckless debug|r"

L["Exclusions"] = "Exclusiones"
L["Quest Exclusion List"] = "Lista de exclusión de misiones"
L["Prune Exclusion List"] = "Podar lista de exclusión"
L["Clear Exclusion List"] = "Lista de exclusión clara"
L["The quest exclusion list allows you to exclude quests from group abandons. To use it, simply right click a quest abandon button in the quest log."] = "La lista de exclusión de misiones te permite excluir misiones de abandonos grupales. Para usarlo, simplemente haga clic con el botón derecho en un botón de abandono de la misión en el registro de misiones."
L["|cFF00D1FFNote:|r Each character has their own exclusion list."] = "|cFF00D1FFNota:|r Cada personaje tiene su propia lista de exclusión."
L["Quests that appear in |cFFFF6B6Bred|r are no longer detected in your quest log."] = "Misiones que aparecen en |cFFFF6B6Brojo|r ya no se detectan en tu registro de misiones."
L["You can prune them by clicking this button, or leave them and they will be excluded again the next time they are picked up."] = "Puede podarlos haciendo clic en este botón, o dejarlos y serán excluidos nuevamente la próxima vez que sean recogidos."
L["|cFF808080There are currently no quests being excluded.|r"] = "|cFF808080Actualmente no se excluyen misiones.|r"
L["Pruning '%s' from the exclusion list"] = "Eliminando '%s' de la lista de exclusión"
L["Pruned %s |4orphan:orphans;!"] = "Poda %s |4huérfano:huérfanos;!"
L["Pruned %s |4orphan:orphans; from source '%s'!"] = "Poda %s |4huérfano:huérfanos; de la fuente '%s'!"
L["Clear the exclusion list by including quests that are still in your quest log and pruning those that aren't."] = "Borre la lista de exclusión incluyendo misiones que todavía están en su registro de misiones y podando aquellas que no lo estén."
L["Automatic Pruning"] = "Poda automática"
L["Automatically prune quests from the exclusion list when they are abandoned."] = "Elimina automáticamente las misiones de la lista de exclusión cuando se abandonan."
L["|cFF00D1FFNote:|r This does not retroactively prune quests that have already been abandoned, but are still in the exclusion list."] = "|cFF00D1FFNota:|r Esto no elimina de forma retroactiva las misiones que ya se han abandonado, pero que todavía están en la lista de exclusión."
L["Use the 'Prune Exclusion List' button below to do this manually."] = "Use el botón 'Podar lista de exclusión' a continuación para hacer esto manualmente."
L["Unable to prune quests from the exclusion list from source '%s'"] = "No se pueden eliminar las misiones de la lista de exclusión de la fuente '%s'"

L["About"] = "Acerca de"
L["Testers"] = "Probadores"
L["Written by |T626001:0|t |cFF3FC7EB%s|r"] = "Escrito por |T626001:0|t |cFF3FC7EB%s|r"
L["Please report any bugs or request features on our issue board:"] = "Informe cualquier error o solicite funciones en nuestro tablero de problemas:"

L["|cFFFFFF00Abandoned quest %s|r"] = "|cFFFFFF00Misión abandonada %s|r"
L["|cFFFFFF00You can't abandon %s|r"] = "|cFFFFFF00No puedes abandonar %s|r"

L["Skipping %s since it is excluded from group abandons"] = "Omitiendo %s ya que está excluido de los abandonos grupales"
L["Excluding quest '%s' from group abandons"] = "Excluyendo la misión '%s' de abandonos grupales"
L["Including quest '%s' in group abandons"] = "Incluyendo la misión '%s' en abandonos grupales"

L["QuestID"] = "ID de misión"
L["Title"] = "Título"
L["Source"] = "Fuente"
L["Manual"] = "Manual"
L["Automation"] = "Automatización"

L["Abandoning all quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"] = "Abandonar todas las misiones desde la línea de comando está actualmente |cFFFF6B6Bdeshabilitado|r. Puede habilitarlo en los ajustes de configuración |cff888888/reckless config|r"

L["Abandoning quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"] = "Abandonar misiones desde la línea de comando es actualmente |cFFFF6B6Bdeshabilitado|r. Puede habilitarlo en los ajustes de configuración |cff888888/reckless config|r"
L["Unable to abandon quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."] = "No se puede abandonar la misión, no se reconoce '%s'. O la misión no está en tu registro de misiones o es posible que hayas ingresado la identificación incorrecta."

L["Excluding quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"] = "La exclusión de misiones de la línea de comando es actualmente |cFFFF6B6Bdeshabilitado|r. Puede habilitarlo en los ajustes de configuración |cff888888/reckless config|r"
L["Unable to exclude quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."] = "No se puede excluir la misión, '%s' no se reconoce. O la misión no está en tu registro de misiones o es posible que hayas ingresado la identificación incorrecta."
L["%s is already excluded from group abandons!"] = "¡%s ya está excluido de los abandonos grupales!"

L["Including quests from the command line is currently |cFFFF6B6Bdisabled|r. You can enable it in the configuration settings |cff888888/reckless config|r"] = "Incluir misiones desde la línea de comando es actualmente |cFFFF6B6Bdeshabilitado|r. Puede habilitarlo en los ajustes de configuración |cff888888/reckless config|r"
L["Unable to include quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."] = "No se puede incluir la misión, '%s' no se reconoce. O la misión no está en tu registro de misiones o es posible que hayas ingresado la identificación incorrecta."
L["%s is alr1eady included in group abandons!"] = "¡%s ya está incluido en abandonos grupales!"

L["You are running |cFFB5FFEBv%s|r. Type |cff888888/reckless config|r to configure settings."] = "Estas corriendo |cFFB5FFEBv%s|r. Escriba |cff888888/reckless config|r para configurar los ajustes."

L["Abandon invoked with qualifier '%s'"] = "Abandono invocado con el calificador '%s'"
L["Available Qualifiers:%s"] = "Calificadores disponibles:%s"
L["|cFF808080There are no quests that match the qualifier '%s'.|r"] = "|cFF808080No hay misiones que coincidan con el clasificatorio '%s'.|r"

L["Debugging is now on."] = "La depuración está ahora activada"
L["Debugging is now off."] = "La depuración ahora está desactivada"
L["Auto Abandon: "] = "Abandono automático: "
L["%s leveled up (%d -> %d)!"] = "¡%s subió de nivel (%d -> %d)!"
L["Quest Table: "] = "Tabla de misiones: "
L["Excluded Quests: "] = "Misiones excluidas: "

L["%s abandoned via keybinding (%s)"] = "%s abandonada mediante combinación de teclas (%s)"
L["%s excluded via keybinding (%s)"] = "%s excluida mediante combinación de teclas (%s)"
L["%s included via keybinding (%s)"] = "%s incluida mediante combinación de teclas (%s)"
