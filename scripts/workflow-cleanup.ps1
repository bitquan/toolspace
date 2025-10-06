# OPS-Zeta Workflow Cleanup Script
# Provides local and GitHub workflow cleanup capabilities

param(
    [Parameter()]
    [ValidateSet("failed", "old", "all", "cache", "full", "preview", "help")]
    [string]$Action = "help",
    
    [Parameter()]
    [int]$DaysToKeep = 7,
    
    [Parameter()]
    [switch]$DryRun,
    
    [Parameter()]
    [switch]$Force
)

function Show-Help {
    Write-Host ""
    Write-Host "🧹 OPS-Zeta Workflow Cleanup Script" -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\scripts\workflow-cleanup.ps1 -Action <action> [options]"
    Write-Host ""
    Write-Host "ACTIONS:" -ForegroundColor Yellow
    Write-Host "  preview  - Show what would be cleaned (safe)" -ForegroundColor Green
    Write-Host "  failed   - Clean failed/cancelled workflow runs" -ForegroundColor Yellow
    Write-Host "  old      - Clean runs older than specified days" -ForegroundColor Yellow
    Write-Host "  cache    - Clean GitHub Actions cache and artifacts" -ForegroundColor Yellow
    Write-Host "  all      - Clean ALL workflow runs" -ForegroundColor Red
    Write-Host "  full     - Complete cleanup (runs + cache + artifacts)" -ForegroundColor Red
    Write-Host "  help     - Show this help message" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -DaysToKeep <number>  - Days to keep for 'old' action (default: 7)"
    Write-Host "  -DryRun               - Preview actions without making changes"
    Write-Host "  -Force                - Skip confirmation prompts"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\scripts\workflow-cleanup.ps1 -Action preview"
    Write-Host "  .\scripts\workflow-cleanup.ps1 -Action failed -DryRun"
    Write-Host "  .\scripts\workflow-cleanup.ps1 -Action old -DaysToKeep 14"
    Write-Host "  .\scripts\workflow-cleanup.ps1 -Action full -Force"
    Write-Host ""
    Write-Host "NPM SHORTCUTS:" -ForegroundColor Yellow
    Write-Host "  npm run cleanup:preview  - Preview cleanup"
    Write-Host "  npm run cleanup:failed   - Clean failed runs"
    Write-Host "  npm run cleanup:old      - Clean old runs"
    Write-Host "  npm run cleanup:cache    - Clean cache"
    Write-Host "  npm run cleanup:full     - Full cleanup"
    Write-Host ""
}

function Get-WorkflowStats {
    Write-Host "📊 Analyzing workflow runs..." -ForegroundColor Cyan
    
    try {
        $allRuns = gh run list --limit 500 --json databaseId,status,conclusion,createdAt,workflowName | ConvertFrom-Json
        $totalRuns = $allRuns.Count
        
        $failedRuns = $allRuns | Where-Object { $_.conclusion -eq "failure" -or $_.conclusion -eq "cancelled" }
        $failedCount = $failedRuns.Count
        
        $cutoffDate = (Get-Date).AddDays(-$DaysToKeep)
        $oldRuns = $allRuns | Where-Object { [DateTime]$_.createdAt -lt $cutoffDate }
        $oldCount = $oldRuns.Count
        
        Write-Host ""
        Write-Host "📈 Current Statistics:" -ForegroundColor Green
        Write-Host "  Total workflow runs: $totalRuns"
        Write-Host "  Failed/cancelled runs: $failedCount"
        Write-Host "  Runs older than $DaysToKeep days: $oldCount"
        Write-Host ""
        
        return @{
            Total = $totalRuns
            Failed = $failedCount
            Old = $oldCount
            AllRuns = $allRuns
            FailedRuns = $failedRuns
            OldRuns = $oldRuns
        }
    }
    catch {
        Write-Error "Failed to get workflow statistics: $_"
        return $null
    }
}

function Confirm-Action {
    param([string]$Message, [string]$Impact = "Medium")
    
    if ($Force) {
        return $true
    }
    
    $color = switch ($Impact) {
        "Low" { "Green" }
        "Medium" { "Yellow" }
        "High" { "Red" }
        default { "Yellow" }
    }
    
    Write-Host ""
    Write-Host "⚠️ CONFIRMATION REQUIRED" -ForegroundColor $color
    Write-Host $Message -ForegroundColor $color
    Write-Host "Impact Level: $Impact" -ForegroundColor $color
    Write-Host ""
    
    $response = Read-Host "Do you want to continue? (y/N)"
    return $response -eq "y" -or $response -eq "Y"
}

