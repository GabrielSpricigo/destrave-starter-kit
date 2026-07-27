# Fase 0 (Windows nativo) — Terminal produtivo
#
# Equivalente Windows do install-mac-linux.sh (que instala ZSH + Oh My Zsh).
# Aqui: PowerShell 7 + PSReadLine (autocomplete) + Oh My Posh (prompt).
#
# Nada aqui precisa de Administrador. Nada aqui pede reboot.
# Idempotente: rodar de novo não duplica nem quebra.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\lib\detect-os.ps1"

Write-DestraveSection "Fase 0 · Terminal (PowerShell 7 + autocomplete + prompt)"

# --- 1. winget é pré-requisito ----------------------------------------------
if ($DestravePkgManager -ne 'winget') {
    Write-DestraveErr "winget não encontrado — ele é o instalador de programas do Windows."
    Write-DestraveInfo "Abra a Microsoft Store, instale o 'Instalador de Aplicativo' e rode de novo."
    exit 1
}

# --- 2. PowerShell 7 --------------------------------------------------------
# Por que: o PowerShell que já vem no Windows é a versão 5.1, cujo PSReadLine
# (2.0) é anterior ao autocomplete preditivo. O 7 traz o PSReadLine 2.4.
if (-not (Install-DestraveWingetPackage -Id 'Microsoft.PowerShell' -Label 'PowerShell 7')) {
    exit 1
}

# --- 3. Oh My Posh (o prompt) -----------------------------------------------
$poshOk = Install-DestraveWingetPackage -Id 'JanDeDobbeleer.OhMyPosh' -Label 'Oh My Posh (prompt bonito)'
if (-not $poshOk) {
    Write-DestraveWarn "Sigo sem o prompt customizado — o autocomplete não depende dele."
}

# --- 4. Localizar o pwsh ----------------------------------------------------
$pwshPath = Get-DestravePwshPath
if (-not $pwshPath) {
    Write-DestraveErr "O PowerShell 7 foi instalado, mas ainda não apareceu no PATH."
    Write-DestraveInfo "Feche este terminal, abra um novo e rode o instalador de novo."
    exit 1
}
Write-DestraveOk "PowerShell 7 em: $pwshPath"

# --- 5. Descobrir onde fica o perfil do PowerShell 7 ------------------------
# Perguntamos ao próprio pwsh: o caminho muda conforme a instalação.
try {
    $profilePath = (& $pwshPath -NoProfile -Command '$PROFILE' | Out-String).Trim()
} catch {
    $profilePath = ''
}

if ([string]::IsNullOrWhiteSpace($profilePath)) {
    Write-DestraveErr "Não consegui descobrir o caminho do perfil do PowerShell 7."
    exit 1
}

$srcProfile = Join-Path $PSScriptRoot 'pwsh-profile.ps1'
$srcTheme   = Join-Path $PSScriptRoot 'robbyrussell.omp.json'

foreach ($required in @($srcProfile, $srcTheme)) {
    if (-not (Test-Path -LiteralPath $required)) {
        Write-DestraveErr "Arquivo do kit não encontrado: $required"
        exit 1
    }
}

# --- 6. Backup do perfil atual (uma vez só) ---------------------------------
$backupPath = "$profilePath.destrave-backup"
if ((Test-Path -LiteralPath $profilePath) -and -not (Test-Path -LiteralPath $backupPath)) {
    if (Copy-DestraveFileVerified -Source $profilePath -Destination $backupPath) {
        Write-DestraveOk "Backup do seu perfil anterior: $backupPath"
    } else {
        Write-DestraveWarn "Não consegui fazer backup do perfil atual. Sigo sem sobrescrever."
    }
}

# --- 7. Instalar perfil + tema ----------------------------------------------
# Atenção: com o "Acesso Controlado a Pastas" do Defender ligado, gravar em
# Documentos falha SEM AVISAR — por isso usamos cópia verificada e conferimos
# o resultado em vez de confiar no retorno.
$profileDir      = Split-Path -Parent $profilePath
$installedTo     = ''
$usedFallback    = $false

if (Copy-DestraveFileVerified -Source $srcProfile -Destination $profilePath) {
    $installedTo = $profilePath
    $null = Copy-DestraveFileVerified -Source $srcTheme -Destination (Join-Path $profileDir 'robbyrussell.omp.json')
    Write-DestraveOk "Perfil instalado em: $profilePath"
} else {
    # Fallback: pasta própria do kit, que a proteção não cobre.
    $usedFallback  = $true
    $fallbackDir   = Join-Path $env:USERPROFILE '.destrave'
    $fallbackFile  = Join-Path $fallbackDir 'pwsh-profile.ps1'

    Show-DestraveControlledFolderHelp -BlockedPath $profilePath

    if (Copy-DestraveFileVerified -Source $srcProfile -Destination $fallbackFile) {
        $installedTo = $fallbackFile
        $null = Copy-DestraveFileVerified -Source $srcTheme -Destination (Join-Path $fallbackDir 'robbyrussell.omp.json')
        Write-DestraveOk "Perfil instalado no caminho alternativo: $fallbackFile"
    } else {
        Write-DestraveErr "Não consegui gravar o perfil em lugar nenhum."
        Write-DestraveInfo "Rode o comando de liberação mostrado acima e tente de novo."
        exit 1
    }
}

# --- 8. Conferir a versão do PSReadLine -------------------------------------
try {
    $prlVersion = (& $pwshPath -NoProfile -Command `
        '(Get-Module -ListAvailable PSReadLine | Sort-Object Version -Descending | Select-Object -First 1).Version.ToString()' `
        | Out-String).Trim()
    if ($prlVersion) {
        $parts = $prlVersion.Split('.')
        $major = [int]$parts[0]
        $minor = [int]$parts[1]
        if ($major -gt 2 -or ($major -eq 2 -and $minor -ge 2)) {
            Write-DestraveOk "PSReadLine $prlVersion — autocomplete preditivo disponível."
        } else {
            Write-DestraveWarn "PSReadLine $prlVersion é antigo demais para a sugestão em cinza."
            Write-DestraveInfo "No PowerShell 7, rode: Install-Module PSReadLine -Force -Scope CurrentUser"
        }
    }
} catch {
    Write-DestraveWarn "Não consegui checar a versão do PSReadLine (não é bloqueante)."
}

# --- 9. Próximos passos -----------------------------------------------------
Write-DestraveSection "Fase 0 concluída"
Write-Host ""
Write-Host "  Abra um terminal NOVO com o PowerShell 7 (o comando é " -NoNewline
Write-Host "pwsh" -ForegroundColor Cyan -NoNewline
Write-Host ")."
Write-Host ""
Write-Host "  O que você deve ver:" -ForegroundColor White
Write-Host "    · prompt no estilo da aula (setinha + pasta + branch do git)"
Write-Host "    · sugestão em cinza enquanto digita — aceite com a seta →"
Write-Host "    · Tab abre o menu de opções; ↑ e ↓ buscam no histórico"
Write-Host ""

if ($usedFallback) {
    Write-Host "  ATENÇÃO: seu perfil ficou em um caminho alternativo." -ForegroundColor Yellow
    Write-Host "  Enquanto a pasta Documentos estiver protegida, carregue com:" -ForegroundColor Yellow
    Write-Host "    . `"$installedTo`"" -ForegroundColor Cyan
    Write-Host ""
}

Write-DestraveInfo "Dica: no Windows Terminal, vá em Configurações > Perfil padrão e escolha PowerShell 7."
Write-DestraveInfo "Assim todo terminal novo já abre com o autocomplete ligado."
