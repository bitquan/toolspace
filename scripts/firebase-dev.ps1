#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Start Firebase emulators with auto-close functionality
.DESCRIPTION
    This script starts Firebase emulators and automatically closes the terminal
    when the emulators are stopped (Ctrl+C or terminated).
#>

param(
    [switch]$AutoClose
)

# Set up error handling
$ErrorActionPreference = "Continue"

# Function to handle cleanup
function Cleanup {
    Write-Host ""
    Write-Host "🔥 Firebase Emulators have been stopped" -ForegroundColor Green

    if ($AutoClose -or (-not $PSBoundParameters.ContainsKey('AutoClose'))) {
        Write-Host "Terminal will close in 2 seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        exit 0
    } else {
        Write-Host "Press any key to close terminal..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 0
    }
}

# Set up Ctrl+C handler
[Console]::TreatControlCAsInput = $false
$null = Register-EngineEvent PowerShell.Exiting -Action {
    Cleanup
}

try {
    Write-Host "🔥 Starting Firebase Emulators..." -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop emulators" -ForegroundColor Cyan
    Write-Host ""

    # Start Firebase emulators
    & firebase emulators:start

    # If we reach here, emulators stopped normally
    Cleanup
}
catch {
    Write-Host "❌ Firebase emulators stopped or failed to start" -ForegroundColor Red
    if ($_.Exception.Message) {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Cleanup
}
