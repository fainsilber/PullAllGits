param(
    [string]$runDirectory = "C:\git\jf\PullAllGits\",
    [string]$gitDirectory = "C:\git\ncr\"
)
# List of Git directories to pull from
$gitDirectories = @(
    "charts",
    "edge-infra",
    "emeraldgx",
    "emeraldgx-gitops-multi",
    "emeraldgx-third-party",
    "emeraldgx-core-v2"
)

# Path to the GitPull script
$originalDirectory = Get-Location


$gitPullScript = "$runDirectory\GitPull.ps1"
# Write-Host $originalDirectory$gitPullScript
# [void][System.Console]::ReadKey($true)
# Loop through each directory and call GitPull.ps1
foreach ($dir in $gitDirectories) {
    Write-Host "Pulling from git directory: $dir" -ForegroundColor Green
    & $gitPullScript -gitDirectory $gitDirectory$dir
    Write-Host "------------------------------------------"
}

Write-Host "Pull operation completed for all git repositories." -ForegroundColor Cyan
Set-Location $originalDirectory
