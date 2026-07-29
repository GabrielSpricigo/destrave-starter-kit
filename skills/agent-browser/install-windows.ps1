# Skill · agent-browser — Windows nativo
#
# CLI de navegação web para agentes (Vercel Labs). Instala Node LTS se
# faltar, o pacote global, e registra a regra de uso no CLAUDE.md do usuário.
#
# Idempotente.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\..\lib\detect-os.ps1"

Write-DestraveSection "Skill · agent-browser"

# --- 1. Node >= 20 ----------------------------------------------------------
$needsNode = $true
if (Get-Command node -ErrorAction SilentlyContinue) {
    try {
        $nodeVersion = (& node -v 2>&1 | Out-String).Trim()   # ex: v20.11.0
        $major = [int]($nodeVersion.TrimStart('v').Split('.')[0])
        if ($major -ge 20) {
            Write-DestraveOk "Node já instalado: $nodeVersion"
            $needsNode = $false
        } else {
            Write-DestraveWarn "Node $nodeVersion detectado, mas precisamos da versão 20 ou maior."
        }
    } catch {
        Write-DestraveWarn "Não consegui ler a versão do Node. Vou instalar a LTS."
    }
}

if ($needsNode) {
    if (-not (Install-DestraveWingetPackage -Id 'OpenJS.NodeJS.LTS' -Label 'Node.js LTS')) {
        exit 1
    }
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-DestraveWarn "Node instalado, mas ainda não visível neste terminal."
        Write-DestraveInfo "Feche este terminal, abra um novo e rode o instalador de novo."
        exit 1
    }
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-DestraveErr "npm não encontrado mesmo com o Node instalado."
    Write-DestraveInfo "Feche este terminal, abra um novo e rode de novo."
    exit 1
}

# --- 2. Pacote global -------------------------------------------------------
if (Get-Command agent-browser -ErrorAction SilentlyContinue) {
    Write-DestraveOk "agent-browser já instalado."
} else {
    Write-DestraveInfo "Instalando agent-browser..."
    # npm é comando nativo: dependendo da versão do pwsh o erro vem por exceção
    # ou só por exit code. Cobrimos os dois — senão o script "passa" sem instalar.
    $npmFalhou = $false
    try {
        & npm install -g 'agent-browser'
        if ($LASTEXITCODE -ne 0) { $npmFalhou = $true }
    } catch {
        $npmFalhou = $true
        Write-DestraveErr "Falha no npm install: $($_.Exception.Message)"
    }
    if ($npmFalhou) {
        Write-DestraveErr "npm não conseguiu instalar o agent-browser."
        Write-DestraveInfo "Tente na mão: npm install -g agent-browser"
        exit 1
    }
    if (Get-Command agent-browser -ErrorAction SilentlyContinue) {
        Write-DestraveOk "agent-browser instalado."
    } else {
        Write-DestraveWarn "npm terminou sem erro, mas 'agent-browser' ainda não aparece neste terminal."
        Write-DestraveInfo "Abra um terminal NOVO e confirme com: agent-browser --version"
    }
}

# --- 3. Regra no CLAUDE.md --------------------------------------------------
if (-not (New-DestraveDirVerified -Path $DestraveClaudeDir)) {
    Write-DestraveErr "Não consegui criar $DestraveClaudeDir"
    exit 1
}

$claudeMd = Join-Path $DestraveClaudeDir 'CLAUDE.md'
$marker   = '<!-- destrave-starter-kit:agent-browser -->'

$existing = ''
if (Test-Path -LiteralPath $claudeMd) {
    try { $existing = Get-Content -LiteralPath $claudeMd -Raw -ErrorAction Stop } catch { $existing = '' }
    if ($null -eq $existing) { $existing = '' }
}

if ($existing.Contains($marker)) {
    Write-DestraveOk "Regra do agent-browser já presente em $claudeMd"
} else {
    $rule = @"

$marker
## Navegação web

Quando precisar abrir um site, ler conteúdo da web, tirar screenshot ou interagir com UI:
use ``agent-browser`` (CLI Vercel Labs).

Hierarquia: API oficial > ``agent-browser`` > playwright > puppeteer.

Comando útil: ``agent-browser snapshot <url>`` devolve uma árvore com refs ``@eN``
(LLM-friendly). ``agent-browser click @e5``, ``agent-browser type @e3 "texto"``.

"@

    if (Write-DestraveFileVerified -Path $claudeMd -Content ($existing + $rule)) {
        Write-DestraveOk "Regra do agent-browser adicionada a $claudeMd"
    } else {
        Write-DestraveErr "Não consegui gravar $claudeMd"
        Show-DestraveControlledFolderHelp -BlockedPath $claudeMd
        exit 1
    }
}

Write-DestraveSection "agent-browser pronto"
Write-DestraveInfo "Teste: agent-browser snapshot https://example.com"
