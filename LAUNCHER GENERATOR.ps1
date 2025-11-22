<#
    SCRIPT: Gerador de Launcher GFL (Por Fabiopsyduck)
    FUNCAO: Menu interativo bilingue com pre-checagem e monitoramento ao vivo.
#>

# --- 1. CONFIGURACAO INICIAL ---
[Console]::CursorVisible = $false

# Funcao auxiliar para ler a regiao atual
function Get-CurrentRegion {
    try {
        return (Get-ItemProperty "HKCU:\Control Panel\International" -Name "LocaleName").LocaleName
    } catch {
        return "Unknown"
    }
}

# --- 2. PRE-CHECAGEM (EXISTE EN-US?) ---
$enUsExiste = [System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::SpecificCultures) | Where-Object { $_.Name -eq "en-US" }

if (-not $enUsExiste) {
    Clear-Host
    Write-Host "=============================================" -ForegroundColor Red
    Write-Host " [ERRO CRITICO] / [CRITICAL ERROR]           " -ForegroundColor White
    Write-Host "=============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host " O idioma 'English (United States)' nao foi encontrado." -ForegroundColor Yellow
    Write-Host " The language 'English (United States)' was not found." -ForegroundColor Yellow
    Write-Host ""
    Write-Host " Para que o script funcione, voce precisa instalar este pacote." -ForegroundColor Gray
    Write-Host " For the script to work, you need to install this pack." -ForegroundColor Gray
    Write-Host ""
    Write-Host " Abrindo configuracoes do Windows..." -ForegroundColor Cyan
    Write-Host " Opening Windows settings..." -ForegroundColor Cyan
    Write-Host ""
    
    # Abre a tela de configuracao
    Start-Process "ms-settings:regionformatting"
    
    Write-Host " Pressione Enter para sair / Press Enter to exit" -ForegroundColor White
    Read-Host
    exit
}

# --- 3. FUNCAO DE DESENHO DO MENU ---
function Show-Menu {
    param (
        [array]$Options,
        [int]$SelectedIndex,
        [string]$CurrentRegion
    )
    Clear-Host
    # --- TITULO DUPLO ---
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "   GERADOR DE LAUNCHER GFL (Por Fabiopsyduck)" -ForegroundColor White
    Write-Host "   GFL LAUNCHER GENERATOR (By Fabiopsyduck)  " -ForegroundColor White
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
    
    # --- INSTRUCOES ---
    Write-Host "Use as setas (Cima/Baixo) e Enter:" -ForegroundColor DarkGray
    Write-Host "Use arrows (Up/Down) and Enter:" -ForegroundColor DarkGray
    Write-Host ""

    # --- OPCOES ---
    for ($i = 0; $i -lt $Options.Count; $i++) {
        if ($i -eq $SelectedIndex) {
            Write-Host " > $($Options[$i]) " -ForegroundColor Black -BackgroundColor Green
        } else {
            Write-Host "   $($Options[$i]) " -ForegroundColor Gray
        }
    }

    # --- AVISO DE REGIAO (ATUALIZAVEL) ---
    Write-Host ""
    Write-Host "---------------------------------------------" -ForegroundColor DarkGray
    Write-Host " Formato Regional Atual / Current Region: [$CurrentRegion]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host " ATENCAO: Este sera o formato restaurado ao fechar o jogo." -ForegroundColor DarkGray
    Write-Host " Se estiver incorreto, mude nas configuracoes do Windows agora." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " NOTE: This format will be restored when the game closes." -ForegroundColor DarkGray
    Write-Host " If incorrect, change it in Windows settings now." -ForegroundColor DarkGray
    Write-Host "---------------------------------------------" -ForegroundColor DarkGray
}

# --- 4. LOOP DO MENU (TEMPO REAL) ---
$opcoes = @("English (United States)", "Portugues (Brasil)")
$index = 0
$lastRegion = Get-CurrentRegion
$needsRedraw = $true

# Loop infinito ate pressionar Enter
while ($true) {
    # 1. Checa se a regiao mudou externamente
    $currentRegion = Get-CurrentRegion
    if ($currentRegion -ne $lastRegion) {
        $lastRegion = $currentRegion
        $needsRedraw = $true
    }

    # 2. Redesenha a tela se necessario
    if ($needsRedraw) {
        Show-Menu -Options $opcoes -SelectedIndex $index -CurrentRegion $lastRegion
        $needsRedraw = $false
    }

    # 3. Verifica entrada do teclado (sem bloquear o loop)
    if ([Console]::KeyAvailable) {
        $key = [Console]::ReadKey($true)
        
        if ($key.Key -eq "UpArrow") {
            $index--
            if ($index -lt 0) { $index = $opcoes.Count - 1 }
            $needsRedraw = $true
        }
        elseif ($key.Key -eq "DownArrow") {
            $index++
            if ($index -ge $opcoes.Count) { $index = 0 }
            $needsRedraw = $true
        }
        elseif ($key.Key -eq "Enter") {
            break # Sai do loop e gera o script
        }
    }

    # Pequena pausa para nao usar 100% da CPU
    Start-Sleep -Milliseconds 100
}

