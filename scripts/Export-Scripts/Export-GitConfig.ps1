<#
.SYNOPSIS
    Export Git configuration from current PC
.DESCRIPTION
    Exports Git global configuration to a file that can be transferred to a new PC
.NOTES
    Run this script on your OLD PC before moving to the new one
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Git Configuration Export" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Git is installed
try {
    $null = Get-Command git -ErrorAction Stop
}
catch {
    Write-Host "✗ Git not found. Please ensure Git is installed." -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host "✓ Found Git" -ForegroundColor Green
Write-Host ""

# Get Git configuration
$gitConfigPath = Join-Path $env:USERPROFILE ".gitconfig"

if (-not (Test-Path $gitConfigPath)) {
    Write-Host "⚠ No Git configuration found at: $gitConfigPath" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# Export git config
$exportPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Output-Files\git-config-backup.txt"

try {
    Copy-Item -Path $gitConfigPath -Destination $exportPath -Force
    
    Write-Host "✓ Git configuration exported successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Details:" -ForegroundColor Yellow
    Write-Host "  Export location: $exportPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Current Git Configuration:" -ForegroundColor Yellow
    git config --global --list | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Copy '$exportPath' to your new PC" -ForegroundColor White
    Write-Host "2. On your new PC, run: Import-GitConfig.ps1" -ForegroundColor White
    Write-Host ""
}
catch {
    Write-Host "✗ Failed to export Git configuration: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}
