-- Portuguese localization file for enUS and enGB.
local E = unpack(RecklessAbandon) -- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("RecklessAbandon", "ptBR")

if not L then
    return
end

L["Version"] = "Versão"
L["Configuration"] = "Configuração"
L["Description"] = "Uma ferramenta para abandonar missões rapidamente (e imprudentemente)"

L["You are currently running a pre-release version of %s. Please report any issues on github (|cFFB5FFEB%s|r) so they can be addressed quickly. Thank you for your interest in testing new features!"] = "Você está executando uma versão de pré-lançamento de %s. Por favor, relate quaisquer problemas no GitHub (|cFFB5FFEB%s|r) para que possam ser resolvidos rapidamente. Obrigado pelo seu interesse em testar novos recursos!"

L["Enable"] = "Ativar"
L["Enable/Disable Reckless Abandon"] = "Ativar/Desativar Abandono Imprudente"

L["Yes"] = "Sim"
L["No"] = "Não"

L["|cFFFF6B6BThis cannot be undone.|r"] = "|cFFFF6B6BEste processo não pode ser desfeito.|r"
L["Are you sure you want to abandon all quests in |cFFF2E699%s|r?"] = "Você tem certeza de que deseja abandonar todas as missões em |cFFF2E699%s|r?"
L["Are you sure you want to abandon |cFFF2E699%s|r?"] = "Você tem certeza de que deseja abandonar |cFFF2E699%s|r?"
L["Are you sure you want to abandon all of the quests in your questlog?"] = "Você tem certeza de que deseja abandonar todas as missões no seu registro de missões?"
L["Are you sure you want to abandon the following %s quests?"] = "Você tem certeza de que deseja abandonar as seguintes missões %s?"

L["Only show messages for errors"] = "Mostrar apenas mensagens de erro"
L["Only show messages for warnings and errors"] = "Mostrar mensagens de alerta e erro"
L["Only show important messages"] = "Mostrar apenas mensagens importantes"
L["Show all messages (default)"] = "Mostrar todas as mensagens (padrão)"

L["Left Click: Abandon quest"] = "Clique Esquerdo: Abandonar missão"
L["Right Click: Exclude quest from group abandons"] = "Clique Direito: Excluir missão de abandonos em grupo"
L["Right Click: Include quest in group abandons"] = "Clique Direito: Incluir missão em abandonos em grupo"
L["Left Click: Abandon all quests"] = "Clique Esquerdo: Abandonar todas as missões"

L["covenant callings"] = "chamados de covénio"
L["Left Click: Abandon all covenant calling quests"] = "Clique Esquerdo: Abandonar todas as missões de chamados de covénio"

L["|cFFFF9C00<Zone Header>|r"] = "|cFFFF9C00<Cabeçalho da Zona>|r"
L["    |cFFF2E699<Title>|r - |cFFB5FFEB<QuestID>|r"] = "    |cFFF2E699<Título>|r - |cFFB5FFEB<QuestID>|r"

L["General"] = "Geral"
L["General Settings"] = "Configurações Gerais"
L["Debugging"] = "Depuração"
L["Commands"] = "Comandos"

L["Individual Quests"] = "Missões Individuais"
L["Zone Quests"] = "Missões na Zona"
L["Campaign Quests"] = "Missões de Campanha"
L["Covenant Callings"] = "Chamados de Covénio"
L["Keybindings"] = "Atalhos"

