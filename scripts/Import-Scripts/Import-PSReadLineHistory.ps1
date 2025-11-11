<#
.SYNOPSIS
    Import PSReadLine history to new PC
.DESCRIPTION
    Imports PSReadLine command history from exported file to the new PC
.NOTES
    Run this script on your NEW PC after copying the exported history file
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PSReadLine History Import" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get the PSReadLine history file path
$historyPath = (Get-PSReadLineOption).HistorySavePath
$historyDir = Split-Path -Parent $historyPath

# Look for the exported history file
$exportPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Output-Files\PSReadLine-History-Export.txt"
$encryptedPath = "$exportPath.encrypted"

# Check if encrypted version exists
if (-not (Test-Path $exportPath) -and (Test-Path $encryptedPath)) {
    Write-Host "Encrypted history file detected: $encryptedPath" -ForegroundColor Yellow
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
    Write-Host "Please ensure you have copied 'PSReadLine-History-Export.txt' to:" -ForegroundColor Yellow
    Write-Host "  $PSScriptRoot" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

# Create history directory if it doesn't exist
if (-not (Test-Path $historyDir)) {
    New-Item -ItemType Directory -Path $historyDir -Force | Out-Null
    Write-Host "✓ Created history directory" -ForegroundColor Green
}

# Backup existing history if it exists
if (Test-Path $historyPath) {
    $backupPath = "$historyPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -Path $historyPath -Destination $backupPath -Force
    Write-Host "✓ Backed up existing history to: $backupPath" -ForegroundColor Green
    
    # Merge old and new history
    $existingHistory = Get-Content $historyPath
    $importedHistory = Get-Content $exportPath
    
    # Combine and remove duplicates while preserving order
    $mergedHistory = @($importedHistory) + @($existingHistory) | Select-Object -Unique
    
    Set-Content -Path $historyPath -Value $mergedHistory
    Write-Host "✓ Merged histories (removed duplicates)" -ForegroundColor Green
} else {
    # No existing history, just copy the imported one
    Copy-Item -Path $exportPath -Destination $historyPath -Force
    Write-Host "✓ Imported history successfully" -ForegroundColor Green
}

$historyCount = (Get-Content $historyPath).Count

Write-Host ""
Write-Host "Details:" -ForegroundColor Yellow
Write-Host "  Total commands in history: $historyCount" -ForegroundColor White
Write-Host "  History location: $historyPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "✓ Import complete! Restart your terminal to use the imported history." -ForegroundColor Green
Write-Host ""
