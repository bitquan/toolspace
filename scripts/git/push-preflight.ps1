# push-preflight.ps1 - Git push preflight checks for reliable pushes
# Part of GIT-01 Push Stabilizer

$ErrorActionPreference = "Stop"

Write-Host "Git Push Preflight Checks" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

# 1. Print remote + branch info
Write-Host "Remote and Branch Info:" -ForegroundColor Yellow
Write-Host "Remote:"
git remote -v
Write-Host ""
Write-Host "Current branch:"
$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Host "  $currentBranch" -ForegroundColor Green
Write-Host ""

# 2. Set user if missing
Write-Host "User Configuration:" -ForegroundColor Yellow
try { $userName = git config user.name } catch { $userName = $null }
try { $userEmail = git config user.email } catch { $userEmail = $null }

if (-not $userName) {
    Write-Host "  Setting user.name to bitquan-bot" -ForegroundColor Green
    git config user.name "bitquan-bot"
} else {
    Write-Host "  user.name: $userName"
}

if (-not $userEmail) {
    Write-Host "  Setting user.email to bot@toolspace" -ForegroundColor Green
    git config user.email "bot@toolspace"
} else {
    Write-Host "  user.email: $userEmail"
}
Write-Host ""

# 3. Check for uncommitted changes
Write-Host "Working Directory Status:" -ForegroundColor Yellow
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "ERROR: You have uncommitted changes!" -ForegroundColor Red
    Write-Host "   Please commit or stash your changes before pushing." -ForegroundColor Red
    git status --porcelain
    exit 1
} else {
    Write-Host "Working directory is clean" -ForegroundColor Green
}
Write-Host ""

# 4. Check upstream
Write-Host "Sync Status:" -ForegroundColor Yellow
try {
    git fetch origin $currentBranch 2>$null
} catch {
    Write-Host "  (Remote branch not found, will create upstream)" -ForegroundColor Yellow
}

try {
    $upstream = git rev-parse --abbrev-ref --symbolic-full-name "`@{u}"
} catch {
    $upstream = $null
}

if (-not $upstream) {
    Write-Host "  No upstream set for $currentBranch" -ForegroundColor Yellow
    Write-Host "  Will set upstream during push: origin/$currentBranch" -ForegroundColor Green
} else {
    Write-Host "  Upstream: $upstream"
    Write-Host "Upstream configured" -ForegroundColor Green
}
Write-Host ""

# 5. Push configuration
Write-Host "Push Configuration:" -ForegroundColor Yellow
if (-not $upstream) {
    Write-Host "  Will set upstream: git push -u origin $currentBranch" -ForegroundColor Green
} else {
    Write-Host "  Upstream configured: git push" -ForegroundColor Green
}
Write-Host ""

Write-Host "All preflight checks passed!" -ForegroundColor Green
Write-Host "Ready to push $currentBranch" -ForegroundColor Cyan
Write-Host ""
