# detect-os.ps1 — detecta versão Windows e exporta variáveis usadas pelos installers.
#
# Uso (em outro script PowerShell):
#   . "$PSScriptRoot\..\lib\detect-os.ps1"
#   Write-Host $DestraveOS          # win10 | win11 | unknown
#   Write-Host $DestravePkgManager  # winget | scoop | choco | unknown
#   Write-Host $DestraveClaudeDir   # %USERPROFILE%\.claude

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Detecção de SO ---------------------------------------------------------
$script:DestraveOS = 'unknown'
$script:DestraveArch = $env:PROCESSOR_ARCHITECTURE

try {
    $build = [int](Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).BuildNumber
    if ($build -ge 22000) {
        $script:DestraveOS = 'win11'
    } elseif ($build -ge 10240) {
        $script:DestraveOS = 'win10'
    }
} catch {
    $script:DestraveOS = 'unknown'
}

# --- Detecção de gerenciador de pacote --------------------------------------
$script:DestravePkgManager = 'unknown'
if (Get-Command winget -ErrorAction SilentlyContinue) {
    $script:DestravePkgManager = 'winget'
} elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
    $script:DestravePkgManager = 'scoop'
} elseif (Get-Command choco -ErrorAction SilentlyContinue) {
    $script:DestravePkgManager = 'choco'
}

$script:DestraveClaudeDir = Join-Path $env:USERPROFILE '.claude'

# Expor como variáveis de script para o caller
Set-Variable -Name DestraveOS         -Value $script:DestraveOS         -Scope Script
Set-Variable -Name DestravePkgManager -Value $script:DestravePkgManager -Scope Script
Set-Variable -Name DestraveArch       -Value $script:DestraveArch       -Scope Script
Set-Variable -Name DestraveClaudeDir  -Value $script:DestraveClaudeDir  -Scope Script

# --- Helpers de log ---------------------------------------------------------
function Write-DestraveInfo    { param([string]$Msg) Write-Host "ℹ  $Msg" -ForegroundColor Cyan }
function Write-DestraveOk      { param([string]$Msg) Write-Host "✓  $Msg" -ForegroundColor Green }
function Write-DestraveWarn    { param([string]$Msg) Write-Warning $Msg }
function Write-DestraveErr     { param([string]$Msg) Write-Host "✗  $Msg" -ForegroundColor Red }
function Write-DestraveSection {
    param([string]$Msg)
    Write-Host ""
    Write-Host "== " -NoNewline -ForegroundColor Cyan
    Write-Host $Msg -ForegroundColor White
}
