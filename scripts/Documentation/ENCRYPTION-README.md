# Configuration File Encryption

## Overview

To protect sensitive information in your exported configuration files, this toolkit includes encryption utilities using **AES-256-CBC encryption** with **PBKDF2 key derivation** (100,000 iterations).

## Why Encrypt?

Your exported configuration files may contain sensitive information:

- **git-config-backup.txt** - Email addresses, Git credentials, authentication tokens
- **BeyondCompare-License.reg** - Software license keys
- **PSReadLine-History-Export.txt** - Command history that may contain passwords, API keys, or other secrets
- **BeyondCompare-License-Info.json** - Computer names and user information

## Automatic Encryption

### During Export

When you run `Export-AllConfigurations.ps1`, you will be prompted to encrypt your files:

```powershell
.\Export-AllConfigurations.ps1
```

You'll see:
```
Would you like to encrypt these files now? (Y/N)
```

Choose `Y` and enter a strong password. The script will:
1. Encrypt all sensitive files
2. Add `.encrypted` extension to encrypted files
3. Delete the unencrypted originals

### During Import

When you run `Import-AllConfigurations.ps1` on your new PC, encrypted files are automatically detected:

```powershell
.\Import-AllConfigurations.ps1
```

You'll see:
```
Encrypted files detected!
Would you like to decrypt these files now? (Y/N)
```

Choose `Y` and enter the same password you used during export.

## Manual Encryption/Decryption

### Encrypt a Single File

```powershell
.\Protect-ConfigFile.ps1 -FilePath "git-config-backup.txt"
```

Options:
- `-DeleteOriginal` - Automatically delete the unencrypted file after encryption

Example:
```powershell
.\Protect-ConfigFile.ps1 -FilePath "git-config-backup.txt" -DeleteOriginal
```

### Decrypt a Single File

```powershell
.\Unprotect-ConfigFile.ps1 -FilePath "git-config-backup.txt.encrypted"
```

Options:
- `-DeleteEncrypted` - Automatically delete the encrypted file after decryption

Example:
```powershell
.\Unprotect-ConfigFile.ps1 -FilePath "git-config-backup.txt.encrypted" -DeleteEncrypted
```

## Security Details

### Encryption Algorithm
- **Algorithm**: AES-256 (Advanced Encryption Standard)
- **Mode**: CBC (Cipher Block Chaining)
- **Padding**: PKCS7
- **Key Derivation**: PBKDF2 (Password-Based Key Derivation Function 2)
- **Iterations**: 100,000 (protects against brute-force attacks)
- **Salt**: 32 bytes (random, unique per file)
- **Key Size**: 256 bits
- **IV Size**: 128 bits

### Password Security
- Passwords are handled as `SecureString` objects in memory
- Passwords are cleared from memory immediately after use
- Password confirmation required during encryption
- No passwords are stored or logged

### File Format
Encrypted files have the following structure:
```
[32-byte salt][encrypted data]
```

## Best Practices

### Password Management
1. **Use a strong password** with at least 12 characters
2. **Include** uppercase, lowercase, numbers, and symbols
3. **Remember your password** - there's no recovery option
4. **Don't reuse** passwords from other services
5. **Consider using** a password manager

### File Handling
1. **Verify encryption** before deleting original files
2. **Delete decrypted files** after importing on new PC
3. **Keep encrypted files secure** during transfer
4. **Don't commit** unencrypted files to version control

### Transfer Security
1. Transfer encrypted files via secure channels (HTTPS, SCP, encrypted USB)
2. Delete temporary copies after successful transfer
3. Verify file integrity after transfer

## Troubleshooting

### "Decryption failed" Error
- **Cause**: Incorrect password or corrupted file
- **Solution**: 
  - Verify you're using the correct password
  - Try typing the password carefully
  - Check if the file was completely transferred

### "File not found" Error
- **Cause**: Looking for unencrypted file when encrypted version exists
- **Solution**: 
  - Check for `.encrypted` extension
  - Manually decrypt using `Unprotect-ConfigFile.ps1`

### "Passwords do not match" Error
- **Cause**: Password confirmation doesn't match
- **Solution**: Retype both passwords carefully

## Security Warnings

⚠️ **Important Security Notes**:

1. **No Password Recovery**: If you forget your password, encrypted files cannot be recovered
2. **Secure Storage**: Keep your password in a secure location (password manager recommended)
3. **Delete After Import**: Remove decrypted files from your new PC after import completes
4. **Secure Transfer**: Use encrypted channels when transferring files
5. **Don't Share**: Never share your password via insecure channels (email, text, etc.)

## Examples

### Complete Workflow with Encryption

**On OLD PC:**
```powershell
# Export and encrypt
.\Export-AllConfigurations.ps1
# Choose Y when prompted
# Enter strong password: MyS3cure!Pass@2024
# Confirm password: MyS3cure!Pass@2024
```

**Transfer Files:**
- Copy entire folder to USB drive or secure cloud storage
- Transfer to NEW PC

**On NEW PC:**
```powershell
# Setup new PC
.\setup-new-pc.ps1

# Import and decrypt
.\Import-AllConfigurations.ps1
# Choose Y when prompted
# Enter password: MyS3cure!Pass@2024
```

### Manual Encryption of Specific Files

```powershell
# Encrypt Git config
.\Protect-ConfigFile.ps1 -FilePath "git-config-backup.txt" -DeleteOriginal

# Encrypt command history
.\Protect-ConfigFile.ps1 -FilePath "PSReadLine-History-Export.txt" -DeleteOriginal

# Encrypt license
.\Protect-ConfigFile.ps1 -FilePath "BeyondCompare-License.reg" -DeleteOriginal
```

## Technical Implementation

The encryption system uses .NET's built-in cryptography libraries:
- `System.Security.Cryptography.Aes` for encryption/decryption
- `System.Security.Cryptography.Rfc2898DeriveBytes` for key derivation
- `System.Security.Cryptography.RNGCryptoServiceProvider` for random salt generation
- `System.Security.SecureString` for secure password handling

This ensures compatibility with all Windows systems running PowerShell 5.1+ without requiring additional dependencies.

## FAQ

**Q: Can I use different passwords for different files?**
A: Yes, but it's easier to use the same password for all files during batch export.

**Q: What happens if I lose my password?**
A: The files cannot be recovered. There is no backdoor or recovery mechanism.

**Q: Is this encryption secure?**
A: Yes, AES-256 with PBKDF2 is industry-standard and considered cryptographically secure when used with a strong password.

**Q: Can I skip encryption?**
A: Yes, encryption is optional. Choose `N` when prompted, but be aware of security risks.

**Q: Do encrypted files work on Mac/Linux?**
A: These PowerShell scripts are Windows-only, but the encryption format is standard and could be decrypted on other platforms with appropriate tools.

**Q: How do I verify a file is encrypted?**
A: Encrypted files have a `.encrypted` extension and contain binary data (not readable as text).

## Support

For issues or questions about encryption:
1. Check the troubleshooting section above
2. Verify your PowerShell version: `$PSVersionTable.PSVersion`
3. Ensure you're using the exact password used during encryption
4. Check file integrity (file size should be 32 bytes + original size + padding)

---

**Remember**: Security is only as strong as your password! Choose wisely and store it securely.
