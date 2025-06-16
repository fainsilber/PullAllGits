param(
    [string]$gitDirectory = "C:\path\to\git\repository"
)

# Check if the directory exists
if (Test-Path $gitDirectory) {
    # Change to the Git directory
    Set-Location $gitDirectory
    
    # Perform a git pull from the origin remote
    git pull origin

    # Determine if the branch is 'master' or 'main'
    $branch = if (git branch --list master) { "master" } elseif (git branch --list main) { "main" } elseif (git branch --list develop) { "develop" } else { "" }

    if ($branch) {
        # Checkout the branch ('master' or 'main')
        git checkout $branch

        # Pull the latest changes from the origin remote
        git pull origin
    } else {
        Write-Host "No 'master' or 'main' branch found in this repository." -ForegroundColor Yellow
    }
} else {
    Write-Host "The specified directory does not exist: $gitDirectory" -ForegroundColor Red
}