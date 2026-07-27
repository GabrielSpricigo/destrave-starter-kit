# detect-os.ps1 — detecta ambiente Windows e exporta helpers usados pelos installers.
#
# Uso (em outro script PowerShell):
#   . "$PSScriptRoot\..\lib\detect-os.ps1"
#   Write-Host $DestraveOS          # win10 | win11 | unknown
#   Write-Host $DestravePkgManager  # winget | scoop | choco | unknown
#   Write-Host $DestraveClaudeDir   # %USERPROFILE%\.claude
#
# IMPORTANTE: este arquivo (e todo .ps1 do kit) precisa ser salvo em
# UTF-8 COM BOM. Sem o BOM, o Windows PowerShell 5.1 lê como ANSI e todo
# acento vira lixo ("instalação" -> "instalaÃ§Ã£o") na tela do mentorado.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Console em UTF-8 -------------------------------------------------------
# Sem isto, acentos e os símbolos ✓/✗ saem quebrados no console legado.
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch {
    # console que não aceita troca de encoding — segue, só a estética sofre
}

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

# --- Escrita verificada -----------------------------------------------------
# Por que existe: com o "Acesso Controlado a Pastas" do Defender ligado, gravar
# em Documents FALHA EM SILÊNCIO — New-Item retorna sucesso e o arquivo não
# existe depois. Nunca confie no retorno; escreva, releia e confirme.

function New-DestraveDirVerified {
    param([Parameter(Mandatory)][string]$Path)

    if (Test-Path -LiteralPath $Path) { return $true }
    try {
        New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop | Out-Null
    } catch {
        return $false
    }
    # a verificação é o ponto: criar "com sucesso" não prova que existe
    return (Test-Path -LiteralPath $Path)
}

function Write-DestraveFileVerified {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][AllowEmptyString()][string]$Content
    )

    $dir = Split-Path -Parent $Path
    if ($dir -and -not (New-DestraveDirVerified -Path $dir)) { return $false }

    try {
        Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8 -ErrorAction Stop
    } catch {
        return $false
    }
    if (-not (Test-Path -LiteralPath $Path)) { return $false }

    try {
        $readBack = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
    } catch {
        return $false
    }
    if ($null -eq $readBack) { return $false }
    return ($readBack.Trim() -eq $Content.Trim())
}

function Copy-DestraveFileVerified {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) { return $false }

    $dir = Split-Path -Parent $Destination
    if ($dir -and -not (New-DestraveDirVerified -Path $dir)) { return $false }

    try {
        Copy-Item -LiteralPath $Source -Destination $Destination -Force -ErrorAction Stop
    } catch {
        return $false
    }
    if (-not (Test-Path -LiteralPath $Destination)) { return $false }

    try {
        $srcHash = (Get-FileHash -LiteralPath $Source      -Algorithm SHA256).Hash
        $dstHash = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash
    } catch {
        return $false
    }
    return ($srcHash -eq $dstHash)
}

function Test-DestraveControlledFolderAccess {
    # true = proteção ligada em modo bloqueio (a que causa a falha silenciosa)
    try {
        $pref = Get-MpPreference -ErrorAction Stop
        return ([int]$pref.EnableControlledFolderAccess -eq 1)
    } catch {
        return $false
    }
}

function Show-DestraveControlledFolderHelp {
    param([string]$BlockedPath)

    Write-DestraveWarn "Não consegui gravar em: $BlockedPath"
    Write-Host ""
    Write-Host "  Causa provável: 'Acesso Controlado a Pastas' do Windows Defender." -ForegroundColor Yellow
    Write-Host "  Ele bloqueia gravação em Documentos sem dar mensagem de erro." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Segui por um caminho alternativo, então a instalação continua." -ForegroundColor Gray
    Write-Host "  Se quiser usar o caminho padrão, abra o PowerShell como" -ForegroundColor Gray
    Write-Host "  Administrador e rode:" -ForegroundColor Gray
    Write-Host ""
    Write-Host "    Set-MpPreference -EnableControlledFolderAccess Disabled" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  (ou libere só o PowerShell, em Segurança do Windows >" -ForegroundColor Gray
    Write-Host "   Proteção contra ransomware > Permitir um aplicativo)" -ForegroundColor Gray
    Write-Host ""
}

# --- JSON -------------------------------------------------------------------
function Test-DestraveJsonProperty {
    param($InputObject, [string]$Name)

    if ($null -eq $InputObject) { return $false }

    # Cuidado: NÃO usar $InputObject.PSObject.Properties.Name -contains $Name.
    # Quando o objeto vem de um JSON vazio ({}), a coleção de propriedades é
    # vazia e o Set-StrictMode transforma esse acesso em erro fatal.
    foreach ($property in $InputObject.PSObject.Properties) {
        if ($property.Name -eq $Name) { return $true }
    }
    return $false
}

# --- winget -----------------------------------------------------------------
function Get-DestravePwshPath {
    # winget instala o PowerShell 7 como app da Store: o executável fica em
    # ...\AppData\Local\Microsoft\WindowsApps\, NÃO em C:\Program Files\PowerShell\7\.
    # Por isso resolvemos dinamicamente em vez de fixar caminho.
    $cmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\pwsh.exe'),
        (Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe')
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }
    return $null
}

function Test-DestraveWingetPackage {
    param([Parameter(Mandatory)][string]$Id)

    try {
        $output = & winget list --id $Id --exact --accept-source-agreements 2>&1 | Out-String
    } catch {
        return $false
    }
    return ($output -match [regex]::Escape($Id))
}

function Install-DestraveWingetPackage {
    param(
        [Parameter(Mandatory)][string]$Id,
        [string]$Label = ''
    )

    if ([string]::IsNullOrWhiteSpace($Label)) { $Label = $Id }

    if ($script:DestravePkgManager -ne 'winget') {
        Write-DestraveErr "winget não encontrado — não consigo instalar $Label automaticamente."
        Write-DestraveInfo "Instale o 'Instalador de Aplicativo' pela Microsoft Store e rode de novo."
        return $false
    }

    if (Test-DestraveWingetPackage -Id $Id) {
        Write-DestraveOk "$Label já instalado."
        return $true
    }

    Write-DestraveInfo "Instalando $Label (pode levar 1-2 min)..."
    try {
        & winget install --id $Id --exact --source winget `
            --accept-source-agreements --accept-package-agreements --disable-interactivity
    } catch {
        Write-DestraveErr "Falha ao instalar $Label : $($_.Exception.Message)"
        return $false
    }

    if (Test-DestraveWingetPackage -Id $Id) {
        Write-DestraveOk "$Label instalado."
        return $true
    }

    Write-DestraveErr "$Label não aparece como instalado depois do winget."
    return $false
}
