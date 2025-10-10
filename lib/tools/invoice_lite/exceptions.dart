/// Custom exceptions for Invoice Lite operations
library;

/// Thrown when invoice data validation fails
class InvoiceValidationError implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  InvoiceValidationError(this.message, {this.fieldErrors});

  @override
  String toString() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final errors =
          fieldErrors!.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      return 'InvoiceValidationError: $message ($errors)';
    }
    return 'InvoiceValidationError: $message';
  }
}

/// Thrown when a paywall blocks an operation
class PaywallRequiredError implements Exception {
  final String message;
  final String requiredPlan;
  final String? currentPlan;

  PaywallRequiredError(
    this.message, {
    required this.requiredPlan,
    this.currentPlan,
  });

  @override
  String toString() =>
      'PaywallRequiredError: $message (requires: $requiredPlan, current: ${currentPlan ?? "free"})';
}
