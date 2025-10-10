# Manual Plan Update Script
# This PowerShell script will update your billing profile to Pro plan

$projectId = "toolspace-beta"
$now = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

# Data to update
$updateData = @{
    plan            = "pro"
    planDisplayName = "Pro Plan"
    status          = "active"
    updatedAt       = $now
    subscriptionId  = "manual_update_$(Get-Date -Format 'yyyyMMddHHmmss')"
    priceId         = "price_1Q8QFNKH9qhDPyF8xTlgONJW"
} | ConvertTo-Json

Write-Host "🔍 Updating billing profile to Pro plan..." -ForegroundColor Yellow
Write-Host "Update data: $updateData" -ForegroundColor Cyan

# You'll need to replace USER_ID with your actual Firebase user ID
Write-Host ""
Write-Host "⚠️ IMPORTANT: You need to provide your Firebase User ID" -ForegroundColor Red
Write-Host "To find your user ID, check the browser console when logged into the app" -ForegroundColor Yellow
Write-Host "Or look in Firebase Console > Authentication > Users" -ForegroundColor Yellow
Write-Host ""
$userId = Read-Host "Enter your Firebase User ID"

if ($userId) {
    $url = "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/billingProfiles/$userId"

    try {
        $headers = @{
            "Authorization" = "Bearer $(firebase auth:print-access-token --project $projectId)"
            "Content-Type"  = "application/json"
        }

        Write-Host "🚀 Sending update request..." -ForegroundColor Green
        $response = Invoke-RestMethod -Uri $url -Method PATCH -Headers $headers -Body $updateData
        Write-Host "✅ Plan updated successfully!" -ForegroundColor Green
        Write-Host "🎉 You should now have Pro plan access. Please refresh your app!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Error updating plan: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "🔧 Trying alternative approach..." -ForegroundColor Yellow

        # Alternative: use firebase CLI
        $tempFile = "temp_update.json"
        $updateData | Out-File -FilePath $tempFile
        firebase firestore:set billingProfiles/$userId $tempFile --project $projectId
        Remove-Item $tempFile
    }
}
else {
    Write-Host "❌ User ID is required to update the billing profile" -ForegroundColor Red
}
