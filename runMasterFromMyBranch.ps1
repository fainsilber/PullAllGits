param(
    [string]$gitDirectory = "C:\repos\ncr\emeraldgx-core"
)

# Check if the directory exists
if (Test-Path $gitDirectory) {
    # Change to the Git directory
    Set-Location $gitDirectory
    if ($branch) {
        # Checkout the branch ('master' or 'main')
        git checkout $branch

        # Pull the latest changes from the origin remote
        git pull origin
    } else {
        Write-Host "No 'master' or 'main' branch found in this repository." -ForegroundColor Yellow
    }    

    git checkout jf185221-master/ci
    
    git pull origin

    git merge master -m "merge master"

    git push origin

} else {
    Write-Host "The specified directory does not exist: $gitDirectory" -ForegroundColor Red
}