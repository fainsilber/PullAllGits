<#
.SYNOPSIS
    Import Git configuration to new PC
.DESCRIPTION
    Imports Git global configuration from exported file to the new PC
.NOTES
    Run this script on your NEW PC after copying the exported config file
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Git Configuration Import" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Look for the exported config file
$exportPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Output-Files\git-config-backup.txt"
$encryptedPath = "$exportPath.encrypted"

# Check if encrypted version exists
if (-not (Test-Path $exportPath) -and (Test-Path $encryptedPath)) {
    Write-Host "Encrypted config file detected: $encryptedPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Enter decryption password:" -ForegroundColor Yellow
    $password = Read-Host -AsSecureString
    Write-Host ""
    
    try {
        Write-Host "Decrypting file..." -ForegroundColor Yellow
        & (Join-Path (Split-Path $PSScriptRoot -Parent) "Encryption-Scripts\Unprotect-ConfigFile.ps1") -FilePath $encryptedPath -Password $password -DeleteEncrypted
        Write-Host "✓ File decrypted successfully!" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host "✗ Failed to decrypt file: $_" -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}

if (-not (Test-Path $exportPath)) {
    Write-Host "✗ Export file not found: $exportPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure you have copied 'git-config-backup.txt' to:" -ForegroundColor Yellow
    Write-Host "  $PSScriptRoot" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

# Check if Git is installed
$gitCommand = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCommand) {
    Write-Host "✗ Git not found in PATH." -ForegroundColor Red
    Write-Host ""
    
    # Check common installation locations
    $gitPaths = @(
        "C:\Program Files\Git\bin\git.exe",
        "C:\Program Files (x86)\Git\bin\git.exe",
        "$env:LOCALAPPDATA\Programs\Git\bin\git.exe"
    )
    
    $gitExePath = $null
    foreach ($path in $gitPaths) {
        if (Test-Path $path) {
            $gitExePath = $path
            break
        }
    }
    
    if ($gitExePath) {
        Write-Host "✓ Found Git installed at: $gitExePath" -ForegroundColor Green
        Write-Host ""
        Write-Host "However, Git is not in your PATH. You have two options:" -ForegroundColor Yellow
        Write-Host "  1. Add Git to your system PATH and restart your terminal" -ForegroundColor White
        Write-Host "  2. Re-run the setup-new-pc.ps1 script (it will fix PATH automatically)" -ForegroundColor White
        Write-Host ""
        Write-Host "Temporary fix for this session:" -ForegroundColor Cyan
        Write-Host "  `$env:PATH += ';$(Split-Path $gitExePath -Parent)'" -ForegroundColor Gray
        Write-Host ""
    }
    else {
        Write-Host "Git does not appear to be installed." -ForegroundColor Yellow
        Write-Host "Please install Git first, then run this script again." -ForegroundColor White
        Write-Host ""
    }
    
    exit 1
}

Write-Host "✓ Found Git ($(git --version))" -ForegroundColor Green
Write-Host ""

# Backup existing config if it exists
$gitConfigPath = Join-Path $env:USERPROFILE ".gitconfig"

if (Test-Path $gitConfigPath) {
    $backupPath = "$gitConfigPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -Path $gitConfigPath -Destination $backupPath -Force
    Write-Host "✓ Backed up existing Git config to: $backupPath" -ForegroundColor Green
}

# Import config
try {
    Copy-Item -Path $exportPath -Destination $gitConfigPath -Force
    Write-Host "✓ Git configuration imported successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Imported Git Configuration:" -ForegroundColor Yellow
    git config --global --list | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    Write-Host ""
}
catch {
    Write-Host "✗ Failed to import Git configuration: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}