# --- 5. DEFINICAO DE TEXTOS (POS-SELECAO) ---
if ($index -eq 0) {
    # === ENGLISH SELECTED ===
    $msgGeradorSucesso = " [SUCCESS] File 'LauncherGFL.ps1' created!"
    $msgGeradorInterface = " Interface configured for: English"
    $msgGeradorRegiao = " System Region detected: $lastRegion"
    $msgGeradorAdmin = " Run the file 'LauncherGFL.ps1' as Administrator."
    $msgGeradorSair = " Press Enter to exit"

    # Conteudo Ingles
    $txtTitulo = "=== AUTOMATIC LAUNCHER: GIRLS' FRONTLINE (By Fabiopsyduck) ==="
    $txtAvisoFechar = "This window will close automatically when the game ends"
    $txtErroIngles = "[CRITICAL ERROR]"
    $txtErroInglesMsg = "The format 'English (United States)' was not found."
    $txtErroInglesInstrucao = "Please install English (US) language pack in Windows settings."
    $txtCancelando = "`nCanceling operation in 10 seconds..."
    $txtErroJogoAberto = "[ERROR] The game is already running!"
    $txtErroJogoAbertoMsg = "To avoid region conflicts, the script will be cancelled."
    $txtStatus = "Current Status: "
    $txtDetectadoMudar = "Detected System Region. Switching to English (US)..."
    $txtSistemaJaIngles = "System is already in en-US. Keeping as is."
    $txtAguardando = "`nWaiting 2 seconds..."
    $txtIniciandoSteam = "Starting game on Steam (ID: {0})..."
    $txtAguardandoProcesso = "Waiting for process '{0}' to start..."
    $txtJogoDetectado = " [DETECTED]"
    $txtMonitorando = "Game running. Monitoring..."
    $txtMinimizando = "Minimizing window..."
    $txtAvisoNaoEncontrado = "`n[WARNING] Process not found after 2 min."
    $txtRestaurandoErro = "Restoring region and exiting..."
    $txtJogoEncerrado = "`nGame closed!"
    $txtRestaurando = "Restoring region to {0}..."
    $txtFinalizando = "`nAll done. Closing in 3 seconds."
    $txtOkMudou = " [OK] Region changed to: "
    $txtErroMudou = " [ERROR] Failed to change region: "
}
else {
    # === PORTUGUES SELECTED ===
    $msgGeradorSucesso = " [SUCESSO] Arquivo 'LauncherGFL.ps1' criado!"
    $msgGeradorInterface = " Interface configurada para: Portugues"
    $msgGeradorRegiao = " Regiao do Sistema detectada: $lastRegion"
    $msgGeradorAdmin = " Execute o arquivo 'LauncherGFL.ps1' como Administrador."
    $msgGeradorSair = " Pressione Enter para sair"

    # Conteudo Portugues ASCII
    $txtTitulo = "=== LAUNCHER AUTOM$([char]193)TICO: GIRLS' FRONTLINE (Por Fabiopsyduck) ==="
    $txtAvisoFechar = "Esta janela fechar$([char]225) automaticamente ao encerrar o jogo"
    $txtErroIngles = "[ERRO CR$([char]205)TICO]"
    $txtErroInglesMsg = "O formato 'Ingl$([char]234)s (Estados Unidos)' n$([char]227)o foi encontrado."
    $txtErroInglesInstrucao = "Instale o pacote de idioma English (US) nas configura$([char]231)$([char]245)es."
    $txtCancelando = "`nCancelando opera$([char]231)$([char]227)o em 10 segundos..."
    $txtErroJogoAberto = "[ERRO] O jogo j$([char]225) est$([char]225) em execu$([char]231)$([char]227)o!"
    $txtErroJogoAbertoMsg = "Para evitar conflitos de regi$([char]227)o, o script ser$([char]225) cancelado."
    $txtStatus = "Status Atual: "
    $txtDetectadoMudar = "Detectado Regi$([char]227)o do Sistema. Mudando para Ingl$([char]234)s (US)..."
    $txtSistemaJaIngles = "Sistema j$([char]225) est$([char]225) em en-US. Mantendo."
    $txtAguardando = "`nAguardando 2 segundos..."
    $txtIniciandoSteam = "Iniciando o jogo na Steam (ID: {0})..."
    $txtAguardandoProcesso = "Aguardando processo '{0}' iniciar..."
    $txtJogoDetectado = " [DETECTADO]"
    $txtMonitorando = "Jogo em execu$([char]231)$([char]227)o. Monitorando..."
    $txtMinimizando = "Minimizando janela..."
    $txtAvisoNaoEncontrado = "`n[AVISO] Processo n$([char]227)o encontrado ap$([char]243)s 2 min."
    $txtRestaurandoErro = "Restaurando regi$([char]227)o e saindo..."
    $txtJogoEncerrado = "`nJogo encerrado!"
    $txtRestaurando = "Restaurando regi$([char]227)o para {0}..."
    $txtFinalizando = "`nTudo pronto. Fechando em 3 segundos."
    $txtOkMudou = " [OK] Regi$([char]227)o alterada para: "
    $txtErroMudou = " [ERRO] Falha ao alterar regi$([char]227)o: "
}

