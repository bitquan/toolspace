# Advanced PR Merge Automation Script with Intelligent Conflict Resolution
# This script automates the merging of remaining PRs with smart conflict resolution

param(
    [switch]$DryRun = $false,
    [array]$PRList = @(55, 56, 57, 58, 59, 60, 62)
)

$ErrorActionPreference = "Continue"

# PR metadata for conflict resolution
$PRMetadata = @{
    55 = @{
        toolId = "markdown-pdf"
        toolName = "Markdown PDF"
        toolDescription = "Convert Markdown to PDF with themeable export options"
        toolIcon = "Icons.picture_as_pdf"
        importPath = "../tools/markdown_pdf/markdown_pdf_screen.dart"
        screenClass = "MarkdownPdfScreen"
        colorIndex = 7
    }
    56 = @{
        toolId = "color-extractor"
        toolName = "Color Palette Extractor"
        toolDescription = "Extract color palettes from images to swatches"
        toolIcon = "Icons.palette"
        importPath = "../tools/color_extractor/color_extractor_screen.dart"
        screenClass = "ColorExtractorScreen"
        colorIndex = 8
    }
    57 = @{
        toolId = "uuid-generator"
        toolName = "UUID & NanoID Generator"
        toolDescription = "Generate UUIDs and NanoIDs with custom options"
        toolIcon = "Icons.generating_tokens"
        importPath = "../tools/uuid_generator/uuid_generator_screen.dart"
        screenClass = "UuidGeneratorScreen"
        colorIndex = 9
    }
    58 = @{
        toolId = "regex-tester"
        toolName = "Regex Tester"
        toolDescription = "Test regex patterns with live match and groups"
        toolIcon = "Icons.pattern"
        importPath = "../tools/regex_tester/regex_tester_screen.dart"
        screenClass = "RegexTesterScreen"
        colorIndex = 10
    }
    59 = @{
        toolId = "timestamp-converter"
        toolName = "Timestamp Converter"
        toolDescription = "Convert between human readable and epoch timestamps"
        toolIcon = "Icons.access_time"
        importPath = "../tools/timestamp_converter/timestamp_converter_screen.dart"
        screenClass = "TimestampConverterScreen"
        colorIndex = 11
    }
    60 = @{
        toolId = "base64-encoder"
        toolName = "Base64 / Hex Encoder-Decoder"
        toolDescription = "Encode and decode Base64 and Hex strings"
        toolIcon = "Icons.transform"
        importPath = "../tools/base64_encoder/base64_encoder_screen.dart"
        screenClass = "Base64EncoderScreen"
        colorIndex = 12
    }
    62 = @{
        toolId = "url-shortener"
        toolName = "URL Shortener"
        toolDescription = "Shorten URLs with Firebase backend integration"
        toolIcon = "Icons.link"
        importPath = "../tools/url_shortener/url_shortener_screen.dart"
        screenClass = "UrlShortenerScreen"
        colorIndex = 13
    }
}

function Write-Status {
    param($Message, $Type = "Info")
    $color = switch ($Type) {
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        "Info" { "Cyan" }
        default { "White" }
    }
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor $color
}

function Get-CurrentImports {
    $homeScreenPath = "lib/screens/home_screen.dart"
    if (Test-Path $homeScreenPath) {
        $content = Get-Content $homeScreenPath -Raw
        $importSection = $content -split "import '../widgets/animated_tools_grid.dart';" | Select-Object -First 1
        return $importSection -split "`n" | Where-Object { $_ -match "import '../tools/" }
    }
    return @()
}

function Get-CurrentTools {
    $homeScreenPath = "lib/screens/home_screen.dart"
    if (Test-Path $homeScreenPath) {
        $content = Get-Content $homeScreenPath -Raw
        $toolsSection = ($content -split "static final List<ToolItem> _tools = \[")[1]
        $toolsSection = ($toolsSection -split "\];\s*\}")[0]
        return $toolsSection
    }
    return ""
}

