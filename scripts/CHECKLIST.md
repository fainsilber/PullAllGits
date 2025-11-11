# New PC Setup Checklist

Use this checklist to ensure you complete all steps when setting up your new PC.

## ✅ Before Leaving Your Old PC

- [ ] Navigate to `c:\git\jf\scripts`
- [ ] Run `.\Export-AllConfigurations.ps1`
- [ ] **🔐 NEW: Encryption (Recommended)**
  - [ ] When prompted "Would you like to encrypt these files now?", choose `Y`
  - [ ] Enter a strong password (write it down securely!)
  - [ ] Confirm password
  - [ ] Verify files were encrypted (`.encrypted` extension added)
- [ ] Verify the following files were created:
  - [ ] `PSReadLine-History-Export.txt` (or `.encrypted`)
  - [ ] `vscode-extensions.txt`
  - [ ] `vscode-extensions-list.txt`
  - [ ] `git-config-backup.txt` (or `.encrypted`)
  - [ ] `BeyondCompare-License.reg` (or `.encrypted`) - if Beyond Compare is licensed
  - [ ] `BeyondCompare-License-Info.json` (or `.encrypted`) - if Beyond Compare is licensed
- [ ] Copy the entire `c:\git\jf\scripts` folder to:
  - [ ] USB drive, or
  - [ ] Cloud storage (OneDrive, Google Drive, etc.), or
  - [ ] Network location
- [ ] **Remember your encryption password!** (Store in password manager)
- [ ] (Optional) Export SSH keys from `%USERPROFILE%\.ssh`
- [ ] (Optional) Backup any custom application settings

## ✅ On Your New PC - Initial Setup

- [ ] Copy the scripts folder to `c:\git\jf\scripts`
- [ ] Open PowerShell 7 **as Administrator**
  - Right-click PowerShell → "Run as Administrator"
- [ ] Navigate to scripts: `cd c:\git\jf\scripts`
- [ ] Run main setup: `.\setup-new-pc.ps1`
- [ ] When prompted, configure Artifactory credentials:
  - [ ] Username: _________________
  - [ ] Token: (paste securely)
- [ ] Wait for all software installations to complete (~15-30 minutes)

## ✅ On Your New PC - Configuration Import

- [ ] In PowerShell (can be non-admin now), navigate to scripts folder
- [ ] Run import script: `.\Import-AllConfigurations.ps1`
- [ ] **🔐 NEW: Decryption (if you encrypted)**
  - [ ] When prompted "Would you like to decrypt these files now?", choose `Y`
  - [ ] Enter your encryption password
  - [ ] Verify files were decrypted successfully
- [ ] Verify imports completed successfully:
  - [ ] PowerShell history imported
  - [ ] VS Code extensions installed
  - [ ] Git configuration imported
  - [ ] Beyond Compare license (if admin) or note to import later
- [ ] If Beyond Compare license was skipped, run as Administrator:
  - [ ] Open PowerShell as Administrator
  - [ ] Navigate to scripts folder
  - [ ] Run: `.\Import-BeyondCompareLicense.ps1`
  - [ ] Enter decryption password if prompted
- [ ] **🔐 Security Cleanup**
  - [ ] Delete decrypted files after successful import:
    - [ ] `git-config-backup.txt`
    - [ ] `PSReadLine-History-Export.txt`
    - [ ] `BeyondCompare-License.reg`
    - [ ] `BeyondCompare-License-Info.json`
  - [ ] Keep `.encrypted` files if you want to re-import later
- [ ] Close and restart Windows Terminal
- [ ] Close and restart VS Code

## ✅ Post-Installation Configuration

### Git Configuration
- [ ] Verify Git user settings:
  ```powershell
  git config --global user.name
  git config --global user.email
  ```
- [ ] If needed, update Git credentials:
  ```powershell
  git config --global user.name "Your Name"
  git config --global user.email "your.email@example.com"
  ```
