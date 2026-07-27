# Skill · Wiki template — Windows nativo
#
# Copia o esqueleto da wiki (segundo cérebro) para uma pasta que você escolhe.
# Arquivos que já existem no destino nunca são sobrescritos — se você já tem
# uma wiki, rodar de novo só preenche o que falta.
#
# Idempotente.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\..\lib\detect-os.ps1"

Write-DestraveSection "Skill · Wiki template"

$templateDir = Join-Path $PSScriptRoot 'template'
if (-not (Test-Path -LiteralPath $templateDir)) {
    Write-DestraveErr "Template não encontrado em $templateDir"
    exit 1
}

# --- Onde criar a wiki ------------------------------------------------------
$defaultDest = if ($env:DESTRAVE_WIKI_DEST) {
    $env:DESTRAVE_WIKI_DEST
} else {
    Join-Path (Get-Location).Path 'wiki'
}

$dest = $defaultDest
try {
    $answer = Read-Host "Onde criar a wiki? [$defaultDest]"
    if (-not [string]::IsNullOrWhiteSpace($answer)) { $dest = $answer }
} catch {
    # rodando sem terminal interativo — fica no default
    $dest = $defaultDest
}

# Expansão de ~ (o mentorado pode digitar ~\wiki por costume)
if ($dest.StartsWith('~')) {
    $dest = Join-Path $env:USERPROFILE $dest.Substring(1).TrimStart('\', '/')
}

if (-not (New-DestraveDirVerified -Path $dest)) {
    Write-DestraveErr "Não consegui criar $dest"
    Show-DestraveControlledFolderHelp -BlockedPath $dest
    exit 1
}

# --- Copiar preservando o que já existe -------------------------------------
$copied = 0
$kept   = 0
$failed = 0

$templateRoot = (Resolve-Path -LiteralPath $templateDir).Path

Get-ChildItem -LiteralPath $templateDir -Recurse -File -Force | ForEach-Object {
    $relative = $_.FullName.Substring($templateRoot.Length).TrimStart('\', '/')
    $target   = Join-Path $dest $relative

    if (Test-Path -LiteralPath $target) {
        $kept++
        return
    }

    if (Copy-DestraveFileVerified -Source $_.FullName -Destination $target) {
        $copied++
    } else {
        $failed++
        Write-DestraveWarn "Falhou ao copiar: $relative"
    }
}

if ($failed -gt 0) {
    Write-DestraveErr "$failed arquivo(s) não puderam ser gravados."
    Show-DestraveControlledFolderHelp -BlockedPath $dest
    exit 1
}

Write-DestraveOk "Wiki criada em $dest ($copied novo(s), $kept preservado(s))"

Write-Host ""
Write-Host "  Estrutura:"
Write-Host "    _schema.md    — regras pro LLM manter a wiki"
Write-Host "    index.md      — mapa principal"
Write-Host "    log.md        — log append-only de operações"
Write-Host "    clientes/     — uma página por cliente"
Write-Host "    padroes/      — processos repetíveis"
Write-Host "    decisoes/     — ADRs"
Write-Host "    projetos/     — seus projetos próprios"
Write-Host "    _fontes/      — raw sources (transcrições, dossiês)"
Write-Host ""
Write-DestraveInfo "Aponte o Obsidian pra essa pasta pra navegar o grafo."