# --- 6. GERACAO DO ARQUIVO ---
$scriptContent = @"
<#
    SCRIPT: Launcher Automático Girls' Frontline (Por Fabiopsyduck)
#>

# --- 1. BLOQUEAR CRTL+C ---
[Console]::TreatControlCAsInput = `$true

# --- 2. API WINDOWS (BOTAO FECHAR + MINIMIZAR/RESTAURAR) ---
`$code = @'
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    
    [DllImport("user32.dll")]
    public static extern IntPtr GetSystemMenu(IntPtr hWnd, bool bRevert);
    
    [DllImport("user32.dll")]
    public static extern bool DeleteMenu(IntPtr hMenu, uint uPosition, uint uFlags);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
'@
Add-Type -TypeDefinition `$code

# Constantes e Bloqueio do X
`$SC_CLOSE = 0xF060
`$MF_BYCOMMAND = 0x0000
`$SW_MINIMIZE = 6
`$SW_RESTORE = 9
`$hwnd = [Win32]::GetConsoleWindow()
`$hmenu = [Win32]::GetSystemMenu(`$hwnd, `$false)
[Win32]::DeleteMenu(`$hmenu, `$SC_CLOSE, `$MF_BYCOMMAND) | Out-Null

# --- 3. CONFIGURACOES ---
`$steamAppId = "3887700"
`$nomeProcesso = "GirlsFrontLine" 

# --- 4. AJUSTE DE JANELA (SEM SCROLLBARS) ---
try {
    `$largura = 65
    `$altura = 20
    [System.Console]::SetBufferSize(120, 120) 
    [System.Console]::SetWindowSize(`$largura, `$altura)
    [System.Console]::SetBufferSize(`$largura, `$altura) 
} catch {}

# --- 5. VERIFICACAO DE ADMIN ---
`$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
`$principal = New-Object Security.Principal.WindowsPrincipal `$identity
if (!(`$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host "Solicitando permissao de administrador..." -ForegroundColor Yellow
    `$arguments = "& '" + `$myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb RunAs -ArgumentList `$arguments
    Break
}

# --- 6. FUNCOES ---
function Ler-Regiao {
    return (Get-ItemProperty "HKCU:\Control Panel\International" -Name "LocaleName").LocaleName
}

function Mudar-Regiao (`$novaCultura) {
    try {
        Set-Culture -CultureInfo `$novaCultura
        Start-Sleep -Milliseconds 500
        [System.Globalization.CultureInfo]::CurrentCulture.ClearCachedData()
        
        Write-Host "$txtOkMudou`$novaCultura" -ForegroundColor Green
    }
    catch {
        Write-Host "$txtErroMudou`$_" -ForegroundColor Red
    }
}

# --- 7. LOGICA PRINCIPAL ---
Clear-Host
Write-Host "$txtTitulo" -ForegroundColor Cyan
Write-Host "$txtAvisoFechar" -ForegroundColor DarkGray
Write-Host ""

# A) VERIFICACAO DE SEGURANCA: IDIOMA INGLES EXISTE?
`$enUsExiste = [System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::SpecificCultures) | Where-Object { `$_.Name -eq "en-US" }

