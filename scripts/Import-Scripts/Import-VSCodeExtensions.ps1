<#
.SYNOPSIS
    Import VS Code extensions to new PC
.DESCRIPTION
    Imports VS Code extensions from exported file to the new PC
.NOTES
    Run this script on your NEW PC after copying the exported extensions file
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  VS Code Extensions Import" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Look for the exported extensions file
$exportPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Output-Files\vscode-extensions.txt"

if (-not (Test-Path $exportPath)) {
    Write-Host "✗ Export file not found: $exportPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure you have copied 'vscode-extensions.txt' to:" -ForegroundColor Yellow
    Write-Host "  $PSScriptRoot" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

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
        Write-Host "  You may need to restart your terminal after installing VS Code." -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
}

Write-Host "✓ Found VS Code" -ForegroundColor Green
Write-Host ""

# Read extensions list
$extensions = Get-Content $exportPath

if ($extensions.Count -eq 0) {
    Write-Host "⚠ No extensions found in export file" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

Write-Host "Found $($extensions.Count) extensions to install" -ForegroundColor Yellow
Write-Host ""

# Install each extension
$successCount = 0
$failCount = 0
$skippedCount = 0

foreach ($extension in $extensions) {
    $extension = $extension.Trim()
    if ([string]::IsNullOrWhiteSpace($extension)) {
        continue
    }
    
    Write-Host "Installing $extension..." -ForegroundColor Yellow
    
    try {
        # Check if already installed
        $installed = & $codeCommand --list-extensions
        if ($installed -contains $extension) {
            Write-Host "  ⊙ Already installed, skipping" -ForegroundColor Gray
            $skippedCount++
            continue
        }
        
        # Install extension
        $null = & $codeCommand --install-extension $extension --force 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Installed successfully" -ForegroundColor Green
            $successCount++
        }
        else {
            Write-Host "  ✗ Failed to install" -ForegroundColor Red
            $failCount++
        }
    }
    catch {
        Write-Host "  ✗ Error: $_" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Import Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total extensions: $($extensions.Count)" -ForegroundColor White
Write-Host "Successfully installed: $successCount" -ForegroundColor Green
Write-Host "Already installed (skipped): $skippedCount" -ForegroundColor Gray
Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "White" })
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "✓ Extensions imported successfully!" -ForegroundColor Green
    Write-Host "  You may need to restart VS Code to use the new extensions." -ForegroundColor Yellow
}

if ($failCount -gt 0) {
    Write-Host "⚠ Some extensions failed to install. You may need to install them manually." -ForegroundColor Yellow
}

Write-Host ""
