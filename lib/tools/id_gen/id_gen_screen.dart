import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../text_tools/logic/uuid_gen.dart';
import '../text_tools/logic/nanoid_gen.dart';

/// ID Generator - Generate UUIDs and NanoIDs with batch support
class IdGenScreen extends StatefulWidget {
  const IdGenScreen({super.key});

  @override
  State<IdGenScreen> createState() => _IdGenScreenState();
}

class _IdGenScreenState extends State<IdGenScreen>
    with TickerProviderStateMixin {
  IdType _selectedType = IdType.uuidV4;
  int _batchCount = 1;
  int _nanoidSize = 21;
  String _customAlphabet = NanoidGenerator.defaultAlphabet;
  AlphabetPreset _alphabetPreset = AlphabetPreset.urlSafe;

  final List<String> _generatedIds = [];
  final TextEditingController _customAlphabetController =
      TextEditingController();

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _customAlphabetController.text = _customAlphabet;
    _customAlphabetController.addListener(_onAlphabetChanged);

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _customAlphabetController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onAlphabetChanged() {
    if (_alphabetPreset == AlphabetPreset.custom) {
      setState(() {
        _customAlphabet = _customAlphabetController.text;
      });
    }
  }

  void _generateIds() {
    setState(() {
      _generatedIds.clear();
    });

    try {
      List<String> newIds;

      switch (_selectedType) {
        case IdType.uuidV4:
          newIds =
              List.generate(_batchCount, (_) => UuidGenerator.generateV4());
          break;
        case IdType.uuidV7:
          newIds =
              List.generate(_batchCount, (_) => UuidGenerator.generateV7());
          break;
        case IdType.nanoid:
          newIds = NanoidGenerator.generateMultiple(
            _batchCount,
            size: _nanoidSize,
            alphabet: _customAlphabet,
          );
          break;
      }

      setState(() {
        _generatedIds.addAll(newIds);
      });

      _bounceController.forward().then((_) => _bounceController.reverse());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generated ${_generatedIds.length} IDs'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _copyId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('ID copied to clipboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _copyAllIds() {
    if (_generatedIds.isEmpty) return;

    final allIds = _generatedIds.join('\n');
    Clipboard.setData(ClipboardData(text: allIds));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied ${_generatedIds.length} IDs to clipboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearIds() {
    setState(() {
      _generatedIds.clear();
    });
  }

  void _applyAlphabetPreset(AlphabetPreset preset) {
    setState(() {
      _alphabetPreset = preset;
      switch (preset) {
        case AlphabetPreset.urlSafe:
          _customAlphabet = NanoidGenerator.defaultAlphabet;
          break;
        case AlphabetPreset.alphanumeric:
          _customAlphabet = NanoidGenerator.alphanumericAlphabet;
          break;
        case AlphabetPreset.numbers:
          _customAlphabet = NanoidGenerator.numbersAlphabet;
          break;
        case AlphabetPreset.lowercase:
          _customAlphabet = NanoidGenerator.lowercaseAlphabet;
          break;
        case AlphabetPreset.uppercase:
          _customAlphabet = NanoidGenerator.uppercaseAlphabet;
          break;
        case AlphabetPreset.hex:
          _customAlphabet = NanoidGenerator.hexAlphabet;
          break;
        case AlphabetPreset.custom:
          // Keep current custom alphabet
          break;
      }
      _customAlphabetController.text = _customAlphabet;
    });
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
                Icons.fingerprint,
                color: Color(0xFF9C27B0),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('ID Generator'),
          ],
        ),
        actions: [
          if (_generatedIds.isNotEmpty)
            IconButton(
              onPressed: _copyAllIds,
              icon: const Icon(Icons.copy_all),
              tooltip: 'Copy All IDs',
            ),
          if (_generatedIds.isNotEmpty)
            IconButton(
              onPressed: _clearIds,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: Row(
        children: [
          // Configuration panel
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
                    // ID Type selector
                    Text(
                      'ID Type',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: IdType.values.map((type) {
                        final isSelected = _selectedType == type;
                        return FilterChip(
                          label: Text(_getTypeLabel(type)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedType = type;
                              });
                            }
                          },
                          selectedColor:
                              const Color(0xFF9C27B0).withOpacity(0.2),
                          checkmarkColor: const Color(0xFF9C27B0),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Type description
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getTypeDescription(_selectedType),
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Batch count
                    Text(
                      'Batch Count',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _batchCount.toDouble(),
                            min: 1,
                            max: 1000,
                            divisions: 99,
                            label: _batchCount.toString(),
                            onChanged: (value) {
                              setState(() {
                                _batchCount = value.round();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 60,
                          child: Text(
                            _batchCount.toString(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF9C27B0),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // NanoID specific options
                    if (_selectedType == IdType.nanoid) ...[
                      Text(
                        'NanoID Length',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _nanoidSize.toDouble(),
                              min: 8,
                              max: 64,
                              divisions: 56,
                              label: _nanoidSize.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _nanoidSize = value.round();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 60,
                            child: Text(
                              _nanoidSize.toString(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9C27B0),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Alphabet preset
                      Text(
                        'Alphabet Preset',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AlphabetPreset.values.map((preset) {
                          final isSelected = _alphabetPreset == preset;
                          return FilterChip(
                            label: Text(_getPresetLabel(preset)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                _applyAlphabetPreset(preset);
                              }
                            },
                            selectedColor:
                                const Color(0xFF9C27B0).withOpacity(0.2),
                            checkmarkColor: const Color(0xFF9C27B0),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Custom alphabet input
                      if (_alphabetPreset == AlphabetPreset.custom) ...[
                        TextField(
                          controller: _customAlphabetController,
                          decoration: InputDecoration(
                            labelText: 'Custom Alphabet',
                            hintText: 'Enter unique characters',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            helperText: 'Characters: ${_customAlphabet.length}',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Collision probability
                      if (_customAlphabet.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Collision Probability',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                NanoidGenerator.calculateCollisionProbability(
                                  _nanoidSize,
                                  _customAlphabet.length,
                                ),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],

                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _generateIds,
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(
                            'Generate ${_batchCount > 1 ? '$_batchCount IDs' : 'ID'}'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Results panel
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Generated IDs',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_generatedIds.isNotEmpty)
                        Text(
                          '${_generatedIds.length} ${_generatedIds.length == 1 ? 'ID' : 'IDs'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),

                // IDs list
                Expanded(
                  child: _generatedIds.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fingerprint,
                                size: 64,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No IDs generated yet',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Configure options and click Generate',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : AnimatedBuilder(
                          animation: _bounceAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _bounceAnimation.value,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _generatedIds.length,
                                itemBuilder: (context, index) {
                                  final id = _generatedIds[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: const Color(0xFF9C27B0)
                                            .withOpacity(0.2),
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Color(0xFF9C27B0),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      title: SelectableText(
                                        id,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 13,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.copy, size: 20),
                                        onPressed: () => _copyId(id),
                                        tooltip: 'Copy ID',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(IdType type) {
    switch (type) {
      case IdType.uuidV4:
        return 'UUID v4';
      case IdType.uuidV7:
        return 'UUID v7';
      case IdType.nanoid:
        return 'NanoID';
    }
  }

  String _getTypeDescription(IdType type) {
    switch (type) {
      case IdType.uuidV4:
        return 'Random UUID (128-bit). Most common format, RFC 4122 compliant.';
      case IdType.uuidV7:
        return 'Timestamp-based UUID (128-bit). Sortable by creation time, RFC 9562 compliant.';
      case IdType.nanoid:
        return 'Compact URL-safe ID. Customizable size and alphabet. Smaller and faster than UUID.';
    }
  }

  String _getPresetLabel(AlphabetPreset preset) {
    switch (preset) {
      case AlphabetPreset.urlSafe:
        return 'URL-Safe';
      case AlphabetPreset.alphanumeric:
        return 'Alphanumeric';
      case AlphabetPreset.numbers:
        return 'Numbers';
      case AlphabetPreset.lowercase:
        return 'Lowercase';
      case AlphabetPreset.uppercase:
        return 'Uppercase';
      case AlphabetPreset.hex:
        return 'Hexadecimal';
      case AlphabetPreset.custom:
        return 'Custom';
    }
  }
}

enum IdType { uuidV4, uuidV7, nanoid }

enum AlphabetPreset {
  urlSafe,
  alphanumeric,
  numbers,
  lowercase,
  uppercase,
  hex,
  custom
}
