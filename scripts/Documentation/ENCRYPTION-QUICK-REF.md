# Quick Encryption Reference

## 🔐 Why Encrypt?

Your exported files may contain:
- Git credentials and tokens (`git-config-backup.txt`)
- Software license keys (`BeyondCompare-License.reg`)
- Command history with passwords (`PSReadLine-History-Export.txt`)

## ⚡ Quick Commands

### Automatic (Recommended)
```powershell
# Export with auto-encryption prompt
.\Export-AllConfigurations.ps1

# Import with auto-decryption prompt
.\Import-AllConfigurations.ps1
```

### Manual Single File
```powershell
# Encrypt a file
.\Protect-ConfigFile.ps1 -FilePath "filename.txt" -DeleteOriginal

# Decrypt a file
.\Unprotect-ConfigFile.ps1 -FilePath "filename.txt.encrypted" -DeleteEncrypted
```

## 🔑 Password Tips

✅ **DO:**
- Use 12+ characters
- Mix uppercase, lowercase, numbers, symbols
- Store in password manager
- Use same password for all files in one export

❌ **DON'T:**
- Use common words or patterns
- Reuse from other services
- Share via email/text
- Forget it (no recovery possible!)

## 🛡️ Security Specs

- **Algorithm**: AES-256-CBC
- **Key Derivation**: PBKDF2 (100,000 iterations)
- **Salt**: 32 bytes (random, unique per file)
- **No backdoors**: If you lose password, files are unrecoverable

## 📁 Encrypted Files

Look for `.encrypted` extension:
- `git-config-backup.txt.encrypted`
- `PSReadLine-History-Export.txt.encrypted`
- `BeyondCompare-License.reg.encrypted`
- `BeyondCompare-License-Info.json.encrypted`

## 🔄 Workflow

```
OLD PC:
  Export-AllConfigurations.ps1
    ↓ Choose Y for encryption
    ↓ Enter password
    ↓ Files encrypted
    ↓ Copy folder to new PC

NEW PC:
  setup-new-pc.ps1 (install software)
    ↓
  Import-AllConfigurations.ps1
    ↓ Detects encrypted files
    ↓ Enter password
    ↓ Files decrypted & imported
    ↓ Delete decrypted files
```

## 🆘 Troubleshooting

**"Decryption failed"**
- Check password carefully (case-sensitive)
- Ensure file wasn't corrupted during transfer

**"File not found"**
- Look for `.encrypted` version
- Check file was copied to scripts folder

**"Passwords do not match"**
- Retype both passwords carefully
- Check Caps Lock is off

## 📖 Full Documentation

See [ENCRYPTION-README.md](ENCRYPTION-README.md) for complete details.

---

**Remember**: Strong password + Secure storage = Your data is safe! 🔒
