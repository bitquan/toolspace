# Automate PR merging with conflict resolution
$prs = @(55, 56, 57, 58, 59, 60, 62)

foreach ($pr in $prs) {
    Write-Host "=== Processing PR #$pr ===" -ForegroundColor Cyan

    # Checkout PR
    gh pr checkout $pr
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to checkout PR #$pr" -ForegroundColor Red
        continue
    }

    # Fetch and merge main
    git fetch origin main
    git merge origin/main

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Merge conflicts detected in PR #$pr" -ForegroundColor Yellow

        # For home_screen.dart conflicts, use a template resolution
        if (Test-Path "lib/screens/home_screen.dart") {
            $content = Get-Content "lib/screens/home_screen.dart" -Raw
            if ($content -match "<<<<<<< HEAD") {
                Write-Host "Resolving home_screen.dart conflicts..." -ForegroundColor Yellow
                # Auto-resolve by keeping both imports and tools
                # This will need manual intervention per PR
                Write-Host "Manual resolution needed for PR #$pr - skipping for now" -ForegroundColor Red
                git merge --abort
                git checkout main
                continue
            }
        }
    }

    # Stage and commit
    git add .
    git commit -m "Resolve merge conflicts for PR #$pr"

    # Push
    git push --force-with-lease

    # Switch to main and merge
    git checkout main
    git pull
    gh pr merge $pr --squash --delete-branch

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully merged PR #$pr" -ForegroundColor Green
    }
    else {
        Write-Host "Failed to merge PR #$pr" -ForegroundColor Red
    }
}
