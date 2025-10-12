# Invoice Lite - Professional Business Invoicing System

**Tool**: Invoice Lite  
**Route**: /tools/invoice-lite  
**Category**: Business Operations  
**Billing**: Pro Plan Required  
**Heavy Op**: Yes (PDF generation, payment processing)  
**Owner Code**: `invoice_lite`

## Professional Invoicing Solution Overview

Invoice Lite provides a comprehensive business invoicing system with professional PDF generation, integrated payment processing via Stripe, and complete business/client relationship management. Designed for freelancers, small businesses, and service providers, the tool streamlines the entire invoicing workflow from creation to payment collection while maintaining professional standards and regulatory compliance.

### Enterprise-Grade Invoicing Capabilities

Invoice Lite implements a full-featured invoicing ecosystem that handles complex business scenarios, multi-currency transactions, recurring billing cycles, and comprehensive financial reporting. The system integrates seamlessly with external payment processors and accounting platforms while maintaining data integrity and audit trails.

#### Professional Invoice Management Architecture

```typescript
interface InvoicingSystemCapabilities {
  invoiceGeneration: {
    templates: "Professional PDF templates with customizable branding";
    itemization: "Detailed line items with quantities, rates, and calculations";
    taxation: "Automatic tax calculations with regional compliance";
    currencies: "Multi-currency support with real-time exchange rates";
    numbering: "Sequential invoice numbering with custom prefixes";
  };

  clientManagement: {
    profiles: "Complete client profiles with contact and billing information";
    history: "Comprehensive invoice history and payment tracking";
    communication: "Automated invoice delivery and payment reminders";
    relationships: "Long-term client relationship management";
    preferences: "Client-specific billing preferences and terms";
  };

  paymentProcessing: {
    stripeIntegration: "Secure payment links with credit card processing";
    paymentTracking: "Real-time payment status updates and confirmations";
    refundManagement: "Professional refund processing and dispute handling";
    multipleGateways: "Support for multiple payment processors";
    subscriptions: "Recurring billing and subscription management";
  };

  businessOperations: {
    branding: "Custom business branding with logos and color schemes";
    templates: "Multiple invoice templates for different business types";
    automation: "Automated invoice generation and delivery workflows";
    reporting: "Comprehensive financial reporting and analytics";
    compliance: "Tax compliance and regulatory requirement adherence";
  };
}
```

#### Professional Invoice Service Architecture

