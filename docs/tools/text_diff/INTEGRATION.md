# Text Diff - Integration Guide

## Integration Architecture

The Text Diff tool is designed as a **cornerstone component** in text analysis workflows, providing sophisticated comparison capabilities that integrate seamlessly with the broader Toolspace ecosystem. Built on the ShareEnvelope framework, it serves as both a data consumer and producer, enabling complex multi-tool workflows for professional text analysis and development operations.

### Integration Philosophy

- **Universal Text Analysis Hub**: Central comparison point for all text-based workflows
- **Bidirectional Data Flow**: Both import from and export to other tools seamlessly
- **Quality Chain Preservation**: Maintain data provenance across tool boundaries
- **Developer-Focused APIs**: Programmatic access for automation and scripting
- **Cross-Platform Compatibility**: Consistent behavior across web, mobile, and desktop

## ShareEnvelope Framework Integration

### Core Integration Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                ShareEnvelope Data Flow                      │
├─────────────────────────────────────────────────────────────┤
│  Upstream Sources          Text Diff Hub          Downstream │
│                                                             │
│  Text Tools ────────────────┐                              │
│  Code Editors ──────────────┤                              │
│  File Merger ───────────────┼──→ Text Diff ──→ Report Gen  │
│  Audio Transcriber ─────────┤    (Analysis)      Export    │
│  Subtitle Maker ────────────┘                   Share      │
│  Manual Input                                    Archive    │
└─────────────────────────────────────────────────────────────┘
```

### Data Import Capabilities

**ShareEnvelope Data Handler**

```dart
@override
void handleSharedData(SharedData data) {
  switch (data.type) {
    case SharedDataType.text:
      _handleTextImport(data);
      break;
    case SharedDataType.file:
      _handleFileImport(data);
      break;
    case SharedDataType.config:
      _handleConfigImport(data);
      break;
  }
}

void _handleTextImport(SharedData data) {
  final targetField = data.metadata['target_field'] ?? 'text1';
  final source = data.source;

  switch (targetField) {
    case 'text1':
    case 'original':
      _text1Controller.text = data.content;
      break;
    case 'text2':
    case 'modified':
      _text2Controller.text = data.content;
      break;
    case 'base':
      _baseTextController.text = data.content;
      break;
  }

  // Update quality chain
  _qualityChain.addStep(QualityStep(
    tool: 'text_diff',
    operation: 'import_text',
    source: source,
    timestamp: DateTime.now(),
    metadata: {'target_field': targetField},
  ));

  // Trigger automatic comparison
  _compareTexts();

  // Show import confirmation
  _showImportFeedback(source, targetField);
}
```

### Data Export Framework

**Multi-Format Export Support**

```dart
class TextDiffExporter {
  /// Export diff results in multiple formats
  static Map<String, dynamic> exportDiffResults({
    required List<DiffLine> diffLines,
    required DiffStats stats,
    required List<WordDiff> wordDiffs,
    required WordDiffStats wordStats,
    String format = 'standard',
  }) {
    switch (format) {
      case 'unified':
        return _exportUnifiedDiff(diffLines, stats);
      case 'side_by_side':
        return _exportSideBySideDiff(diffLines, stats);
      case 'word_analysis':
        return _exportWordAnalysis(wordDiffs, wordStats);
      case 'statistical':
        return _exportStatisticalSummary(stats, wordStats);
      case 'merge_result':
        return _exportMergeResult();
      default:
        return _exportStandardFormat(diffLines, stats);
    }
  }
}
```

**ShareEnvelope Export Integration**

```dart
void _exportToShareEnvelope(String format) {
  final exportData = TextDiffExporter.exportDiffResults(
    diffLines: _diffLines,
    stats: _stats,
    wordDiffs: _wordDiffs,
    wordStats: _wordStats,
    format: format,
  );

  final sharedData = SharedData(
    type: SharedDataType.analysis,
    content: jsonEncode(exportData),
    source: 'text_diff',
    metadata: {
      'analysis_type': 'text_comparison',
      'format': format,
      'similarity': _stats.similarity.toString(),
      'total_changes': _stats.totalChanges.toString(),
      'processing_time': _lastProcessingTime.toString(),
    },
    qualityChain: _qualityChain,
  );

  ShareEnvelope.share(sharedData);
}
```

## Cross-Tool Integration Patterns

### Developer Workflow Integration

**Code Review Workflow**

```
Git Diff Output → Text Diff → Analysis Report → Documentation
    ↓                ↓              ↓             ↓
