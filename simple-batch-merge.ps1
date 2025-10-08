# Simplified PR Merge Automation Script
param(
    [switch]$DryRun = $false,
    [array]$PRList = @(55, 56, 57, 58, 59, 60, 62)
)

$ErrorActionPreference = "Continue"

# Tool metadata for each PR
$PRMetadata = @{
    55 = @{ toolId = "markdown-pdf"; toolName = "Markdown PDF"; importPath = "../tools/markdown_pdf/markdown_pdf_screen.dart"; screenClass = "MarkdownPdfScreen" }
    56 = @{ toolId = "color-extractor"; toolName = "Color Palette Extractor"; importPath = "../tools/color_extractor/color_extractor_screen.dart"; screenClass = "ColorExtractorScreen" }
    57 = @{ toolId = "uuid-generator"; toolName = "UUID & NanoID Generator"; importPath = "../tools/uuid_generator/uuid_generator_screen.dart"; screenClass = "UuidGeneratorScreen" }
    58 = @{ toolId = "regex-tester"; toolName = "Regex Tester"; importPath = "../tools/regex_tester/regex_tester_screen.dart"; screenClass = "RegexTesterScreen" }
    59 = @{ toolId = "timestamp-converter"; toolName = "Timestamp Converter"; importPath = "../tools/timestamp_converter/timestamp_converter_screen.dart"; screenClass = "TimestampConverterScreen" }
    60 = @{ toolId = "base64-encoder"; toolName = "Base64 / Hex Encoder"; importPath = "../tools/base64_encoder/base64_encoder_screen.dart"; screenClass = "Base64EncoderScreen" }
    62 = @{ toolId = "url-shortener"; toolName = "URL Shortener"; importPath = "../tools/url_shortener/url_shortener_screen.dart"; screenClass = "UrlShortenerScreen" }
}

function Write-Status {
    param($Message, $Type = "Info")
    $timestamp = Get-Date -Format "HH:mm:ss"
    switch ($Type) {
        "Success" { Write-Host "[$timestamp] $Message" -ForegroundColor Green }
        "Warning" { Write-Host "[$timestamp] $Message" -ForegroundColor Yellow }
        "Error" { Write-Host "[$timestamp] $Message" -ForegroundColor Red }
        default { Write-Host "[$timestamp] $Message" -ForegroundColor Cyan }
    }
}

function Resolve-Conflicts {
    param($PRNumber)
    
    $homeScreen = "lib/screens/home_screen.dart"
    if (-not (Test-Path $homeScreen)) {
        Write-Status "home_screen.dart not found" "Error"
        return $false
    }

    $content = Get-Content $homeScreen -Raw
    if ($content -notmatch "<<<<<<< HEAD") {
        Write-Status "No conflicts in home_screen.dart" "Success"
        return $true
    }

    Write-Status "Resolving conflicts in home_screen.dart for PR #$PRNumber" "Info"
    
    # Simple conflict resolution: accept both sides for imports and tools
    $content = $content -replace "<<<<<<< HEAD\s*", ""
    $content = $content -replace "=======\s*", ""
    $content = $content -replace ">>>>>>> origin/main\s*", ""
    
    Set-Content -Path $homeScreen -Value $content -Encoding UTF8
    Write-Status "Resolved conflicts in home_screen.dart" "Success"
    return $true
}

function Process-SinglePR {
    param($PRNumber)
    
    Write-Status "Processing PR #$PRNumber ($($PRMetadata[$PRNumber].toolName))" "Info"
    
    if ($DryRun) {
        Write-Status "DRY RUN: Would process PR #$PRNumber" "Warning"
        return $true
    }

    try {
        # Checkout PR
        Write-Status "Checking out PR #$PRNumber" "Info"
        $result = & gh pr checkout $PRNumber 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Status "Failed to checkout: $result" "Error"
            return $false
        }

        # Fetch and merge main
        Write-Status "Merging with main" "Info"
        & git fetch origin main 2>$null
        $mergeResult = & git merge origin/main 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Status "Conflicts detected, attempting resolution" "Warning"
            
            if (-not (Resolve-Conflicts -PRNumber $PRNumber)) {
                Write-Status "Failed to resolve conflicts" "Error"
                & git merge --abort 2>$null
                return $false
            }
        }

        # Stage and commit
        Write-Status "Committing changes" "Info"
        & git add . 2>$null
        & git commit -m "Resolve conflicts: add $($PRMetadata[$PRNumber].toolName)" 2>$null

        # Push
        Write-Status "Pushing changes" "Info"
        $pushResult = & git push --force-with-lease 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Status "Failed to push: $pushResult" "Error"
            return $false
        }

        # Switch to main and merge
        Write-Status "Merging PR #$PRNumber" "Info"
        & git checkout main 2>$null
        & git pull 2>$null
        
        $mergeResult = & gh pr merge $PRNumber --squash --delete-branch 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Successfully merged PR #$PRNumber" "Success"
            return $true
        } else {
            Write-Status "Failed to merge: $mergeResult" "Error"
            return $false
        }
    }
    catch {
        Write-Status "Error: $($_.Exception.Message)" "Error"
        & git merge --abort 2>$null
        & git checkout main 2>$null
        return $false
    }
}

# Main execution
Write-Status "Starting batch PR merge process" "Info"
Write-Status "Target PRs: $($PRList -join ', ')" "Info"

if ($DryRun) {
    Write-Status "DRY RUN MODE - No changes will be made" "Warning"
}

$results = @()
$successCount = 0

foreach ($pr in $PRList) {
    $success = Process-SinglePR -PRNumber $pr
    $results += @{
        PR = $pr
        Success = $success
        Tool = $PRMetadata[$pr].toolName
    }
    
    if ($success) { $successCount++ }
    
    Start-Sleep -Seconds 1
}

# Summary
Write-Status "`nBatch merge completed!" "Info"
Write-Status "Successful merges: $successCount/$($PRList.Count)" "Success"

Write-Host "`nResults:" -ForegroundColor Cyan
foreach ($result in $results) {
    $status = if ($result.Success) { "✅" } else { "❌" }
    $color = if ($result.Success) { "Green" } else { "Red" }
    Write-Host "  $status PR #$($result.PR): $($result.Tool)" -ForegroundColor $color
}

if ($DryRun) {
    Write-Status "`nDry run completed. Remove -DryRun to execute for real." "Warning"
}