```dart
// Professional Invoice Service Implementation
class InvoiceLiteService {
  static const String serviceScope = 'professional-business-invoicing';
  static const String integrationStandard = 'enterprise-grade-financial-processing';
  static const String securityLevel = 'pci-dss-compliant-payment-handling';

  // Professional Invoice Configuration
  static const Map<String, Map<String, dynamic>> invoicingStandards = {
    'pdf_generation': {
      'engine': 'professional-pdf-renderer',
      'resolution': '300-dpi-print-quality',
      'compression': 'optimized-for-email-delivery',
      'accessibility': 'wcag-2.1-aa-compliant',
      'security': 'password-protection-available',
      'watermarking': 'draft-payment-status-watermarks'
    },

    'payment_integration': {
      'processor': 'stripe-connect-api',
      'security': 'tokenized-payment-processing',
      'compliance': 'pci-dss-level-1-certified',
      'currencies': 'multi-currency-with-conversion',
      'fees': 'transparent-processing-fee-structure',
      'settlements': 'automated-merchant-settlements'
    },

    'business_logic': {
      'calculations': 'precision-decimal-arithmetic',
      'taxation': 'configurable-tax-rates-and-rules',
      'discounts': 'percentage-and-fixed-amount-discounts',
      'rounding': 'currency-appropriate-rounding-rules',
      'validation': 'comprehensive-business-rule-validation',
      'audit': 'complete-transaction-audit-trails'
    },

    'workflow_automation': {
      'delivery': 'automated-invoice-email-delivery',
      'reminders': 'configurable-payment-reminder-schedules',
      'overdue': 'automated-overdue-notification-escalation',
      'recurring': 'subscription-based-recurring-billing',
      'reporting': 'scheduled-financial-report-generation'
    }
  };

  // Professional Invoice Creation Engine
  static Future<InvoiceCreationResult> createInvoice({
    required BusinessProfile businessProfile,
    required ClientProfile clientProfile,
    required List<InvoiceLineItem> lineItems,
    InvoiceSettings? customSettings,
  }) async {

    final invoiceId = await _generateInvoiceNumber(businessProfile.invoiceSequence);
    final invoiceDate = DateTime.now();
    final dueDate = _calculateDueDate(invoiceDate, clientProfile.paymentTerms);

    // Professional calculation engine
    final calculations = await InvoiceCalculationEngine.calculateTotals(
      lineItems: lineItems,
      taxRates: businessProfile.taxConfiguration,
      discounts: customSettings?.discounts ?? [],
      currency: businessProfile.defaultCurrency,
    );

    // Professional invoice model creation
    final invoice = Invoice(
      id: invoiceId,
      businessProfile: businessProfile,
      clientProfile: clientProfile,
      lineItems: lineItems,
      calculations: calculations,
      invoiceDate: invoiceDate,
      dueDate: dueDate,
      status: InvoiceStatus.draft,
      metadata: InvoiceMetadata(
        createdBy: 'invoice-lite-system',
        createdAt: DateTime.now(),
        version: '1.0',
        template: customSettings?.template ?? 'professional-standard'
      )
    );

    // Professional validation
    final validation = await InvoiceValidator.validateInvoice(invoice);
    if (!validation.isValid) {
      throw InvoiceValidationException('Invoice validation failed: ${validation.errors}');
    }

    // Professional PDF generation
    final pdfBytes = await InvoicePdfGenerator.generatePdf(
      invoice: invoice,
      template: customSettings?.template ?? 'professional-standard',
      watermark: customSettings?.watermark,
    );

    // Professional persistence
    await InvoiceRepository.saveInvoice(invoice);
    await InvoiceRepository.savePdf(invoiceId, pdfBytes);

    return InvoiceCreationResult(
      invoice: invoice,
      pdfBytes: pdfBytes,
      validationResult: validation,
      creationMetrics: {
        'invoiceId': invoiceId,
        'totalAmount': calculations.total,
        'currency': businessProfile.defaultCurrency,
        'lineItemCount': lineItems.length,
        'taxAmount': calculations.totalTax,
        'processingTime': DateTime.now().difference(invoiceDate).inMilliseconds
      },
      businessMetrics: {
        'monthlyInvoiceCount': await _getMonthlyInvoiceCount(businessProfile.id),
        'clientInvoiceHistory': await _getClientInvoiceHistory(clientProfile.id),
        'averageInvoiceValue': await _calculateAverageInvoiceValue(businessProfile.id),
        'paymentTermsAnalysis': await _analyzePaymentTerms(clientProfile.id)
      }
    );
  }
}
```

## Professional Client and Business Management

### Comprehensive Client Relationship Management

```dart
// Professional Client Management Implementation
class ClientManagementSystem {
  // Professional Client Profile Management
  static Future<ClientProfile> createClientProfile({
    required String businessName,
    required ContactInformation contactInfo,
    required BillingInformation billingInfo,
    PaymentTerms? paymentTerms,
  }) async {

    final clientId = UuidGenerator.generateV4();
    final creationDate = DateTime.now();

    final clientProfile = ClientProfile(
      id: clientId,
      businessName: businessName,
      contactInformation: contactInfo,
      billingInformation: billingInfo,
      paymentTerms: paymentTerms ?? PaymentTerms.net30(),

      relationshipMetadata: ClientRelationshipMetadata(
        createdDate: creationDate,
        lastInteraction: creationDate,
        totalInvoicesSent: 0,
        totalAmountBilled: 0,
        averagePaymentTime: null,
        creditRating: CreditRating.unrated,
        preferredCommunication: contactInfo.preferredMethod,
        notes: []
      ),

      invoicePreferences: InvoicePreferences(
        preferredTemplate: 'professional-standard',
        deliveryMethod: DeliveryMethod.email,
        reminderSchedule: ReminderSchedule.standard(),
        currency: billingInfo.preferredCurrency ?? 'USD',
        language: billingInfo.language ?? 'en-US',
        taxExempt: billingInfo.taxExemptStatus ?? false
      )
    );

    // Professional validation
    final validation = await ClientValidator.validateProfile(clientProfile);
    if (!validation.isValid) {
      throw ClientValidationException('Client profile validation failed: ${validation.errors}');
    }

    // Professional persistence with audit trail
    await ClientRepository.saveClient(clientProfile);
    await AuditTrail.logClientCreation(clientProfile);

    return clientProfile;
  }

  // Professional Invoice History Management
  static Future<ClientInvoiceHistory> getClientInvoiceHistory({
    required String clientId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {

    final invoices = await InvoiceRepository.getInvoicesByClient(
      clientId: clientId,
      startDate: startDate,
      endDate: endDate,
    );

    final paymentHistory = await PaymentRepository.getPaymentsByClient(
      clientId: clientId,
      startDate: startDate,
      endDate: endDate,
    );

    // Professional analytics calculation
    final analytics = ClientAnalytics(
      totalInvoices: invoices.length,
      totalAmountBilled: invoices.fold(0, (sum, invoice) => sum + invoice.calculations.total),
      totalAmountPaid: paymentHistory.fold(0, (sum, payment) => sum + payment.amount),
      averageInvoiceValue: invoices.isNotEmpty ?
        invoices.fold(0, (sum, invoice) => sum + invoice.calculations.total) / invoices.length : 0,
      averagePaymentTime: await _calculateAveragePaymentTime(invoices, paymentHistory),
      paymentSuccessRate: _calculatePaymentSuccessRate(invoices, paymentHistory),
      overdueInvoices: invoices.where((i) => i.isOverdue).length,
      creditScore: await _calculateClientCreditScore(clientId, invoices, paymentHistory)
    );

    return ClientInvoiceHistory(
      clientId: clientId,
      invoices: invoices,
      paymentHistory: paymentHistory,
      analytics: analytics,
      recommendations: await _generateClientRecommendations(analytics)
    );
  }
}
```

