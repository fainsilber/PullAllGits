<#
.SYNOPSIS
    Import Beyond Compare license to new PC
.DESCRIPTION
    Imports Beyond Compare license from exported registry file to the new PC
.NOTES
    Run this script on your NEW PC after copying the exported license file
    Must be run as Administrator
#>

#Requires -RunAsAdministrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Beyond Compare License Import" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Look for the exported license file
$exportPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Output-Files\BeyondCompare-License.reg"
$metadataPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Output-Files\BeyondCompare-License-Info.json"
$encryptedLicensePath = "$exportPath.encrypted"
$encryptedMetadataPath = "$metadataPath.encrypted"

# Check if encrypted versions exist
if (-not (Test-Path $exportPath) -and (Test-Path $encryptedLicensePath)) {
    Write-Host "Encrypted license file detected!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Enter decryption password:" -ForegroundColor Yellow
    $password = Read-Host -AsSecureString
    Write-Host ""
    
    try {
        Write-Host "Decrypting license file..." -ForegroundColor Yellow
        & (Join-Path (Split-Path $PSScriptRoot -Parent) "Encryption-Scripts\Unprotect-ConfigFile.ps1") -FilePath $encryptedLicensePath -Password $password -DeleteEncrypted
        Write-Host "✓ License file decrypted!" -ForegroundColor Green
        Write-Host ""
        
        # Decrypt metadata if it exists
        if (Test-Path $encryptedMetadataPath) {
            Write-Host "Decrypting metadata file..." -ForegroundColor Yellow
            & (Join-Path (Split-Path $PSScriptRoot -Parent) "Encryption-Scripts\Unprotect-ConfigFile.ps1") -FilePath $encryptedMetadataPath -Password $password -DeleteEncrypted
            Write-Host "✓ Metadata file decrypted!" -ForegroundColor Green
            Write-Host ""
        }
    }
    catch {
        Write-Host "✗ Failed to decrypt files: $_" -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}

if (-not (Test-Path $exportPath)) {
    Write-Host "✗ License file not found: $exportPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure you have copied 'BeyondCompare-License.reg' to:" -ForegroundColor Yellow
    Write-Host "  $PSScriptRoot" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Alternatively, you can enter your license key manually:" -ForegroundColor Yellow
    Write-Host "  1. Open Beyond Compare" -ForegroundColor White
    Write-Host "  2. Go to Help > Enter Key" -ForegroundColor White
    Write-Host "  3. Enter your license key" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Check if Beyond Compare is installed
$bcInstalled = $false
$bcPaths = @(
    "${env:ProgramFiles}\Beyond Compare 4\BCompare.exe",
    "${env:ProgramFiles(x86)}\Beyond Compare 4\BCompare.exe",
    "$env:LOCALAPPDATA\Programs\Beyond Compare 4\BCompare.exe"
)

foreach ($path in $bcPaths) {
    if (Test-Path $path) {
        $bcInstalled = $true
        Write-Host "✓ Found Beyond Compare at: $path" -ForegroundColor Green
        break
    }
}

if (-not $bcInstalled) {
    Write-Host "⚠ Beyond Compare not found" -ForegroundColor Yellow
    Write-Host "  Please ensure Beyond Compare is installed first." -ForegroundColor Yellow
    Write-Host "  Run setup-new-pc.ps1 if you haven't already." -ForegroundColor White
    Write-Host ""
    Write-Host "Continue with license import anyway? (Y/N)" -ForegroundColor Yellow
    $continue = Read-Host
    if ($continue -ne 'Y' -and $continue -ne 'y') {
        exit 0
    }
}

Write-Host ""
Write-Host "Importing license..." -ForegroundColor Yellow

try {
    # Import the registry file
    $result = reg import $exportPath 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Beyond Compare license imported successfully!" -ForegroundColor Green
        Write-Host ""
        
        # Show metadata if available
        if (Test-Path $metadataPath) {
            $metadata = Get-Content $metadataPath | ConvertFrom-Json
            Write-Host "Import Details:" -ForegroundColor Yellow
            Write-Host "  Originally exported: $($metadata.ExportDate)" -ForegroundColor White
            Write-Host "  From computer: $($metadata.ComputerName)" -ForegroundColor White
            Write-Host "  By user: $($metadata.ExportedBy)" -ForegroundColor White
            Write-Host ""
        }
        
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Launch Beyond Compare" -ForegroundColor White
        Write-Host "2. Verify license under Help > About" -ForegroundColor White
        Write-Host "3. Delete the license files for security:" -ForegroundColor White
        Write-Host "   - $exportPath" -ForegroundColor Cyan
        if (Test-Path $metadataPath) {
            Write-Host "   - $metadataPath" -ForegroundColor Cyan
        }
        Write-Host ""
    }
    else {
        Write-Host "✗ Failed to import license" -ForegroundColor Red
        Write-Host "  Error: $result" -ForegroundColor Red
        Write-Host ""
        Write-Host "Manual import option:" -ForegroundColor Yellow
        Write-Host "1. Double-click on: $exportPath" -ForegroundColor Cyan
        Write-Host "2. Click 'Yes' to add to registry" -ForegroundColor White
        Write-Host ""
    }
}
catch {
    Write-Host "✗ Error importing license: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manual import option:" -ForegroundColor Yellow
    Write-Host "1. Double-click on: $exportPath" -ForegroundColor Cyan
    Write-Host "2. Click 'Yes' to add to registry" -ForegroundColor White
    Write-Host "Or enter your license key manually in Beyond Compare (Help > Enter Key)" -ForegroundColor White
    Write-Host ""
}
