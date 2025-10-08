#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy Toolspace to Firebase Hosting with custom domain
.DESCRIPTION
    This script builds the Flutter web app and deploys it to Firebase Hosting
    with the custom domain toolz.space configured.
#>

param(
    [switch]$BuildOnly,
    [switch]$DeployOnly,
    [switch]$Production
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Toolspace Deployment Script" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Build Flutter web app
    if (-not $SkipBuild) {
        Write-Host "� Building Flutter web app..." -ForegroundColor Yellow

        if ($CleanBuild) {
            Write-Host "🧹 Cleaning previous build..." -ForegroundColor Yellow
            flutter clean
            flutter pub get
        }

        Write-Host "⚙️  Building for web with HTML renderer..." -ForegroundColor Yellow
        flutter build web --release --web-renderer html

        Write-Host "✅ Flutter build completed" -ForegroundColor Green
        Write-Host ""
    }

    if ($BuildOnly) {
        Write-Host "🏁 Build-only mode completed" -ForegroundColor Green
        exit 0
    }

    Write-Host "🔧 Building Firebase Functions..." -ForegroundColor Yellow
    Set-Location "functions"
    npm run build
    Set-Location ".."
    Write-Host "✅ Functions build completed" -ForegroundColor Green
    Write-Host ""

    Write-Host "🚀 Deploying to Firebase..." -ForegroundColor Yellow

    if ($Production) {
        Write-Host "⚠️  PRODUCTION DEPLOYMENT - This will go live!" -ForegroundColor Red
        $confirm = Read-Host "Type 'DEPLOY' to confirm production deployment"
        if ($confirm -ne "DEPLOY") {
            Write-Host "❌ Deployment cancelled" -ForegroundColor Red
            exit 1
        }

        # Deploy to production
        firebase deploy --project toolspace-beta
    }
    else {
        # Deploy to development
        firebase deploy --project toolspace-beta --only hosting, functions
    }

    Write-Host ""
    Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📱 Your app is now live at:" -ForegroundColor Cyan
    Write-Host "  🌐 https://toolspace-beta.web.app" -ForegroundColor Blue
    Write-Host "  🌐 https://toolz.space (once domain is configured)" -ForegroundColor Blue
    Write-Host ""
    Write-Host "🔧 Next steps for custom domain:" -ForegroundColor Yellow
    Write-Host "  1. Run: firebase hosting:channel:deploy main --project toolspace-beta" -ForegroundColor White
    Write-Host "  2. Go to Firebase Console > Hosting" -ForegroundColor White
    Write-Host "  3. Click 'Add custom domain'" -ForegroundColor White
    Write-Host "  4. Enter: toolz.space" -ForegroundColor White
    Write-Host "  5. Follow DNS configuration instructions" -ForegroundColor White

}
catch {
    Write-Host "❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