function Invoke-GitHubWorkflow {
    param(
        [string]$Scope,
        [bool]$IsDryRun = $false
    )
    
    $dryRunValue = if ($IsDryRun) { "true" } else { "false" }
    
    Write-Host "🚀 Triggering GitHub workflow cleanup..." -ForegroundColor Cyan
    Write-Host "  Scope: $Scope"
    Write-Host "  Dry Run: $dryRunValue"
    Write-Host "  Days to Keep: $DaysToKeep"
    
    try {
        $result = gh workflow run workflow-cleanup.yml -f "cleanup_scope=$Scope" -f "dry_run=$dryRunValue" -f "days_to_keep=$DaysToKeep"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Workflow triggered successfully!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Monitor progress with:" -ForegroundColor Yellow
            Write-Host "  gh run list --workflow=workflow-cleanup.yml"
            Write-Host "  gh run watch"
        } else {
            Write-Error "Failed to trigger workflow. Exit code: $LASTEXITCODE"
        }
    }
    catch {
        Write-Error "Error triggering workflow: $_"
    }
}

# Main script logic
switch ($Action) {
    "help" {
        Show-Help
        return
    }
    
    "preview" {
        $stats = Get-WorkflowStats
        if ($stats) {
            Write-Host "🔍 PREVIEW MODE - No changes will be made" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Available cleanup actions:" -ForegroundColor Green
            Write-Host "  • Failed runs cleanup: $($stats.Failed) runs"
            Write-Host "  • Old runs cleanup: $($stats.Old) runs (older than $DaysToKeep days)"
            Write-Host "  • Cache cleanup: GitHub Actions cache and artifacts"
            Write-Host "  • Full cleanup: ALL $($stats.Total) runs + cache + artifacts"
        }
        
        # Also trigger GitHub workflow preview
        Invoke-GitHubWorkflow -Scope "failed_runs" -IsDryRun $true
        return
    }
    
    "failed" {
        $stats = Get-WorkflowStats
        if ($stats -and $stats.Failed -gt 0) {
            $message = "This will delete $($stats.Failed) failed/cancelled workflow runs."
            if (Confirm-Action -Message $message -Impact "Low") {
                Invoke-GitHubWorkflow -Scope "failed_runs" -IsDryRun $DryRun
            }
        } else {
            Write-Host "✅ No failed runs to clean up." -ForegroundColor Green
        }
    }
    
    "old" {
        $stats = Get-WorkflowStats
        if ($stats -and $stats.Old -gt 0) {
            $message = "This will delete $($stats.Old) workflow runs older than $DaysToKeep days."
            if (Confirm-Action -Message $message -Impact "Medium") {
                Invoke-GitHubWorkflow -Scope "old_runs" -IsDryRun $DryRun
            }
        } else {
            Write-Host "✅ No old runs to clean up." -ForegroundColor Green
        }
    }
    
    "cache" {
        $message = "This will clean GitHub Actions cache and artifacts."
        if (Confirm-Action -Message $message -Impact "Low") {
            Invoke-GitHubWorkflow -Scope "cache_cleanup" -IsDryRun $DryRun
        }
    }
    
    "all" {
        $stats = Get-WorkflowStats
        if ($stats) {
            $message = "⚠️ WARNING: This will delete ALL $($stats.Total) workflow runs! This action cannot be undone."
            if (Confirm-Action -Message $message -Impact "High") {
                Invoke-GitHubWorkflow -Scope "all_runs" -IsDryRun $DryRun
            }
        }
    }
    
    "full" {
        $stats = Get-WorkflowStats
        if ($stats) {
            $message = "🚨 MAXIMUM IMPACT: This will delete ALL $($stats.Total) workflow runs, cache, and artifacts! This action cannot be undone."
            if (Confirm-Action -Message $message -Impact "High") {
                Invoke-GitHubWorkflow -Scope "full_cleanup" -IsDryRun $DryRun
            }
        }
    }
    
    default {
        Write-Error "Invalid action: $Action"
        Show-Help
        exit 1
    }
}

Write-Host ""
Write-Host "🧹 Cleanup script completed." -ForegroundColor Cyan