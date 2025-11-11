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
\\\powershell
..\Import-AllConfigurations.ps1
\\\
