<#
.SYNOPSIS
    Implements partial folder organization (recommended approach)
.DESCRIPTION
    - Keeps all scripts in root folder (they cross-reference each other)
    - Moves documentation to Documentation/ folder
    - Moves output files to Output-Files/ folder (with .gitignore)
    - Updates only necessary path references
.NOTES
    This is the recommended approach for maintainability
#>

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Partial Folder Organization" -ForegroundColor Cyan
Write-Host "  (Recommended Approach)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptRoot = $PSScriptRoot

# Create only the folders we need
Write-Host "Creating organized folders..." -ForegroundColor Yellow

$folders = @("Documentation", "Output-Files")
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

# Move documentation files
Write-Host "Moving documentation files..." -ForegroundColor Yellow
$docFiles = @(
    "CHECKLIST.md",
    "ENCRYPTION-README.md",
    "ENCRYPTION-QUICK-REF.md",
    "ENCRYPTION-IMPLEMENTATION.md",
    "ENCRYPTION-COMPLETE.md",
    "FILE-STRUCTURE.md"
)

$docMoved = 0
foreach ($file in $docFiles) {
    $source = Join-Path $scriptRoot $file
    $dest = Join-Path $scriptRoot "Documentation\$file"
    
    if (Test-Path $source) {
        Move-Item -Path $source -Destination $dest -Force
        Write-Host "  ✓ Moved: $file" -ForegroundColor Green
        $docMoved++
    }
}
Write-Host "  Documentation files moved: $docMoved" -ForegroundColor Cyan
Write-Host ""

