# PowerShell Script to Sync and Push Roblox1: Style a Snack to GitHub
param (
    [string]$CommitMessage = "Update game documentation, Notion trackers, and README setup"
)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   Roblox1: Style a Snack - GitHub Sync Utility   " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Check if git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git is not installed or not in PATH."
    Exit 1
}

# 2. Check current branch
$branch = (git branch --show-current).Trim()
Write-Host "Current Branch: $branch" -ForegroundColor Green

# 3. Check git remote
$remoteUrl = (git remote get-url origin 2>$null)
if (-not $remoteUrl) {
    Write-Host "Adding remote origin..." -ForegroundColor Yellow
    git remote add origin https://github.com/sajaytmpc/Roblox1-Style-a-Snack.git
    $remoteUrl = "https://github.com/sajaytmpc/Roblox1-Style-a-Snack.git"
}
Write-Host "Remote Origin URL: $remoteUrl" -ForegroundColor Green

# 4. Git status check
Write-Host "`nChecking working tree status..." -ForegroundColor Cyan
git status -s

# 5. Add and commit changes
Write-Host "`nStaging changes..." -ForegroundColor Cyan
git add .

$status = git status --porcelain
if ($status) {
    Write-Host "Committing changes with message: '$CommitMessage'..." -ForegroundColor Cyan
    git commit -m "$CommitMessage"
} else {
    Write-Host "No unstaged or untracked changes to commit." -ForegroundColor Yellow
}

# 6. Push to GitHub
Write-Host "`nPushing branch '$branch' to origin ($remoteUrl)..." -ForegroundColor Cyan
Write-Host "Note: If this is your first push, ensure the repo 'Roblox1-Style-a-Snack' exists on GitHub under your account." -ForegroundColor Yellow

git push -u origin $branch

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[SUCCESS] Successfully pushed all commits to GitHub!" -ForegroundColor Green
    Write-Host "View your repository at: https://github.com/sajaytmpc/Roblox1-Style-a-Snack" -ForegroundColor Cyan
} else {
    Write-Host "`n[ACTION REQUIRED] Push failed or authentication is needed." -ForegroundColor Red
    Write-Host "1. Ensure the repo exists at: https://github.com/new (Name: 'Roblox1-Style-a-Snack')" -ForegroundColor Yellow
    Write-Host "2. If prompted for credentials, enter your GitHub Personal Access Token (PAT)." -ForegroundColor Yellow
}
