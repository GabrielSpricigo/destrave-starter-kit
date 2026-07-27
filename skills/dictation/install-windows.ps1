# Skill · Dictation (Whispering) — Windows nativo
#
# Ditar com a voz dentro do Claude Code. O Whispering cola o texto onde o
# cursor estiver, então funciona em qualquer editor ou terminal.
#
# Nota: o Whispering NÃO está no winget (verificado em 07/2026), então
# baixamos o instalador direto do GitHub do projeto.
#
# Idempotente.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\..\lib\detect-os.ps1"

Write-DestraveSection "Skill · Dictation (Whispering)"

$SiteUrl = 'https://whispering.bradenwong.com'
$ApiUrl  = 'https://api.github.com/repos/braden-w/whispering/releases/latest'

# --- 1. Já instalado? -------------------------------------------------------
# winget list enxerga todos os programas instalados, não só os que ele instalou.
try {
    $installed = & winget list --name Whispering --accept-source-agreements 2>&1 | Out-String
    if ($installed -match 'Whispering') {
        Write-DestraveOk "Whispering já instalado."
        Write-DestraveInfo "Abra o app, defina sua tecla de atalho e escolha o motor de transcrição."
        exit 0
    }
} catch {
    # segue para a instalação
}

# --- 2. Descobrir o instalador mais recente ---------------------------------
$installerUrl  = ''
$installerName = ''

try {
    Write-DestraveInfo "Consultando a versão mais recente do Whispering..."
    $release = Invoke-RestMethod -Uri $ApiUrl -Headers @{ 'User-Agent' = 'destrave-starter-kit' } -ErrorAction Stop

    # .msi primeiro (instala mais previsível), .exe como alternativa
    foreach ($pattern in @('\.msi$', '-setup\.exe$')) {
        foreach ($asset in $release.assets) {
            if ($asset.name -match 'x64' -and $asset.name -match $pattern) {
                $installerUrl  = $asset.browser_download_url
                $installerName = $asset.name
                break
            }
        }
        if ($installerUrl) { break }
    }
} catch {
    Write-DestraveWarn "Não consegui consultar o GitHub: $($_.Exception.Message)"
}

if (-not $installerUrl) {
    Write-DestraveWarn "Não achei o instalador automaticamente."
    Write-DestraveInfo "Baixe manualmente em: $SiteUrl"
    Write-DestraveInfo "Depois de instalar, o resto do kit continua funcionando normalmente."
    exit 0
}

# --- 3. Baixar --------------------------------------------------------------
$downloadDir = Join-Path $env:USERPROFILE 'Downloads'
if (-not (New-DestraveDirVerified -Path $downloadDir)) {
    $downloadDir = $env:TEMP
}
$installerPath = Join-Path $downloadDir $installerName

if (Test-Path -LiteralPath $installerPath) {
    Write-DestraveOk "Instalador já baixado: $installerPath"
} else {
    Write-DestraveInfo "Baixando $installerName ..."
    try {
        $previousProgress = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'   # sem isso o download fica lentíssimo
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing -ErrorAction Stop
        $ProgressPreference = $previousProgress
    } catch {
        Write-DestraveErr "Falha no download: $($_.Exception.Message)"
        Write-DestraveInfo "Baixe manualmente em: $SiteUrl"
        exit 1
    }
}

if (-not (Test-Path -LiteralPath $installerPath)) {
    Write-DestraveErr "O arquivo não apareceu depois do download."
    Write-DestraveInfo "Baixe manualmente em: $SiteUrl"
    exit 1
}
Write-DestraveOk "Instalador em: $installerPath"

# --- 4. Instalar ------------------------------------------------------------
Write-DestraveInfo "Abrindo o instalador — siga a janela que vai aparecer."
try {
    if ($installerPath.ToLower().EndsWith('.msi')) {
        Start-Process -FilePath 'msiexec.exe' -ArgumentList @('/i', "`"$installerPath`"", '/qb') -Wait -ErrorAction Stop
    } else {
        Start-Process -FilePath $installerPath -Wait -ErrorAction Stop
    }
    Write-DestraveOk "Instalação do Whispering finalizada."
} catch {
    Write-DestraveWarn "Não consegui iniciar o instalador automaticamente."
    Write-DestraveInfo "Abra você mesmo: $installerPath"
}

Write-DestraveSection "Últimos passos (no app)"
Write-Host "  1. Abra o Whispering e permita o acesso ao microfone."
Write-Host "  2. Defina a tecla de atalho que inicia e para a gravação."
Write-Host "  3. Escolha o motor: API da OpenAI (mais fácil) ou Whisper local (offline)."
Write-Host ""
Write-DestraveInfo "Depois é só apertar a tecla e falar — o texto aparece onde o cursor estiver."
