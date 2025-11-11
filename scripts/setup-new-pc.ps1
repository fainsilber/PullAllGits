#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Setup script for new PC installation
.DESCRIPTION
    Installs essential software using winget and configures PowerShell environment
.NOTES
    Must be run as Administrator
#>

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  New PC Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if winget is available
function Test-WingetAvailable {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Function to install software using winget
function Install-Software {
    param(
        [string]$Name,
        [string]$WingetId
    )
    
    Write-Host "Installing $Name..." -ForegroundColor Yellow
    try {
        winget install --id=$WingetId --silent --accept-package-agreements --accept-source-agreements
        Write-Host "✓ $Name installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to install $Name : $_" -ForegroundColor Red
    }
}

# Check if winget is available
if (-not (Test-WingetAvailable)) {
    Write-Host "ERROR: winget is not available. Please install App Installer from Microsoft Store." -ForegroundColor Red
    exit 1
}

Write-Host "Starting software installation..." -ForegroundColor Cyan
Write-Host ""

# Install software list
$softwareList = @(
    @{Name = "Google Chrome"; Id = "Google.Chrome" },
    @{Name = "7-Zip"; Id = "7zip.7zip" },
    @{Name = "Ditto"; Id = "Ditto.Ditto" },
    @{Name = "Windows Terminal"; Id = "Microsoft.WindowsTerminal" },
    @{Name = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode" },
    @{Name = "Git"; Id = "Git.Git" },
    @{Name = "PowerShell 7.5"; Id = "Microsoft.PowerShell" },
    @{Name = "Docker Desktop"; Id = "Docker.DockerDesktop" },
    @{Name = "Tailscale"; Id = "tailscale.tailscale" },
    @{Name = "Notepad++"; Id = "Notepad++.Notepad++" },
    @{Name = "Everything"; Id = "voidtools.Everything" },
    @{Name = "VLC Media Player"; Id = "VideoLAN.VLC" },
    @{Name = "Beyond Compare"; Id = "ScooterSoftware.BeyondCompare4" },
    @{Name = "Postman"; Id = "Postman.Postman" },
    @{Name = "Azure Data Studio"; Id = "Microsoft.AzureDataStudio" },
    @{Name = "Node.js LTS"; Id = "OpenJS.NodeJS.LTS" },
    @{Name = "Python 3"; Id = "Python.Python.3.12" }
)

foreach ($software in $softwareList) {
    Install-Software -Name $software.Name -WingetId $software.Id
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configuring PowerShell Profile" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Install PowerShell modules
Write-Host "Installing PowerShell modules..." -ForegroundColor Yellow

# Install posh-git
if (-not (Get-Module -ListAvailable -Name posh-git)) {
    Write-Host "Installing posh-git..." -ForegroundColor Yellow
    Install-Module -Name posh-git -Scope CurrentUser -Force -AllowClobber
    Write-Host "✓ posh-git installed" -ForegroundColor Green
} else {
    Write-Host "✓ posh-git already installed" -ForegroundColor Green
}

# Install PSReadLine (usually comes with PowerShell 7, but ensure latest version)
Write-Host "Updating PSReadLine..." -ForegroundColor Yellow
Install-Module -Name PSReadLine -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck
Write-Host "✓ PSReadLine updated" -ForegroundColor Green

# Configure PowerShell profile for PowerShell 7
$profilePath = $PROFILE.CurrentUserAllHosts
$profileDir = Split-Path -Parent $profilePath

# Create profile directory if it doesn't exist
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    Write-Host "✓ Created profile directory: $profileDir" -ForegroundColor Green
}

# Prompt for optional environment variables
Write-Host "Would you like to configure Artifactory credentials? (Y/N)" -ForegroundColor Yellow
$configureArtifactory = Read-Host
$artifactoryConfig = ""

if ($configureArtifactory -eq 'Y' -or $configureArtifactory -eq 'y') {
    Write-Host "Enter your Artifactory username:" -ForegroundColor Yellow
    $artifactoryUsername = Read-Host
    Write-Host "Enter your Artifactory token:" -ForegroundColor Yellow
    $artifactoryToken = Read-Host -AsSecureString
    $artifactoryTokenPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($artifactoryToken)
    )
    
    $artifactoryConfig = @"

# Artifactory credentials
`$ENV:ARTIFACTORY_USERNAME="$artifactoryUsername"
`$ENV:ARTIFACTORY_TOKEN="$artifactoryTokenPlain"
"@
    Write-Host "✓ Artifactory credentials will be added to profile" -ForegroundColor Green
}

# Profile configuration content
$profileContent = @"
Import-Module posh-git
Import-Module PSReadLine

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows$artifactoryConfig
"@

# Create or update profile
if (Test-Path $profilePath) {
    $currentContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    if ($currentContent -notlike "*Import-Module posh-git*") {
        Add-Content -Path $profilePath -Value "`n$profileContent"
        Write-Host "✓ Updated PowerShell profile: $profilePath" -ForegroundColor Green
    } else {
        Write-Host "✓ PowerShell profile already configured" -ForegroundColor Green
    }
} else {
    Set-Content -Path $profilePath -Value $profileContent
    Write-Host "✓ Created PowerShell profile: $profilePath" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PSReadLine History Migration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "NOTE: To import your PSReadLine history from your old PC:" -ForegroundColor Yellow
Write-Host "1. On your OLD PC, copy the history file from:" -ForegroundColor White
Write-Host "   $((Get-PSReadLineOption).HistorySavePath)" -ForegroundColor Cyan
Write-Host "2. On your NEW PC, paste it to:" -ForegroundColor White
Write-Host "   $((Get-PSReadLineOption).HistorySavePath)" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Restart your terminal to apply profile changes" -ForegroundColor White
Write-Host "2. Run Export-VSCodeExtensions.ps1 on your old PC to backup extensions" -ForegroundColor White
Write-Host "3. Run Import-VSCodeExtensions.ps1 on this PC to restore extensions" -ForegroundColor White
Write-Host "4. Configure Git with your credentials:" -ForegroundColor White
Write-Host "   git config --global user.name 'Your Name'" -ForegroundColor Cyan
Write-Host "   git config --global user.email 'your.email@example.com'" -ForegroundColor Cyan
Write-Host "5. Sign in to Docker Desktop" -ForegroundColor White
Write-Host "6. Sign in to Tailscale" -ForegroundColor White
Write-Host "7. Configure VS Code settings sync or manually restore settings" -ForegroundColor White
Write-Host ""