function Resolve-HomeScreenConflicts {
    param($PRNumber)
    
    $homeScreenPath = "lib/screens/home_screen.dart"
    if (-not (Test-Path $homeScreenPath)) {
        Write-Status "home_screen.dart not found" "Error"
        return $false
    }

    $content = Get-Content $homeScreenPath -Raw
    
    # Check if there are merge conflicts
    if ($content -notmatch "<<<<<<< HEAD") {
        Write-Status "No conflicts found in home_screen.dart" "Success"
        return $true
    }

    Write-Status "Resolving home_screen.dart conflicts for PR #$PRNumber" "Info"
    
    $metadata = $PRMetadata[$PRNumber]
    if (-not $metadata) {
        Write-Status "No metadata found for PR #$PRNumber" "Error"
        return $false
    }

    # Get existing imports and tools from main branch
    $existingImports = @(
        "import '../tools/text_tools/text_tools_screen.dart';",
        "import '../tools/file_merger/file_merger_screen.dart';",
        "import '../tools/json_doctor/json_doctor_screen.dart';",
        "import '../tools/text_diff/text_diff_screen.dart';",
        "import '../tools/qr_maker/qr_maker_screen.dart';",
        "import '../tools/image_resizer/image_resizer_screen.dart';",
        "import '../tools/password_gen/password_gen_screen.dart';",
        "import '../tools/json_flatten/json_flatten_screen.dart';"
    )

    # Add the new import
    $newImport = "import '$($metadata.importPath)';"
    $allImports = $existingImports + $newImport

    # Create new tool item
    $newToolItem = @"
    ToolItem(
      id: '$($metadata.toolId)',
      name: '$($metadata.toolName)',
      description: '$($metadata.toolDescription)',
      icon: $($metadata.toolIcon),
      screen: const $($metadata.screenClass)(),
      color: PlayfulTheme.toolColors[$($metadata.colorIndex) % PlayfulTheme.toolColors.length],
    ),"@

    # Read the template and replace sections
    try {
        # Create the resolved content
        $resolvedContent = @"
import 'package:flutter/material.dart';
$($allImports -join "`n")
import '../widgets/animated_tools_grid.dart';
import '../theme/playful_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Playful App Bar
          SliverAppBar.large(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 0,
            floating: true,
            snap: true,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.build_circle,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toolspace',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Playful Tools Hub',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tools Grid
          SliverFillRemaining(
            child: AnimatedToolsGrid(
              tools: _tools,
              onToolTap: (tool) => _navigateToTool(context, tool),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTool(BuildContext context, ToolItem tool) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => tool.screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: PlayfulTheme.mediumAnimation,
      ),
    );
  }

  static final List<ToolItem> _tools = [
    ToolItem(
      id: 'text-tools',
      name: 'Text Tools',
      description:
          'Case conversion, cleaning, JSON formatting, and more text utilities',
      icon: Icons.text_fields,
      screen: const TextToolsScreen(),
      color: PlayfulTheme.toolColors[0],
    ),
    ToolItem(
      id: 'file-merger',
      name: 'File Merger',
      description: 'Merge PDFs and images into a single PDF file with ease',
      icon: Icons.merge_type,
      screen: const FileMergerScreen(),
      color: PlayfulTheme.toolColors[1],
    ),
    // T-ToolsPack: Instant-win micro tools
    ToolItem(
      id: 'json-doctor',
      name: 'JSON Doctor',
      description: 'Validate, format, and repair JSON with instant feedback',
      icon: Icons.healing,
      screen: const JsonDoctorScreen(),
      color: PlayfulTheme.toolColors[2],
    ),
    ToolItem(
      id: 'text-diff',
      name: 'Text Diff',
      description: 'Compare texts with highlighted differences line by line',
      icon: Icons.compare_arrows,
      screen: const TextDiffScreen(),
      color: PlayfulTheme.toolColors[3],
    ),
    ToolItem(
      id: 'qr-maker',
      name: 'QR Maker',
      description: 'Generate QR codes instantly with customization options',
      icon: Icons.qr_code,
      screen: const QrMakerScreen(),
      color: PlayfulTheme.toolColors[4],
    ),
    ToolItem(
      id: 'image-resizer',
      name: 'Image Resizer',
      description: 'Resize and convert images with batch processing support',
      icon: Icons.photo_size_select_large,
      screen: const ImageResizerScreen(),
      color: PlayfulTheme.toolColors[0],
    ),
    ToolItem(
      id: 'password-gen',
      name: 'Password Generator',
      description: 'Generate secure passwords with entropy meter and rules',
      icon: Icons.password,
      screen: const PasswordGenScreen(),
      color: PlayfulTheme.toolColors[5 % PlayfulTheme.toolColors.length],
    ),
    ToolItem(
      id: 'json-flatten',
      name: 'JSON Flatten',
      description:
          'Flatten nested JSON to CSV with field selection and preview',
      icon: Icons.table_chart,
      screen: const JsonFlattenScreen(),
      color: const Color(0xFF6A1B9A),
    ),
$newToolItem
  ];
}

class ToolItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Widget screen;
  final Color color;

  const ToolItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.screen,
    required this.color,
  });
}
"@

        Set-Content -Path $homeScreenPath -Value $resolvedContent -Encoding UTF8
        Write-Status "Successfully resolved home_screen.dart conflicts" "Success"
        return $true
    }
    catch {
        Write-Status "Failed to resolve conflicts: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Process-PR {
    param($PRNumber)
    
    Write-Status "Processing PR #$PRNumber" "Info"
    
    if ($DryRun) {
        Write-Status "DRY RUN: Would process PR #$PRNumber" "Warning"
        return $true
    }

    try {
        # Checkout PR
        Write-Status "Checking out PR #$PRNumber" "Info"
        & gh pr checkout $PRNumber
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to checkout PR #$PRNumber"
        }

        # Fetch and merge main
        Write-Status "Fetching and merging main" "Info"
        & git fetch origin main
        & git merge origin/main

        if ($LASTEXITCODE -ne 0) {
            Write-Status "Merge conflicts detected, attempting resolution" "Warning"
            
            # Resolve home_screen.dart conflicts
            if (-not (Resolve-HomeScreenConflicts -PRNumber $PRNumber)) {
                throw "Failed to resolve conflicts for PR #$PRNumber"
            }
        }

        # Stage and commit
        Write-Status "Staging and committing changes" "Info"
        & git add .
        & git commit -m "Resolve merge conflicts: add $($PRMetadata[$PRNumber].toolName) tool"

        # Push
        Write-Status "Pushing changes" "Info"
        & git push --force-with-lease
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to push changes for PR #$PRNumber"
        }

        # Switch to main and merge
        Write-Status "Switching to main and merging" "Info"
        & git checkout main
        & git pull
        & gh pr merge $PRNumber --squash --delete-branch

        if ($LASTEXITCODE -eq 0) {
            Write-Status "Successfully merged PR #$PRNumber" "Success"
            return $true
        } else {
            throw "Failed to merge PR #$PRNumber"
        }
    }
    catch {
        Write-Status "Error processing PR #$PRNumber`: $($_.Exception.Message)" "Error"
        # Cleanup
        & git merge --abort 2>$null
        & git checkout main 2>$null
        return $false
    }
}

