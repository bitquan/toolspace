#!/usr/bin/env pwsh
# Toolspace Local Development - Simple & Reliable
# Starts Firebase emulators and Flutter web dev

Write-Host ""
Write-Host "🚀 Toolspace Local Dev Environment" -ForegroundColor Cyan
Write-Host ""

# Start Firebase Emulators in background
Write-Host "Starting Firebase emulators..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "firebase emulators:start"

# Wait for emulators
Write-Host "Waiting 10 seconds for emulators to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Start Flutter web
Write-Host ""
Write-Host "Starting Flutter web (this will take ~30 seconds to compile)..." -ForegroundColor Yellow
Write-Host ""
Start-Process powershell -ArgumentList "-NoExit", "-Command", "flutter run -d web-server --web-port 8080"

# Wait for Flutter to compile
Start-Sleep -Seconds 35

# Open browser
Write-Host ""
Write-Host "✅ Environment Ready!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 URLs:" -ForegroundColor Cyan
Write-Host "  • App:         http://localhost:8080" -ForegroundColor White
Write-Host "  • Emulator UI: http://localhost:4000" -ForegroundColor White
Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor Cyan
Write-Host "  • Press 'r' in Flutter terminal for hot reload" -ForegroundColor Gray
Write-Host "  • Create test users in emulator UI" -ForegroundColor Gray
Write-Host "  • Close PowerShell windows to stop" -ForegroundColor Gray
Write-Host ""

Start-Process "http://localhost:8080"
Start-Process "http://localhost:4000"

Write-Host "Press any key to exit this launcher..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
