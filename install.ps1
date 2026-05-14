# install.ps1 — Bootstrap Windows do Destrave Starter Kit
#
# Estratégia: o caminho real de instalação é o `install.sh` (bash) rodando
# dentro do Ubuntu via WSL2. Esse script só garante que WSL+Ubuntu existam
# e orienta o mentorado a abrir o Ubuntu pra continuar.
#
# Por quê: ZSH + Oh My Zsh (a stack mostrada na aula) é Unix. WSL é o jeito
# oficial de rodar Linux dentro do Windows.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\lib\detect-os.ps1"

Write-DestraveSection "Destrave Starter Kit · Bootstrap Windows"
Write-DestraveInfo "SO detectado: $DestraveOS · pkg manager: $DestravePkgManager"

# --- Pre-flight: privilégios de admin (WSL --install exige) -----------------
$current = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($current)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-DestraveErr "Rode este script no PowerShell como Administrador."
    Write-DestraveInfo "Clique direito no PowerShell > 'Executar como administrador' e tente de novo."
    exit 1
}

# --- Pre-flight: build mínimo do Windows ------------------------------------
if ($DestraveOS -eq 'unknown') {
    Write-DestraveWarn "Não consegui detectar a versão do Windows. WSL --install precisa do Win10 2004+ ou Win11."
}

# --- WSL: instalado? --------------------------------------------------------
$wslInstalled = $false
try {
    $null = Get-Command wsl -ErrorAction Stop
    $wslInstalled = $true
} catch {
    $wslInstalled = $false
}

if (-not $wslInstalled) {
    Write-DestraveSection "Instalando WSL2 + Ubuntu"
    Write-DestraveInfo "Isso vai pedir um reboot ao final. Salve seu trabalho antes."
    Write-Host ""
    $resp = Read-Host "Continuar? (s/n)"
    if ($resp -ne 's' -and $resp -ne 'S') {
        Write-DestraveInfo "Abortado. Rode de novo quando estiver pronto."
        exit 0
    }

    wsl --install -d Ubuntu
    Write-DestraveOk "WSL2 + Ubuntu instalados."
    Write-DestraveSection "Próximos passos"
    Write-Host "1. " -NoNewline; Write-Host "Reinicie o computador." -ForegroundColor Yellow
    Write-Host "2. " -NoNewline; Write-Host "Abra 'Ubuntu' no menu Iniciar (vai pedir usuário + senha do Linux)."
    Write-Host "3. " -NoNewline; Write-Host "Dentro do Ubuntu, rode:"
    Write-Host ""
    Write-Host "     git clone https://github.com/GabrielSpricigo/destrave-starter-kit.git ~/destrave-starter-kit" -ForegroundColor Cyan
    Write-Host "     cd ~/destrave-starter-kit && bash install.sh" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

# --- WSL já instalado: verifica distros -------------------------------------
Write-DestraveOk "WSL já está disponível."

$distros = @()
try {
    $rawDistros = (wsl --list --quiet) 2>$null
    if ($rawDistros) {
        $distros = $rawDistros |
            ForEach-Object { ($_ -replace "`0", '').Trim() } |
            Where-Object { $_ -ne '' }
    }
} catch {
    $distros = @()
}

$hasUbuntu = $distros | Where-Object { $_ -match '^Ubuntu' }

if (-not $hasUbuntu) {
    Write-DestraveSection "Instalando Ubuntu como distro padrão"
    wsl --install -d Ubuntu --no-launch
    Write-DestraveOk "Ubuntu instalado."
    Write-DestraveInfo "Abra 'Ubuntu' no menu Iniciar pra criar usuário + senha do Linux."
} else {
    Write-DestraveOk "Ubuntu já instalado: $($hasUbuntu -join ', ')"
}

# --- Mensagem final ---------------------------------------------------------
Write-DestraveSection "Tudo pronto no lado Windows"
Write-Host ""
Write-Host "Próximo passo — dentro do Ubuntu (abra pelo menu Iniciar):" -ForegroundColor White
Write-Host ""
Write-Host "  git clone https://github.com/GabrielSpricigo/destrave-starter-kit.git ~/destrave-starter-kit" -ForegroundColor Cyan
Write-Host "  cd ~/destrave-starter-kit && bash install.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "Dúvidas: README.md (seção Troubleshooting)." -ForegroundColor DarkGray
