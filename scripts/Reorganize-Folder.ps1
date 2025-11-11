<#
.SYNOPSIS
    Reorganizes the scripts folder into a logical structure
.DESCRIPTION
    Creates organized folders and moves scripts to appropriate locations.
    Updates all path references in scripts to reflect new structure.
.NOTES
    Run this once to reorganize the folder structure
#>

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Folder Reorganization" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptRoot = $PSScriptRoot

# Define folder structure
$folders = @(
    "Export-Scripts",
    "Import-Scripts",
    "Encryption-Scripts",
    "Documentation",
    "Output-Files"
)

# Create folders if they don't exist
Write-Host "Creating folder structure..." -ForegroundColor Yellow
foreach ($folder in $folders) {
    $folderPath = Join-Path $scriptRoot $folder
    if (-not (Test-Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
        Write-Host "  ✓ Created: $folder" -ForegroundColor Green
    } else {
        Write-Host "  - Exists: $folder" -ForegroundColor Gray
    }
}
Write-Host ""

# Define file movements
$fileMovements = @{
    "Export-Scripts" = @(
        "Export-AllConfigurations.ps1",
        "Export-PSReadLineHistory.ps1",
        "Export-VSCodeExtensions.ps1",
        "Export-GitConfig.ps1",
        "Export-BeyondCompareLicense.ps1"
    )
    "Import-Scripts" = @(
        "Import-AllConfigurations.ps1",
        "Import-PSReadLineHistory.ps1",
        "Import-VSCodeExtensions.ps1",
        "Import-GitConfig.ps1",
        "Import-BeyondCompareLicense.ps1"
    )
    "Encryption-Scripts" = @(
        "Protect-ConfigFile.ps1",
        "Unprotect-ConfigFile.ps1",
        "Protect-AllConfigFiles.ps1",
        "Unprotect-AllConfigFiles.ps1",
        "Test-Encryption.ps1"
    )
    "Documentation" = @(
        "README.md",
        "CHECKLIST.md",
        "ENCRYPTION-README.md",
        "ENCRYPTION-QUICK-REF.md",
        "ENCRYPTION-IMPLEMENTATION.md",
        "ENCRYPTION-COMPLETE.md",
        "FILE-STRUCTURE.md"
    )
    "Output-Files" = @(
        "git-config-backup.txt",
        "git-config-backup.txt.encrypted",
        "PSReadLine-History-Export.txt",
        "PSReadLine-History-Export.txt.encrypted",
        "vscode-extensions.txt",
        "vscode-extensions-list.txt",
        "BeyondCompare-License.reg",
        "BeyondCompare-License.reg.encrypted",
        "BeyondCompare-License-Info.json",
        "BeyondCompare-License-Info.json.encrypted"
    )
}

# Move files
Write-Host "Moving files to organized folders..." -ForegroundColor Yellow
$movedCount = 0
$skippedCount = 0

foreach ($folder in $fileMovements.Keys) {
    $destFolder = Join-Path $scriptRoot $folder
    
    foreach ($file in $fileMovements[$folder]) {
        $sourcePath = Join-Path $scriptRoot $file
        $destPath = Join-Path $destFolder $file
        
        if (Test-Path $sourcePath) {
            try {
                Move-Item -Path $sourcePath -Destination $destPath -Force
                Write-Host "  ✓ Moved: $file → $folder" -ForegroundColor Green
                $movedCount++
            }
            catch {
                Write-Host "  ✗ Failed to move: $file ($_)" -ForegroundColor Red
            }
        }
        else {
            $skippedCount++
        }
    }
}

Write-Host ""
Write-Host "Files moved: $movedCount" -ForegroundColor Green
Write-Host "Files skipped (not found): $skippedCount" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  New Folder Structure" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "scripts/" -ForegroundColor Cyan
Write-Host "  ├── setup-new-pc.ps1                 [Main setup script - stays in root]" -ForegroundColor White
Write-Host "  ├── Reorganize-Folder.ps1            [This script]" -ForegroundColor White
Write-Host "  ├── Export-Scripts/                  [All export scripts]" -ForegroundColor Yellow
Write-Host "  ├── Import-Scripts/                  [All import scripts]" -ForegroundColor Yellow
Write-Host "  ├── Encryption-Scripts/              [All encryption utilities]" -ForegroundColor Yellow
Write-Host "  ├── Documentation/                   [All documentation]" -ForegroundColor Yellow
Write-Host "  └── Output-Files/                    [All exported data]" -ForegroundColor Yellow
Write-Host ""

Write-Host "⚠ IMPORTANT: Path references need to be updated!" -ForegroundColor Red
Write-Host ""
Write-Host "Run the following script to update all path references:" -ForegroundColor Yellow
Write-Host "  .\Update-ScriptPaths.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will update all scripts to use the new folder structure." -ForegroundColor White
Write-Host ""
