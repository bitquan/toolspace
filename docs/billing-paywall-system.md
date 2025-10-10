# Billing Paywall System Documentation

## Overview

Toolspace implements a comprehensive billing and paywall system that controls access to premium features and heavy computational tools. The system is designed to provide a smooth user experience while enforcing subscription limits and encouraging upgrades.

## Architecture

### Core Components

1. **PaywallGuard Widget** - Wraps premium features with access control
2. **BillingService** - Manages subscription state and Stripe integration
3. **BillingTypes** - Type definitions for plans, features, and restrictions
4. **Pricing Configuration** - JSON-based feature and limit definitions

### PaywallGuard System

The PaywallGuard widget is the primary mechanism for protecting premium features:

```dart
PaywallGuard(
  feature: 'invoice_lite',
  child: InvoiceLiteScreen(),
  fallback: PremiumFeaturePaywall(
    featureName: 'Invoice Lite',
    description: 'Professional invoice generation',
  ),
)
```

**Key Features:**

- **Automatic Enforcement**: Checks user subscription status
- **Graceful Degradation**: Shows upgrade prompts instead of errors
- **Real-time Updates**: Responds to subscription changes
- **Feature-Specific**: Granular control per tool/feature

### Billing Service Integration

```dart
class BillingService {
  // Subscription management
  Stream<SubscriptionStatus> subscriptionStream;
  Future<bool> hasAccess(String feature);

  // Stripe integration
  Future<void> createCheckoutSession(String priceId);
  Future<void> createPortalSession();

  // Usage tracking
  Future<void> trackUsage(String feature);
  Future<UsageStats> getUsageStats();
}
```

## Feature Classification

### Free Tier Tools

- **Text Tools** - Basic text manipulation
- **JSON Doctor** - JSON validation and formatting
- **QR Maker** - QR code generation
- **URL Shortener** - Link shortening
- **Regex Tester** - Pattern matching
- **Time Converter** - Date/time utilities
- **ID Generator** - UUID and random ID generation
- **Password Generator** - Secure password creation

### Heavy/Premium Tools (PaywallGuard Protected)

- **Invoice Lite** - Professional invoice generation
- **Audio Converter** - Audio file format conversion
- **File Compressor** - File compression and optimization
- **Palette Extractor** - Advanced color analysis
- **MD to PDF** - Document conversion
- **CSV Cleaner** - Data processing and cleaning
- **Image Resizer** - Bulk image processing
- **JSON Flattener** - Complex data transformations
- **Unit Converter** - Engineering calculations

## Pricing Configuration

Located in `config/pricing.json`:

```json
{
  "plans": {
    "free": {
      "name": "Free",
      "price": 0,
      "features": ["basic_tools"],
      "limits": {
        "heavy_tool_uses": 0,
        "file_size_mb": 1,
        "api_calls_per_day": 10
      }
    },
    "pro": {
      "name": "Pro",
      "price": 9.99,
      "features": ["basic_tools", "heavy_tools", "priority_support"],
      "limits": {
        "heavy_tool_uses": -1,
        "file_size_mb": 50,
        "api_calls_per_day": 1000
      }
    }
  },
  "heavyTools": [
    "invoice_lite",
    "audio_converter",
    "file_compressor",
    "palette_extractor",
    "md_to_pdf",
    "csv_cleaner",
    "image_resizer",
    "json_flatten",
    "unit_converter"
  ]
}
```

## Implementation Patterns

### 1. Wrapping Premium Features

```dart
class PremiumToolScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PaywallGuard(
      feature: 'premium_tool',
      child: ActualToolImplementation(),
      fallback: PremiumFeaturePaywall(
        featureName: 'Premium Tool',
        description: 'Advanced functionality for power users',
        benefits: [
          'Unlimited usage',
          'Priority processing',
          'Advanced features',
        ],
      ),
    );
  }
}
```

### 2. Usage Tracking

```dart
class ToolScreen extends StatefulWidget {
  @override
  _ToolScreenState createState() => _ToolScreenState();
}

class _ToolScreenState extends State<ToolScreen> {
  final BillingService _billing = BillingService();

  Future<void> _performPremiumAction() async {
    if (await _billing.hasAccess('premium_feature')) {
      await _billing.trackUsage('premium_feature');
      // Perform the action
    } else {
      // Show upgrade prompt
      _showUpgradeDialog();
    }
  }
}
```

### 3. Subscription Monitoring

```dart
class AppStateManager extends ChangeNotifier {
  late StreamSubscription _subscriptionListener;

  void _initializeBilling() {
    _subscriptionListener = BillingService()
        .subscriptionStream
        .listen(_onSubscriptionChanged);
  }

  void _onSubscriptionChanged(SubscriptionStatus status) {
    // Update app state
    // Refresh paywall guards
    // Show/hide premium features
    notifyListeners();
  }
}
```

## User Experience Flow

### Free User Journey

1. **Discovery**: User encounters premium tool in navigation
2. **Soft Paywall**: PaywallGuard shows upgrade prompt with benefits
3. **Education**: Clear explanation of premium features and pricing
4. **Call-to-Action**: Simple upgrade buttons with Stripe checkout
5. **Trial Options**: Limited-time access or feature previews

