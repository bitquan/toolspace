import 'package:flutter/material.dart';
import 'logic/case_convert.dart';
import 'logic/clean_text.dart';
import 'logic/json_tools.dart';
import 'logic/slugify.dart';
import 'logic/counters.dart';
import 'logic/uuid_gen.dart';
import '../../core/ui/clipboard_btn.dart';

class TextToolsScreen extends StatefulWidget {
  const TextToolsScreen({super.key});

  @override
  State<TextToolsScreen> createState() => _TextToolsScreenState();
}

class _TextToolsScreenState extends State<TextToolsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Tools'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.text_fields), text: 'Case Convert'),
            Tab(icon: Icon(Icons.cleaning_services), text: 'Clean Text'),
            Tab(icon: Icon(Icons.code), text: 'JSON Tools'),
            Tab(icon: Icon(Icons.link), text: 'Slugify'),
            Tab(icon: Icon(Icons.analytics), text: 'Counters'),
            Tab(icon: Icon(Icons.fingerprint), text: 'UUID Gen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCaseConvertTab(),
          _buildCleanTextTab(),
          _buildJsonToolsTab(),
          _buildSlugifyTab(),
          _buildCountersTab(),
          _buildUuidTab(),
        ],
      ),
    );
  }

  Widget _buildCaseConvertTab() {
    return _buildTwoColumnLayout(
      title: 'Case Conversion',
      inputHint: 'Enter text to convert case...',
      actions: [
        _buildActionButton('UPPERCASE', () {
          _outputController.text =
              CaseConverter.toUpperCase(_inputController.text);
        }),
        _buildActionButton('lowercase', () {
          _outputController.text =
              CaseConverter.toLowerCase(_inputController.text);
        }),
        _buildActionButton('Title Case', () {
          _outputController.text =
              CaseConverter.toTitleCase(_inputController.text);
        }),
        _buildActionButton('Sentence case', () {
          _outputController.text =
              CaseConverter.toSentenceCase(_inputController.text);
        }),
        _buildActionButton('camelCase', () {
          _outputController.text =
              CaseConverter.toCamelCase(_inputController.text);
        }),
        _buildActionButton('PascalCase', () {
          _outputController.text =
              CaseConverter.toPascalCase(_inputController.text);
        }),
        _buildActionButton('snake_case', () {
          _outputController.text =
              CaseConverter.toSnakeCase(_inputController.text);
        }),
        _buildActionButton('kebab-case', () {
          _outputController.text =
              CaseConverter.toKebabCase(_inputController.text);
        }),
      ],
    );
  }

  Widget _buildCleanTextTab() {
    return _buildTwoColumnLayout(
      title: 'Text Cleaning',
      inputHint: 'Enter text to clean...',
      actions: [
        _buildActionButton('Collapse Spaces', () {
          _outputController.text =
              TextCleaner.collapseSpaces(_inputController.text);
        }),
        _buildActionButton('Clean Whitespace', () {
          _outputController.text =
              TextCleaner.cleanWhitespace(_inputController.text);
        }),
        _buildActionButton('Strip Punctuation', () {
          _outputController.text =
              TextCleaner.stripPunctuation(_inputController.text);
        }),
        _buildActionButton('Normalize Unicode', () {
          _outputController.text =
              TextCleaner.normalizeUnicode(_inputController.text);
        }),
        _buildActionButton('Strip Numbers', () {
          _outputController.text =
              TextCleaner.stripNumbers(_inputController.text);
        }),
        _buildActionButton('Clean All', () {
          _outputController.text = TextCleaner.cleanAll(_inputController.text);
        }),
      ],
    );
  }

  Widget _buildJsonToolsTab() {
    return _buildTwoColumnLayout(
      title: 'JSON Tools',
      inputHint: 'Enter JSON text...',
      actions: [
        _buildActionButton('Validate', () {
          final result = JsonTools.validateJson(_inputController.text);
          if (result.isValid) {
            _outputController.text = 'Valid JSON ✓';
          } else {
            _outputController.text = 'Invalid JSON ✗\n${result.error}';
          }
        }),
        _buildActionButton('Pretty Print (2 spaces)', () {
          _outputController.text =
              JsonTools.prettyPrint(_inputController.text, indent: 2);
        }),
        _buildActionButton('Pretty Print (4 spaces)', () {
          _outputController.text =
              JsonTools.prettyPrint(_inputController.text, indent: 4);
        }),
        _buildActionButton('Minify', () {
          _outputController.text = JsonTools.minify(_inputController.text);
        }),
        _buildActionButton('Sort Keys', () {
          _outputController.text = JsonTools.sortKeys(_inputController.text);
        }),
      ],
    );
  }

  Widget _buildSlugifyTab() {
    return _buildTwoColumnLayout(
      title: 'URL Slugify',
      inputHint: 'Enter text to convert to URL slug...',
      actions: [
        _buildActionButton('Create Slug', () {
          _outputController.text = Slugify.toSlug(_inputController.text);
        }),
        _buildActionButton('Slug (Keep Accents)', () {
          _outputController.text =
              Slugify.custom(_inputController.text, removeAccents: false);
        }),
        _buildActionButton('Slug (Custom Separator)', () {
          _outputController.text =
              Slugify.toSlug(_inputController.text, separator: '_');
        }),
        _buildActionButton('Validate Slug', () {
          final isValid = Slugify.isValidSlug(_inputController.text);
          _outputController.text = isValid ? 'Valid slug ✓' : 'Invalid slug ✗';
        }),
      ],
    );
  }

  Widget _buildCountersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics),
                      const SizedBox(width: 8),
                      Text(
                        'Text Analysis',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Enter text to analyze...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 8,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  _buildAnalysisResults(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults() {
    if (_inputController.text.isEmpty) {
      return const Text('Enter text above to see analysis...');
    }

    final result = TextCounters.analyze(_inputController.text);

    return Column(
      children: [
        _buildStatRow('Characters', result.characters.toString()),
        _buildStatRow(
            'Characters (no spaces)', result.charactersNoSpaces.toString()),
        _buildStatRow('Words', result.words.toString()),
        _buildStatRow('Sentences', result.sentences.toString()),
        _buildStatRow('Paragraphs', result.paragraphs.toString()),
        _buildStatRow('Lines', result.lines.toString()),
        _buildStatRow('Avg words per sentence',
            result.avgWordsPerSentence.toStringAsFixed(1)),
        _buildStatRow(
            'Avg chars per word', result.avgCharsPerWord.toStringAsFixed(1)),
        if (result.wordFrequency.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Top Words',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...result.wordFrequency.entries
              .take(5)
              .map((e) => _buildStatRow(e.key, e.value.toString())),
        ],
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildUuidTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fingerprint),
                      const SizedBox(width: 8),
                      Text(
                        'UUID Generator',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildUuidButton('Standard UUID v4', () {
                        _outputController.text = UuidGenerator.generateV4();
                      }),
                      _buildUuidButton('Simple (no dashes)', () {
                        _outputController.text = UuidGenerator.generateSimple();
                      }),
                      _buildUuidButton('Uppercase', () {
                        _outputController.text =
                            UuidGenerator.generateUppercase();
                      }),
                      _buildUuidButton('Short (8 chars)', () {
                        _outputController.text = UuidGenerator.generateShort();
                      }),
                      _buildUuidButton('Generate 5', () {
                        final uuids = UuidGenerator.generateMultiple(5);
                        _outputController.text = uuids.join('\n');
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _outputController,
                    decoration: InputDecoration(
                      hintText: 'Generated UUIDs will appear here...',
                      border: const OutlineInputBorder(),
                      suffixIcon: ClipboardButton(
                        text: _outputController.text,
                        compact: true,
                      ),
                    ),
                    maxLines: 10,
                    readOnly: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnLayout({
    required String title,
    required String inputHint,
    required List<Widget> actions,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Input',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _inputController,
                              decoration: InputDecoration(
                                hintText: inputHint,
                                border: const OutlineInputBorder(),
                              ),
                              maxLines: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Actions column
                      SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Actions',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ...actions,
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Output column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Output',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _outputController,
                              decoration: InputDecoration(
                                hintText: 'Results will appear here...',
                                border: const OutlineInputBorder(),
                                suffixIcon: ClipboardButton(
                                  text: _outputController.text,
                                  compact: true,
                                ),
                              ),
                              maxLines: 8,
                              readOnly: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildUuidButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
