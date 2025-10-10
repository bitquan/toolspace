/// Invoice Lite Screen - Professional invoicing tool with billing integration
///
/// Features:
/// - Business & client info sections
/// - Dynamic line items with calculations
/// - Tax and discount controls
/// - PDF generation & payment links (Pro-gated)
/// - Cross-tool sharing capabilities
/// - Neo-Playground theme with glassmorphism
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../billing/billing_service.dart';
import '../../billing/widgets/paywall_guard.dart';
import '../../shared/cross_tool/share_bus.dart';
import '../../shared/cross_tool/share_envelope.dart';
import 'exceptions.dart';
import 'invoice_lite_service.dart';
import 'models/models.dart';

class InvoiceLiteScreen extends StatefulWidget {
  const InvoiceLiteScreen({super.key});

  @override
  State<InvoiceLiteScreen> createState() => _InvoiceLiteScreenState();
}

class _InvoiceLiteScreenState extends State<InvoiceLiteScreen>
    with TickerProviderStateMixin {
  final BillingService _billingService = BillingService();
  late InvoiceLiteService _invoiceService;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Form controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Business info controllers
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessEmailController =
      TextEditingController();
  final TextEditingController _businessAddressController =
      TextEditingController();
  final TextEditingController _businessPhoneController =
      TextEditingController();

  // Client info controllers
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();
  final TextEditingController _clientAddressController =
      TextEditingController();

  // Invoice details controllers
  final TextEditingController _invoiceNumberController =
      TextEditingController();
  final TextEditingController _taxRateController = TextEditingController();
  final TextEditingController _discountAmountController =
      TextEditingController();
  final TextEditingController _discountPercentController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _paymentTermsController = TextEditingController();

  // State
  List<InvoiceItem> _items = [];
  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  String _selectedCurrency = 'USD';
  bool _loading = false;
  String? _errorMessage;
  String? _successMessage;

  // Available currencies
  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
    'JPY',
    'CHF',
    'SEK',
    'NOK',
    'DKK'
  ];

  @override
  void initState() {
    super.initState();
    _invoiceService = InvoiceLiteService(billing: _billingService);

    _setupAnimations();
    _initializeForm();
    _listenForSharedData();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _initializeForm() {
    // Auto-generate invoice number
    _invoiceNumberController.text =
        'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    // Set default due date (30 days from now)
    _dueDate = DateTime.now().add(const Duration(days: 30));

    // Initialize with one empty item
    _items = [
      InvoiceItem(
        description: '',
        quantity: 1,
        unitPrice: 0,
      ),
    ];

    // Try to load last used business info
    _loadBusinessInfo();
  }

  void _listenForSharedData() {
    // Listen for cross-tool shared data using existing service
    // For now, we'll use the SharedDataService approach
    // TODO: Implement ShareBus listener when cross-tool is fully implemented
  }

  Future<void> _loadBusinessInfo() async {
    // For now, we'll store in SharedDataService until persistence is added
    // TODO: Implement proper business info persistence
  }

  Future<void> _saveBusinessInfo() async {
    // For now, we'll store in SharedDataService until persistence is added
    // TODO: Implement proper business info persistence
  }

  void _addItem() {
    setState(() {
      _items.add(InvoiceItem(
        description: '',
        quantity: 1,
        unitPrice: 0,
      ));
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items.removeAt(index);
      });
    }
  }

  void _updateItem(int index, InvoiceItem item) {
    setState(() {
      _items[index] = item;
    });
  }

  InvoiceLite _buildCurrentInvoice() {
    final businessInfo = BusinessInfo(
      name: _businessNameController.text.trim(),
      email: _businessEmailController.text.trim(),
      address: _businessAddressController.text.trim().isEmpty
          ? null
          : _businessAddressController.text.trim(),
      phone: _businessPhoneController.text.trim().isEmpty
          ? null
          : _businessPhoneController.text.trim(),
    );

    final clientInfo = ClientInfo(
      name: _clientNameController.text.trim(),
      email: _clientEmailController.text.trim(),
      address: _clientAddressController.text.trim().isEmpty
          ? null
          : _clientAddressController.text.trim(),
    );

    var invoice = _invoiceService.draft(
      business: businessInfo,
      client: clientInfo,
    );

    // Update invoice details
    invoice = invoice.copyWith(
      invoiceNumber: _invoiceNumberController.text.trim(),
      invoiceDate: _invoiceDate,
      dueDate: _dueDate,
      currency: _selectedCurrency,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      paymentTerms: _paymentTermsController.text.trim().isEmpty
          ? null
          : _paymentTermsController.text.trim(),
    );

    // Add all items
    for (final item in _items) {
      if (item.description.trim().isNotEmpty) {
        invoice = _invoiceService.addItem(invoice, item);
      }
    }

    // Apply tax
    final taxRate = double.tryParse(_taxRateController.text) ?? 0;
    if (taxRate > 0) {
      invoice = _invoiceService.applyTax(invoice, percent: taxRate);
    }

    // Apply discounts
    final discountAmount = double.tryParse(_discountAmountController.text) ?? 0;
    final discountPercent =
        double.tryParse(_discountPercentController.text) ?? 0;

    if (discountAmount > 0) {
      invoice = _invoiceService.applyDiscount(invoice, fixed: discountAmount);
    } else if (discountPercent > 0) {
      invoice =
          _invoiceService.applyDiscount(invoice, percent: discountPercent);
    }

    return _invoiceService.calculateTotals(invoice);
  }

  InvoiceLite _buildCurrentInvoiceForDisplay() {
    // Build invoice without validation for display purposes
    try {
      final businessInfo = BusinessInfo(
        name: _businessNameController.text.trim(),
        email: _businessEmailController.text.trim(),
        address: _businessAddressController.text.trim().isEmpty
            ? null
            : _businessAddressController.text.trim(),
        phone: _businessPhoneController.text.trim().isEmpty
            ? null
            : _businessPhoneController.text.trim(),
      );

      final clientInfo = ClientInfo(
        name: _clientNameController.text.trim(),
        email: _clientEmailController.text.trim(),
        address: _clientAddressController.text.trim().isEmpty
            ? null
            : _clientAddressController.text.trim(),
      );

      var invoice = _invoiceService.draft(
        business: businessInfo,
        client: clientInfo,
      );

      // Update invoice details
      invoice = invoice.copyWith(
        invoiceNumber: _invoiceNumberController.text.trim(),
        invoiceDate: _invoiceDate,
        dueDate: _dueDate,
        currency: _selectedCurrency,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        paymentTerms: _paymentTermsController.text.trim().isEmpty
            ? null
            : _paymentTermsController.text.trim(),
      );

      // Add all items
      for (final item in _items) {
        if (item.description.trim().isNotEmpty) {
          invoice = _invoiceService.addItem(invoice, item);
        }
      }

      // Apply tax
      final taxRate = double.tryParse(_taxRateController.text) ?? 0;
      if (taxRate > 0) {
        invoice = _invoiceService.applyTax(invoice, percent: taxRate);
      }

      // Apply discounts
      final discountAmount =
          double.tryParse(_discountAmountController.text) ?? 0;
      final discountPercent =
          double.tryParse(_discountPercentController.text) ?? 0;

      if (discountAmount > 0) {
        invoice = _invoiceService.applyDiscount(invoice, fixed: discountAmount);
      } else if (discountPercent > 0) {
        invoice =
            _invoiceService.applyDiscount(invoice, percent: discountPercent);
      }

      // Return without validation for display
      return invoice;
    } catch (e) {
      // If anything fails, return a minimal invoice
      return _invoiceService.draft();
    }
  }

  Future<void> _generatePdf() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Please fix the form errors before generating PDF');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final invoice = _buildCurrentInvoice();
      await _saveBusinessInfo(); // Save for future use

      final pdfUrl = await _invoiceService.getInvoicePdfUrl(invoice);

      // Track heavy operation
      await _billingService.trackHeavyOp();

      setState(() {
        _loading = false;
        _successMessage = 'PDF generated successfully!';
      });

      // Trigger confetti animation
      _pulseController.forward().then((_) {
        _pulseController.reverse();
      });

      // Share PDF URL with other tools
      ShareBus.instance.publish(ShareEnvelope.fileUrl(
        pdfUrl.toString(),
        meta: {
          'filename': '${invoice.invoiceNumber}.pdf',
          'type': 'invoice',
        },
      ));

      _showSuccess('PDF generated! URL: $pdfUrl');
    } on PaywallRequiredError catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = e.message;
      });
    } on InvoiceValidationError catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Failed to generate PDF: $e';
      });
    }
  }

  Future<void> _createPaymentLink() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Please fix the form errors before creating payment link');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final invoice = _buildCurrentInvoice();
      await _saveBusinessInfo();

      final paymentUrl = await _invoiceService.createPayLink(invoice);

      // Track heavy operation
      await _billingService.trackHeavyOp();

      setState(() {
        _loading = false;
        _successMessage = 'Payment link created!';
      });

      // Share payment link with other tools
      ShareBus.instance.publish(ShareEnvelope.text(
        paymentUrl.toString(),
        meta: {
          'type': 'payment_link',
          'invoice_number': invoice.invoiceNumber,
        },
      ));

      _showSuccess('Payment link created! $paymentUrl');
    } on PaywallRequiredError catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Failed to create payment link: $e';
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();

    // Dispose all controllers
    _businessNameController.dispose();
    _businessEmailController.dispose();
    _businessAddressController.dispose();
    _businessPhoneController.dispose();
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientAddressController.dispose();
    _invoiceNumberController.dispose();
    _taxRateController.dispose();
    _discountAmountController.dispose();
    _discountPercentController.dispose();
    _notesController.dispose();
    _paymentTermsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PaywallGuard(
      billingService: _billingService,
      permission: const ToolPermission(
        toolId: 'invoice_lite',
        requiresHeavyOp: false, // Only PDF/PayLink operations require heavy ops
      ),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade400,
                      Colors.teal.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Invoice Lite'),
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade200, Colors.teal.shade200],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'NEW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          actions: [
            // Send to menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.share),
              onSelected: (value) {
                final invoice = _buildCurrentInvoice();
                switch (value) {
                  case 'json_doctor':
                    ShareBus.instance.publish(ShareEnvelope.json(
                      invoice.toJson(),
                      meta: {'source': 'invoice_lite'},
                    ));
                    _showSuccess('Invoice data sent to JSON Doctor');
                    break;
                  case 'qr_maker':
                    final summary = _invoiceService.getInvoiceSummary(invoice);
                    ShareBus.instance.publish(ShareEnvelope.text(
                      summary,
                      meta: {'source': 'invoice_lite'},
                    ));
                    _showSuccess('Invoice summary sent to QR Maker');
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'json_doctor',
                  child: Row(
                    children: [
                      Icon(Icons.code),
                      SizedBox(width: 8),
                      Text('Send to JSON Doctor'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'qr_maker',
                  child: Row(
                    children: [
                      Icon(Icons.qr_code),
                      SizedBox(width: 8),
                      Text('Send to QR Maker'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error/Success messages
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    setState(() => _errorMessage = null),
                              ),
                            ],
                          ),
                        ),

                      if (_successMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border.all(color: Colors.green.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: Colors.green.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style:
                                      TextStyle(color: Colors.green.shade700),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    setState(() => _successMessage = null),
                              ),
                            ],
                          ),
                        ),

                      // Main form content
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 800;

                          if (isWide) {
                            // Desktop layout - two columns
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      _buildBusinessInfoSection(),
                                      const SizedBox(height: 16),
                                      _buildClientInfoSection(),
                                      const SizedBox(height: 16),
                                      _buildInvoiceItemsList(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      _buildInvoiceDetails(),
                                      const SizedBox(height: 16),
                                      _buildTaxAndDiscounts(),
                                      const SizedBox(height: 16),
                                      _buildInvoiceTotalsPanel(),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Mobile layout - single column
                            return Column(
                              children: [
                                _buildBusinessInfoSection(),
                                const SizedBox(height: 16),
                                _buildClientInfoSection(),
                                const SizedBox(height: 16),
                                _buildInvoiceDetails(),
                                const SizedBox(height: 16),
                                _buildInvoiceItemsList(),
                                const SizedBox(height: 16),
                                _buildTaxAndDiscounts(),
                                const SizedBox(height: 16),
                                _buildInvoiceTotalsPanel(),
                              ],
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 16),
                      _buildNotesSection(),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: PaywallGuard(
                              billingService: _billingService,
                              permission: const ToolPermission(
                                toolId: 'invoice_lite',
                                requiresHeavyOp: true,
                              ),
                              blockedWidget: ElevatedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.lock),
                                label: const Text('Generate PDF (Pro)'),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _loading ? null : _generatePdf,
                                icon: _loading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.picture_as_pdf),
                                label: const Text('Generate PDF'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PaywallGuard(
                        billingService: _billingService,
                        permission: const ToolPermission(
                          toolId: 'invoice_lite',
                          requiresHeavyOp: true,
                        ),
                        blockedWidget: ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.lock),
                          label: const Text('Payment Link (Pro)'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _createPaymentLink,
                          icon: _loading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.payment),
                          label: const Text('Payment Link'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invoice Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Invoice number
          TextFormField(
            controller: _invoiceNumberController,
            decoration: const InputDecoration(
              labelText: 'Invoice Number *',
              hintText: 'INV-12345',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Invoice number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Currency selector
          DropdownButtonFormField<String>(
            initialValue: _selectedCurrency,
            decoration: const InputDecoration(
              labelText: 'Currency',
              border: OutlineInputBorder(),
            ),
            items: _currencies.map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(currency),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCurrency = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Dates
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _invoiceDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _invoiceDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Invoice Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_invoiceDate.day}/${_invoiceDate.month}/${_invoiceDate.year}',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ??
                          DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _dueDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _dueDate != null
                          ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                          : 'Select date',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaxAndDiscounts() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tax & Discounts',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Tax rate
          TextFormField(
            controller: _taxRateController,
            decoration: const InputDecoration(
              labelText: 'Tax Rate (%)',
              hintText: '10',
              border: OutlineInputBorder(),
              suffixText: '%',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            onChanged: (_) => setState(() {}), // Trigger totals recalculation
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final rate = double.tryParse(value);
                if (rate == null || rate < 0 || rate > 100) {
                  return 'Enter a valid tax rate (0-100)';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Discount amount
          TextFormField(
            controller: _discountAmountController,
            decoration: InputDecoration(
              labelText: 'Discount Amount',
              hintText: '0.00',
              border: const OutlineInputBorder(),
              prefixText: _invoiceService
                  .formatMoney(0, _selectedCurrency)
                  .substring(0, 1),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            onChanged: (value) {
              if (value.isNotEmpty) {
                _discountPercentController.clear();
              }
              setState(() {});
            },
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final amount = double.tryParse(value);
                if (amount == null || amount < 0) {
                  return 'Enter a valid discount amount';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // OR label
          Center(
            child: Text(
              'OR',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Discount percentage
          TextFormField(
            controller: _discountPercentController,
            decoration: const InputDecoration(
              labelText: 'Discount Percentage',
              hintText: '10',
              border: OutlineInputBorder(),
              suffixText: '%',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            onChanged: (value) {
              if (value.isNotEmpty) {
                _discountAmountController.clear();
              }
              setState(() {});
            },
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final percent = double.tryParse(value);
                if (percent == null || percent < 0 || percent > 100) {
                  return 'Enter a valid discount percentage (0-100)';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Notes
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Additional notes or special instructions...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Payment terms
          TextFormField(
            controller: _paymentTermsController,
            decoration: const InputDecoration(
              labelText: 'Payment Terms',
              hintText: 'Net 30 days, Due on receipt, etc.',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoSection() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Business name
          TextFormField(
            controller: _businessNameController,
            decoration: const InputDecoration(
              labelText: 'Business Name *',
              hintText: 'Your Business Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Business email
          TextFormField(
            controller: _businessEmailController,
            decoration: const InputDecoration(
              labelText: 'Business Email *',
              hintText: 'contact@business.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Business address
          TextFormField(
            controller: _businessAddressController,
            decoration: const InputDecoration(
              labelText: 'Business Address',
              hintText: '123 Business St, City, State',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Business phone
          TextFormField(
            controller: _businessPhoneController,
            decoration: const InputDecoration(
              labelText: 'Business Phone',
              hintText: '+1 (555) 123-4567',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfoSection() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Client Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Client name
          TextFormField(
            controller: _clientNameController,
            decoration: const InputDecoration(
              labelText: 'Client Name *',
              hintText: 'Client Company Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Client name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Client email
          TextFormField(
            controller: _clientEmailController,
            decoration: const InputDecoration(
              labelText: 'Client Email *',
              hintText: 'client@company.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Client email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Client address
          TextFormField(
            controller: _clientAddressController,
            decoration: const InputDecoration(
              labelText: 'Client Address',
              hintText: '456 Client Ave, City, State',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItemsList() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invoice Items',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Items list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Description
                      TextFormField(
                        initialValue: item.description,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          hintText: 'Service or product description',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _updateItem(index, item.copyWith(description: value));
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Quantity and Unit Price row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: item.quantity.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*')),
                              ],
                              onChanged: (value) {
                                final qty = double.tryParse(value) ?? 1;
                                _updateItem(
                                    index, item.copyWith(quantity: qty));
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              initialValue: item.unitPrice.toString(),
                              decoration: InputDecoration(
                                labelText: 'Unit Price',
                                border: const OutlineInputBorder(),
                                prefixText: _invoiceService
                                    .formatMoney(0, _selectedCurrency)
                                    .substring(0, 1),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*')),
                              ],
                              onChanged: (value) {
                                final price = double.tryParse(value) ?? 0;
                                _updateItem(
                                    index, item.copyWith(unitPrice: price));
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Text(
                                    _invoiceService.formatMoney(
                                        item.total, _selectedCurrency),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_items.length > 1)
                            IconButton(
                              onPressed: () => _removeItem(index),
                              icon: const Icon(Icons.delete),
                              color: Colors.red.shade600,
                            ),
                        ],
                      ),

                      // Notes (optional)
                      if (item.notes != null || index == 0) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: item.notes,
                          decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                            hintText: 'Additional notes for this item',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _updateItem(
                                index,
                                item.copyWith(
                                    notes: value.isEmpty ? null : value));
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTotalsPanel() {
    final theme = Theme.of(context);
    final invoice = _buildCurrentInvoiceForDisplay();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.green.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invoice Totals',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Subtotal
          _buildTotalRow('Subtotal', invoice.subtotal, invoice.currency, theme),

          // Tax
          if (invoice.taxRate > 0)
            _buildTotalRow('Tax (${invoice.taxRate}%)', invoice.taxAmount,
                invoice.currency, theme),

          // Discount
          if (invoice.totalDiscount > 0)
            _buildTotalRow(
                'Discount', -invoice.totalDiscount, invoice.currency, theme,
                isDiscount: true),

          const Divider(height: 24),

          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade600,
                  Colors.teal.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _invoiceService.formatMoney(invoice.total, invoice.currency),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
      String label, double amount, String currency, ThemeData theme,
      {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge,
          ),
          Text(
            _invoiceService.formatMoney(amount, currency),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDiscount ? Colors.green.shade700 : null,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
