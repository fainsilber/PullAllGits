# 📁 File Structure Overview

## Complete Script Collection

```
c:\git\jf\PullAllGits\scripts\
│
├── 📋 SETUP SCRIPTS
│   ├── setup-new-pc.ps1                      [Main installation script]
│   └── Export-AllConfigurations.ps1          [Master export with encryption prompt]
│   └── Import-AllConfigurations.ps1          [Master import with auto-decryption]
│
├── 📤 EXPORT SCRIPTS (Run on OLD PC)
│   ├── Export-PSReadLineHistory.ps1          [Export PowerShell history]
│   ├── Export-VSCodeExtensions.ps1           [Export VS Code extensions]
│   ├── Export-GitConfig.ps1                  [Export Git configuration]
│   └── Export-BeyondCompareLicense.ps1       [Export BC license]
│
├── 📥 IMPORT SCRIPTS (Run on NEW PC)
│   ├── Import-PSReadLineHistory.ps1          [Import PowerShell history + decrypt]
│   ├── Import-VSCodeExtensions.ps1           [Install VS Code extensions]
│   ├── Import-GitConfig.ps1                  [Import Git config + decrypt]
│   └── Import-BeyondCompareLicense.ps1       [Import BC license + decrypt]
│
├── 🔐 ENCRYPTION SCRIPTS (NEW!)
│   ├── Protect-ConfigFile.ps1                [Encrypt single file - AES-256]
│   ├── Unprotect-ConfigFile.ps1              [Decrypt single file]
│   ├── Protect-AllConfigFiles.ps1            [Batch encrypt all configs]
│   ├── Unprotect-AllConfigFiles.ps1          [Batch decrypt all configs]
│   └── Test-Encryption.ps1                   [Test encryption system]
│
├── 📄 EXPORTED DATA FILES
│   ├── git-config-backup.txt                 [Git config (can be encrypted)]
│   ├── PSReadLine-History-Export.txt         [Command history (can be encrypted)]
│   ├── vscode-extensions.txt                 [VS Code extension IDs]
│   ├── vscode-extensions-list.txt            [VS Code extensions list]
│   ├── BeyondCompare-License.reg             [BC license (can be encrypted)]
│   └── BeyondCompare-License-Info.json       [BC metadata (can be encrypted)]
│
├── 🔒 ENCRYPTED FILES (After encryption)
│   ├── git-config-backup.txt.encrypted       [Encrypted Git config]
│   ├── PSReadLine-History-Export.txt.encrypted [Encrypted history]
│   ├── BeyondCompare-License.reg.encrypted   [Encrypted license]
│   └── BeyondCompare-License-Info.json.encrypted [Encrypted metadata]
│
└── 📚 DOCUMENTATION
    ├── README.md                              [Main documentation]
    ├── CHECKLIST.md                           [Setup checklist]
    ├── ENCRYPTION-README.md                   [Complete encryption docs]
    ├── ENCRYPTION-QUICK-REF.md               [Quick reference guide]
    ├── ENCRYPTION-IMPLEMENTATION.md          [Technical implementation]
    ├── ENCRYPTION-COMPLETE.md                [Feature completion summary]
    └── FILE-STRUCTURE.md                     [This file!]
```

## 📊 File Statistics

### Scripts by Category

| Category | Count | Purpose |
|----------|-------|---------|
| **Setup Scripts** | 3 | Main orchestration |
| **Export Scripts** | 4 | Export configurations from old PC |
| **Import Scripts** | 4 | Import configurations to new PC |
| **Encryption Scripts** | 5 | Protect sensitive files |
| **Documentation** | 7 | User guides and references |
| **Data Files** | Variable | Exported configurations |

### Total Files: 26 files