L["Show login message"] = "Mostrar mensagem de login"
L["Messaging Rate"] = "Frequência de Mensagens"
L["Adjust the amount of messages you will receive from actions taken against your quest log."] = "Ajuste a quantidade de mensagens que você receberá de ações tomadas contra o seu registro de missões."
L["|cFF00D1FFNote:|r You will always be notified when a quest is abandoned on your behalf."] = "|cFF00D1FFNota:|r Você sempre será notificado quando uma missão for abandonada em seu nome."
L["Show Abandon Button"] = "Mostrar Botão de Abandono"
L["Show Group Abandon Button"] = "Mostrar Botão de Abandono em Grupo"
L["Complete Protection"] = "Proteção Completa"
L["Automatically exclude completed quests from group abandons and automation options."] = "Excluir automaticamente missões concluídas de abandonos em grupo e opções de automação."
L["Show an abandon button for individual quests."] = "Mostrar um botão de abandonar para missões individuais."
L["Abandon Quest"] = "Abandonar Missão"
L["Use this keybinding on a quest in your quest log to abandon it."] = "Use este atalho em uma missão no seu registro de missões para abandoná-la."
L["Exclude/Include Quest"] = "Excluir/Incluir Missão"
L["Use this keybinding on a quest in your quest log to toggle exclusion from group abandons."] = "Use este atalho em uma missão no seu registro de missões para alternar a exclusão dos abandonos em grupo."
L["Show a group abandon button for zone quests."] = "Mostrar um botão de abandonar em grupo para missões na zona."
L["Abandon Quests"] = "Abandonar Missões"
L["Use this keybinding on a zone header in your quest log to abandon all quests for that zone that are included in group abandons."] = "Use este atalho em um cabeçalho de zona no seu registro de missões para abandonar todas as missões para aquela zona que estão incluídas nos abandonos em grupo."
L["Are you sure you want to bind %s?"] = "Você tem certeza de que deseja vincular %s?"
L["|cFFFF6B6BCaution: This can cause you to accidently abandon a quest when trying to select a quest in your quest log.|r"] = "|cFFFF6B6BAviso: Isso pode fazer com que você acidentalmente abandone uma missão ao tentar selecionar uma missão no seu registro de missões.|r"
L["|cFFFF6B6BCaution: This can cause you to accidently abandon a quest when trying to track a quest in your quest log.|r"] = "|cFFFF6B6BAviso: Isso pode fazer com que você acidentalmente abandone uma missão ao tentar rastrear uma missão no seu registro de missões.|r"
L["|cFFFF6B6BCaution: This can cause you to accidently toggle exclusion of a quest from group abandons when trying to select a quest in your quest log.|r"] = "|cFFFF6B6BCuidado: Isso pode fazer com que você acidentalmente alterne a exclusão de uma missão dos abandonos em grupo ao tentar selecionar uma missão no seu registro de missões.|r"
L["|cFFFF6B6BCaution: This can cause you to accidently toggle exclusion of a quest from group abandons when trying to track a quest in your quest log.|r"] = "|cFFFF6B6BCuidado: Isso pode fazer com que você acidentalmente alterne a exclusão de uma missão dos abandonos em grupo ao tentar rastrear uma missão no seu registro de missões.|r"
L["|cFFFF6B6BCaution: This can cause you to accidently abandon all quests in a zone when trying to expand a zone header in your quest log.|r"] = "|cFFFF6B6BAviso: Isso pode fazer com que você abandone acidentalmente todas as missões em uma zona ao tentar expandir um cabeçalho de zona no seu registro de missões.|r"
L["Show a group abandon button for campaign quests."] = "Mostrar um botão de abandonar em grupo para missões de campanha."
L["Show a group abandon button for covenant callings."] = "Mostrar um botão de abandonar em grupo para chamados de covénio."
L["|cFF00D1FFNote:|r Blizzard currently does not allow covenant callings to be abandoned. This button will be disabled if shown."] = "|cFF00D1FFNota:|r Atualmente, a Blizzard não permite que chamados de covénio sejam abandonados. Este botão será desativado se for exibido."

L["Confirm individual abandons"] = "Confirmar abandonos individuais"
L["Prompt for confirmation when abandoning individual quests."] = "Solicitar confirmação ao abandonar missões individuais."
L["|cFFFF6B6BCaution: Turning this off means a quest will be abandoned instantly. Be careful!|r"] = "|cFFFF6B6BAviso: Desativar isso significa que uma missão será abandonada instantaneamente. Tenha cuidado!|r"
L["Confirm group abandons"] = "Confirmar abandonos em grupo"
L["Prompt for confirmation when abandoning multiple quests."] = "Solicitar confirmação ao abandonar várias missões."
L["|cFFFF6B6BCaution: Turning this off means a group of quests will be abandoned instantly. Be careful!|r"] = "|cFFFF6B6BAviso: Desativar isso significa que um grupo de missões será abandonado instantaneamente. Tenha cuidado!|r"

