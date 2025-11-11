<#
.SYNOPSIS
    Master export script - exports all configurations from current PC
.DESCRIPTION
    Runs all export scripts to backup configurations before moving to a new PC
.NOTES
    Run this script on your OLD PC before moving to the new one
#>

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MASTER EXPORT SCRIPT" -ForegroundColor Cyan
Write-Host "  Backing up all configurations" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path $PSScriptRoot -Parent
$exportScripts = @(
    "Export-PSReadLineHistory.ps1",
    "Export-VSCodeExtensions.ps1",
    "Export-GitConfig.ps1",
    "Export-BeyondCompareLicense.ps1"
)

$results = @()

foreach ($script in $exportScripts) {
    $fullPath = Join-Path $scriptPath "Export-Scripts\$script"
    
    if (Test-Path $fullPath) {
        Write-Host "Running $script..." -ForegroundColor Cyan
        Write-Host ""
        
        try {
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
Write-Host "  EXPORT SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($result in $results) {
    $color = switch ($result.Status) {
        "Success" { "Green" }
        "Failed" { "Red" }
        "Not Found" { "Yellow" }
        default { "White" }
    }
    Write-Host "$($result.Script): $($result.Status)" -ForegroundColor $color
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ENCRYPTION RECOMMENDED" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠ Your exported files may contain sensitive information!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Files that may contain secrets:" -ForegroundColor Yellow
Write-Host "  - git-config-backup.txt (email, credentials)" -ForegroundColor White
Write-Host "  - BeyondCompare-License.reg (license keys)" -ForegroundColor White
Write-Host "  - PSReadLine-History-Export.txt (command history, passwords)" -ForegroundColor White
Write-Host ""

# Ask if user wants to encrypt the files
$encrypt = Read-Host "Would you like to encrypt these files now? (Y/N)"
Write-Host ""

if ($encrypt -eq 'Y' -or $encrypt -eq 'y') {
    Write-Host "Enter encryption password:" -ForegroundColor Yellow
    $password = Read-Host -AsSecureString
    Write-Host ""
    Write-Host "Confirm password:" -ForegroundColor Yellow
    $password2 = Read-Host -AsSecureString
    Write-Host ""
    
    # Compare passwords
    $bstr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
    $bstr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password2)
    $passwordsMatch = $false
    try {
        $pass1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr1)
        $pass2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)
        $passwordsMatch = ($pass1 -eq $pass2)
    }
    finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr1)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2)
    }
    
    if ($passwordsMatch) {
        Write-Host "Encrypting files..." -ForegroundColor Cyan
        Write-Host ""
        
        $filesToEncrypt = @(
            "git-config-backup.txt",
            "BeyondCompare-License.reg",
            "BeyondCompare-License-Info.json",
            "PSReadLine-History-Export.txt"
        )
        
        foreach ($file in $filesToEncrypt) {
            $filePath = Join-Path $scriptPath "Output-Files\$file"
            if (Test-Path $filePath) {
                try {
                    & (Join-Path $scriptPath "Protect-ConfigFile.ps1") -FilePath $filePath -Password $password -DeleteOriginal
                    Write-Host "  ✓ Encrypted: $file" -ForegroundColor Green
                }
                catch {
                    Write-Host "  ✗ Failed to encrypt $file : $_" -ForegroundColor Red
                }
            }
        }
        
        Write-Host ""
        Write-Host "✓ Encryption complete!" -ForegroundColor Green
        Write-Host ""
        Write-Host "IMPORTANT: Remember your password!" -ForegroundColor Red
        Write-Host "  You will need it to decrypt files on your new PC." -ForegroundColor Yellow
        Write-Host ""
    }
    else {
        Write-Host "✗ Passwords do not match. Files NOT encrypted." -ForegroundColor Red
        Write-Host "  You can manually encrypt them later using:" -ForegroundColor Yellow
        Write-Host "  .\Protect-ConfigFile.ps1 -FilePath <file>" -ForegroundColor Cyan
        Write-Host ""
    }
}
else {
    Write-Host "⚠ Files will remain UNENCRYPTED." -ForegroundColor Yellow
    Write-Host "  You can manually encrypt them later using:" -ForegroundColor Yellow
    Write-Host "  .\Protect-ConfigFile.ps1 -FilePath <file>" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Next Steps" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Copy the entire folder to your NEW PC:" -ForegroundColor Yellow
Write-Host "   $scriptPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. On your NEW PC, run as Administrator:" -ForegroundColor Yellow
Write-Host "   .\setup-new-pc.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Then run the import script:" -ForegroundColor Yellow
Write-Host "   .\Import-AllConfigurations.ps1" -ForegroundColor Cyan
Write-Host "   (It will automatically detect and decrypt encrypted files)" -ForegroundColor White
Write-Host ""
