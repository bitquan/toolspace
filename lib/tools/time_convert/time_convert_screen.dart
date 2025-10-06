import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/shared_data_service.dart';
import '../../core/ui/import_data_button.dart';
import '../../core/ui/share_data_button.dart';
import 'logic/timestamp_converter.dart';

/// Time Convert - Convert between timestamps, natural language, and formats
class TimeConvertScreen extends StatefulWidget {
  const TimeConvertScreen({super.key});

  @override
  State<TimeConvertScreen> createState() => _TimeConvertScreenState();
}

class _TimeConvertScreenState extends State<TimeConvertScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  DateTime? _parsedDateTime;
  String _selectedTimezone = 'UTC';
  TimeFormat _selectedFormat = TimeFormat.iso8601;
  String? _errorMessage;
  String _result = '';

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _inputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final input = _inputController.text.trim();
    
    if (input.isEmpty) {
      setState(() {
        _parsedDateTime = null;
        _errorMessage = null;
        _result = '';
      });
      return;
    }

    final parsed = TimestampConverter.parseNaturalLanguage(
      input,
      timezone: _selectedTimezone,
    );

    setState(() {
      if (parsed != null) {
        _parsedDateTime = parsed;
        _errorMessage = null;
        _updateResult();
        _bounceController.forward().then((_) => _bounceController.reverse());
      } else {
        _parsedDateTime = null;
        _errorMessage = 'Unable to parse input. Try "now", "yesterday", "5 minutes ago", ISO date, or Unix timestamp.';
        _result = '';
      }
    });
  }

  void _updateResult() {
    if (_parsedDateTime == null) {
      setState(() => _result = '');
      return;
    }

    setState(() {
      _result = TimestampConverter.formatCustom(_parsedDateTime!, _selectedFormat);
    });
  }

  void _setNow() {
    _inputController.text = 'now';
  }

  void _copyResult() {
    if (_result.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _result));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Result copied to clipboard!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearInput() {
    _inputController.clear();
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
                color: const Color(0xFF9C27B0).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.schedule,
                color: Color(0xFF9C27B0),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Time Converter'),
          ],
        ),
        actions: [
          if (_result.isNotEmpty)
            ShareDataButton(
              data: _result,
              type: SharedDataType.text,
              sourceTool: 'Time Converter',
              compact: true,
            ),
          IconButton(
            onPressed: _clearInput,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear',
          ),
          if (_result.isNotEmpty)
            IconButton(
              onPressed: _copyResult,
              icon: const Icon(Icons.copy),
              tooltip: 'Copy Result',
            ),
        ],
      ),
      body: Row(
        children: [
          // Input panel
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Input',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter a timestamp, date, or natural language',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input field
                    TextField(
                      controller: _inputController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'now, yesterday, 5 minutes ago, 1234567890, 2024-01-01...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        errorText: _errorMessage,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _setNow,
                            icon: const Icon(Icons.access_time),
                            label: const Text('Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF9C27B0).withOpacity(0.1),
                              foregroundColor: const Color(0xFF9C27B0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ImportDataButton(
                            acceptedTypes: const [SharedDataType.text],
                            onImport: (data, type, source) {
                              setState(() {
                                _inputController.text = data;
                              });
                            },
                            label: 'Import',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick templates
                    Text(
                      'Quick Examples',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickTemplate('now', theme),
                        _buildQuickTemplate('yesterday', theme),
                        _buildQuickTemplate('5 minutes ago', theme),
                        _buildQuickTemplate('in 2 hours', theme),
                        _buildQuickTemplate('3 days ago', theme),
                        _buildQuickTemplate('1 week ago', theme),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Timezone selector
                    Text(
                      'Timezone',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedTimezone,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: TimestampConverter.commonTimezones
                          .map((tz) => DropdownMenuItem(
                                value: tz,
                                child: Text(tz),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedTimezone = value;
                          });
                          _onInputChanged();
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Format selector
                    Text(
                      'Output Format',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TimeFormat.values.map((format) {
                        final isSelected = _selectedFormat == format;
                        return FilterChip(
                          label: Text(_getFormatLabel(format)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFormat = format;
                              _updateResult();
                            });
                          },
                          selectedColor:
                              const Color(0xFF9C27B0).withOpacity(0.2),
                          checkmarkColor: const Color(0xFF9C27B0),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Result panel
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Result',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_parsedDateTime == null && _errorMessage == null)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Enter a time to convert',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_parsedDateTime != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main result
                            AnimatedBuilder(
                              animation: _bounceAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _bounceAnimation.value,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF9C27B0)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF9C27B0)
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: SelectableText(
                                      _result,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // Additional formats
                            Text(
                              'Other Formats',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),

                            ...TimeFormat.values
                                .where((f) => f != _selectedFormat)
                                .map((format) {
                              final formatted = TimestampConverter.formatCustom(
                                _parsedDateTime!,
                                format,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildFormatItem(
                                  _getFormatLabel(format),
                                  formatted,
                                  theme,
                                ),
                              );
                            }),

                            const SizedBox(height: 12),

                            // Relative time
                            _buildFormatItem(
                              'Relative Time',
                              TimestampConverter.getRelativeTime(
                                  _parsedDateTime!),
                              theme,
                            ),
                          ],
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

  Widget _buildQuickTemplate(String template, ThemeData theme) {
    return ActionChip(
      label: Text(template),
      onPressed: () {
        _inputController.text = template;
      },
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
    );
  }

  Widget _buildFormatItem(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _getFormatLabel(TimeFormat format) {
    switch (format) {
      case TimeFormat.iso8601:
        return 'ISO 8601';
      case TimeFormat.rfc3339:
        return 'RFC 3339';
      case TimeFormat.unixSeconds:
        return 'Unix (seconds)';
      case TimeFormat.unixMilliseconds:
        return 'Unix (ms)';
      case TimeFormat.humanReadable:
        return 'Human Readable';
      case TimeFormat.dateOnly:
        return 'Date Only';
      case TimeFormat.timeOnly:
        return 'Time Only';
    }
  }
}
