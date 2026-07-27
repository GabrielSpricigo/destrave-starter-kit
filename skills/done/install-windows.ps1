# Skill · /done — Windows nativo
#
# Copia o SKILL.md para ~/.claude/skills/done/.
# Se você já usa a skill e ela tem calibrações suas registradas,
# o arquivo é preservado — sua customização não é perdida.
#
# Idempotente.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\..\lib\detect-os.ps1"

Write-DestraveSection "Skill · /done"

$source = Join-Path $PSScriptRoot 'SKILL.md'
if (-not (Test-Path -LiteralPath $source)) {
    Write-DestraveErr "SKILL.md não encontrado em $source"
    exit 1
}

$destDir  = Join-Path $DestraveClaudeDir 'skills\done'
$destFile = Join-Path $destDir 'SKILL.md'

if (-not (New-DestraveDirVerified -Path $destDir)) {
    Write-DestraveErr "Não consegui criar $destDir"
    Show-DestraveControlledFolderHelp -BlockedPath $destDir
    exit 1
}

# --- Preservar calibrações do usuário ---------------------------------------
# Uma calibração é uma linha no formato "- [2026-05-03] regra...".
# Se existir pelo menos uma, o arquivo é do usuário e não sobrescrevemos.
if (Test-Path -LiteralPath $destFile) {
    $hasCalibration = $false
    try {
        $current = Get-Content -LiteralPath $destFile -ErrorAction Stop
        foreach ($line in $current) {
            if ($line -match '^- \[20\d{2}-') { $hasCalibration = $true; break }
        }
    } catch {
        $hasCalibration = $false
    }

    if ($hasCalibration) {
        Write-DestraveWarn "$destFile já tem calibrações registradas. Preservando seu arquivo."
        Write-DestraveInfo "Para forçar a substituição: apague o arquivo e rode de novo."
        exit 0
    }
    Write-DestraveInfo "Substituindo $destFile (sem calibrações próprias)."
}

if (Copy-DestraveFileVerified -Source $source -Destination $destFile) {
    Write-DestraveOk "Skill /done instalada em $destFile"
} else {
    Write-DestraveErr "Não consegui gravar $destFile"
    Show-DestraveControlledFolderHelp -BlockedPath $destFile
    exit 1
}

Write-DestraveInfo "Em uma sessão do Claude Code: digite '/done' ao terminar uma etapa ou projeto."
