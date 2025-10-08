/// Stripe configuration for the toolspace app
///
/// This file contains the Stripe publishable key which is safe to expose
/// in client-side code. The secret key should NEVER be in client code.
class StripeConfig {
  /// Stripe publishable key (Test mode)
  /// Safe to expose in client-side code
  static const String publishableKey =
      'pk_test_51RxNzfQJjz2bfxmCmpfNb2X2x62KRBeTKGtnz19jPStogeQ4IS0ZRXL5N7vx71oqISBQV1LEIpuF8u6k8764i6Jz00q0I0xaV5';

  /// For production, use environment variables:
  /// ```dart
  /// static const String publishableKey = String.fromEnvironment(
  ///   'STRIPE_PUBLISHABLE_KEY',
  ///   defaultValue: publishableKey,
  /// );
  /// ```

  /// Merchant identifier for Apple Pay (if needed)
  static const String merchantIdentifier = 'merchant.com.toolspace';

  /// URL scheme for returning from payment flow
  static const String urlScheme = 'toolspace';
}
