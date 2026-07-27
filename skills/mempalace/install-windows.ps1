# Skill · MemPalace (opt-in, avançado) — Windows nativo
#
# Memória semântica persistente entre conversas. Requer Python 3.10+.
# Fica FORA da opção "Tudo" do menu de propósito: se você está começando,
# a wiki resolve a maior parte do problema com muito menos peça móvel.
#
# Idempotente.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\..\lib\detect-os.ps1"

Write-DestraveSection "Skill · MemPalace (opt-in)"
Write-DestraveWarn "Avançado. Pule se está começando — a wiki resolve 80% do problema."

# Test-DestraveJsonProperty vem de lib/detect-os.ps1

# --- 1. Python 3.10+ --------------------------------------------------------
function Get-DestravePython {
    foreach ($candidate in @('python3', 'python', 'py')) {
        $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
        if (-not $cmd) { continue }
        try {
            $ver = (& $cmd.Source -c "import sys; print(sys.version_info[0]*100+sys.version_info[1])" 2>&1 | Out-String).Trim()
            if ($ver -match '^\d+$' -and [int]$ver -ge 310) { return $cmd.Source }
        } catch {
            continue
        }
    }
    return $null
}

$pythonBin = Get-DestravePython

if (-not $pythonBin) {
    Write-DestraveInfo "Python 3.10+ não encontrado. Instalando..."
    if (-not (Install-DestraveWingetPackage -Id 'Python.Python.3.12' -Label 'Python 3.12')) {
        exit 1
    }
    $pythonBin = Get-DestravePython
    if (-not $pythonBin) {
        Write-DestraveWarn "Python instalado, mas ainda não visível neste terminal."
        Write-DestraveInfo "Feche este terminal, abra um novo e rode de novo."
        exit 1
    }
}

$pythonVersion = (& $pythonBin --version 2>&1 | Out-String).Trim()
Write-DestraveOk "Python: $pythonBin ($pythonVersion)"

# --- 2. Pacote mempalace ----------------------------------------------------
$alreadyInstalled = $false
try {
    $show = (& $pythonBin -m pip show mempalace 2>&1 | Out-String)
    if ($show -match 'Version:\s*(\S+)') {
        Write-DestraveOk "mempalace já instalado (v$($Matches[1]))"
        $alreadyInstalled = $true
    }
} catch {
    $alreadyInstalled = $false
}

if (-not $alreadyInstalled) {
    Write-DestraveInfo "Instalando mempalace via pip (1-3 min — o chromadb traz muitas dependências)..."
    try {
        & $pythonBin -m pip install --user --upgrade mempalace
    } catch {
        Write-DestraveErr "Falha no pip install: $($_.Exception.Message)"
        exit 1
    }
    Write-DestraveOk "mempalace instalado."
}

# --- 3. Registrar o servidor MCP no projeto ---------------------------------
$defaultProject = (Get-Location).Path
$project = $defaultProject
try {
    $answer = Read-Host "Qual é a raiz do seu projeto? [$defaultProject]"
    if (-not [string]::IsNullOrWhiteSpace($answer)) { $project = $answer }
} catch {
    $project = $defaultProject
}

if ($project.StartsWith('~')) {
    $project = Join-Path $env:USERPROFILE $project.Substring(1).TrimStart('\', '/')
}

if (-not (New-DestraveDirVerified -Path $project)) {
    Write-DestraveErr "Não consegui acessar/criar $project"
    exit 1
}

$mcpFile = Join-Path $project '.mcp.json'

$serverConfig = [PSCustomObject]@{
    command = $pythonBin
    args    = @('-m', 'mempalace.mcp_server')
    env     = [PSCustomObject]@{ MEMPALACE_DIR = $project }
}

$mcpRoot = $null
if (Test-Path -LiteralPath $mcpFile) {
    try {
        $existingRaw = Get-Content -LiteralPath $mcpFile -Raw -ErrorAction Stop
        if (-not [string]::IsNullOrWhiteSpace($existingRaw)) {
            $mcpRoot = $existingRaw | ConvertFrom-Json -ErrorAction Stop
        }
    } catch {
        Write-DestraveErr "$mcpFile existe mas tem JSON inválido — não vou sobrescrever."
        Write-DestraveInfo "Corrija o arquivo (ou renomeie) e rode de novo."
        exit 1
    }
}

if ($null -eq $mcpRoot) { $mcpRoot = [PSCustomObject]@{} }

if (-not (Test-DestraveJsonProperty -InputObject $mcpRoot -Name 'mcpServers')) {
    Add-Member -InputObject $mcpRoot -NotePropertyName 'mcpServers' -NotePropertyValue ([PSCustomObject]@{}) -Force
}
Add-Member -InputObject $mcpRoot.mcpServers -NotePropertyName 'mempalace' -NotePropertyValue $serverConfig -Force

$mcpJson = $mcpRoot | ConvertTo-Json -Depth 20
if (Write-DestraveFileVerified -Path $mcpFile -Content $mcpJson) {
    Write-DestraveOk "$mcpFile configurado (outros servidores MCP foram preservados)."
} else {
    Write-DestraveErr "Não consegui gravar $mcpFile"
    Show-DestraveControlledFolderHelp -BlockedPath $mcpFile
    exit 1
}

Write-DestraveSection "Próximos passos"
Write-Host "  1. Reinicie o Claude Code."
Write-Host "  2. Em uma sessão dentro de $project, teste: 'rode mempalace_status'."
Write-Host "  3. Leia o README.md desta skill antes de começar a gravar memórias."