File Merger ←── Review Notes ←── Statistics ←── Archive
```

**Implementation Example:**

```dart
class CodeReviewIntegration {
  static void processGitDiff(String gitDiffOutput) {
    final parsedDiff = GitDiffParser.parse(gitDiffOutput);

    // Send to Text Diff for analysis
    ShareEnvelope.share(SharedData(
      type: SharedDataType.text,
      content: parsedDiff.originalContent,
      metadata: {'target_field': 'text1', 'source_type': 'git'},
    ));

    ShareEnvelope.share(SharedData(
      type: SharedDataType.text,
      content: parsedDiff.modifiedContent,
      metadata: {'target_field': 'text2', 'source_type': 'git'},
    ));
  }

  static void exportReviewReport(TextDiffResults results) {
    final report = ReviewReportGenerator.generate(results);

    ShareEnvelope.share(SharedData(
      type: SharedDataType.document,
      content: report.toMarkdown(),
      metadata: {'document_type': 'code_review'},
    ));
  }
}
```

### Content Management Workflow

**Editorial Workflow**

```
Document Versions → Text Diff → Change Analysis → Publication
       ↓               ↓            ↓               ↓
Version Control ← Review Queue ← Editor Notes ← CMS Update
```

**Content Management Integration:**

```dart
class ContentManagementIntegration {
  static void compareDocumentVersions(
    String originalDoc,
    String revisedDoc,
    Map<String, dynamic> metadata,
  ) {
    // Import documents for comparison
    final importData1 = SharedData(
      type: SharedDataType.text,
      content: originalDoc,
      source: 'cms',
      metadata: {
        'target_field': 'text1',
        'document_id': metadata['document_id'],
        'version': metadata['original_version'],
      },
    );

    final importData2 = SharedData(
      type: SharedDataType.text,
      content: revisedDoc,
      source: 'cms',
      metadata: {
        'target_field': 'text2',
        'document_id': metadata['document_id'],
        'version': metadata['revised_version'],
      },
    );

    ShareEnvelope.share(importData1);
    ShareEnvelope.share(importData2);
  }

  static void exportEditorialReport(TextDiffResults results) {
    final editorialReport = EditorialReportGenerator.create(
      changes: results.diffLines,
      statistics: results.stats,
      recommendations: _generateEditorialRecommendations(results),
    );

    ShareEnvelope.share(SharedData(
      type: SharedDataType.report,
      content: editorialReport.toJson(),
      metadata: {'report_type': 'editorial_analysis'},
    ));
  }
}
```

### Data Science and Analytics Integration

**Text Analysis Pipeline**

```
Data Sources → Text Preprocessing → Text Diff → Pattern Analysis → ML Training
     ↓              ↓                  ↓             ↓              ↓
Raw Text ←── Cleaned Data ←── Change Patterns ←── Features ←── Models
```

**Analytics Integration Example:**

```dart
class AnalyticsIntegration {
  static void analyzeBulkTextChanges(List<TextPair> textPairs) {
    final analysisResults = <AnalysisResult>[];

    for (final pair in textPairs) {
      // Process each pair through Text Diff
      final diffResult = TextDiffEngine.compare(pair.original, pair.modified);

      analysisResults.add(AnalysisResult(
        pairId: pair.id,
        similarity: diffResult.stats.similarity,
        changeTypes: _categorizeChanges(diffResult.diffLines),
        wordLevelChanges: diffResult.wordStats,
        processingTime: diffResult.processingTime,
      ));
    }

    // Export aggregate analysis
    final aggregateReport = BulkAnalysisReporter.generate(analysisResults);

    ShareEnvelope.share(SharedData(
      type: SharedDataType.analysis,
      content: aggregateReport.toJson(),
      metadata: {
        'analysis_type': 'bulk_text_comparison',
        'sample_size': textPairs.length.toString(),
        'processing_date': DateTime.now().toIso8601String(),
      },
    ));
  }
}
```

## API Integration Framework

### REST API Compatibility

**Text Diff API Endpoints**

```typescript
// Text Diff API Interface
interface TextDiffAPI {
  // Compare two texts
  POST /api/v1/text-diff/compare
  Request: {
    text1: string;
    text2: string;
    mode?: 'line' | 'word' | 'character';
    options?: {
      caseSensitive?: boolean;
      ignoreWhitespace?: boolean;
      contextLines?: number;
    };
  }
  Response: {
    diffLines: DiffLine[];
    statistics: DiffStats;
    wordDiffs?: WordDiff[];
    wordStats?: WordDiffStats;
    processingTime: number;
  }