L["Automation Options"] = "Opções de Automatização"
L["These options will act upon your quest log automatically. This can save you time, however, care should be taken when using them."] = "Essas opções agirão automaticamente no seu registro de missões. Isso pode economizar tempo, no entanto, cuidado deve ser tomado ao usá-las."
L["|cFF00D1FFNote:|r Each character has their own automation options."] = "|cFF00D1FFNota:|r Cada personagem tem suas próprias opções de automação."
L["Abandon Quests"] = "Abandonar Missões"
L["Quest Type"] = "Tipo de Missão"
L["Automatically abandon quests of the given type if they are included in group abandons."] = "Abandonar automaticamente missões do tipo especificado se estiverem incluídas nos abandonos em grupo."
L["|cFFFF6B6BCaution:|r These quests will be abandoned for you, confirmation settings will be ignored."] = "|cFFFF6B6BAviso:|r Essas missões serão abandonadas por você, as configurações de confirmação serão ignoradas."
L["Automatically abandoned %s |4quest:quests;!"] = "Missões %s abandonadas automaticamente |4quest:quests;!"
L["Green"] = "Verde"
L["Yellow"] = "Amarelo"
L["Orange"] = "Laranja"
L["Red"] = "Vermelho"
L["Gray"] = "Cinza"
L["Quest IDs"] = "IDs de Missões"
L["Enter quest ids separated by a comma. These quests will be abandoned automatically if they are included in group abandons."] = "Digite IDs de missões separadas por vírgula. Essas missões serão abandonadas automaticamente se estiverem incluídas nos abandonos em grupo."

L["Slash Commands"] = "Comandos de Barra"
L["|cFF00D1FFNote:|r The token |cff888888reckless|r can be replaced by |cff888888rab|r for all commands."] = "|cFF00D1FFNota:|r O token |cff888888reckless|r pode ser substituído por |cff888888rab|r para todos os comandos."
L["Enable |cff888888/reckless list all|r"] = "Ativar |cff888888/reckless list all|r"
L["This command lists all quests in a table."] = "Este comando lista todas as missões em uma tabela."
L["Enable |cff888888/reckless abandon all|r"] = "Ativar |cff888888/reckless abandon all|r"
L["|cFFFFF569Warning:|r This command abandons all quests in your quest log that are not excluded from group abandons, use it wisely."] = "|cFFFFF569Aviso:|r Este comando abandona todas as missões em seu registro de missões que não estão excluídas dos abandonos em grupo, use com sabedoria."
L["Enable |cff888888/reckless abandon <questID>|r"] = "Ativar |cff888888/reckless abandon <questID>|r"
L["This command abandons a quest that matches the provided questID."] = "Este comando abandona uma missão que corresponde ao questID fornecido."
L["Enable |cff888888/reckless exclude <questID>|r"] = "Ativar |cff888888/reckless exclude <questID>|r"
L["This command excludes a quest that matches the provided questID from group abandons."] = "Este comando exclui uma missão que corresponde ao questID fornecido dos abandonos em grupo."
L["Enable |cff888888/reckless include <questID>|r"] = "Ativar |cff888888/reckless include <questID>|r"
L["This command includes a quest that matches the provided questID in group abandons."] = "Este comando inclui uma missão que corresponde ao questID fornecido nos abandonos em grupo."
L["Enable |cff888888/reckless abandon <qualifier>|r"] = "Ativar |cff888888/reckless abandon <qualificador>|r"
L["This command abandons all quests that match a given qualifier and are not excluded from group abandons."] = "Este comando abandona todas as missões que correspondem a um qualificador dado e não estão excluídas dos abandonos em grupo."

L["Available Qualifiers:"] = "Qualificadores Disponíveis:"

L["Matches all daily quests."] = "Corresponde a todas as missões diárias."
L["Matches all failed quests."] = "Corresponde a todas as missões falhadas."
L["Matches all dungeon quests."] = "Corresponde a todas as missões de masmorra."
L["Matches all raid quests."] = "Corresponde a todas as missões de raide."
L["Matches all group quests."] = "Corresponde a todas as missões de grupo."
L["Matches all heroic quests."] = "Corresponde a todas as missões heroicas."
L["Matches all elite quests."] = "Corresponde a todas as missões de elite."
L["Matches all pvp quests."] = "Corresponde a todas as missões de PvP."
L["Matches all weekly quests."] = "Corresponde a todas as missões semanais."
L["gray"] = "cinza"
L["Matches all gray quests."] = "Corresponde a todas as missões cinza."
L["green"] = "verde"
L["Matches all green quests."] = "Corresponde a todas as missões verdes."
L["yellow"] = "amarelo"
L["Matches all yellow quests."] = "Corresponde a todas as missões amarelas."
L["orange"] = "laranja"
L["Matches all orange quests."] = "Corresponde a todas as missões laranjas."
L["red"] = "vermelho"
L["Matches all red quests."] = "Corresponde a todas as missões vermelhas."

