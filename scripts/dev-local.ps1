#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Complete local development environment
.DESCRIPTION
    Starts Firebase emulators and Flutter web for local development
.EXAMPLE
    .\dev-local.ps1
#>

param(
    [switch]$EmulatorsOnly,
    [switch]$SkipBrowser
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Cyan }
function Write-Warn { param($msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Write-Err { param($msg) Write-Host "❌ $msg" -ForegroundColor Red }

# Banner
Write-Host ""
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  🚀 Toolspace Local Development Environment  ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# Cleanup function
$jobs = @()
function Cleanup {
    Write-Host ""
    Write-Info "Stopping all services..."

    # Stop all background jobs
    foreach ($job in $jobs) {
        Stop-Job -Job $job -ErrorAction SilentlyContinue
        Remove-Job -Job $job -ErrorAction SilentlyContinue
    }

    # Kill any remaining processes
    Get-Process | Where-Object { $_.ProcessName -like "*firebase*" -or $_.ProcessName -like "*dart*" } | Stop-Process -Force -ErrorAction SilentlyContinue

    Write-Success "All services stopped"
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

# Register cleanup on exit
Register-EngineEvent PowerShell.Exiting -Action { Cleanup }

try {
    # Check prerequisites
    Write-Info "Checking prerequisites..."

    $hasFirebase = Get-Command firebase -ErrorAction SilentlyContinue
    $hasFlutter = Get-Command flutter -ErrorAction SilentlyContinue

    if (-not $hasFirebase) {
        Write-Err "Firebase CLI not found. Install: npm install -g firebase-tools"
        exit 1
    }

    if (-not $hasFlutter -and -not $EmulatorsOnly) {
        Write-Err "Flutter not found. Install: https://flutter.dev"
        exit 1
    }

    Write-Success "Prerequisites OK"
    Write-Host ""

    # ============================================
    # Start Firebase Emulators
    # ============================================
    if (-not $FlutterOnly) {
        Write-Info "Starting Firebase Emulators..."
        Write-Host "  • Auth:      http://localhost:9099" -ForegroundColor Gray
        Write-Host "  • Firestore: http://localhost:8080" -ForegroundColor Gray
        Write-Host "  • Functions: http://localhost:5001" -ForegroundColor Gray
        Write-Host "  • UI:        http://localhost:4000" -ForegroundColor Gray
        Write-Host ""

        $emuJob = Start-Job -ScriptBlock {
            Set-Location $using:PWD
            firebase emulators:start
        }
        $jobs += $emuJob

        # Wait for emulators to start
        Write-Info "Waiting for emulators to initialize..."
        Start-Sleep -Seconds 8

        # Check if emulators started successfully
        $emuState = Receive-Job -Job $emuJob -ErrorAction SilentlyContinue | Select-Object -Last 10
        if ($emuJob.State -eq "Failed") {
            Write-Err "Firebase emulators failed to start"
            Cleanup
        }

        Write-Success "Firebase emulators running"
        Write-Host ""
    }

    # ============================================
    # Start Flutter Web Dev Server
    # ============================================
    if (-not $EmulatorsOnly) {
        Write-Info "Starting Flutter web dev server..."
        Write-Host "  • Dev Server: http://localhost:$FlutterPort" -ForegroundColor Gray
        Write-Host ""

        # Get dependencies first
        Write-Info "Running flutter pub get..."
        flutter pub get | Out-Null

        # Start Flutter web
        $flutterJob = Start-Job -ScriptBlock {
            Set-Location $using:PWD
            flutter run -d web-server --web-port $using:FlutterPort --web-hostname localhost
        }
        $jobs += $flutterJob

        # Wait for Flutter to compile
        Write-Info "Compiling Flutter app (this takes ~30 seconds)..."
        Start-Sleep -Seconds 30

        # Check if Flutter started
        if ($flutterJob.State -eq "Failed") {
            Write-Err "Flutter dev server failed to start"
            Cleanup
        }

        Write-Success "Flutter dev server running"
        Write-Host ""
    }

    # ============================================
    # Summary & URLs
    # ============================================
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║          🎉 DEVELOPMENT ENVIRONMENT READY!    ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "📍 Access Points:" -ForegroundColor Cyan
    Write-Host ""

    if (-not $FlutterOnly) {
        Write-Host "  🔥 Firebase Emulator UI:  http://localhost:4000" -ForegroundColor Yellow
        Write-Host "     • Auth:                http://localhost:9099" -ForegroundColor Gray
        Write-Host "     • Firestore:           http://localhost:8080" -ForegroundColor Gray
        Write-Host "     • Functions:           http://localhost:5001" -ForegroundColor Gray
        Write-Host ""
    }

    if (-not $EmulatorsOnly) {
        Write-Host "  🚀 Flutter App:           http://localhost:$FlutterPort" -ForegroundColor Yellow
        Write-Host ""
    }

    Write-Host "🎯 Features:" -ForegroundColor Cyan
    Write-Host "  • Hot Reload enabled (press 'r' in Flutter console)" -ForegroundColor Gray
    Write-Host "  • Local auth with emulated users" -ForegroundColor Gray
    Write-Host "  • Firestore data persisted in .firebase/" -ForegroundColor Gray
    Write-Host "  • All changes isolated from production" -ForegroundColor Gray
    Write-Host ""
    Write-Host "⚡ Tips:" -ForegroundColor Cyan
    Write-Host "  • Create test users in Auth emulator UI" -ForegroundColor Gray
    Write-Host "  • View Firestore data in emulator UI" -ForegroundColor Gray
    Write-Host "  • Press Ctrl+C to stop all services" -ForegroundColor Gray
    Write-Host ""

    # Open browser
    if (-not $SkipBrowser -and -not $EmulatorsOnly) {
        Write-Info "Opening browser in 3 seconds..."
        Start-Sleep -Seconds 3
        Start-Process "http://localhost:$FlutterPort"
        Start-Process "http://localhost:4000"  # Emulator UI
    }

    Write-Host ""
    Write-Warn "Press Ctrl+C to stop all services"
    Write-Host ""

    # Keep script running and monitor jobs
    while ($true) {
        Start-Sleep -Seconds 5

        # Check if any jobs failed
        foreach ($job in $jobs) {
            if ($job.State -eq "Failed") {
                Write-Err "A service stopped unexpectedly"
                Cleanup
            }
        }
    }
}
catch {
    Write-Err "Error: $($_.Exception.Message)"
    Cleanup
}
finally {
    Cleanup
}
