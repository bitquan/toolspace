# PowerShell script to close failed Dependabot PRs
# Requires GitHub CLI (gh) to be installed and authenticated

Write-Host "🔍 Finding failed Dependabot PRs..." -ForegroundColor Yellow

# Get all open Dependabot PRs and their status
$failedPRs = gh pr list --author app/dependabot --state open --json number,title,url,statusCheckRollup | ConvertFrom-Json | Where-Object {
    $_.statusCheckRollup | Where-Object { $_.state -eq "FAILURE" }
}

if ($failedPRs.Count -gt 0) {
    Write-Host "📋 Found $($failedPRs.Count) failed PRs:" -ForegroundColor Red
    
    foreach ($pr in $failedPRs) {
        Write-Host "  #$($pr.number): $($pr.title)" -ForegroundColor Red
    }
    
    Write-Host ""
    $confirmation = Read-Host "Do you want to close these failed PRs? (y/N)"
    
    if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
        Write-Host "🗑️ Closing failed PRs..." -ForegroundColor Yellow
        
        foreach ($pr in $failedPRs) {
            Write-Host "Closing PR #$($pr.number)..." -ForegroundColor Yellow
            gh pr close $pr.number --comment "Auto-closing due to CI failures. Dependencies will be updated in grouped PRs going forward."
        }
        
        Write-Host "✅ Completed closing failed PRs" -ForegroundColor Green
    } else {
        Write-Host "❌ Operation cancelled" -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ No failed Dependabot PRs found" -ForegroundColor Green
}

Write-Host ""
Write-Host "📊 Current Dependabot PR status:" -ForegroundColor Cyan
gh pr list --author app/dependabot --state open --json number,title,statusCheckRollup | ConvertFrom-Json | ForEach-Object {
    $status = if ($_.statusCheckRollup) { $_.statusCheckRollup[0].state } else { "PENDING" }
    $color = switch ($status) {
        "SUCCESS" { "Green" }
        "FAILURE" { "Red" }
        "PENDING" { "Yellow" }
        default { "White" }
    }
    Write-Host "  #$($_.number): $($_.title) - $status" -ForegroundColor $color
}