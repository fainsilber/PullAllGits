<#
.SYNOPSIS
    Export Beyond Compare license from current PC
.DESCRIPTION
    Exports Beyond Compare license key to a file that can be transferred to a new PC
.NOTES
    Run this script on your OLD PC before moving to the new one
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Beyond Compare License Export" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Beyond Compare registry paths (version 4)
$registryPaths = @(
    "HKCU:\Software\Scooter Software\Beyond Compare 4",
    "HKLM:\Software\Scooter Software\Beyond Compare 4",
    "HKLM:\Software\WOW6432Node\Scooter Software\Beyond Compare 4"
)

$licenseFound = $false
$exportData = @{
    LicenseKey = $null
    UserName = $null
    RegistryPath = $null
}

# Check each registry path
foreach ($regPath in $registryPaths) {
    if (Test-Path $regPath) {
        Write-Host "Checking registry path: $regPath" -ForegroundColor Yellow
        
        try {
            $regKey = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
            
            # Check for license information (Beyond Compare stores license in various keys)
            if ($regKey.PSObject.Properties.Name -contains "CacheID") {
                $exportData.RegistryPath = $regPath
                $licenseFound = $true
                
                # Export the entire registry key
                $exportPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Output-Files\BeyondCompare-License.reg"
                
                # Use reg export to export the registry key
                $regPathForExport = $regPath -replace "HKCU:\\", "HKEY_CURRENT_USER\" -replace "HKLM:\\", "HKEY_LOCAL_MACHINE\"
                $null = reg export $regPathForExport $exportPath /y 2>&1
                
                if (Test-Path $exportPath) {
                    Write-Host "✓ Beyond Compare license exported successfully!" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "Details:" -ForegroundColor Yellow
                    Write-Host "  Registry path: $regPath" -ForegroundColor White
                    Write-Host "  Export location: $exportPath" -ForegroundColor Cyan
                    Write-Host ""
                    
                    # Also create a JSON file with metadata
                    $metadataPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Output-Files\BeyondCompare-License-Info.json"
                    @{
                        ExportDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        RegistryPath = $regPath
                        ExportedBy = $env:USERNAME
                        ComputerName = $env:COMPUTERNAME
                    } | ConvertTo-Json | Out-File -FilePath $metadataPath -Encoding utf8
                    
                    Write-Host "Next steps:" -ForegroundColor Yellow
                    Write-Host "1. Copy '$exportPath' to your new PC" -ForegroundColor White
                    Write-Host "2. On your new PC, run: Import-BeyondCompareLicense.ps1" -ForegroundColor White
                    Write-Host ""
                    Write-Host "NOTE: License export may contain sensitive information." -ForegroundColor Yellow
                    Write-Host "      Keep this file secure and delete it after import." -ForegroundColor Yellow
                    Write-Host ""
                }
                break
            }
        }
        catch {
            Write-Host "  Error reading registry: $_" -ForegroundColor Red
        }
    }
}

if (-not $licenseFound) {
    Write-Host "⚠ No Beyond Compare license found in registry" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "  - Beyond Compare is not installed" -ForegroundColor White
    Write-Host "  - Beyond Compare is not licensed (trial version)" -ForegroundColor White
    Write-Host "  - License is stored in a different location" -ForegroundColor White
    Write-Host ""
    Write-Host "You can manually export the license by:" -ForegroundColor Yellow
    Write-Host "  1. Open Beyond Compare" -ForegroundColor White
    Write-Host "  2. Go to Help > About" -ForegroundColor White
    Write-Host "  3. Copy your license key" -ForegroundColor White
    Write-Host "  4. Save it securely for your new PC" -ForegroundColor White
    Write-Host ""
}
