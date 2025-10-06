import 'unit_converter.dart';

/// Fuzzy search implementation for units
class UnitSearch {
  /// Search for units across all categories
  static List<UnitSearchResult> search(String query) {
    if (query.isEmpty) return [];

    final results = <UnitSearchResult>[];
    final lowerQuery = query.toLowerCase();

    for (final category in UnitConverter.getCategories()) {
      final units = UnitConverter.getUnitsForCategory(category);
      
      for (final unit in units) {
        final score = _calculateMatchScore(lowerQuery, unit.toLowerCase());
        
        if (score > 0) {
          results.add(UnitSearchResult(
            unit: unit,
            category: category,
            score: score,
          ));
        }
      }

      // Also search through aliases
      final aliases = UnitConverter.getUnitAliases();
      for (final entry in aliases.entries) {
        final unit = entry.key;
        if (!units.contains(unit)) continue;
        
        for (final alias in entry.value) {
          final score = _calculateMatchScore(lowerQuery, alias.toLowerCase());
          
          if (score > 0) {
            // Check if we already have this unit in results
            final existing = results.where((r) => r.unit == unit && r.category == category).firstOrNull;
            if (existing != null) {
              // Update score if this is better
              if (score > existing.score) {
                results.remove(existing);
                results.add(UnitSearchResult(
                  unit: unit,
                  category: category,
                  score: score,
                  matchedAlias: alias,
                ));
              }
            } else {
              results.add(UnitSearchResult(
                unit: unit,
                category: category,
                score: score,
                matchedAlias: alias,
              ));
            }
          }
        }
      }
    }

    // Sort by score (descending)
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  /// Calculate match score using fuzzy matching
  static int _calculateMatchScore(String query, String target) {
    if (target == query) return 1000; // Exact match
    if (target.startsWith(query)) return 500; // Starts with
    if (target.contains(query)) return 250; // Contains

    // Fuzzy match - check if all query characters appear in order
    int queryIndex = 0;
    int matches = 0;
    
    for (int i = 0; i < target.length && queryIndex < query.length; i++) {
      if (target[i] == query[queryIndex]) {
        matches++;
        queryIndex++;
      }
    }

    if (queryIndex == query.length) {
      // All query characters found in order
      return 100 + matches * 10;
    }

    return 0;
  }

  /// Get popular conversion pairs
  static List<ConversionPair> getPopularConversions() {
    return [
      ConversionPair(
        fromUnit: 'kilometer',
        toUnit: 'mile',
        category: 'Length',
      ),
      ConversionPair(
        fromUnit: 'celsius',
        toUnit: 'fahrenheit',
        category: 'Temperature',
      ),
      ConversionPair(
        fromUnit: 'kilogram',
        toUnit: 'pound',
        category: 'Mass',
      ),
      ConversionPair(
        fromUnit: 'meter',
        toUnit: 'foot',
        category: 'Length',
      ),
      ConversionPair(
        fromUnit: 'liter',
        toUnit: 'gallon',
        category: 'Volume',
      ),
      ConversionPair(
        fromUnit: 'gigabyte',
        toUnit: 'megabyte',
        category: 'Data Storage',
      ),
    ];
  }
}

/// Result from unit search
class UnitSearchResult {
  final String unit;
  final String category;
  final int score;
  final String? matchedAlias;

  UnitSearchResult({
    required this.unit,
    required this.category,
    required this.score,
    this.matchedAlias,
  });

  String get displayName {
    if (matchedAlias != null) {
      return '$unit ($matchedAlias)';
    }
    return unit;
  }
}

/// Conversion pair for history and popular conversions
class ConversionPair {
  final String fromUnit;
  final String toUnit;
  final String category;
  final DateTime? timestamp;

  ConversionPair({
    required this.fromUnit,
    required this.toUnit,
    required this.category,
    this.timestamp,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversionPair &&
        other.fromUnit == fromUnit &&
        other.toUnit == toUnit &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(fromUnit, toUnit, category);
}
