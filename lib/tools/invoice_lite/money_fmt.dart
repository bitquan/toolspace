/// Pure Dart money formatting utility with ISO-4217 currency support
library;

class MoneyFmt {
  /// Common ISO-4217 currency symbols
  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CNY': '¥',
    'INR': '₹',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'CHF': 'CHF',
    'SEK': 'kr',
    'NZD': 'NZ\$',
    'KRW': '₩',
    'SGD': 'S\$',
    'HKD': 'HK\$',
    'NOK': 'kr',
    'MXN': 'Mex\$',
    'BRL': 'R\$',
    'ZAR': 'R',
    'RUB': '₽',
    'TRY': '₺',
  };

  /// Decimal places for currencies (most use 2, some like JPY use 0)
  static const Map<String, int> _currencyDecimals = {
    'JPY': 0,
    'KRW': 0,
    'VND': 0,
    'CLP': 0,
    'ISK': 0,
  };

  /// Format an amount with currency code
  ///
  /// Examples:
  /// - format(1234.56, 'USD') => '$1,234.56'
  /// - format(1234.56, 'EUR') => '€1,234.56'
  /// - format(1234, 'JPY') => '¥1,234'
  static String format(double amount, String currencyCode) {
    final symbol = _currencySymbols[currencyCode] ?? currencyCode;
    final decimals = _currencyDecimals[currencyCode] ?? 2;
    
    // Round to appropriate decimal places
    final roundedAmount = _roundToDecimals(amount, decimals);
    
    // Format with thousands separator
    final formatted = _formatWithSeparator(roundedAmount, decimals);
    
    return '$symbol$formatted';
  }

  /// Format without symbol (just the number)
  static String formatPlain(double amount, String currencyCode) {
    final decimals = _currencyDecimals[currencyCode] ?? 2;
    final roundedAmount = _roundToDecimals(amount, decimals);
    return _formatWithSeparator(roundedAmount, decimals);
  }

  /// Get symbol for currency code
  static String getSymbol(String currencyCode) {
    return _currencySymbols[currencyCode] ?? currencyCode;
  }

  /// Validate currency code (basic ISO-4217 check)
  static bool isValidCurrency(String code) {
    if (code.length != 3) return false;
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) return false;
    return true;
  }

  // Internal helpers

  static double _roundToDecimals(double value, int decimals) {
    final multiplier = _pow10(decimals);
    return (value * multiplier).roundToDouble() / multiplier;
  }

  static String _formatWithSeparator(double amount, int decimals) {
    final parts = amount.toStringAsFixed(decimals).split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '';

    // Add thousands separators
    final buffer = StringBuffer();
    var count = 0;
    for (var i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
      count++;
    }

    // Reverse and add decimal part
    final formatted = buffer.toString().split('').reversed.join('');
    if (decimals > 0) {
      return '$formatted.$decPart';
    }
    return formatted;
  }

  static int _pow10(int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
}