# Main execution
Write-Status "Starting automated PR merge process" "Info"
Write-Status "Target PRs: $($PRList -join ', ')" "Info"

if ($DryRun) {
    Write-Status "DRY RUN MODE - No actual changes will be made" "Warning"
}

$successCount = 0
$failureCount = 0
$results = @()

foreach ($pr in $PRList) {
    $result = Process-PR -PRNumber $pr
    $results += @{
        PR = $pr
        Success = $result
        Tool = $PRMetadata[$pr].toolName
    }
    
    if ($result) {
        $successCount++
    } else {
        $failureCount++
    }
    
    # Small delay between PRs
    Start-Sleep -Seconds 2
}

# Summary
Write-Status "Merge process completed" "Info"
Write-Status "Successful merges: $successCount" "Success"
Write-Status "Failed merges: $failureCount" "Error"

Write-Host "`nDetailed Results:" -ForegroundColor Cyan
foreach ($result in $results) {
    $status = if ($result.Success) { "✅" } else { "❌" }
    $color = if ($result.Success) { "Green" } else { "Red" }
    Write-Host "  $status PR #$($result.PR): $($result.Tool)" -ForegroundColor $color
}

if ($DryRun) {
    Write-Status "Dry run completed - review the script and run without -DryRun to execute" "Warning"
}