  // Three-way merge
  POST /api/v1/text-diff/merge
  Request: {
    base: string;
    left: string;
    right: string;
    conflictResolution?: 'manual' | 'left' | 'right';
  }
  Response: {
    mergedText: string;
    hasConflicts: boolean;
    conflicts: MergeConflict[];
    mergeStats: MergeStats;
  }

  // Batch comparison
  POST /api/v1/text-diff/batch
  Request: {
    comparisons: Array<{
      id: string;
      text1: string;
      text2: string;
    }>;
    mode?: 'line' | 'word';
  }
  Response: {
    results: Array<{
      id: string;
      diffResult: DiffResult;
      error?: string;
    }>;
    batchStats: BatchStats;
  }
}
```

### WebSocket Integration

**Real-time Collaboration Support**

```dart
class RealtimeTextDiffService {
  late WebSocketChannel _channel;

  void connectToCollaborationSession(String sessionId) {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://api.toolspace.com/text-diff/collaborate/$sessionId')
    );

    _channel.stream.listen((data) {
      final message = CollaborationMessage.fromJson(data);
      _handleCollaborationMessage(message);
    });
  }

  void shareTextChanges(String fieldName, String content) {
    final message = CollaborationMessage(
      type: 'text_update',
      data: {
        'field': fieldName,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
        'userId': _currentUserId,
      },
    );

    _channel.sink.add(message.toJson());
  }

  void _handleCollaborationMessage(CollaborationMessage message) {
    switch (message.type) {
      case 'text_update':
        _handleRemoteTextUpdate(message.data);
        break;
      case 'cursor_position':
        _handleRemoteCursorUpdate(message.data);
        break;
      case 'diff_request':
        _handleRemoteDiffRequest(message.data);
        break;
    }
  }
}
```

## Plugin and Extension Framework

### Browser Extension Integration

**Browser Extension API**

```javascript
// Browser Extension Interface
const ToolspaceTextDiff = {
  // Compare selected text on any webpage
  comparePageSelections: async function (selection1, selection2) {
    const response = await fetch(
      "https://toolspace.com/api/text-diff/compare",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          text1: selection1,
          text2: selection2,
          source: "browser_extension",
        }),
      }
    );

    return response.json();
  },

  // Open Text Diff tool with pre-populated content
  openWithContent: function (text1, text2) {
    const params = new URLSearchParams({
      text1: encodeURIComponent(text1),
      text2: encodeURIComponent(text2),
      source: "browser_extension",
    });

    window.open(`https://toolspace.com/tools/text-diff?${params}`);
  },

  // Context menu integration
  addContextMenuItems: function () {
    chrome.contextMenus.create({
      id: "compare-with-toolspace",
      title: "Compare with Toolspace Text Diff",
      contexts: ["selection"],
    });
  },
};
```

### IDE Plugin Integration

**VS Code Extension Interface**

```typescript
// VS Code Extension Integration
import * as vscode from "vscode";

export class ToolspaceTextDiffProvider {
  static register(context: vscode.ExtensionContext) {
    // Register diff provider
    const diffProvider = new ToolspaceTextDiffProvider();

    // Compare selected text
    const compareSelection = vscode.commands.registerCommand(
      "toolspace.compareSelection",
      () => diffProvider.compareSelection()
    );

    // Compare files
    const compareFiles = vscode.commands.registerCommand(
      "toolspace.compareFiles",
      (file1: vscode.Uri, file2: vscode.Uri) =>
        diffProvider.compareFiles(file1, file2)
    );

    context.subscriptions.push(compareSelection, compareFiles);
  }

  async compareSelection() {
    const editor = vscode.window.activeTextEditor;
    if (!editor) return;

    const selection = editor.document.getText(editor.selection);

    // Open Toolspace Text Diff with selection
    const uri = vscode.Uri.parse(
      `https://toolspace.com/tools/text-diff?text1=${encodeURIComponent(
        selection
      )}&source=vscode`
    );

    vscode.env.openExternal(uri);
  }

