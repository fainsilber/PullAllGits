<#
.SYNOPSIS
    Test script to verify encryption/decryption functionality
.DESCRIPTION
    Creates test files, encrypts them, decrypts them, and verifies integrity
.NOTES
    Run this to ensure encryption is working correctly
#>

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Encryption System Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$testsPassed = 0
$testsFailed = 0
$scriptPath = Split-Path $PSScriptRoot -Parent

# Test 1: Create test file
Write-Host "Test 1: Creating test file..." -ForegroundColor Yellow
$testContent = @"
Test Git Config
[user]
    name = Test User
    email = test@example.com
    token = secret_test_token_12345
[credential]
    helper = manager-core
"@

$testFile = Join-Path $scriptPath "test-config.txt"
$testContent | Out-File -FilePath $testFile -Encoding utf8

if (Test-Path $testFile) {
    Write-Host "  ✓ Test file created" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ✗ Failed to create test file" -ForegroundColor Red
    $testsFailed++
    exit 1
}
Write-Host ""

# Test 2: Encrypt file
Write-Host "Test 2: Encrypting test file..." -ForegroundColor Yellow
$password = ConvertTo-SecureString "TestPassword123!" -AsPlainText -Force

try {
    & (Join-Path $scriptPath "Encryption-Scripts\Protect-ConfigFile.ps1") -FilePath $testFile -Password $password -DeleteOriginal | Out-Null
    
    $encryptedFile = "$testFile.encrypted"
    if (Test-Path $encryptedFile) {
        Write-Host "  ✓ File encrypted successfully" -ForegroundColor Green
        Write-Host "    Original file deleted: $(-not (Test-Path $testFile))" -ForegroundColor White
        
        # Check file size
        $fileSize = (Get-Item $encryptedFile).Length
        if ($fileSize -gt 32) {
            Write-Host "    File size: $fileSize bytes (valid)" -ForegroundColor White
            $testsPassed++
        } else {
            Write-Host "    ✗ File size too small: $fileSize bytes" -ForegroundColor Red
            $testsFailed++
        }
    } else {
        Write-Host "  ✗ Encrypted file not found" -ForegroundColor Red
        $testsFailed++
    }
}
catch {
    Write-Host "  ✗ Encryption failed: $_" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# Test 3: Decrypt file
Write-Host "Test 3: Decrypting test file..." -ForegroundColor Yellow
$encryptedFile = "$testFile.encrypted"

try {
    & (Join-Path $scriptPath "Encryption-Scripts\Unprotect-ConfigFile.ps1") -FilePath $encryptedFile -Password $password -DeleteEncrypted | Out-Null
    
    if (Test-Path $testFile) {
        Write-Host "  ✓ File decrypted successfully" -ForegroundColor Green
        Write-Host "    Encrypted file deleted: $(-not (Test-Path $encryptedFile))" -ForegroundColor White
        $testsPassed++
    } else {
        Write-Host "  ✗ Decrypted file not found" -ForegroundColor Red
        $testsFailed++
    }
}
catch {
    Write-Host "  ✗ Decryption failed: $_" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# Test 4: Verify content integrity
Write-Host "Test 4: Verifying content integrity..." -ForegroundColor Yellow

if (Test-Path $testFile) {
    $decryptedContent = Get-Content $testFile -Raw
    
    # Normalize line endings for comparison
    $originalNormalized = $testContent -replace "`r`n", "`n"
    $decryptedNormalized = $decryptedContent -replace "`r`n", "`n"
    
    if ($originalNormalized.Trim() -eq $decryptedNormalized.Trim()) {
        Write-Host "  ✓ Content matches original" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  ✗ Content mismatch!" -ForegroundColor Red
        Write-Host "    Original length: $($testContent.Length)" -ForegroundColor Yellow
        Write-Host "    Decrypted length: $($decryptedContent.Length)" -ForegroundColor Yellow
        $testsFailed++
    }
} else {
    Write-Host "  ✗ Cannot verify - decrypted file not found" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# Test 5: Wrong password handling
Write-Host "Test 5: Testing wrong password handling..." -ForegroundColor Yellow

# Re-encrypt the file
$encryptedFile = "$testFile.encrypted"
try {
    & (Join-Path $scriptPath "Encryption-Scripts\Protect-ConfigFile.ps1") -FilePath $testFile -Password $password -DeleteOriginal | Out-Null
    
    # Try to decrypt with wrong password
    $wrongPassword = ConvertTo-SecureString "WrongPassword!" -AsPlainText -Force
    
    $output = & (Join-Path $scriptPath "Encryption-Scripts\Unprotect-ConfigFile.ps1") -FilePath $encryptedFile -Password $wrongPassword 2>&1
    $decryptFailed = ($LASTEXITCODE -ne 0) -or ($output -like "*Decryption failed*")
    
    if ($decryptFailed) {
        Write-Host "  ✓ Correctly rejected wrong password" -ForegroundColor Green
        $testsPassed++
    }
    else {
        Write-Host "  ✗ Should have failed with wrong password!" -ForegroundColor Red
        $testsFailed++
    }
}
catch {
    Write-Host "  ✗ Test setup failed: $_" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# Cleanup
Write-Host "Cleaning up test files..." -ForegroundColor Yellow
@($testFile, "$testFile.encrypted", "$testFile.decrypted") | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item $_ -Force
        Write-Host "  Deleted: $_" -ForegroundColor Gray
    }
}
Write-Host ""

# Results
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "Tests Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "✓ All tests passed! Encryption system is working correctly." -ForegroundColor Green
    Write-Host ""
    exit 0
} else {
    Write-Host "✗ Some tests failed. Please check the encryption scripts." -ForegroundColor Red
    Write-Host ""
    exit 1
}