### Professional Business Profile Management

```dart
// Professional Business Configuration System
class BusinessProfileManager {
  // Comprehensive Business Profile Setup
  static Future<BusinessProfile> createBusinessProfile({
    required CompanyInformation companyInfo,
    required BrandingConfiguration branding,
    required TaxConfiguration taxConfig,
    required InvoiceConfiguration invoiceConfig,
  }) async {

    final businessId = UuidGenerator.generateV4();
    final creationDate = DateTime.now();

    final businessProfile = BusinessProfile(
      id: businessId,
      companyInformation: companyInfo,
      brandingConfiguration: branding,
      taxConfiguration: taxConfig,
      invoiceConfiguration: invoiceConfig,

      operationalSettings: OperationalSettings(
        defaultCurrency: invoiceConfig.defaultCurrency,
        timeZone: companyInfo.timeZone,
        fiscalYearStart: taxConfig.fiscalYearStart,
        invoiceSequence: InvoiceSequence(
          prefix: invoiceConfig.invoicePrefix,
          currentNumber: 1,
          digits: invoiceConfig.sequenceDigits
        ),

        automationRules: AutomationRules(
          autoSendInvoices: false,
          reminderSchedule: ReminderSchedule.standard(),
          overdueEscalation: OverdueEscalation.gentle(),
          paymentNotifications: true,
          reportGeneration: ReportGeneration.monthly()
        )
      ),

      integrationSettings: IntegrationSettings(
        stripeConfiguration: null, // Configured separately
        emailConfiguration: EmailConfiguration.default(),
        webhookConfiguration: WebhookConfiguration(),
        apiAccess: ApiAccess(
          enabled: false,
          rateLimits: RateLimits.standard()
        )
      ),

      complianceSettings: ComplianceSettings(
        taxCompliance: TaxCompliance.fromConfiguration(taxConfig),
        dataRetention: DataRetention.standard(),
        auditRequirements: AuditRequirements.basic(),
        privacySettings: PrivacySettings.gdprCompliant()
      )
    );

    // Professional validation
    final validation = await BusinessValidator.validateProfile(businessProfile);
    if (!validation.isValid) {
      throw BusinessValidationException('Business profile validation failed: ${validation.errors}');
    }

    // Professional persistence
    await BusinessRepository.saveProfile(businessProfile);
    await AuditTrail.logBusinessCreation(businessProfile);

    return businessProfile;
  }

  // Professional Branding System
  static Future<BrandingConfiguration> setupBusinessBranding({
    required String businessName,
    String? logoPath,
    ColorScheme? colorScheme,
    Typography? typography,
  }) async {

    BrandingAssets? assets;

    if (logoPath != null) {
      // Professional logo processing
      final logoBytes = await File(logoPath).readAsBytes();
      final processedLogo = await LogoProcessor.processBusinessLogo(
        imageBytes: logoBytes,
        maxWidth: 400,
        maxHeight: 200,
        formats: ['png', 'svg'],
        optimizeForPrint: true
      );

      assets = BrandingAssets(
        logo: processedLogo.primaryFormat,
        logoVariants: processedLogo.variants,
        favicon: await LogoProcessor.generateFavicon(processedLogo.primaryFormat)
      );
    }

    final branding = BrandingConfiguration(
      businessName: businessName,
      assets: assets,
      colorScheme: colorScheme ?? ColorScheme.professional(),
      typography: typography ?? Typography.professional(),

      templateCustomization: TemplateCustomization(
        headerStyle: HeaderStyle.modern,
        footerContent: FooterContent.minimal(),
        layoutPreferences: LayoutPreferences.balanced(),
        watermarkSettings: WatermarkSettings.disabled()
      ),

      communicationBranding: CommunicationBranding(
        emailSignature: await _generateEmailSignature(businessName, colorScheme),
        letterheadTemplate: await _generateLetterhead(businessName, assets),
        businessCardTemplate: await _generateBusinessCard(businessName, assets, colorScheme)
      )
    );

    return branding;
  }
}
```