L["Generic"] = "Genérico"

L["|cffffcc00%s Debug:|r"] = "|cffffcc00%s Debug:|r"
L["Debug Settings"] = "Configurações de Depuração"
L["Enable Debugging"] = "Ativar Depuração"
L["Print debugging statements when this is enabled."] = "Imprimir declarações de depuração quando isso estiver ativado."
L["|cFF00D1FFNote:|r You can also toggle this quickly via |cff888888/reckless debug|r"] = "|cFF00D1FFNota:|r Você também pode alternar isso rapidamente via |cff888888/reckless debug|r"

L["Exclusions"] = "Exclusões"
L["Quest Exclusion List"] = "Lista de Exclusão de Missões"
L["Prune Exclusion List"] = "Podar Lista de Exclusão"
L["Clear Exclusion List"] = "Limpar Lista de Exclusão"
L["The quest exclusion list allows you to exclude quests from group abandons. To use it, simply right click a quest abandon button in the quest log."] = "A lista de exclusão de missões permite que você exclua missões dos abandonos em grupo. Para usá-la, basta clicar com o botão direito em um botão de abandono de missão no registro de missões."
L["|cFF00D1FFNote:|r Each character has their own exclusion list."] = "|cFF00D1FFNota:|r Cada personagem tem sua própria lista de exclusão."
L["Quests that appear in |cFFFF6B6Bvermelho|r are no longer detected in your quest log."] = "Missões que aparecem em |cFFFF6B6Bvermelho|r não são mais detectadas em seu registro de missões."
L["You can prune them by clicking this button, or leave them and they will be excluded again the next time they are picked up."] = "Você pode podá-las clicando neste botão, ou deixá-las e elas serão excluídas novamente da próxima vez que forem pegas."
L["|cFF808080There are currently no quests being excluded.|r"] = "|cFF808080Atualmente, não há missões sendo excluídas.|r"
L["Pruning '%s' from the exclusion list"] = "Podando '%s' da lista de exclusão"
L["Pruned %s |4órfãos:órfãos;!"] = "Podadas %s |4órfãos:órfãos;!"
L["Pruned %s |4órfãos:órfãos; da fonte '%s'!"] = "Podadas %s |4órfãos:órfãos; da fonte '%s'!"
L["Clear the exclusion list by including quests that are still in your quest log and pruning those that aren't."] = "Limpe a lista de exclusão incluindo missões que ainda estão em seu registro de missões e podando aquelas que não estão."
L["Automatic Pruning"] = "Podar Automaticamente"
L["Automatically prune quests from the exclusion list when they are abandoned, or when they are no longer in your quest log and were excluded via automation."] = "Podar automaticamente missões da lista de exclusão quando são abandonadas ou quando não estão mais em seu registro de missões e foram excluídas via automação."
L["|cFF00D1FFNote:|r This does not retroactively prune quests that have already been abandoned but are still in the exclusion list."] = "|cFF00D1FFNota:|r Isso não poda retroativamente missões que já foram abandonadas, mas ainda estão na lista de exclusão."
L["Use the 'Prune Exclusion List' button below to do this manually."] = "Use o botão 'Podar Lista de Exclusão' abaixo para fazer isso manualmente."
L["Unable to prune quests from the exclusion list from source '%s'"] = "Não é possível podar missões da lista de exclusão da fonte '%s'"

L["About"] = "Sobre"
L["Testers"] = "Testadores"
L["Written by %s%s%s%s %s"] = "Escrito por %s%s%s%s %s"
L["Please report any bugs or request features on our issue board:"] = "Por favor, relate qualquer bug ou solicite recursos em nosso quadro de problemas:"