- [ ] (Optional) Copy SSH keys to `%USERPROFILE%\.ssh`
- [ ] (Optional) Test Git authentication:
  ```powershell
  ssh -T git@github.com
  ```

### Application Sign-ins
- [ ] **Docker Desktop**
  - [ ] Launch Docker Desktop
  - [ ] Sign in with Docker Hub account
  - [ ] Wait for Docker to start
  - [ ] Test: `docker --version`

- [ ] **Tailscale**
  - [ ] Launch Tailscale
  - [ ] Sign in with your account
  - [ ] Connect to your network

- [ ] **VS Code**
  - [ ] Launch VS Code
  - [ ] Sign in to Settings Sync (if using)
  - [ ] Verify extensions loaded
  - [ ] Check that all extensions are enabled

- [ ] **Google Chrome**
  - [ ] Launch Chrome
  - [ ] Sign in to sync bookmarks and settings

### PowerShell Verification
- [ ] Open new PowerShell terminal
- [ ] Verify posh-git is loaded (Git status in prompt)
- [ ] Test PSReadLine predictions (type part of a previous command)
- [ ] Press Up arrow - should show ListView suggestions
- [ ] Test Artifactory credentials (if configured):
  ```powershell
  $env:ARTIFACTORY_USERNAME
  $env:ARTIFACTORY_TOKEN
  ```

### Optional Tools Configuration
- [ ] **Ditto** (Clipboard Manager)
  - [ ] Launch Ditto
  - [ ] Configure hotkeys (default: Ctrl+`)
  - [ ] Set to start with Windows

- [ ] **Everything** (File Search)
  - [ ] Launch Everything
  - [ ] Wait for initial index
  - [ ] Test search functionality

- [ ] **Windows Terminal**
  - [ ] Set as default terminal
  - [ ] Configure color scheme (if desired)
  - [ ] Set PowerShell 7 as default profile

- [ ] **Beyond Compare** (if licensed)
  - [ ] Launch Beyond Compare
  - [ ] Verify license: Help > About
  - [ ] Check license status is "Licensed" not "Trial"
  - [ ] Delete license files after successful import:
    - [ ] Delete `BeyondCompare-License.reg`
    - [ ] Delete `BeyondCompare-License-Info.json`

## ✅ Development Environment Tests

- [ ] Test PowerShell 7:
  ```powershell
  $PSVersionTable.PSVersion
  ```

- [ ] Test Git:
  ```powershell
  git --version
  git config --list
  ```

- [ ] Test Node.js:
  ```powershell
  node --version
  npm --version
  ```

- [ ] Test Python:
  ```powershell
  python --version
  pip --version
  ```

- [ ] Test Docker:
  ```powershell
  docker --version
  docker ps
  ```

- [ ] Test VS Code:
  ```powershell
  code --version
  code --list-extensions
  ```

## ✅ Additional Setup (As Needed)

- [ ] Install additional VS Code extensions
- [ ] Configure Windows settings (themes, display, etc.)
- [ ] Install additional software not in the script
- [ ] Set up browser extensions
- [ ] Configure file associations
- [ ] Set up network drives
- [ ] Configure printers
- [ ] Restore bookmarks/favorites
- [ ] Configure startup applications

## 🎉 Final Verification

- [ ] All required applications installed and working
- [ ] PowerShell profile loading correctly
- [ ] Command history available in PowerShell
- [ ] VS Code extensions loaded and functional
- [ ] Git configuration correct
- [ ] Docker running (if needed immediately)
- [ ] All logins and authentications complete
- [ ] Development environment functional

## 📝 Notes

Use this space to note any issues or additional steps needed:

```
_____________________________________________________________

_____________________________________________________________

_____________________________________________________________

_____________________________________________________________

_____________________________________________________________
```

---

**Date Started**: _______________  
**Date Completed**: _______________  
**Total Time**: _______________
