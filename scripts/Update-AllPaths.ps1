<#
.SYNOPSIS
    Updates all script paths after reorganization into folders
.DESCRIPTION
    Updates all cross-references between scripts to work with the new folder structure
#>

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Updating All Script Path References" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptRoot = $PSScriptRoot

# Update Export-AllConfigurations.ps1
Write-Host "Updating Export-AllConfigurations.ps1..." -ForegroundColor Yellow
$file = Join-Path $scriptRoot "Export-Scripts\Export-AllConfigurations.ps1"
$content = Get-Content $file -Raw
$content = $content -replace '\$scriptPath = \$PSScriptRoot', '$scriptPath = Split-Path $PSScriptRoot -Parent'
$content = $content -replace 'Join-Path \$scriptPath \$script', 'Join-Path $scriptPath "Export-Scripts\$script"'
$content = $content -replace 'Join-Path \$scriptPath "\.\.\\Encryption-Scripts\\Protect-ConfigFile\.ps1"', 'Join-Path $scriptPath "Encryption-Scripts\Protect-ConfigFile.ps1"'
$content | Out-File $file -Encoding utf8 -NoNewline
Write-Host "  ✓ Updated" -ForegroundColor Green

# Update Import-AllConfigurations.ps1
Write-Host "Updating Import-AllConfigurations.ps1..." -ForegroundColor Yellow
$file = Join-Path $scriptRoot "Import-Scripts\Import-AllConfigurations.ps1"
$content = Get-Content $file -Raw
$content = $content -replace '\$scriptPath = \$PSScriptRoot', '$scriptPath = Split-Path $PSScriptRoot -Parent'
$content = $content -replace '\$outputPath = Join-Path \$scriptPath "Output-Files"', '$outputPath = Join-Path $scriptPath "Output-Files"'
$content = $content -replace 'Join-Path \$scriptPath \$script', 'Join-Path $scriptPath "Import-Scripts\$script"'
$content = $content -replace 'Join-Path \$scriptPath "\.\.\\Encryption-Scripts\\Unprotect-ConfigFile\.ps1"', 'Join-Path $scriptPath "Encryption-Scripts\Unprotect-ConfigFile.ps1"'
$content | Out-File $file -Encoding utf8 -NoNewline
Write-Host "  ✓ Updated" -ForegroundColor Green

# Update all Export scripts to use correct output path
$exportScripts = Get-ChildItem -Path (Join-Path $scriptRoot "Export-Scripts") -Filter "Export-*.ps1" | Where-Object {$_.Name -ne "Export-AllConfigurations.ps1"}
foreach ($script in $exportScripts) {
    Write-Host "Updating $($script.Name)..." -ForegroundColor Yellow
    $content = Get-Content $script.FullName -Raw
    $content = $content -replace '\$PSScriptRoot\\Output-Files\\', '(Split-Path $PSScriptRoot -Parent) + "\Output-Files\"'
    $content = $content -replace 'Join-Path \$PSScriptRoot "Output-Files\\', 'Join-Path (Split-Path $PSScriptRoot -Parent) "Output-Files\'
    $content | Out-File $script.FullName -Encoding utf8 -NoNewline
    Write-Host "  ✓ Updated" -ForegroundColor Green
}

# Update all Import scripts to use correct paths
$importScripts = Get-ChildItem -Path (Join-Path $scriptRoot "Import-Scripts") -Filter "Import-*.ps1" | Where-Object {$_.Name -ne "Import-AllConfigurations.ps1"}
foreach ($script in $importScripts) {
    Write-Host "Updating $($script.Name)..." -ForegroundColor Yellow
    $content = Get-Content $script.FullName -Raw
    
    # Update paths to Output-Files
    $content = $content -replace 'Join-Path \$PSScriptRoot "Output-Files\\', 'Join-Path (Split-Path $PSScriptRoot -Parent) "Output-Files\'
    
    # Update paths to Encryption-Scripts
    $content = $content -replace 'Join-Path \$PSScriptRoot "Unprotect-ConfigFile\.ps1"', 'Join-Path (Split-Path $PSScriptRoot -Parent) "Encryption-Scripts\Unprotect-ConfigFile.ps1"'
    
    $content | Out-File $script.FullName -Encoding utf8 -NoNewline
    Write-Host "  ✓ Updated" -ForegroundColor Green
}

# Update Protect-AllConfigFiles.ps1
Write-Host "Updating Protect-AllConfigFiles.ps1..." -ForegroundColor Yellow
$file = Join-Path $scriptRoot "Encryption-Scripts\Protect-AllConfigFiles.ps1"
$content = Get-Content $file -Raw
$content = $content -replace '\$scriptPath = \$PSScriptRoot', '$scriptPath = Split-Path $PSScriptRoot -Parent'
$content = $content -replace 'Join-Path \$scriptPath "Protect-ConfigFile\.ps1"', 'Join-Path $scriptPath "Encryption-Scripts\Protect-ConfigFile.ps1"'
$content | Out-File $file -Encoding utf8 -NoNewline
Write-Host "  ✓ Updated" -ForegroundColor Green

# Update Unprotect-AllConfigFiles.ps1
Write-Host "Updating Unprotect-AllConfigFiles.ps1..." -ForegroundColor Yellow
$file = Join-Path $scriptRoot "Encryption-Scripts\Unprotect-AllConfigFiles.ps1"
$content = Get-Content $file -Raw
$content = $content -replace '\$scriptPath = \$PSScriptRoot', '$scriptPath = Split-Path $PSScriptRoot -Parent'
$content = $content -replace 'Join-Path \$scriptPath "Unprotect-ConfigFile\.ps1"', 'Join-Path $scriptPath "Encryption-Scripts\Unprotect-ConfigFile.ps1"'
$content | Out-File $file -Encoding utf8 -NoNewline
Write-Host "  ✓ Updated" -ForegroundColor Green

# Update Test-Encryption.ps1
Write-Host "Updating Test-Encryption.ps1..." -ForegroundColor Yellow
$file = Join-Path $scriptRoot "Encryption-Scripts\Test-Encryption.ps1"
$content = Get-Content $file -Raw
$content = $content -replace '\$scriptPath = \$PSScriptRoot', '$scriptPath = Split-Path $PSScriptRoot -Parent'
$content = $content -replace 'Join-Path \$scriptPath "Protect-ConfigFile\.ps1"', 'Join-Path $scriptPath "Encryption-Scripts\Protect-ConfigFile.ps1"'
$content = $content -replace 'Join-Path \$scriptPath "Unprotect-ConfigFile\.ps1"', 'Join-Path $scriptPath "Encryption-Scripts\Unprotect-ConfigFile.ps1"'
$content | Out-File $file -Encoding utf8 -NoNewline
Write-Host "  ✓ Updated" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Path Updates Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "✓ All scripts updated to use new folder structure" -ForegroundColor Green
Write-Host ""
Write-Host "New usage:" -ForegroundColor Yellow
Write-Host "  cd scripts" -ForegroundColor White
Write-Host "  .\Export-Scripts\Export-AllConfigurations.ps1" -ForegroundColor Cyan
Write-Host "  .\Import-Scripts\Import-AllConfigurations.ps1" -ForegroundColor Cyan
Write-Host "  .\Encryption-Scripts\Test-Encryption.ps1" -ForegroundColor Cyan
Write-Host ""