L["|cFFFFFF00Abandoned quest %s|r"] = "|cFFFFFF00Missão abandonada %s|r"
L["|cFFFFFF00You can't abandon %s|r"] = "|cFFFFFF00Você não pode abandonar %s|r"

L["Skipping %s since it is excluded from group abandons"] = "Ignorando %s, pois está excluído dos abandonos em grupo"
L["Excluding quest %s from group abandons"] = "Excluindo missão %s dos abandonos em grupo"
L["Including quest %s in group abandons"] = "Incluindo missão %s nos abandonos em grupo"

L["QuestID"] = "ID da Missão"
L["Title"] = "Título"
L["Source"] = "Origem"
L["Manual"] = "Manual"
L["Automation"] = "Automação"

L["Abandoning all quests from the command line is currently |cFFFF6B6Bdesativado|r. Você pode ativá-lo nas configurações de configuração |cff888888/reckless config|r"] = "Abandonar todas as missões via linha de comando está atualmente |cFFFF6B6Bdesativado|r. Você pode ativá-lo nas configurações de configuração |cff888888/reckless config|r"

L["Abandoning quests from the command line is currently |cFFFF6B6Bdisabled|r. Você pode ativá-lo nas configurações de configuração |cff888888/reckless config|r"] = "Abandonar missões via linha de comando está atualmente |cFFFF6B6Bdesativado|r. Você pode ativá-lo nas configurações de configuração |cff888888/reckless config|r"
L["Unable to abandon quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."] = "Não é possível abandonar a missão, '%s' não é reconhecida. Ou a missão não está no seu registro de missões, ou você pode ter digitado o ID errado."

L["Excluding quests from the command line is currently |cFFFF6B6Bdisabled|r. Você pode ativá-lo nas configurações de configuração |cff888888/reckless config|r"] = "Excluir missões via linha de comando está atualmente |cFFFF6B6Bdesativado|r. Você pode ativá-lo nas configurações de configuração |cff888888/reckless config|r"
L["Unable to exclude quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."] = "Não é possível excluir a missão, '%s' não é reconhecida. Ou a missão não está no seu registro de missões, ou você pode ter digitado o ID errado."
L["%s is already excluded from group abandons!"] = "%s já está excluído dos abandonos em grupo!"

L["Including quests from the command line is currently |cFFFF6B6Bdisabled|r. Você pode ativá-lo nas configurações de configuração |cff888888/reckless config|r"] = "Incluir missões via linha de comando está atualmente |cFFFF6B6Bdesativado|r. Você pode ativá-lo nas configurações de configuração |cff888888/reckless config|r"
L["Unable to include quest, '%s' is not recognized. Either the quest is not in your quest log, or you may have entered the wrong id."] = "Não é possível incluir a missão, '%s' não é reconhecida. Ou a missão não está no seu registro de missões, ou você pode ter digitado o ID errado."
L["%s is already included in group abandons!"] = "%s já está incluído nos abandonos em grupo!"

L["You are running |cFFB5FFEBv%s|r. Digite |cff888888/reckless config|r para configurar as configurações."] = "Você está usando a versão |cFFB5FFEBv%s|r. Digite |cff888888/reckless config|r para configurar as configurações."

L["Abandon invoked with qualifier '%s'"] = "Abandonar invocado com qualificador '%s'"
L["Available Qualifiers:%s"] = "Qualificadores Disponíveis:%s"
L["|cFF808080There are no quests that match the qualifier '%s'.|r"] = "|cFF808080Não há missões que correspondam ao qualificador '%s'.|r"

L["Debugging is now on."] = "A depuração está ativada."
L["Debugging is now off."] = "A depuração está desativada."
L["Auto Abandon: "] = "Auto Abandonar:"
L["%s leveled up (%d -> %d)!"] = "%s evoluiu (%d -> %d)!"
L["Quest Table: "] = "Tabela de Missões:"
L["Excluded Quests: "] = "Missões Excluídas:"

L["%s abandoned via keybinding (%s)"] = "%s abandonada via atalho (%s)"
L["%s excluded via keybinding (%s)"] = "%s excluída via atalho (%s)"
L["%s included via keybinding (%s)"] = "%s incluída via atalho (%s)"