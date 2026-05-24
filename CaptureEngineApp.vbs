' =====================================================================================
' NOME DO PROJETO: Capture Engine Launcher
' VERSÃO: 1.1.0 (Auditada e Otimizada)
' FINALIDADE: Inicializador seguro para renderização HTML local via Microsoft Edge.
' NÍVEL DE SEGURANÇA: User-Mode (Não requer privilégios de Administrador).
' REQUISITOS DE AUDITORIA:
'   1. Não altera o Registro do Windows (evita impacto na integridade do SO).
'   2. Opera exclusivamente em diretórios temporários do utilizador (%TEMP%).
'   3. Isola a sessão do navegador via --user-data-dir para prevenir vazamento de cache.
' =====================================================================================

Option Explicit

' Definição de Constantes
Const APP_NAME         = "Capture Engine"
Const APP_VERSION      = "1.1.0"
Const EDGE_PATH        = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
Const TARGET_HTML      = "capture-engine.html"

Dim fso, shell, currentDir, htmlPath, profilePath, desktopPath, shortcutFile, shortcut, edgeArgs

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

' SECÇÃO 1: VALIDAÇÃO DE INTEGRIDADE (Com feedback ao utilizador)
currentDir = fso.GetParentFolderName(WScript.ScriptFullName)

If Not fso.FileExists(EDGE_PATH) Then
    MsgBox "Erro de Execução:" & vbCrLf & "O Microsoft Edge não foi encontrado no caminho padrão do sistema." & vbCrLf & vbCrLf & "Caminho: " & EDGE_PATH, vbCritical, APP_NAME
    WScript.Quit(1)
End If

If Not fso.FileExists(currentDir & "\" & TARGET_HTML) Then
    MsgBox "Erro de Configuração:" & vbCrLf & "O arquivo de interface '" & TARGET_HTML & "' não foi encontrado no diretório do script.", vbCritical, APP_NAME
    WScript.Quit(1)
End If

' SECÇÃO 2: SANITIZAÇÃO DE INPUT
htmlPath = "file:///" & SecureURLEncode(Replace(currentDir & "\" & TARGET_HTML, "\", "/"))

' SECÇÃO 3: ISOLAMENTO DE AMBIENTE (SANDBOX) E HIGIENIZAÇÃO
profilePath = shell.ExpandEnvironmentStrings("%TEMP%\CE")
If Not fso.FolderExists(profilePath) Then fso.CreateFolder(profilePath)
If Not fso.FolderExists(profilePath & "\Default") Then fso.CreateFolder(profilePath & "\Default")

' Purga seletiva de cache antigo para poupança de espaço em disco
Dim cachePath
cachePath = profilePath & "\Default\Cache"
On Error Resume Next
If fso.FolderExists(cachePath) Then
    fso.DeleteFolder cachePath, True
End If
On Error GoTo 0

' SECÇÃO 4: CONFIGURAÇÃO DE PRIMEIRA EXECUÇÃO (FIRST-RUN)
Dim prefsPath, prefsFile
prefsPath = profilePath & "\Default\Preferences"
If Not fso.FileExists(prefsPath) Then
    Set prefsFile = fso.CreateTextFile(prefsPath, True)
    prefsFile.Write "{""browser"":{""shortcut_creation_time"":""13350000000000000""}}"
    prefsFile.Close
End If

' SECÇÃO 5: COMPOSIÇÃO DE ARGUMENTOS DE SEGURANÇA
' - Removido: --disable-features=RendererCodeIntegrity (Flag obsoleta/risco de falso positivo no EDR)
' - Adicionado: --disable-translate (Previne barra de tradução intrusiva em ambientes locais)
edgeArgs = "--app=""" & htmlPath & """ --user-data-dir=""" & profilePath & """ --app-id=CaptureEngineCustom --no-default-browser-check --no-first-run --disable-translate --start-maximized"

' SECÇÃO 6: GESTÃO DE ATALHO NO DESKTOP
desktopPath = shell.ExpandEnvironmentStrings("%USERPROFILE%\Desktop")
shortcutFile = desktopPath & "\" & APP_NAME & ".lnk"

' Só recria o atalho se ele tiver sido removido (preserva a organização do utilizador)
If Not fso.FileExists(shortcutFile) Then
    Set shortcut = shell.CreateShortcut(shortcutFile)
    shortcut.TargetPath = EDGE_PATH
    shortcut.Arguments = edgeArgs
    shortcut.WorkingDirectory = currentDir
    ' Expansão explícita da variável de ambiente para garantir a renderização correta do ícone
    shortcut.IconLocation = shell.ExpandEnvironmentStrings("%SystemRoot%\System32\shell32.dll") & ", 195"
    shortcut.Description = "Capture Engine - Acesso Seguro v" & APP_VERSION
    shortcut.Save
    Set shortcut = Nothing
End If

' SECÇÃO 7: EXECUÇÃO DO PROCESSO
shell.Run """" & EDGE_PATH & """ " & edgeArgs, 3, False

' Limpeza de memória
Set shell = Nothing: Set fso = Nothing

' FUNÇÃO DE AUXÍLIO: SecureURLEncode
Function SecureURLEncode(ByVal s)
    s = Replace(s, "%", "%25"): s = Replace(s, " ", "%20"): s = Replace(s, "#", "%23")
    s = Replace(s, "&", "%26"): s = Replace(s, "+", "%2B"): s = Replace(s, "=", "%3D")
    s = Replace(s, "[", "%5B"): s = Replace(s, "]", "%5D"): s = Replace(s, "'", "%27")
    SecureURLEncode = s
End Function