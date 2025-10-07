import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/unit_converter/logic/unit_converter.dart';
import 'package:toolspace/tools/unit_converter/logic/unit_search.dart';
import 'package:toolspace/tools/unit_converter/logic/conversion_history.dart';

void main() {
  group('UnitConverter Tests', () {
    test('converts length units correctly', () {
      expect(UnitConverter.convert(1, 'meter', 'meter', 'Length'), 1.0);
      expect(UnitConverter.convert(1, 'meter', 'kilometer', 'Length'), 0.001);
      expect(UnitConverter.convert(1, 'kilometer', 'meter', 'Length'), 1000.0);
      expect(UnitConverter.convert(1, 'meter', 'centimeter', 'Length'), 100.0);
      expect(UnitConverter.convert(1, 'mile', 'kilometer', 'Length'),
          closeTo(1.609344, 0.00001));
    });

    test('converts mass units correctly', () {
      expect(UnitConverter.convert(1, 'kilogram', 'kilogram', 'Mass'), 1.0);
      expect(UnitConverter.convert(1, 'kilogram', 'gram', 'Mass'), 1000.0);
      expect(UnitConverter.convert(1, 'ton', 'kilogram', 'Mass'), 1000.0);
      expect(UnitConverter.convert(1, 'pound', 'kilogram', 'Mass'),
          closeTo(0.453592, 0.00001));
    });

    test('converts temperature correctly', () {
      expect(UnitConverter.convertTemperature(0, 'celsius', 'celsius'), 0.0);
      expect(
          UnitConverter.convertTemperature(0, 'celsius', 'fahrenheit'), 32.0);
      expect(UnitConverter.convertTemperature(0, 'celsius', 'kelvin'), 273.15);
      expect(
          UnitConverter.convertTemperature(32, 'fahrenheit', 'celsius'), 0.0);
      expect(UnitConverter.convertTemperature(100, 'celsius', 'fahrenheit'),
          212.0);
      expect(
          UnitConverter.convertTemperature(273.15, 'kelvin', 'celsius'), 0.0);
    });

    test('converts data storage units correctly', () {
      expect(UnitConverter.convert(1, 'byte', 'byte', 'Data Storage'), 1.0);
      expect(
          UnitConverter.convert(1, 'kilobyte', 'byte', 'Data Storage'), 1024.0);
      expect(UnitConverter.convert(1, 'megabyte', 'kilobyte', 'Data Storage'),
          1024.0);
      expect(UnitConverter.convert(1, 'gigabyte', 'megabyte', 'Data Storage'),
          1024.0);
      expect(UnitConverter.convert(8, 'bit', 'byte', 'Data Storage'), 1.0);
    });

    test('converts time units correctly', () {
      expect(UnitConverter.convert(1, 'second', 'second', 'Time'), 1.0);
      expect(UnitConverter.convert(1, 'minute', 'second', 'Time'), 60.0);
      expect(UnitConverter.convert(1, 'hour', 'minute', 'Time'), 60.0);
      expect(UnitConverter.convert(1, 'day', 'hour', 'Time'), 24.0);
      expect(UnitConverter.convert(1, 'week', 'day', 'Time'), 7.0);
    });

    test('converts area units correctly', () {
      expect(UnitConverter.convert(1, 'square meter', 'square meter', 'Area'),
          1.0);
      expect(
          UnitConverter.convert(1, 'square kilometer', 'square meter', 'Area'),
          1000000.0);
      expect(
          UnitConverter.convert(1, 'hectare', 'square meter', 'Area'), 10000.0);
      expect(UnitConverter.convert(1, 'acre', 'square meter', 'Area'),
          closeTo(4046.86, 0.01));
    });

    test('converts volume units correctly', () {
      expect(UnitConverter.convert(1, 'liter', 'liter', 'Volume'), 1.0);
      expect(UnitConverter.convert(1, 'liter', 'milliliter', 'Volume'), 1000.0);
      expect(
          UnitConverter.convert(1, 'cubic meter', 'liter', 'Volume'), 1000.0);
      expect(UnitConverter.convert(1, 'gallon', 'liter', 'Volume'),
          closeTo(3.78541, 0.00001));
    });

    test('handles precision correctly', () {
      final result =
          UnitConverter.convert(1.234567, 'meter', 'centimeter', 'Length');
      expect(result, closeTo(123.4567, 0.0001));
    });

    test('returns all categories', () {
      final categories = UnitConverter.getCategories();
      expect(categories.length, 7);
      expect(categories, contains('Length'));
      expect(categories, contains('Mass'));
      expect(categories, contains('Temperature'));
      expect(categories, contains('Data Storage'));
      expect(categories, contains('Time'));
      expect(categories, contains('Area'));
      expect(categories, contains('Volume'));
    });

    test('returns units for each category', () {
      final lengthUnits = UnitConverter.getUnitsForCategory('Length');
      expect(lengthUnits, isNotEmpty);
      expect(lengthUnits, contains('meter'));
      expect(lengthUnits, contains('kilometer'));

      final massUnits = UnitConverter.getUnitsForCategory('Mass');
      expect(massUnits, isNotEmpty);
      expect(massUnits, contains('kilogram'));
      expect(massUnits, contains('gram'));
    });

    test('provides unit aliases', () {
      final aliases = UnitConverter.getUnitAliases();
      expect(aliases, isNotEmpty);
      expect(aliases['meter'], contains('m'));
      expect(aliases['kilogram'], contains('kg'));
      expect(aliases['celsius'], contains('°c'));
    });
  });

  group('UnitSearch Tests', () {
    test('finds exact matches', () {
      final results = UnitSearch.search('meter');
      expect(results, isNotEmpty);
      expect(results.first.unit, 'meter');
      expect(results.first.category, 'Length');
    });

    test('finds partial matches', () {
      final results = UnitSearch.search('kilo');
      expect(results, isNotEmpty);
      expect(results.any((r) => r.unit == 'kilometer'), true);
      expect(results.any((r) => r.unit == 'kilogram'), true);
      expect(results.any((r) => r.unit == 'kilobyte'), true);
    });

    test('finds matches through aliases', () {
      final results = UnitSearch.search('km');
      expect(results, isNotEmpty);
      expect(results.any((r) => r.unit == 'kilometer'), true);
    });

    test('ranks exact matches higher', () {
      final results = UnitSearch.search('meter');
      expect(results.first.unit, 'meter');
      expect(results.first.score, greaterThan(500));
    });

    test('returns empty for no matches', () {
      final results = UnitSearch.search('xyz123notarealunit');
      expect(results, isEmpty);
    });

    test('returns empty for empty query', () {
      final results = UnitSearch.search('');
      expect(results, isEmpty);
    });

    test('is case insensitive', () {
      final results1 = UnitSearch.search('METER');
      final results2 = UnitSearch.search('meter');
      expect(results1.length, results2.length);
      expect(results1.first.unit, results2.first.unit);
    });

    test('provides popular conversions', () {
      final popular = UnitSearch.getPopularConversions();
      expect(popular, isNotEmpty);
      expect(popular.length, greaterThanOrEqualTo(5));
      expect(popular.any((p) => p.category == 'Length'), true);
      expect(popular.any((p) => p.category == 'Temperature'), true);
    });

    test('search result has correct display name', () {
      final results = UnitSearch.search('km');
      final kmResult = results.firstWhere((r) => r.unit == 'kilometer');
      expect(kmResult.displayName, contains('kilometer'));
    });
  });

  group('ConversionHistory Tests', () {
    setUp(() {
      ConversionHistory.clear();
    });

    test('starts empty', () {
      expect(ConversionHistory.isEmpty, true);
      expect(ConversionHistory.size, 0);
    });

    test('adds conversion to history', () {
      final pair = ConversionPair(
        fromUnit: 'meter',
        toUnit: 'kilometer',
        category: 'Length',
      );
      ConversionHistory.add(pair);

      expect(ConversionHistory.isEmpty, false);
      expect(ConversionHistory.size, 1);
    });

    test('returns recent conversions', () {
      ConversionHistory.add(ConversionPair(
        fromUnit: 'meter',
        toUnit: 'kilometer',
        category: 'Length',
      ));
      ConversionHistory.add(ConversionPair(
        fromUnit: 'celsius',
        toUnit: 'fahrenheit',
        category: 'Temperature',
      ));

      final recent = ConversionHistory.getRecent();
      expect(recent.length, 2);
      expect(recent.first.fromUnit, 'celsius'); // Most recent first
    });

    test('removes duplicates', () {
      final pair = ConversionPair(
        fromUnit: 'meter',
        toUnit: 'kilometer',
        category: 'Length',
      );
      ConversionHistory.add(pair);
      ConversionHistory.add(pair);

      expect(ConversionHistory.size, 1);
    });

    test('limits history size', () {
      for (int i = 0; i < 25; i++) {
        ConversionHistory.add(ConversionPair(
          fromUnit: 'meter',
          toUnit: 'unit$i',
          category: 'Length',
        ));
      }

      expect(ConversionHistory.size, lessThanOrEqualTo(20));
    });

    test('can clear history', () {
      ConversionHistory.add(ConversionPair(
        fromUnit: 'meter',
        toUnit: 'kilometer',
        category: 'Length',
      ));
      ConversionHistory.clear();

      expect(ConversionHistory.isEmpty, true);
    });

    test('returns limited recent conversions', () {
      for (int i = 0; i < 15; i++) {
        ConversionHistory.add(ConversionPair(
          fromUnit: 'meter',
          toUnit: 'unit$i',
          category: 'Length',
        ));
      }

      final recent = ConversionHistory.getRecent(limit: 5);
      expect(recent.length, 5);
    });

    test('conversion pairs are equal when same units', () {
      final pair1 = ConversionPair(
        fromUnit: 'meter',
        toUnit: 'kilometer',
        category: 'Length',
      );
      final pair2 = ConversionPair(
        fromUnit: 'meter',
        toUnit: 'kilometer',
        category: 'Length',
      );

      expect(pair1, equals(pair2));
      expect(pair1.hashCode, equals(pair2.hashCode));
    });
  });

  group('Edge Cases', () {
    test('handles zero values', () {
      expect(UnitConverter.convert(0, 'meter', 'kilometer', 'Length'), 0.0);
      expect(
          UnitConverter.convertTemperature(0, 'celsius', 'fahrenheit'), 32.0);
    });

    test('handles negative values', () {
      expect(
          UnitConverter.convert(-5, 'meter', 'centimeter', 'Length'), -500.0);
      expect(UnitConverter.convertTemperature(-40, 'celsius', 'fahrenheit'),
          -40.0);
    });

    test('handles large values', () {
      expect(UnitConverter.convert(1000000, 'meter', 'kilometer', 'Length'),
          1000.0);
    });

    test('handles same unit conversion', () {
      expect(UnitConverter.convert(100, 'meter', 'meter', 'Length'), 100.0);
      expect(
          UnitConverter.convertTemperature(100, 'celsius', 'celsius'), 100.0);
    });

    test('handles decimal precision', () {
      final result =
          UnitConverter.convert(3.14159, 'meter', 'centimeter', 'Length');
      expect(result.toStringAsFixed(2), '314.16');
    });
  });
}
