# bootstrap.ps1 — entrada de um comando só do Destrave Starter Kit (Windows)
#
# Uso (cole no PowerShell, não precisa ser Administrador):
#
#   powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/GabrielSpricigo/destrave-starter-kit/main/bootstrap.ps1 | iex"
#
# O que ele faz: baixa o kit para a sua pasta de usuário e abre o instalador.
# Não depende de git instalado (baixa o .zip) e não depende de $PSScriptRoot
# (este arquivo roda direto da internet, sem existir em disco).

$ErrorActionPreference = 'Stop'

$RepoOwner  = 'GabrielSpricigo'
$RepoName   = 'destrave-starter-kit'
$Branch     = 'main'
$TargetDir  = Join-Path $env:USERPROFILE $RepoName

function Write-Step { param([string]$Msg) Write-Host "==  $Msg" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Msg) Write-Host "✓  $Msg" -ForegroundColor Green }
function Write-Bad  { param([string]$Msg) Write-Host "✗  $Msg" -ForegroundColor Red }

try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

# TLS 1.2 explícito: em Windows 10 mais antigo o padrão ainda é TLS 1.0,
# e o GitHub recusa a conexão sem dizer o porquê.
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch { }

Write-Step "Destrave Starter Kit"
Write-Host ""

# --- 1. Trazer o kit para o disco -------------------------------------------
$isGitRepo = (Test-Path -LiteralPath (Join-Path $TargetDir '.git'))
$hasGit    = [bool](Get-Command git -ErrorAction SilentlyContinue)

if ($isGitRepo -and $hasGit) {
    Write-Step "Atualizando o kit que já está em $TargetDir"
    try {
        & git -C $TargetDir pull --ff-only
        Write-Ok "Kit atualizado."
    } catch {
        Write-Host "Não consegui atualizar via git; seguindo com a versão que já está no disco." -ForegroundColor Yellow
    }
} else {
    Write-Step "Baixando o kit..."

    $zipUrl  = "https://github.com/$RepoOwner/$RepoName/archive/refs/heads/$Branch.zip"
    $tempZip = Join-Path $env:TEMP "$RepoName-$Branch.zip"
    $tempDir = Join-Path $env:TEMP "$RepoName-extract"

    try {
        $previousProgress = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'   # sem isso o download fica lentíssimo
        Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip -UseBasicParsing -ErrorAction Stop
        $ProgressPreference = $previousProgress
    } catch {
        Write-Bad "Falha ao baixar o kit: $($_.Exception.Message)"
        Write-Host "  Verifique sua internet e tente de novo." -ForegroundColor Yellow
        exit 1
    }

    if (Test-Path -LiteralPath $tempDir) {
        Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    try {
        Expand-Archive -LiteralPath $tempZip -DestinationPath $tempDir -Force -ErrorAction Stop
    } catch {
        Write-Bad "Falha ao descompactar: $($_.Exception.Message)"
        exit 1
    }

    # O zip do GitHub extrai numa pasta "<repo>-<branch>"
    $extracted = Get-ChildItem -LiteralPath $tempDir -Directory | Select-Object -First 1
    if (-not $extracted) {
        Write-Bad "O arquivo baixado veio vazio."
        exit 1
    }

    if (-not (Test-Path -LiteralPath $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    Copy-Item -Path (Join-Path $extracted.FullName '*') -Destination $TargetDir -Recurse -Force

    Remove-Item -LiteralPath $tempZip -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue

    Write-Ok "Kit em $TargetDir"
}

# --- 2. Abrir o instalador --------------------------------------------------
$installer = Join-Path $TargetDir 'install.ps1'
if (-not (Test-Path -LiteralPath $installer)) {
    Write-Bad "Instalador não encontrado em $installer"
    exit 1
}

Write-Host ""
Write-Step "Abrindo o instalador"
Write-Host ""

# Rodar em processo próprio garante o ExecutionPolicy Bypass mesmo se a
# política da máquina bloquear scripts.
$psExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$pwsh  = Get-Command pwsh -ErrorAction SilentlyContinue
if ($pwsh) { $psExe = $pwsh.Source }

& $psExe -NoProfile -ExecutionPolicy Bypass -File $installer
exit $LASTEXITCODE
