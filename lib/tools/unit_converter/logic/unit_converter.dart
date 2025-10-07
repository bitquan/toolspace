/// Unit conversion engine supporting multiple categories
class UnitConverter {
  /// Convert value from one unit to another
  static double convert(
      double value, String fromUnit, String toUnit, String category) {
    if (fromUnit == toUnit) return value;

    // Convert to base unit first, then to target unit
    final baseValue = _toBaseUnit(value, fromUnit, category);
    return _fromBaseUnit(baseValue, toUnit, category);
  }

  /// Convert value to base unit for the category
  static double _toBaseUnit(double value, String unit, String category) {
    final conversions = _getConversions(category);
    return value * (conversions[unit] ?? 1.0);
  }

  /// Convert value from base unit to target unit
  static double _fromBaseUnit(double value, String unit, String category) {
    final conversions = _getConversions(category);
    return value / (conversions[unit] ?? 1.0);
  }

  /// Get conversion factors for a category (to base unit)
  static Map<String, double> _getConversions(String category) {
    switch (category.toLowerCase()) {
      case 'length':
        return {
          'meter': 1.0,
          'kilometer': 1000.0,
          'centimeter': 0.01,
          'millimeter': 0.001,
          'mile': 1609.344,
          'yard': 0.9144,
          'foot': 0.3048,
          'inch': 0.0254,
          'nautical mile': 1852.0,
        };
      case 'mass':
        return {
          'kilogram': 1.0,
          'gram': 0.001,
          'milligram': 0.000001,
          'ton': 1000.0,
          'pound': 0.453592,
          'ounce': 0.0283495,
          'stone': 6.35029,
        };
      case 'temperature':
        // Temperature requires special handling
        return {};
      case 'data storage':
        return {
          'byte': 1.0,
          'kilobyte': 1024.0,
          'megabyte': 1048576.0,
          'gigabyte': 1073741824.0,
          'terabyte': 1099511627776.0,
          'petabyte': 1125899906842624.0,
          'bit': 0.125,
          'kilobit': 128.0,
          'megabit': 131072.0,
          'gigabit': 134217728.0,
        };
      case 'time':
        return {
          'second': 1.0,
          'millisecond': 0.001,
          'microsecond': 0.000001,
          'nanosecond': 0.000000001,
          'minute': 60.0,
          'hour': 3600.0,
          'day': 86400.0,
          'week': 604800.0,
          'month': 2592000.0, // 30 days
          'year': 31536000.0, // 365 days
        };
      case 'area':
        return {
          'square meter': 1.0,
          'square kilometer': 1000000.0,
          'square centimeter': 0.0001,
          'square millimeter': 0.000001,
          'hectare': 10000.0,
          'acre': 4046.86,
          'square mile': 2589988.11,
          'square yard': 0.836127,
          'square foot': 0.092903,
          'square inch': 0.00064516,
        };
      case 'volume':
        return {
          'liter': 1.0,
          'milliliter': 0.001,
          'cubic meter': 1000.0,
          'cubic centimeter': 0.001,
          'gallon': 3.78541,
          'quart': 0.946353,
          'pint': 0.473176,
          'cup': 0.236588,
          'fluid ounce': 0.0295735,
          'tablespoon': 0.0147868,
          'teaspoon': 0.00492892,
        };
      default:
        return {};
    }
  }

  /// Special handling for temperature conversion
  static double convertTemperature(
      double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;

    // Convert to Celsius first
    double celsius;
    switch (fromUnit.toLowerCase()) {
      case 'celsius':
        celsius = value;
        break;
      case 'fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'kelvin':
        celsius = value - 273.15;
        break;
      default:
        return value;
    }

    // Convert from Celsius to target
    switch (toUnit.toLowerCase()) {
      case 'celsius':
        return celsius;
      case 'fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'kelvin':
        return celsius + 273.15;
      default:
        return value;
    }
  }

  /// Get all available categories
  static List<String> getCategories() {
    return [
      'Length',
      'Mass',
      'Temperature',
      'Data Storage',
      'Time',
      'Area',
      'Volume',
    ];
  }

  /// Get units for a category
  static List<String> getUnitsForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'length':
        return [
          'meter',
          'kilometer',
          'centimeter',
          'millimeter',
          'mile',
          'yard',
          'foot',
          'inch',
          'nautical mile',
        ];
      case 'mass':
        return [
          'kilogram',
          'gram',
          'milligram',
          'ton',
          'pound',
          'ounce',
          'stone',
        ];
      case 'temperature':
        return [
          'celsius',
          'fahrenheit',
          'kelvin',
        ];
      case 'data storage':
        return [
          'byte',
          'kilobyte',
          'megabyte',
          'gigabyte',
          'terabyte',
          'petabyte',
          'bit',
          'kilobit',
          'megabit',
          'gigabit',
        ];
      case 'time':
        return [
          'second',
          'millisecond',
          'microsecond',
          'nanosecond',
          'minute',
          'hour',
          'day',
          'week',
          'month',
          'year',
        ];
      case 'area':
        return [
          'square meter',
          'square kilometer',
          'square centimeter',
          'square millimeter',
          'hectare',
          'acre',
          'square mile',
          'square yard',
          'square foot',
          'square inch',
        ];
      case 'volume':
        return [
          'liter',
          'milliliter',
          'cubic meter',
          'cubic centimeter',
          'gallon',
          'quart',
          'pint',
          'cup',
          'fluid ounce',
          'tablespoon',
          'teaspoon',
        ];
      default:
        return [];
    }
  }

  /// Get common aliases for units
  static Map<String, List<String>> getUnitAliases() {
    return {
      'meter': ['m', 'meters', 'metre', 'metres'],
      'kilometer': ['km', 'kilometers', 'kilometre', 'kilometres'],
      'centimeter': ['cm', 'centimeters', 'centimetre', 'centimetres'],
      'millimeter': ['mm', 'millimeters', 'millimetre', 'millimetres'],
      'mile': ['mi', 'miles'],
      'yard': ['yd', 'yards'],
      'foot': ['ft', 'feet'],
      'inch': ['in', 'inches'],
      'kilogram': ['kg', 'kilograms'],
      'gram': ['g', 'grams'],
      'milligram': ['mg', 'milligrams'],
      'ton': ['t', 'tons', 'metric ton'],
      'pound': ['lb', 'lbs', 'pounds'],
      'ounce': ['oz', 'ounces'],
      'celsius': ['c', '°c', 'centigrade'],
      'fahrenheit': ['f', '°f'],
      'kelvin': ['k'],
      'byte': ['b', 'bytes'],
      'kilobyte': ['kb', 'kilobytes'],
      'megabyte': ['mb', 'megabytes'],
      'gigabyte': ['gb', 'gigabytes'],
      'terabyte': ['tb', 'terabytes'],
      'petabyte': ['pb', 'petabytes'],
      'bit': ['bits'],
      'second': ['s', 'sec', 'seconds'],
      'minute': ['min', 'minutes'],
      'hour': ['h', 'hr', 'hours'],
      'day': ['d', 'days'],
      'week': ['w', 'weeks'],
      'month': ['mo', 'months'],
      'year': ['y', 'yr', 'years'],
      'liter': ['l', 'liters', 'litre', 'litres'],
      'milliliter': ['ml', 'milliliters', 'millilitre', 'millilitres'],
      'gallon': ['gal', 'gallons'],
    };
  }
}
