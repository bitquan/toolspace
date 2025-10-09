import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logic/regex_engine.dart';
import 'logic/regex_presets.dart';

/// Regex Tester - Test regex patterns with live match highlighting and capture groups
class RegexTesterScreen extends StatefulWidget {
  const RegexTesterScreen({super.key});

  @override
  State<RegexTesterScreen> createState() => _RegexTesterScreenState();
}

class _RegexTesterScreenState extends State<RegexTesterScreen>
    with TickerProviderStateMixin {
  final TextEditingController _patternController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  RegexTestResult? _result;
  bool _caseSensitive = true;
  bool _multiline = false;
  bool _dotAll = false;
  bool _unicode = true;
  bool _showPresets = false;

  @override
  void initState() {
    super.initState();
    _patternController.addListener(_testRegex);
    _textController.addListener(_testRegex);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _patternController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _testRegex() {
    final pattern = _patternController.text;
    final text = _textController.text;

    if (pattern.isEmpty || text.isEmpty) {
      setState(() {
        _result = null;
      });
      return;
    }

    setState(() {
      _result = RegexEngine.test(
        pattern,
        text,
        caseSensitive: _caseSensitive,
        multiline: _multiline,
        dotAll: _dotAll,
        unicode: _unicode,
      );

      if (_result!.isValid && _result!.hasMatches) {
        _pulseController.forward(from: 0.0);
      }
    });
  }

  void _applyPreset(RegexPreset preset) {
    _patternController.text = preset.pattern;
    if (_textController.text.isEmpty) {
      _textController.text = preset.example;
    }
    setState(() {
      _showPresets = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Regex Tester'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(_showPresets ? Icons.close : Icons.library_books),
            onPressed: () {
              setState(() {
                _showPresets = !_showPresets;
              });
            },
            tooltip: _showPresets ? 'Close Presets' : 'Show Presets',
          ),
        ],
      ),
      body: Row(
        children: [
          // Main content
          Expanded(
            child: Column(
              children: [
                // Header with status
                _buildHeader(theme),

                // Pattern input and flags
                _buildPatternSection(theme),

                // Test text area and results
                Expanded(
                  child: _buildTestSection(theme),
                ),
              ],
            ),
          ),

          // Preset library sidebar
          if (_showPresets)
            Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: _buildPresetsPanel(theme),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _result?.isValid == true && _result?.hasMatches == true
                    ? _pulseAnimation.value
                    : 1.0,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor(theme),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getStatusIcon(),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_result != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getStatusMessage(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Copy pattern button
          if (_patternController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: _patternController.text),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pattern copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Copy pattern',
            ),
        ],
      ),
    );
  }

  Widget _buildPatternSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pattern input
          TextField(
            controller: _patternController,
            decoration: InputDecoration(
              labelText: 'Regex Pattern',
              hintText: r'e.g., \b\w+@\w+\.\w+\b',
              border: const OutlineInputBorder(),
              errorText: _result?.hasError == true ? _result!.error : null,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _patternController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _patternController.clear();
                      },
                    )
                  : null,
            ),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          // Flags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFlagChip(
                theme,
                'Case sensitive',
                _caseSensitive,
                (value) => setState(() {
                  _caseSensitive = value;
                  _testRegex();
                }),
              ),
              _buildFlagChip(
                theme,
                'Multiline',
                _multiline,
                (value) => setState(() {
                  _multiline = value;
                  _testRegex();
                }),
              ),
              _buildFlagChip(
                theme,
                'Dot all',
                _dotAll,
                (value) => setState(() {
                  _dotAll = value;
                  _testRegex();
                }),
              ),
              _buildFlagChip(
                theme,
                'Unicode',
                _unicode,
                (value) => setState(() {
                  _unicode = value;
                  _testRegex();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlagChip(
    ThemeData theme,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildTestSection(ThemeData theme) {
    return Row(
      children: [
        // Test text input
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Test Text',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter text to test against your pattern...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Results panel
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Matches & Groups',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: _buildResultsPanel(theme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsPanel(ThemeData theme) {
    if (_result == null || _textController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Enter a pattern and text to see matches',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_result!.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Invalid Pattern',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _result!.error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (!_result!.hasMatches) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No matches found',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Highlighted text
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.highlight,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Highlighted Matches',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildHighlightedText(theme),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Match details
        ...List.generate(_result!.matches.length, (index) {
          final match = _result!.matches[index];
          return Card(
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                match.fullMatch,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('Position: ${match.start}-${match.end}'),
              children: [
                if (match.hasGroups) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Capture Groups',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...match.groups.map((group) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          theme.colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      group.displayName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme
                                            .colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      group.value,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHighlightedText(ThemeData theme) {
    final text = _textController.text;
    final matches = _result!.matches;

    if (matches.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      );
    }

    // Build spans with highlighting
    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
          ),
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: match.fullMatch,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          backgroundColor: theme.colorScheme.primaryContainer,
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ));

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      ));
    }

    return SelectableText.rich(TextSpan(children: spans));
  }

  Widget _buildPresetsPanel(ThemeData theme) {
    final categories = RegexPresets.getAllCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.library_books,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Pattern Library',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ExpansionTile(
                leading: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  category.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: category.presets.map((preset) {
                  return ListTile(
                    dense: true,
                    title: Text(preset.name),
                    subtitle: Text(
                      preset.description,
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () => _applyPreset(preset),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ThemeData theme) {
    if (_result == null) {
      return theme.colorScheme.outline;
    } else if (_result!.hasError) {
      return theme.colorScheme.error;
    } else if (_result!.hasMatches) {
      return Colors.green;
    } else {
      return theme.colorScheme.primary;
    }
  }

  IconData _getStatusIcon() {
    if (_result == null) {
      return Icons.circle;
    } else if (_result!.hasError) {
      return Icons.error;
    } else if (_result!.hasMatches) {
      return Icons.check_circle;
    } else {
      return Icons.info;
    }
  }

  String _getStatusTitle() {
    if (_result == null) {
      return 'Ready';
    } else if (_result!.hasError) {
      return 'Error';
    } else if (_result!.hasMatches) {
      return 'Success';
    } else {
      return 'No Matches';
    }
  }

  String _getStatusMessage() {
    if (_result == null) {
      return 'Enter a pattern to start testing';
    } else if (_result!.hasError) {
      return 'Fix the pattern syntax';
    } else if (_result!.hasMatches) {
      final groupCount = _result!.matches.expand((m) => m.groups).length;
      return '${_result!.matchCount} match(es) found${groupCount > 0 ? ' with $groupCount group(s)' : ''}';
    } else {
      return 'Pattern is valid but no matches in text';
    }
  }
}