# Move output files
Write-Host "Moving output files..." -ForegroundColor Yellow
$outputFiles = @(
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

$outputMoved = 0
foreach ($file in $outputFiles) {
    $source = Join-Path $scriptRoot $file
    $dest = Join-Path $scriptRoot "Output-Files\$file"
    
    if (Test-Path $source) {
        Move-Item -Path $source -Destination $dest -Force
        Write-Host "  ✓ Moved: $file" -ForegroundColor Green
        $outputMoved++
    }
}
Write-Host "  Output files moved: $outputMoved" -ForegroundColor Cyan
Write-Host ""

# Create .gitignore for Output-Files
Write-Host "Creating .gitignore for Output-Files..." -ForegroundColor Yellow
$gitignoreContent = @"
# Ignore all exported configuration files
*.txt
*.reg
*.json
*.encrypted

# But keep the README
!README.md
"@

$gitignorePath = Join-Path $scriptRoot "Output-Files\.gitignore"
$gitignoreContent | Out-File -FilePath $gitignorePath -Encoding utf8
Write-Host "  ✓ Created: Output-Files\.gitignore" -ForegroundColor Green
Write-Host ""

# Create README for Output-Files
Write-Host "Creating README for Output-Files..." -ForegroundColor Yellow
$outputReadmeContent = @"
# Output Files Directory

This directory contains all exported configuration files from your old PC.

## Files Created by Export Scripts

### Configuration Files
- **git-config-backup.txt** - Git global configuration
- **PSReadLine-History-Export.txt** - PowerShell command history
- **vscode-extensions.txt** - VS Code extension IDs
- **vscode-extensions-list.txt** - VS Code extension names and descriptions

### License Files (if applicable)
- **BeyondCompare-License.reg** - Beyond Compare license registry export
- **BeyondCompare-License-Info.json** - Beyond Compare license metadata

## Encrypted Files

If you chose to encrypt during export, you'll also see:
- **git-config-backup.txt.encrypted**
- **PSReadLine-History-Export.txt.encrypted**
- **BeyondCompare-License.reg.encrypted**
- **BeyondCompare-License-Info.json.encrypted**

## Security Note

⚠️ **These files may contain sensitive information!**

- Git configuration may include email, credentials, and tokens
- Command history may contain passwords or API keys
- License files contain software keys

### Recommendations:
1. Use encryption (prompted during export)
2. Delete unencrypted files after encryption
3. Don't commit these files to version control (.gitignore is configured)
4. Delete decrypted files after import on new PC

## Usage

These files are automatically read by the import scripts. No manual action needed!

Run on your new PC:
\`\`\`powershell
..\Import-AllConfigurations.ps1
\`\`\`
"@

$outputReadmePath = Join-Path $scriptRoot "Output-Files\README.md"
$outputReadmeContent | Out-File -FilePath $outputReadmePath -Encoding utf8
Write-Host "  ✓ Created: Output-Files\README.md" -ForegroundColor Green
Write-Host ""

# Create README for Documentation
Write-Host "Creating README for Documentation..." -ForegroundColor Yellow
$docReadmeContent = @"
# Documentation Directory

Complete documentation for the PC Setup Scripts toolkit.

## Main Documentation

Start here if you're new:
- **../README.md** - Main documentation (in root folder)

## Detailed Guides

- **CHECKLIST.md** - Step-by-step setup checklist
- **ENCRYPTION-README.md** - Complete encryption documentation
- **ENCRYPTION-QUICK-REF.md** - Quick encryption reference
- **ENCRYPTION-IMPLEMENTATION.md** - Technical implementation details
- **ENCRYPTION-COMPLETE.md** - Encryption feature summary
- **FILE-STRUCTURE.md** - Project file structure overview

## Reading Order

1. **../README.md** - Understand the overall system
2. **CHECKLIST.md** - Follow the setup process
3. **ENCRYPTION-QUICK-REF.md** - Learn encryption basics
4. **ENCRYPTION-README.md** - Deep dive into encryption (if needed)

## Quick Links

### Need Help With...

**Encryption?**
→ ENCRYPTION-QUICK-REF.md (quick) or ENCRYPTION-README.md (detailed)

**Setup Process?**
→ CHECKLIST.md

**File Organization?**
→ FILE-STRUCTURE.md

**Technical Details?**
→ ENCRYPTION-IMPLEMENTATION.md
"@

$docReadmePath = Join-Path $scriptRoot "Documentation\README.md"
$docReadmeContent | Out-File -FilePath $docReadmePath -Encoding utf8
Write-Host "  ✓ Created: Documentation\README.md" -ForegroundColor Green
Write-Host ""

# Now update the necessary scripts with new paths
Write-Host "Updating script path references..." -ForegroundColor Yellow

# Update all scripts to use Output-Files folder
$scriptsToUpdate = @(
    "Export-PSReadLineHistory.ps1",
    "Export-VSCodeExtensions.ps1",
    "Export-GitConfig.ps1",
    "Export-BeyondCompareLicense.ps1",
    "Import-PSReadLineHistory.ps1",
    "Import-VSCodeExtensions.ps1",
    "Import-GitConfig.ps1",
    "Import-BeyondCompareLicense.ps1",
    "Protect-AllConfigFiles.ps1",
    "Unprotect-AllConfigFiles.ps1"
)

$updatedCount = 0
foreach ($scriptName in $scriptsToUpdate) {
    $scriptPath = Join-Path $scriptRoot $scriptName
    if (Test-Path $scriptPath) {
        $content = Get-Content $scriptPath -Raw
        
        # Replace PSScriptRoot references for output files
        $originalContent = $content
        $content = $content -replace '\$PSScriptRoot\\', '$PSScriptRoot\Output-Files\'
        $content = $content -replace 'Join-Path \$PSScriptRoot "([^"]+\.(txt|reg|json))"', 'Join-Path $PSScriptRoot "Output-Files\$1"'
        
        # Don't replace if it's referencing other scripts
        $content = $content -replace '\$PSScriptRoot\\Output-Files\\([^"]*\.ps1)', '$PSScriptRoot\$1'
        $content = $content -replace 'Join-Path \$PSScriptRoot "Output-Files\\([^"]*\.ps1)"', 'Join-Path $PSScriptRoot "$1"'
        
        if ($content -ne $originalContent) {
            $content | Out-File -FilePath $scriptPath -Encoding utf8 -NoNewline
            Write-Host "  ✓ Updated: $scriptName" -ForegroundColor Green
            $updatedCount++
        }
    }
}

Write-Host "  Scripts updated: $updatedCount" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Organization Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "New structure:" -ForegroundColor Yellow
Write-Host ""
Write-Host "scripts/" -ForegroundColor Cyan
Write-Host "  ├── *.ps1                      [All scripts remain in root]" -ForegroundColor White
Write-Host "  ├── README.md                  [Main documentation stays in root]" -ForegroundColor White
Write-Host "  ├── Documentation/" -ForegroundColor Yellow
Write-Host "  │   ├── README.md" -ForegroundColor White
Write-Host "  │   ├── CHECKLIST.md" -ForegroundColor White
Write-Host "  │   ├── ENCRYPTION-*.md" -ForegroundColor White
Write-Host "  │   └── FILE-STRUCTURE.md" -ForegroundColor White
Write-Host "  └── Output-Files/" -ForegroundColor Yellow
Write-Host "      ├── README.md" -ForegroundColor White
Write-Host "      ├── .gitignore              [Protects sensitive files]" -ForegroundColor White
Write-Host "      └── *.txt, *.reg, *.json    [Exported configurations]" -ForegroundColor White
Write-Host ""

Write-Host "✓ Benefits of this structure:" -ForegroundColor Green
Write-Host "  • Scripts stay in root (easy cross-referencing)" -ForegroundColor White
Write-Host "  • Documentation is organized" -ForegroundColor White
Write-Host "  • Output files are isolated" -ForegroundColor White
Write-Host "  • .gitignore protects sensitive data" -ForegroundColor White
Write-Host "  • Minimal path changes required" -ForegroundColor White
Write-Host ""

Write-Host "⚠️ Important: Test the scripts to ensure paths work correctly!" -ForegroundColor Yellow
Write-Host ""
Write-Host "To test:" -ForegroundColor Yellow
Write-Host "  .\Test-Encryption.ps1           [Test encryption]" -ForegroundColor Cyan
Write-Host "  .\Export-AllConfigurations.ps1  [Test export]" -ForegroundColor Cyan
Write-Host ""
