# install.ps1 — Master do Destrave Starter Kit no Windows
#
# Espelho do install.sh (Mac/Linux): mesmo menu, mesmas opções, mesmo resumo.
# A diferença é só o que roda por baixo — aqui é Windows nativo.
#
# Nada aqui exige Administrador. Nada aqui pede reboot.
#
# Histórico: até 07/2026 este script instalava WSL2 + Ubuntu, porque a Fase 0
# dependia de ZSH. Isso mudou — PSReadLine + Oh My Posh entregam a mesma
# experiência em Windows nativo, e o Claude Code e o RTK sempre rodaram do
# lado Windows de qualquer forma, mesmo quando chamados de dentro do WSL.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\lib\detect-os.ps1"

# --- Catálogo de skills -----------------------------------------------------
# MemPalace é opt-in: entra pela opção 6, nunca pelo "(a) Tudo".
$SkillKeys = @('terminal', 'rtk', 'dictation', 'agent-browser', 'wiki-template', 'done')

$SkillLabels = [ordered]@{
    'terminal'      = 'Fase 0 · Terminal (PowerShell 7 + autocomplete)'
    'rtk'           = 'RTK (token optimizer)'
    'dictation'     = 'Dictation (Whispering)'
    'agent-browser' = 'agent-browser'
    'wiki-template' = 'Wiki template'
    'done'          = '/done (ritual de fim)'
    'mempalace'     = 'MemPalace (avançado, opt-in)'
}

$SkillScripts = [ordered]@{
    'terminal'      = (Join-Path $PSScriptRoot 'terminal\install-windows.ps1')
    'rtk'           = (Join-Path $PSScriptRoot 'skills\rtk\install-windows.ps1')
    'dictation'     = (Join-Path $PSScriptRoot 'skills\dictation\install-windows.ps1')
    'agent-browser' = (Join-Path $PSScriptRoot 'skills\agent-browser\install-windows.ps1')
    'wiki-template' = (Join-Path $PSScriptRoot 'skills\wiki-template\install-windows.ps1')
    'done'          = (Join-Path $PSScriptRoot 'skills\done\install-windows.ps1')
    'mempalace'     = (Join-Path $PSScriptRoot 'skills\mempalace\install-windows.ps1')
}

$SkillStatus = @{}

