<#
.SYNOPSIS
    Master import script - imports all configurations to new PC
.DESCRIPTION
    Runs all import scripts to restore configurations on a new PC
.NOTES
    Run this script on your NEW PC after running setup-new-pc.ps1
#>

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MASTER IMPORT SCRIPT" -ForegroundColor Cyan
Write-Host "  Restoring all configurations" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Git is in PATH (needed for posh-git module)
$gitCommand = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCommand) {
    Write-Host "WARNING: Git is not in your PATH" -ForegroundColor Yellow
    Write-Host "This may cause warnings from posh-git module in your PowerShell profile." -ForegroundColor Yellow
    Write-Host ""
    
    # Check if Git is installed
    $gitPaths = @(
        "C:\Program Files\Git\bin",
        "C:\Program Files (x86)\Git\bin",
        "$env:LOCALAPPDATA\Programs\Git\bin"
    )
    
    $gitFound = $false
    foreach ($path in $gitPaths) {
        if (Test-Path (Join-Path $path "git.exe")) {
            Write-Host "Git is installed at: $path" -ForegroundColor Cyan
            Write-Host "To fix this, run: `$env:PATH += ';$path'" -ForegroundColor White
            Write-Host "Or re-run setup-new-pc.ps1 to add Git to PATH permanently." -ForegroundColor White
            $gitFound = $true
            break
        }
    }
    
    if (-not $gitFound) {
        Write-Host "Git does not appear to be installed." -ForegroundColor Yellow
        Write-Host "Some configurations require Git to be installed first." -ForegroundColor White
    }
    
    Write-Host ""
    $continue = Read-Host "Continue anyway? (Y/N)"
    if ($continue -ne 'Y' -and $continue -ne 'y') {
        Write-Host "Import cancelled." -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# Check for encrypted files
$scriptPath = $PSScriptRoot
$outputPath = Join-Path $scriptPath "Output-Files"
$encryptedFiles = Get-ChildItem -Path $outputPath -Filter "*.encrypted" -ErrorAction SilentlyContinue

if ($encryptedFiles) {
    Write-Host "Encrypted files detected!" -ForegroundColor Cyan
    Write-Host ""
    foreach ($file in $encryptedFiles) {
        Write-Host "  - $($file.Name)" -ForegroundColor Yellow
    }
    Write-Host ""
    
    $decrypt = Read-Host "Would you like to decrypt these files now? (Y/N)"
    Write-Host ""
    
    if ($decrypt -eq 'Y' -or $decrypt -eq 'y') {
        Write-Host "Enter decryption password:" -ForegroundColor Yellow
        $password = Read-Host -AsSecureString
        Write-Host ""
        
        Write-Host "Decrypting files..." -ForegroundColor Cyan
        Write-Host ""
        
        $decryptionFailed = $false
        foreach ($file in $encryptedFiles) {
            try {
                & (Join-Path $scriptPath "Unprotect-ConfigFile.ps1") -FilePath $file.FullName -Password $password -DeleteEncrypted
                Write-Host "  ✓ Decrypted: $($file.Name)" -ForegroundColor Green
            }
            catch {
                Write-Host "  ✗ Failed to decrypt $($file.Name)" -ForegroundColor Red
                $decryptionFailed = $true
            }
        }
        
        Write-Host ""
        
        if ($decryptionFailed) {
            Write-Host "⚠ Some files failed to decrypt. Check password and try again." -ForegroundColor Yellow
            Write-Host ""
            exit 1
        }
        else {
            Write-Host "✓ All files decrypted successfully!" -ForegroundColor Green
            Write-Host ""
        }
    }
    else {
        Write-Host "⚠ Files will remain encrypted. Import may fail." -ForegroundColor Yellow
        Write-Host "  You can manually decrypt them using:" -ForegroundColor Yellow
        Write-Host "  .\Unprotect-ConfigFile.ps1 -FilePath <file>" -ForegroundColor Cyan
        Write-Host ""
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Configuration Import" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = $PSScriptRoot
$importScripts = @(
    "Import-PSReadLineHistory.ps1",
    "Import-VSCodeExtensions.ps1",
    "Import-GitConfig.ps1",
    "Import-BeyondCompareLicense.ps1"
)

$results = @()

foreach ($script in $importScripts) {
    $fullPath = Join-Path $scriptPath $script
    
    if (Test-Path $fullPath) {
        Write-Host "Running $script..." -ForegroundColor Cyan
        Write-Host ""
        
        try {
            # Check if script requires admin (Beyond Compare license import)
            if ($script -eq "Import-BeyondCompareLicense.ps1") {
                # Check if running as admin
                $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
                
                if (-not $isAdmin) {
                    Write-Host "⚠ Skipping $script (requires Administrator privileges)" -ForegroundColor Yellow
                    Write-Host "  Run this script separately as Administrator if needed" -ForegroundColor Yellow
                    Write-Host ""
                    $results += @{Script = $script; Status = "Skipped (Admin Required)" }
                    continue
                }
            }
            
            & $fullPath
            $results += @{Script = $script; Status = "Success" }
        }
        catch {
            Write-Host "✗ Error running $script : $_" -ForegroundColor Red
            Write-Host ""
            $results += @{Script = $script; Status = "Failed" }
        }
    }
    else {
        Write-Host "⚠ Script not found: $script" -ForegroundColor Yellow
        Write-Host ""
        $results += @{Script = $script; Status = "Not Found" }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  IMPORT SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($result in $results) {
    $color = switch ($result.Status) {
        "Success" { "Green" }
        "Failed" { "Red" }
        "Not Found" { "Yellow" }
        "Skipped (Admin Required)" { "Yellow" }
        default { "White" }
    }
    Write-Host "$($result.Script): $($result.Status)" -ForegroundColor $color
}

Write-Host ""

# Check if Beyond Compare license needs manual import
$bcLicenseSkipped = $results | Where-Object { $_.Script -eq "Import-BeyondCompareLicense.ps1" -and $_.Status -eq "Skipped (Admin Required)" }
if ($bcLicenseSkipped) {
    Write-Host "NOTE: To import Beyond Compare license, run as Administrator:" -ForegroundColor Yellow
    Write-Host "  .\Import-BeyondCompareLicense.ps1" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  All Done!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Final steps:" -ForegroundColor Yellow
Write-Host "1. Restart your terminal to apply all changes" -ForegroundColor White
Write-Host "2. Restart VS Code to load extensions" -ForegroundColor White
Write-Host "3. Verify all applications are working correctly" -ForegroundColor White
Write-Host ""
