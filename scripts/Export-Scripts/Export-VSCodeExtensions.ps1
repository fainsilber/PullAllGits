<#
.SYNOPSIS
    Export VS Code extensions from current PC
.DESCRIPTION
    Exports list of installed VS Code extensions to a file that can be transferred to a new PC
.NOTES
    Run this script on your OLD PC before moving to the new one
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VS Code Extensions Export" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if VS Code is installed
$codeCommand = $null
$codePaths = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
    "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd",
    "${env:ProgramFiles(x86)}\Microsoft VS Code\bin\code.cmd"
)

foreach ($path in $codePaths) {
    if (Test-Path $path) {
        $codeCommand = $path
        break
    }
}

# Also check if code is in PATH
if (-not $codeCommand) {
    try {
        $null = Get-Command code -ErrorAction Stop
        $codeCommand = "code"
    }
    catch {
        Write-Host "✗ VS Code not found. Please ensure VS Code is installed." -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}

Write-Host "✓ Found VS Code" -ForegroundColor Green
Write-Host "Exporting extensions..." -ForegroundColor Yellow
Write-Host ""

# Export extensions list
$exportPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Output-Files\vscode-extensions.txt"
$extensionsListPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Output-Files\vscode-extensions-list.txt"

try {
    # Get list of installed extensions
    $extensions = & $codeCommand --list-extensions
    
    if ($extensions.Count -eq 0) {
        Write-Host "⚠ No extensions found to export" -ForegroundColor Yellow
        Write-Host ""
        exit 0
    }
    
    # Save extensions to file (for installation)
    $extensions | Out-File -FilePath $exportPath -Encoding utf8
    
    # Get detailed list with versions
    $detailedExtensions = & $codeCommand --list-extensions --show-versions
    $detailedExtensions | Out-File -FilePath $extensionsListPath -Encoding utf8
    
    Write-Host "✓ Extensions exported successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Details:" -ForegroundColor Yellow
    Write-Host "  Extensions exported: $($extensions.Count)" -ForegroundColor White
    Write-Host "  Export location: $exportPath" -ForegroundColor Cyan
    Write-Host "  Detailed list: $extensionsListPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Installed Extensions:" -ForegroundColor Yellow
    $detailedExtensions | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Copy '$exportPath' to your new PC" -ForegroundColor White
    Write-Host "2. On your new PC, run: Import-VSCodeExtensions.ps1" -ForegroundColor White
    Write-Host ""
}
catch {
    Write-Host "✗ Failed to export extensions: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}
