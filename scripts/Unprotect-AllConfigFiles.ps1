<#
.SYNOPSIS
    Batch decrypt all encrypted configuration files
.DESCRIPTION
    Decrypts all encrypted configuration files (*.encrypted)
.PARAMETER Password
    The password to use for decryption (will be prompted if not provided)
.PARAMETER DeleteEncrypted
    If specified, deletes the encrypted files after successful decryption
.EXAMPLE
    .\Unprotect-AllConfigFiles.ps1
.EXAMPLE
    .\Unprotect-AllConfigFiles.ps1 -DeleteEncrypted
.NOTES
    This is useful if Import-AllConfigurations.ps1 didn't auto-decrypt
#>

param(
    [Parameter(Mandatory=$false)]
    [SecureString]$Password,
    
    [Parameter(Mandatory=$false)]
    [switch]$DeleteEncrypted
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Batch Configuration Decryption" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = $PSScriptRoot

# Find all encrypted files
$encryptedFiles = Get-ChildItem -Path $scriptPath -Filter "*.encrypted" -ErrorAction SilentlyContinue

if (-not $encryptedFiles -or $encryptedFiles.Count -eq 0) {
    Write-Host "No encrypted files found in:" -ForegroundColor Yellow
    Write-Host "  $scriptPath" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

# Display files to be decrypted
Write-Host "Encrypted files found:" -ForegroundColor Yellow
foreach ($file in $encryptedFiles) {
    Write-Host "  - $($file.Name)" -ForegroundColor White
}
Write-Host ""

# Get password if not provided
if (-not $Password) {
    Write-Host "Enter decryption password:" -ForegroundColor Yellow
    $Password = Read-Host -AsSecureString
    Write-Host ""
}

# Decrypt each file
Write-Host "Decrypting files..." -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$failCount = 0

foreach ($file in $encryptedFiles) {
    try {
        Write-Host "  Decrypting: $($file.Name)..." -ForegroundColor Yellow
        
        if ($DeleteEncrypted) {
            & (Join-Path $scriptPath "Unprotect-ConfigFile.ps1") -FilePath $file.FullName -Password $Password -DeleteEncrypted 2>&1 | Out-Null
        }
        else {
            & (Join-Path $scriptPath "Unprotect-ConfigFile.ps1") -FilePath $file.FullName -Password $Password 2>&1 | Out-Null
        }
        
        $decryptedFile = $file.FullName -replace '\.encrypted$', ''
        if (Test-Path $decryptedFile) {
            Write-Host "    ✓ Success" -ForegroundColor Green
            $successCount++
        }
        else {
            Write-Host "    ✗ Failed - decrypted file not created" -ForegroundColor Red
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
Write-Host "  Decryption Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Successfully decrypted: $successCount file(s)" -ForegroundColor $(if ($successCount -gt 0) { "Green" } else { "White" })
Write-Host "Failed: $failCount file(s)" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "White" })
Write-Host ""

if ($failCount -gt 0) {
    Write-Host "✗ Some files failed to decrypt." -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "  - Incorrect password" -ForegroundColor White
    Write-Host "  - Files are corrupted" -ForegroundColor White
    Write-Host "  - Files were not encrypted with these scripts" -ForegroundColor White
    Write-Host ""
    exit 1
}

if ($successCount -gt 0) {
    Write-Host "✓ Decryption complete!" -ForegroundColor Green
    Write-Host ""
    
    if (-not $DeleteEncrypted) {
        Write-Host "Note: Encrypted files still exist." -ForegroundColor Yellow
        Write-Host "  To delete them, run:" -ForegroundColor Yellow
        Write-Host "  .\Unprotect-AllConfigFiles.ps1 -DeleteEncrypted" -ForegroundColor Cyan
        Write-Host ""
    }
    
    Write-Host "⚠ Security Reminder:" -ForegroundColor Yellow
    Write-Host "  Delete decrypted files after importing to new PC!" -ForegroundColor Yellow
    Write-Host ""
}
