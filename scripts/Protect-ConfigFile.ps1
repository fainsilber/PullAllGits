<#
.SYNOPSIS
    Encrypts a configuration file using a password
.DESCRIPTION
    Uses AES-256 encryption to protect exported configuration files.
    The encrypted file will have a .encrypted extension.
.PARAMETER FilePath
    The path to the file to encrypt
.PARAMETER Password
    The password to use for encryption (will be prompted if not provided)
.PARAMETER DeleteOriginal
    If specified, deletes the original unencrypted file after successful encryption
.EXAMPLE
    .\Protect-ConfigFile.ps1 -FilePath "git-config-backup.txt"
.NOTES
    Uses AES-256-CBC encryption with PBKDF2 key derivation
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    
    [Parameter(Mandatory=$false)]
    [SecureString]$Password,
    
    [Parameter(Mandatory=$false)]
    [switch]$DeleteOriginal
)

function Protect-FileWithPassword {
    param(
        [string]$InputFile,
        [SecureString]$SecurePassword
    )
    
    if (-not (Test-Path $InputFile)) {
        throw "File not found: $InputFile"
    }
    
    # Read the file content
    $fileBytes = [System.IO.File]::ReadAllBytes($InputFile)
    
    # Generate a random salt (32 bytes)
    $salt = New-Object byte[] 32
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
    $rng.GetBytes($salt)
    
    # Convert SecureString to plain text for key derivation
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    try {
        $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        
        # Derive key using PBKDF2 (100,000 iterations, 32 bytes for AES-256)
        $pbkdf2 = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($plainPassword, $salt, 100000)
        $key = $pbkdf2.GetBytes(32)
        $iv = $pbkdf2.GetBytes(16)
    }
    finally {
        # Clear the password from memory
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
    
    # Create AES encryptor
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.IV = $iv
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    
    # Encrypt the data
    $encryptor = $aes.CreateEncryptor()
    $encryptedBytes = $encryptor.TransformFinalBlock($fileBytes, 0, $fileBytes.Length)
    
    # Combine salt + encrypted data
    $outputBytes = $salt + $encryptedBytes
    
    # Write to output file with .encrypted extension
    $outputFile = "$InputFile.encrypted"
    [System.IO.File]::WriteAllBytes($outputFile, $outputBytes)
    
    # Clean up
    $aes.Dispose()
    $encryptor.Dispose()
    
    return $outputFile
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  File Encryption Utility" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Resolve full path
$fullPath = Resolve-Path $FilePath -ErrorAction SilentlyContinue
if (-not $fullPath) {
    Write-Host "✗ File not found: $FilePath" -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host "File to encrypt: $fullPath" -ForegroundColor Yellow
Write-Host ""

# Get password if not provided
if (-not $Password) {
    Write-Host "Enter encryption password:" -ForegroundColor Yellow
    $Password = Read-Host -AsSecureString
    Write-Host ""
    Write-Host "Confirm password:" -ForegroundColor Yellow
    $Password2 = Read-Host -AsSecureString
    Write-Host ""
    
    # Compare passwords
    $bstr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $bstr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password2)
    try {
        $pass1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr1)
        $pass2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)
        
        if ($pass1 -ne $pass2) {
            Write-Host "✗ Passwords do not match!" -ForegroundColor Red
            Write-Host ""
            exit 1
        }
    }
    finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr1)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2)
    }
}

try {
    Write-Host "Encrypting file..." -ForegroundColor Yellow
    $encryptedFile = Protect-FileWithPassword -InputFile $fullPath -SecurePassword $Password
    
    Write-Host "✓ File encrypted successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Details:" -ForegroundColor Yellow
    Write-Host "  Original file: $fullPath" -ForegroundColor White
    Write-Host "  Encrypted file: $encryptedFile" -ForegroundColor Cyan
    Write-Host "  Encryption: AES-256-CBC with PBKDF2 (100,000 iterations)" -ForegroundColor White
    Write-Host ""
    
    if ($DeleteOriginal) {
        Remove-Item -Path $fullPath -Force
        Write-Host "✓ Original file deleted" -ForegroundColor Green
        Write-Host ""
    }
    else {
        Write-Host "⚠ Original unencrypted file still exists!" -ForegroundColor Yellow
        Write-Host "  Consider deleting it manually for security:" -ForegroundColor Yellow
        Write-Host "  Remove-Item '$fullPath'" -ForegroundColor Cyan
        Write-Host ""
    }
    
    Write-Host "IMPORTANT: Remember your password!" -ForegroundColor Red
    Write-Host "  Without it, you will NOT be able to decrypt this file." -ForegroundColor Yellow
    Write-Host ""
}
catch {
    Write-Host "✗ Encryption failed: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}