- PowerShell Scripts: 16
- Documentation Files: 7
- Data Files: 3-6 (depends on what's exported)

## 🔄 Workflow Files

### Phase 1: Export (OLD PC)
```
Export-AllConfigurations.ps1
  ├─→ Export-PSReadLineHistory.ps1 → PSReadLine-History-Export.txt
  ├─→ Export-VSCodeExtensions.ps1 → vscode-extensions.txt
  ├─→ Export-GitConfig.ps1 → git-config-backup.txt
  └─→ Export-BeyondCompareLicense.ps1 → BeyondCompare-License.reg

Optional Encryption:
  └─→ Protect-AllConfigFiles.ps1
        ├─→ git-config-backup.txt.encrypted
        ├─→ PSReadLine-History-Export.txt.encrypted
        └─→ BeyondCompare-License.reg.encrypted
```

### Phase 2: Transfer
```
Copy entire scripts\ folder to:
  - USB Drive
  - Cloud Storage (OneDrive, Google Drive)
  - Network Location
```

### Phase 3: Setup (NEW PC)
```
setup-new-pc.ps1
  ├─→ Install winget packages
  ├─→ Configure PowerShell profile
  └─→ Install PowerShell modules
```

### Phase 4: Import (NEW PC)
```
Import-AllConfigurations.ps1
  │
  ├─→ Detect encrypted files
  │   └─→ Unprotect-AllConfigFiles.ps1 (if needed)
  │
  ├─→ Import-PSReadLineHistory.ps1
  ├─→ Import-VSCodeExtensions.ps1
  ├─→ Import-GitConfig.ps1
  └─→ Import-BeyondCompareLicense.ps1
```

## 🔐 Encryption File Flow

### Without Encryption (Original)
```
Export → [plain.txt] → Transfer → [plain.txt] → Import
```

### With Encryption (NEW!)
```
Export → [plain.txt] → Encrypt → [plain.txt.encrypted] → Transfer
  → [plain.txt.encrypted] → Decrypt → [plain.txt] → Import → Delete [plain.txt]
```

## 📋 Script Dependencies

### No Dependencies
- Export-PSReadLineHistory.ps1
- Export-VSCodeExtensions.ps1
- Export-GitConfig.ps1
- Export-BeyondCompareLicense.ps1
- Test-Encryption.ps1

### Uses Protect-ConfigFile.ps1
- Export-AllConfigurations.ps1
- Protect-AllConfigFiles.ps1

### Uses Unprotect-ConfigFile.ps1
- Import-AllConfigurations.ps1
- Import-PSReadLineHistory.ps1
- Import-GitConfig.ps1
- Import-BeyondCompareLicense.ps1
- Unprotect-AllConfigFiles.ps1

## 🎯 Quick File Reference

### Need to encrypt files?
→ `Protect-ConfigFile.ps1` (single file)
→ `Protect-AllConfigFiles.ps1` (all files)

### Need to decrypt files?
→ `Unprotect-ConfigFile.ps1` (single file)
→ `Unprotect-AllConfigFiles.ps1` (all files)

### Need help?
→ `README.md` (start here)
→ `ENCRYPTION-QUICK-REF.md` (quick commands)
→ `ENCRYPTION-README.md` (full details)

### Need to test?
→ `Test-Encryption.ps1` (verify encryption works)

### Need a checklist?
→ `CHECKLIST.md` (step-by-step guide)

## 📦 File Size Reference

| File Type | Typical Size | Notes |
|-----------|-------------|-------|
| PowerShell Scripts | 1-8 KB | Executable code |
| Documentation | 2-9 KB | Markdown files |
| Git Config | < 1 KB | Text configuration |
| Command History | 50-500 KB | Can be large |
| VS Code Extensions | < 1 KB | List of IDs |
| BC License | 1-5 KB | Registry export |
| Encrypted Files | +32 bytes + padding | Original + overhead |

## 🔍 File Search Guide

### Find all PowerShell scripts
```powershell
Get-ChildItem -Filter "*.ps1"
```

### Find all documentation
```powershell
Get-ChildItem -Filter "*.md"
```

### Find encrypted files
```powershell
Get-ChildItem -Filter "*.encrypted"
```

### Find export scripts
```powershell
Get-ChildItem -Filter "Export-*.ps1"
```

### Find import scripts
```powershell
Get-ChildItem -Filter "Import-*.ps1"
```

### Find encryption scripts
```powershell
Get-ChildItem -Filter "*Protect*.ps1"
```

## 🎨 Color Coding Legend

- 📋 Setup & Orchestration
- 📤 Export Operations
- 📥 Import Operations
- 🔐 Encryption & Security
- 📄 Data Files
- 🔒 Encrypted Files
- 📚 Documentation

---

**Last Updated:** November 11, 2025
**Total Files:** 26
**Total Size:** ~500 KB (excluding large history files)