## Professional Payment Processing and Stripe Integration

### Comprehensive Payment System Architecture

```dart
// Professional Payment Processing Implementation
class PaymentProcessingSystem {
  // Stripe Integration for Professional Payment Links
  static Future<PaymentLinkResult> createStripePaymentLink({
    required Invoice invoice,
    StripeConfiguration? customConfig,
  }) async {

    final stripeConfig = customConfig ?? await _getDefaultStripeConfiguration();

    // Professional Stripe product creation
    final stripeProduct = await stripe.products.create(
      name: 'Invoice ${invoice.id}',
      description: 'Payment for ${invoice.businessProfile.companyInformation.name} invoice',
      metadata: {
        'invoice_id': invoice.id,
        'client_id': invoice.clientProfile.id,
        'business_id': invoice.businessProfile.id,
        'invoice_date': invoice.invoiceDate.toIso8601String(),
        'due_date': invoice.dueDate.toIso8601String()
      }
    );

    // Professional price calculation with Stripe precision
    final stripePriceAmount = (invoice.calculations.total * 100).round(); // Convert to cents

    final stripePrice = await stripe.prices.create(
      product: stripeProduct.id,
      unitAmount: stripePriceAmount,
      currency: invoice.businessProfile.defaultCurrency.toLowerCase(),
      metadata: {
        'subtotal': (invoice.calculations.subtotal * 100).round().toString(),
        'tax_amount': (invoice.calculations.totalTax * 100).round().toString(),
        'discount_amount': (invoice.calculations.totalDiscount * 100).round().toString()
      }
    );

    // Professional payment link creation
    final paymentLink = await stripe.paymentLinks.create(
      lineItems: [
        {
          'price': stripePrice.id,
          'quantity': 1
        }
      ],

      afterCompletion: {
        'type': 'redirect',
        'redirect': {
          'url': '${AppConfig.baseUrl}/payment-success?invoice=${invoice.id}'
        }
      },

      allowPromotionCodes: true,
      billingAddressCollection: 'required',
      shippingAddressCollection: null,

      customFields: [
        {
          'key': 'purchase_order',
          'label': {
            'type': 'custom',
            'custom': 'Purchase Order Number'
          },
          'type': 'text',
          'optional': true
        }
      ],

      customText: {
        'submit': {
          'message': 'Payment for ${invoice.businessProfile.companyInformation.name} Invoice ${invoice.id}'
        }
      },

      invoiceCreation: {
        'enabled': true,
        'invoiceData': {
          'description': 'Payment for Invoice ${invoice.id}',
          'metadata': {
            'invoice_id': invoice.id,
            'client_name': invoice.clientProfile.businessName
          },
          'footer': 'Thank you for your business!'
        }
      },

      metadata: {
        'invoice_id': invoice.id,
        'client_id': invoice.clientProfile.id,
        'business_id': invoice.businessProfile.id,
        'created_by': 'invoice-lite-system',
        'integration_version': '2.0'
      }
    );

    // Professional payment tracking setup
    await PaymentTracker.initializeTracking(
      invoiceId: invoice.id,
      paymentLinkId: paymentLink.id,
      expectedAmount: invoice.calculations.total,
      currency: invoice.businessProfile.defaultCurrency
    );

    return PaymentLinkResult(
      paymentLink: paymentLink,
      trackingId: await PaymentTracker.generateTrackingId(invoice.id),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      paymentInstructions: PaymentInstructions(
        currency: invoice.businessProfile.defaultCurrency,
        amount: invoice.calculations.total,
        paymentMethods: ['card', 'bank_transfer', 'apple_pay', 'google_pay'],
        processingFees: await _calculateProcessingFees(invoice.calculations.total)
      )
    );
  }

  // Professional Payment Status Monitoring
  static Future<PaymentStatus> monitorPaymentStatus(String invoiceId) async {
    final paymentTracking = await PaymentTracker.getTracking(invoiceId);

    if (paymentTracking == null) {
      return PaymentStatus.noTrackingFound;
    }

    // Query Stripe for latest payment status
    final stripePaymentIntent = await stripe.paymentIntents.retrieve(
      paymentTracking.stripePaymentIntentId
    );

    final paymentStatus = PaymentStatus(
      invoiceId: invoiceId,
      stripeStatus: stripePaymentIntent.status,
      amount: stripePaymentIntent.amount / 100.0,
      currency: stripePaymentIntent.currency.toUpperCase(),

      paymentDetails: PaymentDetails(
        paymentMethod: stripePaymentIntent.paymentMethod?.type,
        last4: stripePaymentIntent.paymentMethod?.card?.last4,
        brand: stripePaymentIntent.paymentMethod?.card?.brand,
        processingFees: await _getProcessingFees(stripePaymentIntent.id),
        netAmount: await _calculateNetAmount(stripePaymentIntent)
      ),

      timeline: PaymentTimeline(
        created: DateTime.fromMillisecondsSinceEpoch(stripePaymentIntent.created * 1000),
        processing: stripePaymentIntent.processingAt != null ?
          DateTime.fromMillisecondsSinceEpoch(stripePaymentIntent.processingAt! * 1000) : null,
        succeeded: stripePaymentIntent.succeededAt != null ?
          DateTime.fromMillisecondsSinceEpoch(stripePaymentIntent.succeededAt! * 1000) : null,
        refunded: stripePaymentIntent.refundedAt != null ?
          DateTime.fromMillisecondsSinceEpoch(stripePaymentIntent.refundedAt! * 1000) : null
      ),

      metadata: {
        'stripe_payment_intent_id': stripePaymentIntent.id,
        'customer_id': stripePaymentIntent.customer,
        'receipt_url': stripePaymentIntent.receiptUrl,
        'charges': stripePaymentIntent.charges?.data?.length ?? 0
      }
    );

    // Update local payment tracking
    await PaymentTracker.updateStatus(invoiceId, paymentStatus);

    // Trigger automation workflows
    await PaymentAutomation.processPaymentUpdate(invoiceId, paymentStatus);

    return paymentStatus;
  }
}
```