  async compareFiles(file1: vscode.Uri, file2: vscode.Uri) {
    const content1 = await vscode.workspace.fs.readFile(file1);
    const content2 = await vscode.workspace.fs.readFile(file2);

    const text1 = content1.toString();
    const text2 = content2.toString();

    // Send to Toolspace API
    const response = await fetch(
      "https://toolspace.com/api/text-diff/compare",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ text1, text2, source: "vscode" }),
      }
    );

    const result = await response.json();

    // Display results in VS Code
    this.showDiffResults(result);
  }
}
```

## Enterprise Integration Patterns

### CI/CD Pipeline Integration

**GitHub Actions Integration**

```yaml
# .github/workflows/text-diff-analysis.yml
name: Text Diff Analysis
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  analyze-changes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Extract Text Changes
        id: extract
        run: |
          git diff origin/main HEAD -- '*.md' '*.txt' '*.rst' > changes.diff

      - name: Analyze with Toolspace Text Diff
        uses: toolspace/text-diff-action@v1
        with:
          diff-file: changes.diff
          api-key: ${{ secrets.TOOLSPACE_API_KEY }}
          output-format: "github-comment"

      - name: Comment PR
        uses: actions/github-script@v6
        with:
          script: |
            const analysis = require('./diff-analysis.json');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: analysis.comment
            });
```

### Automated Documentation Systems

**Documentation Pipeline Integration**

```dart
class DocumentationIntegration {
  static void analyzeDocumentationChanges(
    String originalDocs,
    String updatedDocs,
  ) {
    // Compare documentation versions
    final diffResult = TextDiffEngine.compare(originalDocs, updatedDocs);

    // Generate documentation change report
    final changeReport = DocumentationChangeAnalyzer.analyze(
      diffResult: diffResult,
      analysisType: 'documentation_update',
    );

    // Export to documentation system
    final exportData = SharedData(
      type: SharedDataType.report,
      content: changeReport.toMarkdown(),
      metadata: {
        'report_type': 'documentation_analysis',
        'change_severity': changeReport.severity,
        'affected_sections': changeReport.affectedSections.join(','),
      },
    );

    ShareEnvelope.share(exportData);
  }
}
```

## Security and Compliance Integration

### Data Privacy Framework

**Privacy-Preserving Comparison**

```dart
class PrivacyPreservingTextDiff {
  static DiffResult compareWithPrivacy(
    String text1,
    String text2, {
    required List<String> sensitivePatterns,
    bool enableRedaction = true,
  }) {
    // Redact sensitive information before comparison
    final redactedText1 = _redactSensitiveData(text1, sensitivePatterns);
    final redactedText2 = _redactSensitiveData(text2, sensitivePatterns);

    // Perform comparison on redacted text
    final diffResult = TextDiffEngine.compare(redactedText1, redactedText2);

    // Log privacy compliance
    PrivacyLogger.log(PrivacyEvent(
      operation: 'text_comparison',
      dataTypes: ['text_content'],
      redactionApplied: enableRedaction,
      sensitivePatternCount: sensitivePatterns.length,
    ));

    return diffResult;
  }

  static String _redactSensitiveData(String text, List<String> patterns) {
    String redacted = text;
    for (final pattern in patterns) {
      redacted = redacted.replaceAll(RegExp(pattern), '[REDACTED]');
    }
    return redacted;
  }
}
```

### Audit Trail Integration

**Comprehensive Audit Logging**

```dart
class TextDiffAuditLogger {
  static void logComparison(
    DiffResult result,
    Map<String, dynamic> context,
  ) {
    final auditEntry = AuditEntry(
      operation: 'text_comparison',
      timestamp: DateTime.now(),
      userId: context['user_id'],
      sessionId: context['session_id'],
      metadata: {
        'text1_length': context['text1_length'],
        'text2_length': context['text2_length'],
        'similarity_score': result.stats.similarity,
        'processing_time': result.processingTime,
        'comparison_mode': context['mode'],
        'source_tool': context['source'],
      },
      complianceFlags: {
        'gdpr_compliant': true,
        'hipaa_compliant': _checkHipaaCompliance(context),
        'pci_compliant': _checkPciCompliance(context),
      },
    );

    AuditTrailService.record(auditEntry);
  }
}
```

This comprehensive integration guide establishes Text Diff as a central hub in professional text analysis workflows, providing seamless connectivity with development tools, content management systems, analytics platforms, and enterprise infrastructure while maintaining security and compliance standards.

---

**Integration Architect**: Robert Kim, Senior Integration Engineer  
**API Lead**: Sarah Chen, Senior Backend Engineer  
**Last Updated**: October 11, 2025  
**Integration Version**: 2.1.0