if (-not `$enUsExiste) {
    Write-Host "$txtErroIngles" -ForegroundColor Red
    Write-Host "$txtErroInglesMsg" -ForegroundColor White
    Write-Host "$txtErroInglesInstrucao" -ForegroundColor Gray
    Write-Host "$txtCancelando"
    Start-Sleep -Seconds 10
    Exit
}

# B) VERIFICACAO DE SEGURANCA: JOGO JA ABERTO?
`$processoExistente = Get-Process -Name `$nomeProcesso -ErrorAction SilentlyContinue
if (`$processoExistente) {
    Write-Host "$txtErroJogoAberto" -ForegroundColor Red
    Write-Host "$txtErroJogoAbertoMsg" -ForegroundColor White
    Write-Host "`nFechando em 5 segundos..."
    Start-Sleep -Seconds 5
    Exit
}

# C) TROCA DE REGIAO
# Le a regiao atual do sistema (Dinamico)
`$regiaoOriginal = Ler-Regiao
Write-Host "$txtStatus`$regiaoOriginal"

# Se nao estiver em en-US, muda. Se ja estiver, nao faz nada.
if (`$regiaoOriginal -ne "en-US") {
    Write-Host "$txtDetectadoMudar" -ForegroundColor Yellow
    Mudar-Regiao "en-US"
} else {
    Write-Host "$txtSistemaJaIngles" -ForegroundColor Gray
}

# D) LANCAR O JOGO
Write-Host "$txtAguardando"
Start-Sleep -Seconds 2

Write-Host "$($txtIniciandoSteam -f '$steamAppId')" -ForegroundColor Cyan
Start-Process "steam://rungameid/`$steamAppId"

# E) AGUARDAR O JOGO ABRIR + MINIMIZAR
Write-Host "$($txtAguardandoProcesso -f '$nomeProcesso')" -NoNewline
`$timeout = 0
`$jogoIniciou = `$false

while (`$timeout -lt 120) { 
    `$processo = Get-Process -Name `$nomeProcesso -ErrorAction SilentlyContinue
    if (`$processo) {
        `$jogoIniciou = `$true
        Write-Host "$txtJogoDetectado" -ForegroundColor Green
        
        Write-Host "$txtMonitorando" -ForegroundColor Magenta
        
        Write-Host "$txtMinimizando" -ForegroundColor DarkGray
        Start-Sleep -Milliseconds 500
        [Win32]::ShowWindow(`$hwnd, `$SW_MINIMIZE) | Out-Null
        
        break
    }
    Start-Sleep -Seconds 1
    Write-Host "." -NoNewline
    `$timeout++
}

if (-not `$jogoIniciou) {
    Write-Host "$txtAvisoNaoEncontrado" -ForegroundColor Red
    Write-Host "$txtRestaurandoErro"
    
    # Restaura para a regiao original salva
    if (`$regiaoOriginal -ne "en-US") {
        Mudar-Regiao `$regiaoOriginal
    }
    
    Start-Sleep -Seconds 3
    Exit
}

# F) MONITORAR ENQUANTO JOGA (RODANDO MINIMIZADO)
while (`$true) {
    `$processo = Get-Process -Name `$nomeProcesso -ErrorAction SilentlyContinue
    if (-not `$processo) {
        # JOGO FECHOU -> RESTAURA A JANELA
        [Win32]::ShowWindow(`$hwnd, `$SW_RESTORE) | Out-Null
        Write-Host "$txtJogoEncerrado" -ForegroundColor Yellow
        break
    }
    
    if ([Console]::KeyAvailable) { `$null = [Console]::ReadKey(`$true) }
    Start-Sleep -Seconds 2 
}

# G) RESTAURAR REGIAO E SAIR
# So restaura se a original nao era Ingles
if (`$regiaoOriginal -ne "en-US") {
    Write-Host "$($txtRestaurando -f '$regiaoOriginal')"
    Mudar-Regiao `$regiaoOriginal
}

Write-Host "$txtFinalizando" -ForegroundColor Gray
Start-Sleep -Seconds 3
"@

# --- 7. GRAVACAO E SAIDA ---
$nomeArquivo = "LauncherGFL.ps1"
Set-Content -Path $nomeArquivo -Value $scriptContent -Encoding UTF8

Write-Host ""
Write-Host "-----------------------------------------------------" -ForegroundColor Green
Write-Host "$msgGeradorSucesso" -ForegroundColor Green
Write-Host "$msgGeradorInterface" -ForegroundColor White
Write-Host "$msgGeradorRegiao" -ForegroundColor White
Write-Host "$msgGeradorAdmin" -ForegroundColor Gray
Write-Host "-----------------------------------------------------" -ForegroundColor Green
Write-Host ""
Write-Host "$msgGeradorSair" -ForegroundColor DarkGray
[Console]::ReadKey($true) | Out-Null
[Console]::CursorVisible = $true