### Professional Invoice PDF Generation Engine

```dart
// Professional PDF Generation Implementation
class InvoicePdfGenerator {
  static const String pdfQualityStandard = 'print-ready-300-dpi';
  static const String accessibilityStandard = 'wcag-2.1-aa-compliant';

  // Professional PDF Generation Engine
  static Future<Uint8List> generatePdf({
    required Invoice invoice,
    String template = 'professional-standard',
    Watermark? watermark,
  }) async {

    final pdfDocument = pw.Document(
      version: PdfVersion.pdf_1_7,
      compress: true,

      info: pw.DocumentInfo(
        title: 'Invoice ${invoice.id}',
        author: invoice.businessProfile.companyInformation.name,
        subject: 'Professional Invoice',
        creator: 'Invoice Lite PDF Generator',
        producer: 'Toolspace Professional Tools',
        creationDate: DateTime.now(),
        keywords: [
          'invoice',
          'billing',
          'payment',
          invoice.businessProfile.companyInformation.name,
          invoice.clientProfile.businessName
        ]
      )
    );

    // Professional template loading
    final templateConfig = await TemplateManager.loadTemplate(template);
    final fonts = await FontManager.loadFonts(templateConfig.fontFamily);
    final theme = ThemeManager.createTheme(
      brandingConfig: invoice.businessProfile.brandingConfiguration,
      templateConfig: templateConfig
    );

    // Professional page generation
    pdfDocument.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),

        header: (context) => _buildPdfHeader(
          invoice: invoice,
          theme: theme,
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount
        ),

        footer: (context) => _buildPdfFooter(
          invoice: invoice,
          theme: theme,
          pageNumber: context.pageNumber,
          totalPages: context.pagesCount
        ),

        build: (context) => [
          _buildInvoiceHeader(invoice, theme),
          pw.SizedBox(height: 20),
          _buildClientInformation(invoice, theme),
          pw.SizedBox(height: 20),
          _buildInvoiceDetails(invoice, theme),
          pw.SizedBox(height: 20),
          _buildLineItemsTable(invoice, theme),
          pw.SizedBox(height: 20),
          _buildTotalsSection(invoice, theme),
          pw.SizedBox(height: 20),
          _buildPaymentInformation(invoice, theme),
          pw.SizedBox(height: 20),
          _buildTermsAndConditions(invoice, theme),
          if (watermark != null) _buildWatermark(watermark, theme)
        ]
      )
    );

    // Professional PDF optimization
    final pdfBytes = await pdfDocument.save();

    // Professional quality assurance
    final qualityCheck = await PdfQualityAssurance.validatePdf(
      pdfBytes: pdfBytes,
      standards: [
        PdfStandard.accessibility,
        PdfStandard.printQuality,
        PdfStandard.emailOptimized
      ]
    );

    if (!qualityCheck.passesAllStandards) {
      throw PdfGenerationException('PDF quality validation failed: ${qualityCheck.failures}');
    }

    return pdfBytes;
  }

  // Professional Line Items Table
  static pw.Widget _buildLineItemsTable(Invoice invoice, InvoiceTheme theme) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: theme.borderColor,
        width: 0.5
      ),

      columnWidths: {
        0: const pw.FlexColumnWidth(3), // Description
        1: const pw.FlexColumnWidth(1), // Quantity
        2: const pw.FlexColumnWidth(1.5), // Rate
        3: const pw.FlexColumnWidth(1.5), // Amount
      },

      children: [
        // Table header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: theme.headerBackgroundColor
          ),
          children: [
            _buildTableCell('Description', theme, isHeader: true),
            _buildTableCell('Qty', theme, isHeader: true),
            _buildTableCell('Rate', theme, isHeader: true),
            _buildTableCell('Amount', theme, isHeader: true),
          ]
        ),

        // Line items
        ...invoice.lineItems.map((item) => pw.TableRow(
          children: [
            _buildTableCell(
              '${item.description}\n${item.details ?? ''}',
              theme,
              multiline: true
            ),
            _buildTableCell(
              item.quantity.toString(),
              theme,
              alignment: pw.Alignment.center
            ),
            _buildTableCell(
              _formatCurrency(item.rate, invoice.businessProfile.defaultCurrency),
              theme,
              alignment: pw.Alignment.centerRight
            ),
            _buildTableCell(
              _formatCurrency(item.total, invoice.businessProfile.defaultCurrency),
              theme,
              alignment: pw.Alignment.centerRight
            ),
          ]
        )).toList(),
      ]
    );
  }
}
```

