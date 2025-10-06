import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logic/word_diff_engine.dart';

/// Text Diff - Compare texts with highlighted differences (simplified version)
class TextDiffScreen extends StatefulWidget {
  const TextDiffScreen({super.key});

  @override
  State<TextDiffScreen> createState() => _TextDiffScreenState();
}

class _TextDiffScreenState extends State<TextDiffScreen>
    with TickerProviderStateMixin {
  final TextEditingController _text1Controller = TextEditingController();
  final TextEditingController _text2Controller = TextEditingController();
  final TextEditingController _baseTextController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  List<DiffLine> _diffLines = [];
  List<WordDiff> _wordDiffs = [];
  ThreeWayMergeResult? _mergeResult;
  bool _isComparing = false;
  DiffStats _stats = DiffStats.empty();
  WordDiffStats _wordStats = const WordDiffStats(
    additions: 0,
    deletions: 0,
    unchanged: 0,
    changes: 0,
  );

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _text1Controller.addListener(_onTextChanged);
    _text2Controller.addListener(_onTextChanged);
    _baseTextController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _text1Controller.dispose();
    _text2Controller.dispose();
    _baseTextController.dispose();
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Debounce comparison for performance
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _compareTexts();
      }
    });
  }

  void _compareTexts() {
    if (_text1Controller.text.isEmpty && _text2Controller.text.isEmpty) {
      setState(() {
        _diffLines = [];
        _wordDiffs = [];
        _mergeResult = null;
        _stats = DiffStats.empty();
        _wordStats = const WordDiffStats(
          additions: 0,
          deletions: 0,
          unchanged: 0,
          changes: 0,
        );
      });
      return;
    }

    setState(() {
      _isComparing = true;
    });

    // Simple line-by-line comparison
    final lines1 = _text1Controller.text.split('\n');
    final lines2 = _text2Controller.text.split('\n');

    final List<DiffLine> diffLines = [];
    final maxLines =
        lines1.length > lines2.length ? lines1.length : lines2.length;

    int additions = 0;
    int deletions = 0;
    int unchanged = 0;

    for (int i = 0; i < maxLines; i++) {
      final line1 = i < lines1.length ? lines1[i] : '';
      final line2 = i < lines2.length ? lines2[i] : '';

      if (line1 == line2) {
        if (line1.isNotEmpty) {
          diffLines.add(DiffLine(text: line1, type: DiffType.equal));
          unchanged++;
        }
      } else {
        if (line1.isNotEmpty) {
          diffLines.add(DiffLine(text: line1, type: DiffType.delete));
          deletions++;
        }
        if (line2.isNotEmpty) {
          diffLines.add(DiffLine(text: line2, type: DiffType.insert));
          additions++;
        }
      }
    }

    final stats = DiffStats(
      additions: additions,
      deletions: deletions,
      unchanged: unchanged,
    );

    // Compute word-level diff
    final wordDiffs = WordDiffEngine.computeWordDiff(
      _text1Controller.text,
      _text2Controller.text,
    );
    final wordStats = WordDiffEngine.getWordDiffStats(wordDiffs);

    // Compute three-way merge if base text is provided
    ThreeWayMergeResult? mergeResult;
    if (_baseTextController.text.isNotEmpty) {
      mergeResult = WordDiffEngine.computeThreeWayMerge(
        _baseTextController.text,
        _text1Controller.text,
        _text2Controller.text,
      );
    }

    setState(() {
      _diffLines = diffLines;
      _stats = stats;
      _wordDiffs = wordDiffs;
      _wordStats = wordStats;
      _mergeResult = mergeResult;
      _isComparing = false;
    });

    _fadeController.reset();
    _fadeController.forward();
  }

  void _swapTexts() {
    final temp = _text1Controller.text;
    _text1Controller.text = _text2Controller.text;
    _text2Controller.text = temp;
  }

  void _clearAll() {
    _text1Controller.clear();
    _text2Controller.clear();
    _baseTextController.clear();
    setState(() {
      _diffLines = [];
      _wordDiffs = [];
      _mergeResult = null;
      _stats = DiffStats.empty();
      _wordStats = const WordDiffStats(
        additions: 0,
        deletions: 0,
        unchanged: 0,
        changes: 0,
      );
    });
  }

  void _copyDiff() {
    final diffText = _diffLines.map((diff) {
      switch (diff.type) {
        case DiffType.insert:
          return '+ ${diff.text}';
        case DiffType.delete:
          return '- ${diff.text}';
        case DiffType.equal:
          return '  ${diff.text}';
      }
    }).join('\n');

    Clipboard.setData(ClipboardData(text: diffText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Diff copied to clipboard!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.compare_arrows,
                color: Color(0xFF1976D2),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Text Diff v2'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _swapTexts,
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Swap Texts',
          ),
          IconButton(
            onPressed: _clearAll,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All',
          ),
          if (_diffLines.isNotEmpty || _wordDiffs.isNotEmpty || _mergeResult != null)
            IconButton(
              onPressed: _copyDiff,
              icon: const Icon(Icons.copy),
              tooltip: 'Copy Diff',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.view_list), text: 'Line Diff'),
            Tab(icon: Icon(Icons.text_fields), text: 'Word Diff'),
            Tab(icon: Icon(Icons.merge), text: 'Three-Way Merge'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLineDiffTab(theme),
          _buildWordDiffTab(theme),
          _buildThreeWayMergeTab(theme),
        ],
      ),
    );
  }

  Widget _buildLineDiffTab(ThemeData theme) {
    return Column(
        children: [
          // Stats panel
          if (_stats.totalChanges > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatChip(
                    label: 'Additions',
                    value: _stats.additions.toString(),
                    color: Colors.green,
                    icon: Icons.add,
                  ),
                  _StatChip(
                    label: 'Deletions',
                    value: _stats.deletions.toString(),
                    color: Colors.red,
                    icon: Icons.remove,
                  ),
                  _StatChip(
                    label: 'Similarity',
                    value: '${_stats.similarity.toStringAsFixed(1)}%',
                    color: theme.colorScheme.primary,
                    icon: Icons.analytics,
                  ),
                ],
              ),
            ),

          // Input panels
          Expanded(
            flex: 1,
            child: Row(
              children: [
                // Text 1
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant
                                .withOpacity(0.3),
                          ),
                          child: Text(
                            'Original Text',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              controller: _text1Controller,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Paste original text here...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Text 2
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        child: Text(
                          'Modified Text',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _text2Controller,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Paste modified text here...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Diff results
          if (_diffLines.isNotEmpty)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primaryContainer.withOpacity(0.5),
                      ),
                      child: Text(
                        'Differences (Line by Line)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _isComparing
                              ? const Center(child: CircularProgressIndicator())
                              : _buildDiffView(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDiffView() {
    return ListView.builder(
      itemCount: _diffLines.length,
      itemBuilder: (context, index) {
        final diff = _diffLines[index];
        Color? backgroundColor;
        Color? textColor = Theme.of(context).colorScheme.onSurface;
        String prefix = '  ';

        switch (diff.type) {
          case DiffType.insert:
            backgroundColor = Colors.green.withOpacity(0.2);
            textColor = Colors.green.shade700;
            prefix = '+ ';
            break;
          case DiffType.delete:
            backgroundColor = Colors.red.withOpacity(0.2);
            textColor = Colors.red.shade700;
            prefix = '- ';
            break;
          case DiffType.equal:
            prefix = '  ';
            break;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$prefix${diff.text}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: textColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWordDiffTab(ThemeData theme) {
    return Column(
      children: [
        // Word Stats panel
        if (_wordStats.totalChanges > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatChip(
                  label: 'Word Additions',
                  value: _wordStats.additions.toString(),
                  color: Colors.green,
                  icon: Icons.add,
                ),
                _StatChip(
                  label: 'Word Deletions',
                  value: _wordStats.deletions.toString(),
                  color: Colors.red,
                  icon: Icons.remove,
                ),
                _StatChip(
                  label: 'Similarity',
                  value: '${_wordStats.similarity.toStringAsFixed(1)}%',
                  color: theme.colorScheme.primary,
                  icon: Icons.analytics,
                ),
              ],
            ),
          ),

        // Input panels
        Expanded(
          flex: 1,
          child: Row(
            children: [
              // Text 1
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant
                              .withOpacity(0.3),
                        ),
                        child: Text(
                          'Original Text',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _text1Controller,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Paste original text here...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Text 2
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      ),
                      child: Text(
                        'Modified Text',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _text2Controller,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Paste modified text here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Word Diff results
        if (_wordDiffs.isNotEmpty)
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primaryContainer.withOpacity(0.5),
                    ),
                    child: Text(
                      'Differences (Word by Word)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildWordDiffView(theme),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWordDiffView(ThemeData theme) {
    return SingleChildScrollView(
      child: Wrap(
        children: _wordDiffs.map((diff) {
          Color? backgroundColor;
          Color? textColor = theme.colorScheme.onSurface;

          switch (diff.type) {
            case WordDiffType.insert:
              backgroundColor = Colors.green.withOpacity(0.3);
              textColor = Colors.green.shade900;
              break;
            case WordDiffType.delete:
              backgroundColor = Colors.red.withOpacity(0.3);
              textColor = Colors.red.shade900;
              break;
            case WordDiffType.equal:
              backgroundColor = Colors.transparent;
              break;
            case WordDiffType.changed:
              backgroundColor = Colors.orange.withOpacity(0.3);
              textColor = Colors.orange.shade900;
              break;
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              diff.text,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: textColor,
                fontWeight: diff.type != WordDiffType.equal
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThreeWayMergeTab(ThemeData theme) {
    return Column(
      children: [
        // Info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Three-way merge compares a base version with two modified versions and highlights conflicts.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),

        // Input panels - 3 columns
        Expanded(
          flex: 2,
          child: Row(
            children: [
              // Base text
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant
                              .withOpacity(0.3),
                        ),
                        child: Text(
                          'Base Version',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: _baseTextController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Base version...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Left version
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                        ),
                        child: Text(
                          'Left Version',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: _text1Controller,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Left version...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right version
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                      ),
                      child: Text(
                        'Right Version',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: _text2Controller,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Right version...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Merge result
        if (_mergeResult != null)
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _mergeResult!.hasConflicts
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _mergeResult!.hasConflicts
                              ? Icons.warning_amber
                              : Icons.check_circle,
                          color: _mergeResult!.hasConflicts
                              ? Colors.orange.shade700
                              : Colors.green.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _mergeResult!.hasConflicts
                              ? 'Merge Result (${_mergeResult!.conflicts.length} Conflicts)'
                              : 'Merge Result (No Conflicts)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _mergeResult!.hasConflicts
                                ? Colors.orange.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _mergeResult!.mergedText,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DiffLine {
  final String text;
  final DiffType type;

  const DiffLine({
    required this.text,
    required this.type,
  });
}

enum DiffType { insert, delete, equal }

class DiffStats {
  final int additions;
  final int deletions;
  final int unchanged;

  const DiffStats({
    required this.additions,
    required this.deletions,
    required this.unchanged,
  });

  factory DiffStats.empty() => const DiffStats(
        additions: 0,
        deletions: 0,
        unchanged: 0,
      );

  int get totalChanges => additions + deletions;
  int get totalLines => additions + deletions + unchanged;

  double get similarity {
    if (totalLines == 0) return 100.0;
    return (unchanged / totalLines) * 100;
  }
}
