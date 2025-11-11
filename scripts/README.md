# Ne## 📁 Folder Structure

```
scripts/
├── setup-new-pc.ps1                → Main installation script (root)
├── README.md                       → This file (main documentation)
│
├── Export-Scripts/                 → All export scripts
│   ├── Export-AllConfigurations.ps1    (Master export + encryption)
│   ├── Export-PSReadLineHistory.ps1
│   ├── Export-VSCodeExtensions.ps1
│   ├── Export-GitConfig.ps1
│   └── Export-BeyondCompareLicense.ps1
│
├── Import-Scripts/                 → All import scripts
│   ├── Import-AllConfigurations.ps1    (Master import + decryption)
│   ├── Import-PSReadLineHistory.ps1
│   ├── Import-VSCodeExtensions.ps1
│   ├── Import-GitConfig.ps1
│   └── Import-BeyondCompareLicense.ps1
│
├── Encryption-Scripts/             → All encryption utilities
│   ├── Protect-ConfigFile.ps1          (Encrypt single file)
│   ├── Unprotect-ConfigFile.ps1        (Decrypt single file)
│   ├── Protect-AllConfigFiles.ps1      (Batch encrypt)
│   ├── Unprotect-AllConfigFiles.ps1    (Batch decrypt)
│   └── Test-Encryption.ps1             (Test suite)
│
├── Documentation/                  → All detailed documentation
│   ├── CHECKLIST.md
│   ├── ENCRYPTION-*.md
│   └── FILE-STRUCTURE.md
│
└── Output-Files/                   → Exported configuration files
    ├── .gitignore                      (Protects sensitive data)
    └── *.txt, *.reg, *.json, *.encrypted
```ipts

A comprehensive collection of PowerShell scripts to automate the setup of a new Windows PC, including software installation and configuration migration.

## � Folder Structure

```
scripts/
├── *.ps1                       → All executable scripts (root level)
├── README.md                   → This file (main documentation)
├── Documentation/              → All detailed documentation
│   ├── CHECKLIST.md
│   ├── ENCRYPTION-*.md
│   └── FILE-STRUCTURE.md
└── Output-Files/               → Exported configuration files
    ├── .gitignore              → Protects sensitive data
    └── *.txt, *.reg, *.json    → Your exported configs
```

## �📋 Contents

### Main Setup Script
- **`setup-new-pc.ps1`** - Main script that installs all software and configures PowerShell profile

### Export Scripts (Run on OLD PC)
- **`Export-AllConfigurations.ps1`** - Master script that runs all exports (with optional encryption)
- **`Export-PSReadLineHistory.ps1`** - Export PowerShell command history
- **`Export-VSCodeExtensions.ps1`** - Export VS Code extensions list
- **`Export-GitConfig.ps1`** - Export Git global configuration
- **`Export-BeyondCompareLicense.ps1`** - Export Beyond Compare license

### Import Scripts (Run on NEW PC)
- **`Import-AllConfigurations.ps1`** - Master script that runs all imports (with auto-decryption)
- **`Import-PSReadLineHistory.ps1`** - Import PowerShell command history
- **`Import-VSCodeExtensions.ps1`** - Install VS Code extensions
- **`Import-GitConfig.ps1`** - Import Git global configuration
- **`Import-BeyondCompareLicense.ps1`** - Import Beyond Compare license (requires admin)

### 🔐 Encryption Utilities (NEW!)
- **`Protect-ConfigFile.ps1`** - Encrypt a single configuration file with AES-256
- **`Unprotect-ConfigFile.ps1`** - Decrypt a single configuration file
- **`Protect-AllConfigFiles.ps1`** - Batch encrypt all sensitive config files
- **`Unprotect-AllConfigFiles.ps1`** - Batch decrypt all encrypted files
- **`Test-Encryption.ps1`** - Test encryption/decryption functionality
- **`ENCRYPTION-README.md`** - Detailed encryption documentation
- **`ENCRYPTION-QUICK-REF.md`** - Quick reference guide

## 🚀 Quick Start Guide

### Step 1: On Your OLD PC

1. Open PowerShell and navigate to the scripts folder:
   ```powershell
   cd c:\git\jf\scripts
   ```

2. Run the master export script:
   ```powershell
   .\Export-Scripts\Export-AllConfigurations.ps1
   ```

