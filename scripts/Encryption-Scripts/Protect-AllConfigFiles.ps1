<#
.SYNOPSIS
    Batch encrypt all sensitive configuration files
.DESCRIPTION
    Encrypts all exported configuration files that may contain sensitive data
.PARAMETER Password
    The password to use for encryption (will be prompted if not provided)
.PARAMETER DeleteOriginals
    If specified, deletes the original unencrypted files after successful encryption
.EXAMPLE
    .\Protect-AllConfigFiles.ps1
.EXAMPLE
    .\Protect-AllConfigFiles.ps1 -DeleteOriginals
.NOTES
    This is useful if you exported files without encryption and want to encrypt them later
#>

param(
    [Parameter(Mandatory=$false)]
    [SecureString]$Password,
    
    [Parameter(Mandatory=$false)]
    [switch]$DeleteOriginals
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Batch Configuration Encryption" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path $PSScriptRoot -Parent

# Define files that should be encrypted
$filesToEncrypt = @(
    "git-config-backup.txt",
    "BeyondCompare-License.reg",
    "BeyondCompare-License-Info.json",
    "PSReadLine-History-Export.txt"
)

# Check which files exist
$existingFiles = @()
$outputPath = Join-Path $scriptPath "Output-Files"
foreach ($file in $filesToEncrypt) {
    $filePath = Join-Path $outputPath $file
    if (Test-Path $filePath) {
        # Check if already encrypted
        if (Test-Path "$filePath.encrypted") {
            Write-Host "  ⚠ $file is already encrypted" -ForegroundColor Yellow
        } else {
            $existingFiles += $filePath
        }
    }
}

if ($existingFiles.Count -eq 0) {
    Write-Host "No unencrypted configuration files found." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Looking for:" -ForegroundColor Yellow
    foreach ($file in $filesToEncrypt) {
        Write-Host "  - $file" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Note: Files may already be encrypted (*.encrypted extension)" -ForegroundColor Gray
    Write-Host ""
    exit 0
}

# Display files to be encrypted
Write-Host "Files to be encrypted:" -ForegroundColor Yellow
foreach ($file in $existingFiles) {
    Write-Host "  - $(Split-Path -Leaf $file)" -ForegroundColor White
}
Write-Host ""

# Get password if not provided
if (-not $Password) {
    Write-Host "Enter encryption password:" -ForegroundColor Yellow
    $Password = Read-Host -AsSecureString
    Write-Host ""
    Write-Host "Confirm password:" -ForegroundColor Yellow
    $Password2 = Read-Host -AsSecureString
    Write-Host ""
    
    # Compare passwords
    $bstr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $bstr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password2)
    try {
        $pass1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr1)
        $pass2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)
        
        if ($pass1 -ne $pass2) {
            Write-Host "✗ Passwords do not match!" -ForegroundColor Red
            Write-Host ""
            exit 1
        }
    }
    finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr1)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2)
    }
}

# Encrypt each file
Write-Host "Encrypting files..." -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$failCount = 0

foreach ($file in $existingFiles) {
    $fileName = Split-Path -Leaf $file
    
    try {
        Write-Host "  Encrypting: $fileName..." -ForegroundColor Yellow
        
        if ($DeleteOriginals) {
            & (Join-Path $scriptPath "Encryption-Scripts\Protect-ConfigFile.ps1") -FilePath $file -Password $Password -DeleteOriginal 2>&1 | Out-Null
        }
        else {
            & (Join-Path $scriptPath "Encryption-Scripts\Protect-ConfigFile.ps1") -FilePath $file -Password $Password 2>&1 | Out-Null
        }
        
        if (Test-Path "$file.encrypted") {
            Write-Host "    ✓ Success" -ForegroundColor Green
            $successCount++
        }
        else {
            Write-Host "    ✗ Failed - encrypted file not created" -ForegroundColor Red
            $failCount++
        }
    }
    catch {
        Write-Host "    ✗ Failed: $_" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Encryption Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Successfully encrypted: $successCount file(s)" -ForegroundColor $(if ($successCount -gt 0) { "Green" } else { "White" })
Write-Host "Failed: $failCount file(s)" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "White" })
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "✓ Encryption complete!" -ForegroundColor Green
    Write-Host ""
    
    if (-not $DeleteOriginals) {
        Write-Host "⚠ Original unencrypted files still exist!" -ForegroundColor Yellow
        Write-Host "  Consider deleting them manually for security." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To delete originals, run:" -ForegroundColor Yellow
        Write-Host "  .\Protect-AllConfigFiles.ps1 -DeleteOriginals" -ForegroundColor Cyan
        Write-Host ""
    }
    
    Write-Host "IMPORTANT: Remember your password!" -ForegroundColor Red
    Write-Host "  You will need it to decrypt files on your new PC." -ForegroundColor Yellow
    Write-Host ""
}

if ($failCount -gt 0) {
    Write-Host "⚠ Some files failed to encrypt." -ForegroundColor Yellow
    Write-Host "  Check the errors above and try again." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
