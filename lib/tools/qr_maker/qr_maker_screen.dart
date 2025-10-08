import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../billing/billing_service.dart';
import '../../billing/widgets/paywall_guard.dart';
import '../../core/services/shared_data_service.dart';
import '../../core/ui/import_data_button.dart';
import '../../core/ui/share_data_button.dart';
import '../../billing/billing_service.dart';
import '../../billing/widgets/paywall_guard.dart';

/// QR Maker - Generate QR codes instantly with customization
class QrMakerScreen extends StatefulWidget {
  const QrMakerScreen({super.key});

  @override
  State<QrMakerScreen> createState() => _QrMakerScreenState();
}

class _QrMakerScreenState extends State<QrMakerScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _batchTextController = TextEditingController();
  final BillingService _billingService = BillingService();

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late TabController _tabController;

  String _qrData = '';
  QrType _selectedType = QrType.text;
  int _qrSize = 200;
  Color _foregroundColor = Colors.black;
  Color _backgroundColor = Colors.white;
  final bool _isGenerating = false;
  List<String> _batchItems = [];
  int _generatedCount = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _batchTextController.dispose();
    _tabController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _qrData = _textController.text;
    });

    if (_qrData.isNotEmpty) {
      _bounceController.forward().then((_) => _bounceController.reverse());
    }
  }

  void _downloadQr() {
    if (_qrData.isEmpty) return;

    // In a real implementation, this would generate and download the QR code
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('QR code download started!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyQrData() {
    if (_qrData.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _qrData));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('QR data copied to clipboard!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearData() {
    _textController.clear();
    setState(() {
      _qrData = '';
    });
  }

  Future<void> _processBatchGeneration() async {
    final input = _batchTextController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter items (one per line)'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final items = input.split('\n').where((line) => line.trim().isNotEmpty).toList();

    setState(() {
      _batchItems = items;
      _generatedCount = items.length;
    });

    // Track heavy operations (one per QR code generated)
    for (var i = 0; i < items.length; i++) {
      await _billingService.trackHeavyOp();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generated ${items.length} QR codes!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadAllBatchQrs() {
    if (_batchItems.isEmpty) return;

    // In a real implementation, this would generate and download all QR codes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${_batchItems.length} QR codes...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearBatch() {
    _batchTextController.clear();
    setState(() {
      _batchItems = [];
      _generatedCount = 0;
    });
  }

  void _useQuickTemplate(String template) {
    _textController.text = template;
  }

  String _getQuickTemplate(QrType type) {
    switch (type) {
      case QrType.text:
        return 'Hello, World!';
      case QrType.url:
        return 'https://example.com';
      case QrType.email:
        return 'mailto:example@email.com';
      case QrType.phone:
        return 'tel:+1234567890';
      case QrType.sms:
        return 'sms:+1234567890';
      case QrType.wifi:
        return 'WIFI:T:WPA;S:MyNetwork;P:MyPassword;;';
      case QrType.vcard:
        return 'BEGIN:VCARD\nVERSION:3.0\nFN:John Doe\nTEL:+1234567890\nEMAIL:john@example.com\nEND:VCARD';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Only gate batch mode (tab index 1)
    final isBatchMode = _tabController.index == 1;
    final batchSize = _batchItems.length;

    return PaywallGuard(
      billingService: _billingService,
      permission: ToolPermission(
        toolId: isBatchMode ? 'qr_maker_batch' : 'qr_maker',
        requiresHeavyOp: isBatchMode,
        batchSize: isBatchMode && batchSize > 0 ? batchSize : null,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code,
                  color: Color(0xFFFF5722),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('QR Maker v2'),
            ],
          ),
          actions: [
            ShareDataButton(
              data: _qrData,
              type: SharedDataType.text,
              sourceTool: 'QR Maker',
              compact: true,
            ),
            IconButton(
              onPressed: _tabController.index == 0 ? _clearData : _clearBatch,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear All',
            ),
            if (_tabController.index == 0)
              IconButton(
                onPressed: _copyQrData,
                icon: const Icon(Icons.copy),
                tooltip: 'Copy Data',
              ),
            IconButton(
              onPressed: _tabController.index == 0 ? _downloadQr : _downloadAllBatchQrs,
              icon: const Icon(Icons.download),
              tooltip: _tabController.index == 0 ? 'Download QR' : 'Download All',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.qr_code_2), text: 'Single QR'),
              Tab(icon: Icon(Icons.qr_code_scanner), text: 'Batch Generation'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSingleQrTab(theme),
            _buildBatchGenerationTab(theme),
          ],
        ),
      ), // Scaffold
    ); // PaywallGuard
  }

  Widget _buildSingleQrTab(ThemeData theme) {
    return Row(
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
                  // QR Type selector
                  Text(
                    'QR Code Type',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: QrType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return FilterChip(
                        label: Text(_getTypeLabel(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = type;
                          });
                          if (selected && _textController.text.isEmpty) {
                            _useQuickTemplate(_getQuickTemplate(type));
                          }
                        },
                        selectedColor: const Color(0xFFFF5722).withOpacity(0.2),
                        checkmarkColor: const Color(0xFFFF5722),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Input field
                  Text(
                    'Content',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _textController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: _getHintText(_selectedType),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Import and quick template buttons
                  Row(
                    children: [
                      Expanded(
                        child: ImportDataButton(
                          acceptedTypes: const [
                            SharedDataType.text,
                            SharedDataType.url,
                          ],
                          onImport: (data, type, source) {
                            setState(() {
                              _textController.text = data;
                            });
                          },
                          label: 'Import Data',
                        ),
                      ),
                      if (_textController.text.isEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _useQuickTemplate(_getQuickTemplate(_selectedType)),
                            icon: const Icon(Icons.auto_fix_high),
                            label: const Text('Template'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5722).withOpacity(0.1),
                              foregroundColor: const Color(0xFFFF5722),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Customization
                  Text(
                    'Customization',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Size slider
                  Text('Size: ${_qrSize}px'),
                  Slider(
                    value: _qrSize.toDouble(),
                    min: 100,
                    max: 500,
                    divisions: 8,
                    onChanged: (value) {
                      setState(() {
                        _qrSize = value.round();
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Color selection
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Foreground'),
                            const SizedBox(height: 8),
                            _ColorPicker(
                              color: _foregroundColor,
                              onColorChanged: (color) {
                                setState(() {
                                  _foregroundColor = color;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Background'),
                            const SizedBox(height: 8),
                            _ColorPicker(
                              color: _backgroundColor,
                              onColorChanged: (color) {
                                setState(() {
                                  _backgroundColor = color;
                                });
                              },
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
        ),

        // QR Preview panel
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'QR Code Preview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: Center(
                    child: _isGenerating
                        ? const CircularProgressIndicator()
                        : _qrData.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_2,
                                    size: 64,
                                    color: theme.colorScheme.outline,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Enter content to generate QR code',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : AnimatedBuilder(
                                animation: _bounceAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _bounceAnimation.value,
                                    child: _QrCodePreview(
                                      data: _qrData,
                                      size: _qrSize.toDouble(),
                                      foregroundColor: _foregroundColor,
                                      backgroundColor: _backgroundColor,
                                    ),
                                  );
                                },
                              ),
                  ),
                ),

                const SizedBox(height: 24),

                // Generation info
                if (_qrData.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Characters:'),
                            Text('${_qrData.length}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Type:'),
                            Text(_getTypeLabel(_selectedType)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Size:'),
                            Text('${_qrSize}x$_qrSize px'),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchGenerationTab(ThemeData theme) {
    return Row(
      children: [
        // Input panel
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Batch QR Generation',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter multiple items (one per line) to generate QR codes in bulk.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _batchTextController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'https://example.com/page1\nhttps://example.com/page2\nhttps://example.com/page3\n...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _processBatchGeneration,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate All'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFFFF5722),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_generatedCount > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Generated $_generatedCount QR codes',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Preview panel
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (_batchItems.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 80,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No QR codes generated yet',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _batchItems.length,
                      itemBuilder: (context, index) {
                        final item = _batchItems[index];
                        return Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: _QrCodePreview(
                                    data: item,
                                    size: 120,
                                    foregroundColor: _foregroundColor,
                                    backgroundColor: _backgroundColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.length > 30
                                      ? '${item.substring(0, 30)}...'
                                      : item,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'QR #${index + 1}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getTypeLabel(QrType type) {
    switch (type) {
      case QrType.text:
        return 'Text';
      case QrType.url:
        return 'URL';
      case QrType.email:
        return 'Email';
      case QrType.phone:
        return 'Phone';
      case QrType.sms:
        return 'SMS';
      case QrType.wifi:
        return 'WiFi';
      case QrType.vcard:
        return 'vCard';
    }
  }

  String _getHintText(QrType type) {
    switch (type) {
      case QrType.text:
        return 'Enter any text...';
      case QrType.url:
        return 'https://example.com';
      case QrType.email:
        return 'mailto:example@email.com';
      case QrType.phone:
        return 'tel:+1234567890';
      case QrType.sms:
        return 'sms:+1234567890';
      case QrType.wifi:
        return 'WIFI:T:WPA;S:NetworkName;P:Password;;';
      case QrType.vcard:
        return 'BEGIN:VCARD\nVERSION:3.0\n...';
    }
  }
}

/// Simple QR Code preview widget (placeholder)
class _QrCodePreview extends StatelessWidget {
  final String data;
  final double size;
  final Color foregroundColor;
  final Color backgroundColor;

  const _QrCodePreview({
    required this.data,
    required this.size,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // This is a placeholder - in real implementation, use qr_flutter package
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: foregroundColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code,
            size: size * 0.6,
            color: foregroundColor,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              data.length > 20 ? '${data.substring(0, 20)}...' : data,
              style: TextStyle(
                fontSize: size * 0.04,
                color: foregroundColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Color picker widget
class _ColorPicker extends StatelessWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const _ColorPicker({
    required this.color,
    required this.onColorChanged,
  });

  static const List<Color> _colors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _colors.map((c) {
        final isSelected = c == color;
        return GestureDetector(
          onTap: () => onColorChanged(c),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}

enum QrType { text, url, email, phone, sms, wifi, vcard }
