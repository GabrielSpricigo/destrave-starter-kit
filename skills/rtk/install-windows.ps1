# Skill · RTK (token optimizer) — Windows nativo
#
# Instala o rtk e liga o hook do Claude Code. Depois disso, comandos como
# `git status` são reescritos para `rtk git status` automaticamente,
# economizando 60-90% de tokens em operações de desenvolvimento.
#
# Diferença para o Mac/Linux: lá o kit instala jq, copia um script auxiliar
# (rtk-rewrite.sh) e edita o settings.json com um filtro jq. Aqui nada disso
# é necessário — o rtk moderno traz `rtk hook claude` embutido, que já lê o
# JSON do Claude Code direto. Sem jq, sem bash, sem script extra.
#
# Idempotente.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\..\lib\detect-os.ps1"

Write-DestraveSection "Skill · RTK (token optimizer)"

$HookCommand = 'rtk hook claude'

# Test-DestraveJsonProperty vem de lib/detect-os.ps1

# --- 1. Binário -------------------------------------------------------------
if (-not (Install-DestraveWingetPackage -Id 'rtk-ai.rtk' -Label 'RTK')) {
    Write-DestraveInfo "Alternativa manual: https://github.com/rtk-ai/rtk"
    exit 1
}

# O winget pode ter instalado agora e o PATH desta sessão ainda não refletir.
if (-not (Get-Command rtk -ErrorAction SilentlyContinue)) {
    Write-DestraveWarn "rtk instalado, mas ainda não visível neste terminal."
    Write-DestraveInfo "Feche este terminal, abra um novo e rode o instalador de novo."
    exit 1
}

try {
    $rtkVersion = (& rtk --version 2>&1 | Out-String).Trim()
    Write-DestraveOk "rtk disponível: $rtkVersion"
} catch {
    Write-DestraveWarn "rtk não respondeu ao --version, mas está no PATH. Seguindo."
}

# --- 2. settings.json do Claude Code ---------------------------------------
if (-not (New-DestraveDirVerified -Path $DestraveClaudeDir)) {
    Write-DestraveErr "Não consegui criar $DestraveClaudeDir"
    exit 1
}

$settingsPath = Join-Path $DestraveClaudeDir 'settings.json'

if (-not (Test-Path -LiteralPath $settingsPath)) {
    if (-not (Write-DestraveFileVerified -Path $settingsPath -Content '{}')) {
        Write-DestraveErr "Não consegui criar $settingsPath"
        exit 1
    }
    Write-DestraveInfo "Criado settings.json vazio em $settingsPath"
}

# Backup uma única vez
$backupPath = "$settingsPath.destrave-backup"
if (-not (Test-Path -LiteralPath $backupPath)) {
    $null = Copy-DestraveFileVerified -Source $settingsPath -Destination $backupPath
}

# --- 3. Ler e validar o JSON existente --------------------------------------
try {
    $raw = Get-Content -LiteralPath $settingsPath -Raw -ErrorAction Stop
} catch {
    Write-DestraveErr "Não consegui ler $settingsPath"
    exit 1
}
if ([string]::IsNullOrWhiteSpace($raw)) { $raw = '{}' }

try {
    $settings = $raw | ConvertFrom-Json -ErrorAction Stop
} catch {
    Write-DestraveErr "Seu settings.json tem erro de sintaxe e não posso editá-lo com segurança."
    Write-DestraveInfo "Arquivo: $settingsPath"
    Write-DestraveInfo "Corrija o JSON (ou renomeie o arquivo) e rode de novo."
    exit 1
}

# --- 4. Inserir o hook, sem duplicar ----------------------------------------
if (-not (Test-DestraveJsonProperty -InputObject $settings -Name 'hooks')) {
    Add-Member -InputObject $settings -NotePropertyName 'hooks' -NotePropertyValue ([PSCustomObject]@{}) -Force
}
if (-not (Test-DestraveJsonProperty -InputObject $settings.hooks -Name 'PreToolUse')) {
    Add-Member -InputObject $settings.hooks -NotePropertyName 'PreToolUse' -NotePropertyValue @() -Force
}

$alreadyRegistered = $false
foreach ($entry in @($settings.hooks.PreToolUse)) {
    if (-not (Test-DestraveJsonProperty -InputObject $entry -Name 'hooks')) { continue }
    foreach ($hook in @($entry.hooks)) {
        if ((Test-DestraveJsonProperty -InputObject $hook -Name 'command') -and $hook.command -eq $HookCommand) {
            $alreadyRegistered = $true
        }
    }
}

if ($alreadyRegistered) {
    Write-DestraveOk "Hook do RTK já estava registrado em settings.json."
} else {
    $newEntry = [PSCustomObject]@{
        matcher = 'Bash'
        hooks   = @([PSCustomObject]@{ type = 'command'; command = $HookCommand })
    }
    $settings.hooks.PreToolUse = @(@($settings.hooks.PreToolUse) + $newEntry)

    $json = $settings | ConvertTo-Json -Depth 20
    if (Write-DestraveFileVerified -Path $settingsPath -Content $json) {
        Write-DestraveOk "Hook do RTK adicionado a settings.json."
    } else {
        Write-DestraveErr "Não consegui gravar $settingsPath"
        Show-DestraveControlledFolderHelp -BlockedPath $settingsPath
        exit 1
    }
}

# --- 5. Smoke test ----------------------------------------------------------
Write-DestraveSection "Teste rápido"
try {
    $check = (& rtk hook check "git status" 2>&1 | Out-String).Trim()
    if ($check) {
        Write-Host $check
    }
} catch {
    Write-DestraveWarn "O teste do hook não rodou, mas a configuração foi gravada."
}

Write-DestraveOk "RTK pronto. Em uma sessão NOVA do Claude Code, os comandos já entram otimizados."
Write-DestraveInfo "Para ver quanto economizou depois de algumas sessões: rtk gain"