3. **🔐 NEW: Optional Encryption**
   - When prompted, choose `Y` to encrypt sensitive files
   - Enter a strong password (you'll need this on your new PC)
   - The script will encrypt:
     - Git configuration (may contain credentials)
     - Beyond Compare license keys
     - PowerShell command history (may contain passwords)

4. Copy the entire `c:\git\jf\scripts` folder to your new PC (USB drive, cloud storage, etc.)

### Step 2: On Your NEW PC

1. Copy the scripts folder to your new PC (e.g., `c:\git\jf\scripts`)

2. Open PowerShell 7 **as Administrator**

3. Run the main setup script:
   ```powershell
   cd c:\git\jf\scripts
   .\setup-new-pc.ps1
   ```

4. Follow the prompts to configure Artifactory credentials (optional)

5. After installation completes, run the import script:
   ```powershell
   .\Import-Scripts\Import-AllConfigurations.ps1
   ```

6. **🔐 NEW: Auto-Decryption**
   - If encrypted files are detected, you'll be prompted automatically
   - Enter the same password you used during export
   - Files will be decrypted and imported seamlessly

7. Restart your terminal and VS Code

## 📦 Software Installed

The setup script installs the following software using winget:

### Essential Tools
- **Google Chrome** - Web browser
- **Windows Terminal** - Modern terminal application
- **PowerShell 7.5** - Latest PowerShell version

### Development Tools
- **Visual Studio Code** - Code editor
- **Git** - Version control
- **Docker Desktop** - Container platform
- **Node.js LTS** - JavaScript runtime
- **Python 3** - Python programming language
- **Postman** - API testing tool
- **Azure Data Studio** - Database management

### Utilities
- **7-Zip** - File compression
- **Ditto** - Clipboard manager
- **Everything** - Fast file search
- **Notepad++** - Text editor
- **Beyond Compare** - File/folder comparison tool
- **VLC Media Player** - Media player
- **Tailscale** - VPN solution

## ⚙️ PowerShell Configuration

The scripts configure your PowerShell profile with:

```powershell
Import-Module posh-git
Import-Module PSReadLine

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
```

### Optional Configuration
- Artifactory credentials (prompted during setup)

## 📝 Individual Script Usage

### Export Scripts

Run these on your **OLD PC**:

```powershell
# Export PowerShell history
.\Export-PSReadLineHistory.ps1

# Export VS Code extensions
.\Export-VSCodeExtensions.ps1

# Export Git configuration
.\Export-GitConfig.ps1

# Export Beyond Compare license
.\Export-BeyondCompareLicense.ps1
```

### Import Scripts

Run these on your **NEW PC**:

```powershell
# Import PowerShell history
.\Import-PSReadLineHistory.ps1

# Import VS Code extensions
.\Import-VSCodeExtensions.ps1

# Import Git configuration
.\Import-GitConfig.ps1

# Import Beyond Compare license (requires Administrator)
.\Import-BeyondCompareLicense.ps1
```

## 🔒 Security Notes

### 🆕 Encryption Protection (AES-256)

Your exported files may contain sensitive information. The toolkit now includes **encryption support**:

**What gets encrypted:**
- Git configuration (credentials, email, tokens)
- Beyond Compare license keys
- PowerShell command history (may contain passwords, API keys)

**How to use:**
1. Run `Export-AllConfigurations.ps1` and choose `Y` when prompted
2. Enter a strong password
3. Files are encrypted with AES-256-CBC encryption
4. On import, encrypted files are automatically detected and decrypted

**Manual encryption:**
```powershell
# Single file
.\Encryption-Scripts\Protect-ConfigFile.ps1 -FilePath "Output-Files\git-config-backup.txt" -DeleteOriginal

# All files at once
.\Encryption-Scripts\Protect-AllConfigFiles.ps1 -DeleteOriginals
```

**Manual decryption:**
```powershell
# Single file
.\Encryption-Scripts\Unprotect-ConfigFile.ps1 -FilePath "Output-Files\git-config-backup.txt.encrypted"

# All files at once
.\Encryption-Scripts\Unprotect-AllConfigFiles.ps1
```

**Test encryption system:**
```powershell
.\Encryption-Scripts\Test-Encryption.ps1
```

📖 **See [ENCRYPTION-README.md](ENCRYPTION-README.md) for complete documentation**

### Other Security Considerations

1. **Artifactory Credentials**: The setup script prompts for credentials securely using `Read-Host -AsSecureString`
2. **Backup**: All import scripts create backups before overwriting existing configurations
3. **Password Storage**: Encryption passwords are never stored or logged
4. **Secure Transfer**: Use encrypted channels (HTTPS, VPN) when transferring files

## ⚠️ Requirements

- **Windows 10/11** with winget (App Installer from Microsoft Store)
- **PowerShell 5.1** or later to run the initial setup
- **Administrator privileges** for the main setup script
- **Internet connection** for downloading software

## 🛠️ Troubleshooting

### Winget not found
- Install "App Installer" from Microsoft Store
- Or update Windows to get the latest version

### Extension installation fails
- Ensure VS Code is installed and in PATH
- Try restarting your terminal
- Install extensions manually if needed

### Git configuration not imported
- Ensure Git is installed first
- Check that the export file exists in the scripts folder

### Beyond Compare license not imported
- The license import requires Administrator privileges
- Run separately as Administrator: `.\Import-BeyondCompareLicense.ps1`
- Or manually enter your license in Beyond Compare (Help > Enter Key)

### Python not found after installation
- Restart your terminal to refresh PATH
- Verify installation: `python --version` or `python3 --version`
- Check if it's installed: `winget list | Select-String -Pattern "Python"`

### PowerShell modules not loading
- Restart your terminal after installation
- Run `Import-Module posh-git` and `Import-Module PSReadLine` manually
- Check execution policy: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

## 📚 Additional Configuration

After running the scripts, you may want to:

1. **Git Configuration**: Verify your Git settings
   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

2. **Docker Desktop**: Sign in with your Docker account

3. **Tailscale**: Sign in and connect to your network

4. **VS Code Settings Sync**: Enable Settings Sync in VS Code for complete configuration

5. **SSH Keys**: Generate or copy SSH keys for Git authentication
   ```powershell
   ssh-keygen -t ed25519 -C "your.email@example.com"
   ```

## 🎯 Customization

### Adding More Software

Edit `setup-new-pc.ps1` and add to the `$softwareList` array:

```powershell
@{Name = "Software Name"; Id = "Publisher.SoftwareName" }
```

Find winget package IDs:
```powershell
winget search "software name"
```

### Modifying PowerShell Profile

Edit the `$profileContent` variable in `setup-new-pc.ps1` to customize your profile.

## 📄 License

These scripts are provided as-is for personal use.

## 🤝 Contributing

Feel free to modify these scripts to suit your needs!

---

**Created**: November 2025  
**Last Updated**: November 11, 2025
