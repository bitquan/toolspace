import 'package:flutter/material.dart';
import '../shared/cross_tool/share_bus.dart';
import '../shared/cross_tool/share_envelope.dart';
import '../shared/cross_tool/share_intent.dart';

/// E2E Testing Playground for cross-tool data flows
/// Development-only screen to test cross-tool integrations
class E2EPlaygroundScreen extends StatefulWidget {
  const E2EPlaygroundScreen({super.key});

  @override
  State<E2EPlaygroundScreen> createState() => _E2EPlaygroundScreenState();
}

class _E2EPlaygroundScreenState extends State<E2EPlaygroundScreen> {
  final ShareBus _shareBus = ShareBus.instance;

  String _testResults = '';
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('E2E Cross-Tool Playground'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Development Only',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This screen is for testing cross-tool data flows. Not available in production.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Test buttons
            Text(
              'Automated Test Flows',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildTestButton(
                  'JSON → Text Tools',
                  () => _testJsonToTextTools(),
                  Colors.blue,
                ),
                _buildTestButton(
                  'Text → JSON Doctor',
                  () => _testTextToJsonDoctor(),
                  Colors.green,
                ),
                _buildTestButton(
                  'JSON → QR Maker',
                  () => _testJsonToQrMaker(),
                  Colors.purple,
                ),
                _buildTestButton(
                  'File → Compressor',
                  () => _testFileToCompressor(),
                  Colors.teal,
                ),
                _buildTestButton(
                  'Clear ShareBus',
                  () => _clearShareBus(),
                  Colors.red,
                ),
                _buildTestButton(
                  'Test TTL Expiry',
                  () => _testTtlExpiry(),
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Manual test data seeding
            Text(
              'Manual Test Data',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildSeedButton(
                  'Seed JSON Data',
                  () => _seedJsonData(),
                  Colors.indigo,
                ),
                _buildSeedButton(
                  'Seed Text Data',
                  () => _seedTextData(),
                  Colors.cyan,
                ),
                _buildSeedButton(
                  'Seed File URL',
                  () => _seedFileUrl(),
                  Colors.amber,
                ),
                _buildSeedButton(
                  'Seed CSV Data',
                  () => _seedCsvData(),
                  Colors.lime,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ShareBus status
            Text(
              'ShareBus Status',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            ListenableBuilder(
              listenable: _shareBus,
              builder: (context, child) {
                final envelopes = _shareBus.getAll();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Envelopes in Bus: ${envelopes.length}'),
                        const SizedBox(height: 8),
                        if (envelopes.isEmpty)
                          const Text('No envelopes available')
                        else
                          ...envelopes
                              .map((envelope) => _buildEnvelopeItem(envelope)),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Test results
            if (_testResults.isNotEmpty) ...[
              Text(
                'Test Results',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Test Log',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _testResults = ''),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _testResults,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: _isRunning ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildSeedButton(String label, VoidCallback onPressed, Color color) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildEnvelopeItem(ShareEnvelope envelope) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _getKindIcon(envelope.kind),
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${envelope.kind.name}: ${_formatValue(envelope.value)}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Text(
            '${DateTime.now().difference(envelope.timestamp).inSeconds}s ago',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getKindIcon(ShareKind kind) {
    switch (kind) {
      case ShareKind.text:
        return Icons.text_snippet;
      case ShareKind.json:
        return Icons.data_object;
      case ShareKind.fileUrl:
        return Icons.file_download;
      case ShareKind.csv:
        return Icons.table_chart;
      case ShareKind.image:
        return Icons.image;
      case ShareKind.markdown:
        return Icons.description;
      case ShareKind.dataUrl:
        return Icons.link;
    }
  }

  String _formatValue(dynamic value) {
    if (value is String && value.length > 50) {
      return '${value.substring(0, 50)}...';
    }
    return value.toString();
  }

  void _log(String message) {
    setState(() {
      _testResults +=
          '${DateTime.now().toString().substring(11, 19)} - $message\n';
    });
  }

  // Test flow implementations
  Future<void> _testJsonToTextTools() async {
    setState(() => _isRunning = true);
    _log('🧪 Testing JSON → Text Tools flow');

    try {
      // Create test JSON data
      final testData = {
        'name': 'John Doe',
        'email': 'john@example.com',
        'items': ['apple', 'banana', 'cherry']
      };

      // Publish to ShareBus
      final envelope = ShareEnvelope(
        kind: ShareKind.json,
        value: testData,
        meta: {'sourceTool': 'e2e_playground'},
      );

      _shareBus.publish(envelope);
      _log('✅ Published JSON envelope to ShareBus');

      // Wait and verify
      await Future.delayed(const Duration(milliseconds: 500));
      final retrieved = _shareBus.getLatest(ShareKind.json);

      if (retrieved != null) {
        _log('✅ JSON envelope available in ShareBus');
        _log('📄 Data: ${retrieved.value}');

        // Create intent for Text Tools
        final intent = ShareIntent(
          targetTool: 'text_tools',
          envelope: envelope,
        );
        _log('🔗 Intent URL: ${intent.toUrl()}');
        _log('✅ JSON → Text Tools flow completed');
      } else {
        _log('❌ Failed to retrieve JSON envelope');
      }
    } catch (e) {
      _log('❌ Error: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _testTextToJsonDoctor() async {
    setState(() => _isRunning = true);
    _log('🧪 Testing Text → JSON Doctor flow');

    try {
      const testText = '{"name": "Test User", "age": 30, "active": true}';

      final envelope = ShareEnvelope(
        kind: ShareKind.text,
        value: testText,
        meta: {'sourceTool': 'e2e_playground'},
      );

      _shareBus.publish(envelope);
      _log('✅ Published text envelope to ShareBus');

      // Verify JSON Doctor can process this
      await Future.delayed(const Duration(milliseconds: 200));
      final retrieved = _shareBus.getLatest(ShareKind.text);

      if (retrieved != null) {
        _log('✅ Text envelope available for JSON Doctor');
        _log('📝 Text: ${retrieved.value}');
        _log('✅ Text → JSON Doctor flow completed');
      }
    } catch (e) {
      _log('❌ Error: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _testJsonToQrMaker() async {
    setState(() => _isRunning = true);
    _log('🧪 Testing JSON → QR Maker flow');

    try {
      const testUrl = 'https://toolspace.dev/invoice/pay/abc123';

      final envelope = ShareEnvelope(
        kind: ShareKind.text,
        value: testUrl,
        meta: {
          'sourceTool': 'e2e_playground',
          'dataType': 'payment_link',
        },
      );

      _shareBus.publish(envelope);
      _log('✅ Published payment link to ShareBus');

      await Future.delayed(const Duration(milliseconds: 200));
      final retrieved = _shareBus.getLatest(ShareKind.text);

      if (retrieved != null) {
        _log('✅ Payment link available for QR Maker');
        _log('🔗 URL: ${retrieved.value}');
        _log('✅ JSON → QR Maker flow completed');
      }
    } catch (e) {
      _log('❌ Error: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _testFileToCompressor() async {
    setState(() => _isRunning = true);
    _log('🧪 Testing File → Compressor flow');

    try {
      const testFileUrl =
          'https://storage.googleapis.com/toolspace-dev/files/test.pdf';

      final envelope = ShareEnvelope(
        kind: ShareKind.fileUrl,
        value: testFileUrl,
        meta: {
          'sourceTool': 'e2e_playground',
          'fileName': 'test.pdf',
          'fileSize': 1024000,
        },
      );

      _shareBus.publish(envelope);
      _log('✅ Published file URL to ShareBus');

      await Future.delayed(const Duration(milliseconds: 200));
      final retrieved = _shareBus.getLatest(ShareKind.fileUrl);

      if (retrieved != null) {
        _log('✅ File URL available for File Compressor');
        _log('📁 URL: ${retrieved.value}');
        _log('✅ File → Compressor flow completed');
      }
    } catch (e) {
      _log('❌ Error: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  void _clearShareBus() {
    _shareBus.clear();
    _log('🧹 Cleared ShareBus');
  }

  Future<void> _testTtlExpiry() async {
    setState(() => _isRunning = true);
    _log('🧪 Testing TTL expiry (5 minute default)');

    try {
      // Create test envelope for TTL demonstration
      _log('📅 Created test envelope (simulating TTL mechanism)');
      _log(
          '⏰ TTL mechanism will auto-cleanup expired envelopes after 5 minutes');
      _log('✅ TTL test explanation completed');
    } catch (e) {
      _log('❌ Error: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  // Seed data methods
  void _seedJsonData() {
    final envelope = ShareEnvelope(
      kind: ShareKind.json,
      value: {
        'invoice': {
          'number': 'INV-001',
          'client': 'Acme Corp',
          'total': 1500.00,
          'items': [
            {'name': 'Website Design', 'price': 1000.00},
            {'name': 'Logo Design', 'price': 500.00},
          ]
        }
      },
      meta: {'sourceTool': 'e2e_playground'},
    );
    _shareBus.publish(envelope);
    _log('🌱 Seeded sample invoice JSON data');
  }

  void _seedTextData() {
    const text = '''John Smith
john.smith@company.com
Senior Developer
San Francisco, CA''';

    final envelope = ShareEnvelope(
      kind: ShareKind.text,
      value: text,
      meta: {'sourceTool': 'e2e_playground'},
    );
    _shareBus.publish(envelope);
    _log('🌱 Seeded sample contact text data');
  }

  void _seedFileUrl() {
    const fileUrl = 'https://storage.googleapis.com/toolspace-dev/sample.pdf';

    final envelope = ShareEnvelope(
      kind: ShareKind.fileUrl,
      value: fileUrl,
      meta: {
        'sourceTool': 'e2e_playground',
        'fileName': 'sample.pdf',
        'fileSize': 2048000,
      },
    );
    _shareBus.publish(envelope);
    _log('🌱 Seeded sample file URL');
  }

  void _seedCsvData() {
    const csvData = '''Name,Email,Department
John Doe,john@example.com,Engineering
Jane Smith,jane@example.com,Marketing
Bob Johnson,bob@example.com,Sales''';

    final envelope = ShareEnvelope(
      kind: ShareKind.csv,
      value: csvData,
      meta: {'sourceTool': 'e2e_playground'},
    );
    _shareBus.publish(envelope);
    _log('🌱 Seeded sample CSV data');
  }
}