# --- Host de execução -------------------------------------------------------
# Cada instalador roda em um processo separado: assim uma falha não derruba
# o master, e o menu segue para a próxima skill.
function Get-DestraveScriptHost {
    $pwshPath = Get-DestravePwshPath
    if ($pwshPath) { return $pwshPath }
    return (Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe')
}

function Invoke-DestraveSkill {
    param([Parameter(Mandatory)][string]$Key)

    $script = $SkillScripts[$Key]
    $label  = $SkillLabels[$Key]

    Write-DestraveSection ">>> $label"

    if (-not (Test-Path -LiteralPath $script)) {
        Write-DestraveErr "Instalador não encontrado: $script"
        $SkillStatus[$Key] = 'fail'
        return
    }

    # Re-resolvido a cada skill: depois da Fase 0 o pwsh 7 passa a existir.
    $scriptHost = Get-DestraveScriptHost

    try {
        & $scriptHost -NoProfile -ExecutionPolicy Bypass -File $script
        $code = $LASTEXITCODE
    } catch {
        Write-DestraveErr "$label · erro: $($_.Exception.Message)"
        $SkillStatus[$Key] = 'fail'
        return
    }

    if ($code -eq 0) {
        $SkillStatus[$Key] = 'ok'
        Write-DestraveOk "$label · concluído"
    } else {
        $SkillStatus[$Key] = 'fail'
        Write-DestraveErr "$label · falhou (código $code)"
    }
}

# --- Pre-flight -------------------------------------------------------------
Write-DestraveSection "Destrave Starter Kit · Instalação (Windows)"
Write-DestraveInfo "Windows: $DestraveOS · instalador de pacotes: $DestravePkgManager · arch: $DestraveArch"

if ($DestraveOS -eq 'unknown') {
    Write-DestraveWarn "Não consegui identificar sua versão do Windows. Vou tentar mesmo assim."
}

if ($DestravePkgManager -ne 'winget') {
    Write-DestraveErr "winget não encontrado — ele é o instalador de programas do Windows."
    Write-DestraveInfo "Abra a Microsoft Store, instale o 'Instalador de Aplicativo', reabra o terminal e rode de novo."
    exit 1
}

if (Test-DestraveControlledFolderAccess) {
    Write-DestraveWarn "O 'Acesso Controlado a Pastas' do Defender está ligado nesta máquina."
    Write-DestraveInfo "Se algo não puder ser gravado, o instalador avisa e usa um caminho alternativo."
}

# --- Menu -------------------------------------------------------------------
Write-Host ""
Write-Host "  [0] $($SkillLabels['terminal'])"
Write-Host ""
Write-Host "  Skills core:"
Write-Host "  [1] $($SkillLabels['rtk'])"
Write-Host "  [2] $($SkillLabels['dictation'])"
Write-Host "  [3] $($SkillLabels['agent-browser'])"
Write-Host "  [4] $($SkillLabels['wiki-template'])"
Write-Host "  [5] $($SkillLabels['done'])"
Write-Host ""
Write-Host "  Avançada (opt-in, FORA do 'a'):"
Write-Host "  [6] $($SkillLabels['mempalace'])"
Write-Host ""
Write-Host "  (a) Tudo — Fase 0 + skills 1-5    (b) Escolher um a um    (c) Sair"
Write-Host ""

# Trim: espaço sobrando (ou colado sem querer) não pode invalidar a escolha.
$choice = (Read-Host "> ").Trim()

switch -Regex ($choice) {
    '^[aA]$' {
        foreach ($key in $SkillKeys) { Invoke-DestraveSkill -Key $key }
    }
    '^[bB]$' {
        foreach ($key in $SkillKeys) {
            $answer = (Read-Host "Instalar $($SkillLabels[$key])? (s/N)").Trim()
            if ($answer -eq 's' -or $answer -eq 'S') {
                Invoke-DestraveSkill -Key $key
            } else {
                $SkillStatus[$key] = 'skip'
            }
        }
    }
    '^[cC]$' { Write-DestraveInfo "Saindo."; exit 0 }
    '^0$'    { Invoke-DestraveSkill -Key 'terminal' }
    '^1$'    { Invoke-DestraveSkill -Key 'rtk' }
    '^2$'    { Invoke-DestraveSkill -Key 'dictation' }
    '^3$'    { Invoke-DestraveSkill -Key 'agent-browser' }
    '^4$'    { Invoke-DestraveSkill -Key 'wiki-template' }
    '^5$'    { Invoke-DestraveSkill -Key 'done' }
    '^6$'    { Invoke-DestraveSkill -Key 'mempalace' }
    default  { Write-DestraveErr "Opção inválida: $choice"; exit 1 }
}

# --- Resumo final -----------------------------------------------------------
Write-Host ""
Write-DestraveSection "Resumo"

$allKeys = @($SkillKeys) + @('mempalace')
foreach ($key in $allKeys) {
    if (-not $SkillStatus.ContainsKey($key)) { continue }
    switch ($SkillStatus[$key]) {
        'ok'   { Write-Host "  ✓  $($SkillLabels[$key])" -ForegroundColor Green }
        'fail' { Write-Host "  ✗  $($SkillLabels[$key]) (veja o log acima)" -ForegroundColor Red }
        'skip' { Write-Host "  -  $($SkillLabels[$key]) (pulado)" -ForegroundColor Yellow }
    }
}

Write-Host ""
Write-DestraveInfo "Próximo: abra um terminal NOVO com 'pwsh' e teste 'rtk gain'."
Write-DestraveInfo "Documentação completa: README.md na raiz do repo."
