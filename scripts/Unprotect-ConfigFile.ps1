<#
.SYNOPSIS
    Decrypts a configuration file that was encrypted with Protect-ConfigFile.ps1
.DESCRIPTION
    Uses AES-256 decryption to restore encrypted configuration files.
    The decrypted file will have the .encrypted extension removed.
.PARAMETER FilePath
    The path to the encrypted file (with .encrypted extension)
.PARAMETER Password
    The password to use for decryption (will be prompted if not provided)
.PARAMETER DeleteEncrypted
    If specified, deletes the encrypted file after successful decryption
.EXAMPLE
    .\Unprotect-ConfigFile.ps1 -FilePath "git-config-backup.txt.encrypted"
.NOTES
    Uses AES-256-CBC decryption with PBKDF2 key derivation
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    
    [Parameter(Mandatory=$false)]
    [SecureString]$Password,
    
    [Parameter(Mandatory=$false)]
    [switch]$DeleteEncrypted
)

function Unprotect-FileWithPassword {
    param(
        [string]$InputFile,
        [SecureString]$SecurePassword
    )
    
    if (-not (Test-Path $InputFile)) {
        throw "File not found: $InputFile"
    }
    
    # Read the encrypted file
    $encryptedData = [System.IO.File]::ReadAllBytes($InputFile)
    
    if ($encryptedData.Length -lt 32) {
        throw "Invalid encrypted file format"
    }
    
    # Extract salt (first 32 bytes)
    $salt = $encryptedData[0..31]
    
    # Extract encrypted content (remaining bytes)
    $encryptedBytes = $encryptedData[32..($encryptedData.Length - 1)]
    
    # Convert SecureString to plain text for key derivation
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    try {
        $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        
        # Derive key using PBKDF2 (same parameters as encryption)
        $pbkdf2 = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($plainPassword, $salt, 100000)
        $key = $pbkdf2.GetBytes(32)
        $iv = $pbkdf2.GetBytes(16)
    }
    finally {
        # Clear the password from memory
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
    
    # Create AES decryptor
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.IV = $iv
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    
    try {
        # Decrypt the data
        $decryptor = $aes.CreateDecryptor()
        $decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
        
        # Remove .encrypted extension
        $outputFile = $InputFile -replace '\.encrypted$', ''
        if ($outputFile -eq $InputFile) {
            $outputFile = "$InputFile.decrypted"
        }
        
        # Write to output file
        [System.IO.File]::WriteAllBytes($outputFile, $decryptedBytes)
        
        # Clean up
        $decryptor.Dispose()
        $aes.Dispose()
        
        return $outputFile
    }
    catch {
        $aes.Dispose()
        throw "Decryption failed. Incorrect password or corrupted file."
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  File Decryption Utility" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Resolve full path
$fullPath = Resolve-Path $FilePath -ErrorAction SilentlyContinue
if (-not $fullPath) {
    Write-Host "✗ File not found: $FilePath" -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host "File to decrypt: $fullPath" -ForegroundColor Yellow
Write-Host ""

# Get password if not provided
if (-not $Password) {
    Write-Host "Enter decryption password:" -ForegroundColor Yellow
    $Password = Read-Host -AsSecureString
    Write-Host ""
}

try {
    Write-Host "Decrypting file..." -ForegroundColor Yellow
    $decryptedFile = Unprotect-FileWithPassword -InputFile $fullPath -SecurePassword $Password
    
    Write-Host "✓ File decrypted successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Details:" -ForegroundColor Yellow
    Write-Host "  Encrypted file: $fullPath" -ForegroundColor White
    Write-Host "  Decrypted file: $decryptedFile" -ForegroundColor Cyan
    Write-Host ""
    
    if ($DeleteEncrypted) {
        Remove-Item -Path $fullPath -Force
        Write-Host "✓ Encrypted file deleted" -ForegroundColor Green
        Write-Host ""
    }
    else {
        Write-Host "Note: Encrypted file still exists at:" -ForegroundColor Yellow
        Write-Host "  $fullPath" -ForegroundColor Cyan
        Write-Host ""
    }
}
catch {
    Write-Host "✗ Decryption failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "  - Incorrect password" -ForegroundColor White
    Write-Host "  - File is corrupted" -ForegroundColor White
    Write-Host "  - File was not encrypted with Protect-ConfigFile.ps1" -ForegroundColor White
    Write-Host ""
    exit 1
}
