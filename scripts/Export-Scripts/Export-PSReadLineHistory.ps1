<#
.SYNOPSIS
    Export PSReadLine history from current PC
.DESCRIPTION
    Exports PSReadLine command history to a file that can be transferred to a new PC
.NOTES
    Run this script on your OLD PC before moving to the new one
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PSReadLine History Export" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get the PSReadLine history file path
$historyPath = (Get-PSReadLineOption).HistorySavePath

if (Test-Path $historyPath) {
    $exportPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Output-Files\PSReadLine-History-Export.txt"
    
    # Copy the history file
    Copy-Item -Path $historyPath -Destination $exportPath -Force
    
    $historyCount = (Get-Content $historyPath).Count
    
    Write-Host "✓ History exported successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Details:" -ForegroundColor Yellow
    Write-Host "  Commands exported: $historyCount" -ForegroundColor White
    Write-Host "  Export location: $exportPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Copy '$exportPath' to your new PC" -ForegroundColor White
    Write-Host "2. On your new PC, run: Import-PSReadLineHistory.ps1" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "✗ History file not found at: $historyPath" -ForegroundColor Red
    Write-Host ""
}