### Premium User Journey

1. **Immediate Access**: No barriers to premium tools
2. **Usage Tracking**: Transparent usage statistics
3. **Value Demonstration**: Regular reminders of premium benefits
4. **Account Management**: Easy access to billing portal
5. **Feature Updates**: First access to new premium tools

### Upgrade Process

1. **Trigger**: User clicks upgrade from paywall or navigation
2. **Plan Selection**: Choose between available subscription tiers
3. **Stripe Checkout**: Secure payment processing
4. **Activation**: Immediate access to premium features
5. **Onboarding**: Welcome flow highlighting new capabilities

## Security Considerations

### Client-Side Validation

- PaywallGuard provides UI enforcement only
- All critical validations happen server-side
- Subscription status verified against Stripe webhooks
- Usage limits enforced by Firebase Functions

### Server-Side Enforcement

```javascript
// Firebase Function example
exports.validateFeatureAccess = functions.https.onCall(
  async (data, context) => {
    const userId = context.auth.uid;
    const feature = data.feature;

    // Check subscription status
    const subscription = await getSubscription(userId);

    // Validate feature access
    if (!hasAccess(subscription, feature)) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Premium subscription required"
      );
    }

    // Track usage
    await trackUsage(userId, feature);

    return { allowed: true };
  }
);
```

### Data Protection

- User billing data never stored in client
- Stripe handles all payment information
- Subscription status cached with TTL
- Regular validation against source of truth

## Analytics and Metrics

### Key Performance Indicators

1. **Conversion Rate**: Free to premium user upgrades
2. **Feature Adoption**: Usage of premium tools
3. **Churn Rate**: Subscription cancellations
4. **Usage Patterns**: Most/least popular premium features
5. **Revenue Metrics**: MRR, ARPU, LTV

### Tracking Implementation

```dart
class AnalyticsService {
  void trackPaywallImpression(String feature) {
    // Record when paywall is shown
  }

  void trackUpgradeClick(String source, String feature) {
    // Track conversion funnel
  }

  void trackFeatureUsage(String feature, Duration duration) {
    // Monitor feature engagement
  }

  void trackSubscriptionEvent(String event, Map<String, dynamic> properties) {
    // Billing lifecycle events
  }
}
```

## Testing Strategy

### Unit Tests

- PaywallGuard component behavior
- BillingService subscription logic
- Pricing configuration validation
- Usage tracking accuracy

### Integration Tests

- End-to-end upgrade flow
- Stripe webhook processing
- Feature access enforcement
- Cross-tool premium workflows

### E2E Testing

```dart
// E2E test example
testWidgets('Premium feature paywall flow', (tester) async {
  // Navigate to premium tool
  await tester.tap(find.text('Invoice Lite'));
  await tester.pumpAndSettle();

  // Verify paywall is shown
  expect(find.byType(PremiumFeaturePaywall), findsOneWidget);

  // Test upgrade button
  await tester.tap(find.text('Upgrade Now'));
  await tester.pumpAndSettle();

  // Verify checkout initiated
  expect(find.byType(StripeCheckout), findsOneWidget);
});
```

## Troubleshooting

### Common Issues

1. **Subscription Not Recognized**

   - Check Stripe webhook delivery
   - Verify user authentication
   - Refresh subscription cache

2. **PaywallGuard Not Working**

   - Confirm feature name matches pricing config
   - Check BillingService initialization
   - Verify subscription stream connectivity

3. **Checkout Flow Errors**
   - Validate Stripe configuration
   - Check network connectivity
   - Review error handling in UI

### Debug Tools

- **Billing Debug Panel**: Development-only billing state viewer
- **Stripe Dashboard**: Payment and subscription monitoring
- **Firebase Console**: Usage tracking and function logs
- **Analytics Dashboard**: User behavior and conversion metrics

## Best Practices

### Development

1. **Test with Free Account**: Always verify paywall behavior
2. **Mock Billing Service**: Use test modes for development
3. **Error Handling**: Graceful fallbacks for billing failures
4. **Progressive Enhancement**: Core features work without premium
5. **Clear Messaging**: Transparent pricing and feature communication

### Production

1. **Monitor Conversion**: Track paywall effectiveness
2. **A/B Testing**: Experiment with messaging and pricing
3. **Performance**: Minimize impact on app startup
4. **Security**: Regular security audits of billing flow
5. **Compliance**: Ensure GDPR/privacy regulation adherence

## Future Enhancements

### Planned Features

1. **Usage-Based Billing**: Pay-per-use for heavy operations
2. **Team Plans**: Multi-user subscriptions with admin controls
3. **Feature Bundles**: Granular feature selection
4. **Regional Pricing**: Location-based pricing optimization
5. **Enterprise Features**: Custom contracts and integrations

### Technical Improvements

1. **Offline Paywall**: Cache subscription status for offline use
2. **Smart Paywalls**: ML-driven upgrade prompts
3. **A/B Framework**: Built-in experimentation platform
4. **Advanced Analytics**: Behavioral cohort analysis
5. **Internationalization**: Multi-language billing flows

This billing system provides a robust foundation for monetizing Toolspace while maintaining excellent user experience and security standards.
