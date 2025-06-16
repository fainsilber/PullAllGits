# List of Git directories to pull from
$gitDirectories = @(
    "C:\repos\ncr\emeraldgx-third-party",
    "C:\repos\ncr\emeraldgx",
    "C:\repos\ncr\emeraldgx-gitops-multi",
    "C:\repos\ncr\charts",
    "C:\repos\ncr\edge-infra",
    #"C:\repos\ncr\emeraldgx-core-v3",
    "C:\repos\ncr\emeraldgx-core-v2",
    "C:\repos\ncr\emeraldgx-core"
)

# Path to the GitPull script
$gitPullScript = "C:\PullAllGits\GitPull.ps1"

# Loop through each directory and call GitPull.ps1
foreach ($dir in $gitDirectories) {
    Write-Host "Pulling from repository: $dir" -ForegroundColor Green
    & $gitPullScript -gitDirectory $dir
    Write-Host "------------------------------------------"
}

Write-Host "Pull operation completed for all repositories." -ForegroundColor Cyan
