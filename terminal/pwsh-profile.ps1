# =========================================================
#  Perfil do PowerShell — Destrave Starter Kit
#
#  Este arquivo é o equivalente Windows do seu ".zshrc".
#  Ele roda toda vez que você abre um terminal novo.
#
#  Cada bloco é blindado com try/catch de propósito: se um
#  deles falhar (acontece quando o PowerShell roda sem
#  console de verdade), o resto continua carregando.
#  Sem isso, um erro no começo derruba o arquivo inteiro e
#  você fica sem prompt e sem atalhos, sem entender por quê.
# =========================================================

# --- Autocomplete (o equivalente ao zsh-autosuggestions) --------------------
# Sugestão em cinza enquanto você digita, baseada no que já rodou antes.
# Aceita com a seta → (ou End). F2 alterna entre sugestão inline e lista.
try {
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin -ErrorAction Stop
    Set-PSReadLineOption -PredictionViewStyle InlineView
} catch {
    # console sem suporte a sugestão preditiva — segue sem ela
}

try {
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -MaximumHistoryCount 20000

    # Tab abre o menu de opções (igual ao zsh)
    Set-PSReadLineKeyHandler -Key Tab       -Function MenuComplete
    # Setas ↑ ↓ buscam no histórico pelo que você já digitou na linha
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
} catch {
    # PSReadLine indisponível neste host
}

# --- Prompt (o equivalente ao tema do Oh My Zsh) ----------------------------
# Tema robbyrussell: o mesmo que aparece na aula, no Mac.
try {
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        $destraveTheme = $null
        $candidates = @()

        if ($PSScriptRoot) {
            $candidates += (Join-Path $PSScriptRoot 'robbyrussell.omp.json')
        }
        $candidates += (Join-Path $env:USERPROFILE '.destrave\robbyrussell.omp.json')

        foreach ($candidate in $candidates) {
            if (Test-Path -LiteralPath $candidate) { $destraveTheme = $candidate; break }
        }

        if ($destraveTheme) {
            oh-my-posh init pwsh --config $destraveTheme | Invoke-Expression
        } else {
            oh-my-posh init pwsh | Invoke-Expression
        }
    }
} catch {
    # sem prompt customizado — o padrão do PowerShell continua funcionando
}

# --- Atalhos ----------------------------------------------------------------
# ll = listar arquivos (inclusive ocultos), como no Mac/Linux
function ll { Get-ChildItem -Force @args }

# .. e ... = subir uma ou duas pastas
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