## Professional Cross-Tool Integration and Automation

### Comprehensive Integration Framework

```dart
// Professional Cross-Tool Integration Implementation
class InvoiceLiteIntegration {
  // Integration with File Merger for Document Attachments
  static Future<Map<String, dynamic>> attachDocumentsToInvoice({
    required String invoiceId,
    required List<String> documentPaths,
  }) async {

    final invoice = await InvoiceRepository.getInvoice(invoiceId);
    if (invoice == null) {
      throw InvoiceNotFoundException('Invoice not found: $invoiceId');
    }

    // Professional document processing
    final processedDocuments = <String, dynamic>{};

    for (final documentPath in documentPaths) {
      final documentBytes = await File(documentPath).readAsBytes();
      final documentMetadata = await DocumentAnalyzer.analyzeDocument(documentBytes);

      // Professional document optimization
      final optimizedBytes = await DocumentOptimizer.optimizeForAttachment(
        documentBytes: documentBytes,
        metadata: documentMetadata,
        maxSizeMb: 10,
        qualityPreservation: true
      );

      final attachmentId = UuidGenerator.generateV4();
      await InvoiceRepository.saveAttachment(
        invoiceId: invoiceId,
        attachmentId: attachmentId,
        documentBytes: optimizedBytes,
        metadata: documentMetadata
      );

      processedDocuments[attachmentId] = {
        'originalPath': documentPath,
        'size': optimizedBytes.length,
        'type': documentMetadata.mimeType,
        'optimized': optimizedBytes.length < documentBytes.length
      };
    }

    return {
      'operation': 'invoice-document-attachment',
      'invoiceId': invoiceId,
      'attachments': processedDocuments,
      'totalAttachments': processedDocuments.length,
      'integrationMetadata': {
        'processedBy': 'invoice-lite-file-integration',
        'optimizationApplied': true,
        'qualityPreserved': true
      }
    };
  }

  // Integration with QR Maker for Payment QR Codes
  static Future<Map<String, dynamic>> generatePaymentQrCode({
    required String invoiceId,
    QrCodeStyle? style,
  }) async {

    final invoice = await InvoiceRepository.getInvoice(invoiceId);
    final paymentLink = await PaymentRepository.getPaymentLink(invoiceId);

    if (invoice == null || paymentLink == null) {
      throw InvoiceProcessingException('Invoice or payment link not found');
    }

    final qrCodeData = QrCodeData(
      type: QrCodeType.url,
      content: paymentLink.url,
      metadata: {
        'invoiceId': invoiceId,
        'amount': invoice.calculations.total,
        'currency': invoice.businessProfile.defaultCurrency,
        'businessName': invoice.businessProfile.companyInformation.name
      }
    );

    final qrCodeResult = await QrMakerIntegration.generateQrCode(
      data: qrCodeData,
      style: style ?? QrCodeStyle.businessProfessional(),
      size: QrCodeSize.medium,
      errorCorrection: QrErrorCorrection.high
    );

    // Professional QR code integration
    await InvoiceRepository.saveQrCode(
      invoiceId: invoiceId,
      qrCodeBytes: qrCodeResult.imageBytes,
      qrCodeMetadata: qrCodeResult.metadata
    );

    return {
      'operation': 'payment-qr-code-generation',
      'invoiceId': invoiceId,
      'qrCodeSize': qrCodeResult.imageBytes.length,
      'paymentUrl': paymentLink.url,
      'integrationSuccess': true
    };
  }

  // Integration with Text Tools for Invoice Content
  static Future<Map<String, dynamic>> enhanceInvoiceContent({
    required String invoiceId,
    bool improveDescriptions = true,
    bool generateSummary = true,
    String? language,
  }) async {

    final invoice = await InvoiceRepository.getInvoice(invoiceId);
    if (invoice == null) {
      throw InvoiceNotFoundException('Invoice not found: $invoiceId');
    }

    final enhancementResults = <String, dynamic>{};

    if (improveDescriptions) {
      final improvedLineItems = <InvoiceLineItem>[];

      for (final lineItem in invoice.lineItems) {
        final enhancedDescription = await TextToolsIntegration.enhanceText(
          text: lineItem.description,
          enhancement: TextEnhancement.clarity,
          language: language ?? 'en-US'
        );

        improvedLineItems.add(
          lineItem.copyWith(
            description: enhancedDescription.enhancedText,
            details: enhancedDescription.improvementNotes
          )
        );
      }

      enhancementResults['improvedLineItems'] = improvedLineItems.length;
    }

    if (generateSummary) {
      final invoiceContent = _extractInvoiceContent(invoice);
      final summaryResult = await TextToolsIntegration.generateSummary(
        text: invoiceContent,
        summaryType: SummaryType.business,
        maxLength: 200
      );

      await InvoiceRepository.updateInvoiceSummary(
        invoiceId: invoiceId,
        summary: summaryResult.summary
      );

      enhancementResults['summaryGenerated'] = true;
      enhancementResults['summaryLength'] = summaryResult.summary.length;
    }

    return {
      'operation': 'invoice-content-enhancement',
      'invoiceId': invoiceId,
      'enhancements': enhancementResults,
      'integrationSuccess': true
    };
  }
}
```

---

**Tool Category**: Professional Business Operations and Financial Management  
**Integration Standards**: Stripe Connect API, PDF/A compliance, Multi-currency support  
**Security Level**: PCI DSS compliant payment processing with audit trails
