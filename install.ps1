[CmdletBinding()]
param(
    [switch]$SkipExtensions
)

$ErrorActionPreference = 'Stop'
$repoDir = $PSScriptRoot
$gitConfig = Join-Path $repoDir 'git/gitconfig'
$extensionsSource = Join-Path $repoDir 'vscode/extensions.json'
$settingsSource = Join-Path $repoDir 'vscode/settings.json'
$settingsDirectory = Join-Path $env:APPDATA 'Code/User'
$settingsDestination = Join-Path $settingsDirectory 'settings.json'

Write-Host '== Git =='
if (Get-Command git -ErrorAction SilentlyContinue) {
    $includes = @(git config --global --get-all include.path 2>$null)
    if ($includes -contains $gitConfig) {
        Write-Host "ok    Git already includes $gitConfig"
    } else {
        git config --global --add include.path $gitConfig
        Write-Host 'added Git aliases via include.path'
    }
} else {
    Write-Host 'skip  Git not found'
}

Write-Host "`n== VS Code settings =="
if (Test-Path $settingsDestination) {
    Write-Host "skip  VS Code settings already exist; review $settingsSource manually"
} else {
    New-Item -ItemType Directory -Force -Path $settingsDirectory | Out-Null
    Copy-Item $settingsSource $settingsDestination
    Write-Host "created $settingsDestination"
}

Write-Host "`n== VS Code extensions =="
if ($SkipExtensions) {
    Write-Host 'skip  requested with -SkipExtensions'
} elseif (Get-Command code -ErrorAction SilentlyContinue) {
    $extensions = (Get-Content $extensionsSource |
        Where-Object { -not $_.TrimStart().StartsWith('//') } | ConvertFrom-Json).recommendations
    $installedExtensions = @(code --list-extensions)
    foreach ($extension in $extensions) {
        if ($installedExtensions -contains $extension) {
            Write-Host "ok    $extension already installed"
        } else {
            code --install-extension $extension --force
        }
    }
} else {
    Write-Host "skip  'code' CLI not found; install VS Code first"
}

Write-Host "`nDone. Restart VS Code to load newly created settings."
