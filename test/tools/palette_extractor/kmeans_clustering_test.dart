import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/palette_extractor/logic/kmeans_clustering.dart';

void main() {
  group('KMeansClustering Tests', () {
    test('extracts palette from single color', () async {
      final pixels = List.filled(100, const Color(0xFFFF0000));

      final result = await KMeansClustering.extractPalette(pixels, k: 5);

      expect(result.colors.length, equals(1));
      expect(result.colors.first.red, equals(255));
      expect(result.frequencies.first, equals(100));
    });

    test('extracts palette from two distinct colors', () async {
      final pixels = [
        ...List.filled(50, const Color(0xFFFF0000)), // Red
        ...List.filled(50, const Color(0xFF0000FF)), // Blue
      ];

      final result = await KMeansClustering.extractPalette(pixels, k: 5);

      expect(result.colors.length, greaterThanOrEqualTo(2));
      expect(result.totalPixels, equals(100));
    });

    test(
        'extracts correct number of colors when k is smaller than unique colors',
        () async {
      final pixels = [
        ...List.filled(25, const Color(0xFFFF0000)), // Red
        ...List.filled(25, const Color(0xFF00FF00)), // Green
        ...List.filled(25, const Color(0xFF0000FF)), // Blue
        ...List.filled(25, const Color(0xFFFFFF00)), // Yellow
      ];

      final result = await KMeansClustering.extractPalette(pixels, k: 2);

      expect(result.colors.length, lessThanOrEqualTo(2));
    });

    test('handles empty pixel list', () async {
      final pixels = <Color>[];

      final result = await KMeansClustering.extractPalette(pixels, k: 5);

      expect(result.colors.isEmpty, isTrue);
      expect(result.frequencies.isEmpty, isTrue);
    });

    test('sorts colors by frequency (most common first)', () async {
      final pixels = [
        ...List.filled(70, const Color(0xFFFF0000)), // Red - most common
        ...List.filled(30, const Color(0xFF0000FF)), // Blue - less common
      ];

      final result = await KMeansClustering.extractPalette(pixels, k: 5);

      expect(result.frequencies.first,
          greaterThanOrEqualTo(result.frequencies.last));
    });

    test('calculates percentage correctly', () async {
      final pixels = [
        ...List.filled(75, const Color(0xFFFF0000)),
        ...List.filled(25, const Color(0xFF0000FF)),
      ];

      final result = await KMeansClustering.extractPalette(pixels, k: 5);

      final firstPercentage = result.getPercentage(0);
      expect(firstPercentage, greaterThan(50));
      expect(firstPercentage, lessThanOrEqualTo(100));
    });

    test('handles sample size limitation', () async {
      final pixels = List.filled(100000, const Color(0xFFFF0000));

      final result = await KMeansClustering.extractPalette(
        pixels,
        k: 5,
        sampleSize: 1000,
      );

      expect(result.colors.isNotEmpty, isTrue);
    });

    test('color frequencies sum to total pixels', () async {
      final pixels = [
        ...List.filled(30, const Color(0xFFFF0000)),
        ...List.filled(40, const Color(0xFF00FF00)),
        ...List.filled(30, const Color(0xFF0000FF)),
      ];

      final result = await KMeansClustering.extractPalette(pixels, k: 5);

      final totalFreq = result.frequencies.fold(0, (sum, f) => sum + f);
      expect(totalFreq, equals(pixels.length));
    });

    test('extracts similar colors when k is larger than unique colors',
        () async {
      final pixels = List.filled(100, const Color(0xFFFF0000));

      final result = await KMeansClustering.extractPalette(pixels, k: 10);

      // Should still extract only the colors present
      expect(result.colors.length, lessThanOrEqualTo(10));
    });

    test('PaletteResult getColorFrequency returns correct data', () async {
      final pixels = List.filled(100, const Color(0xFFFF0000));

      final result = await KMeansClustering.extractPalette(pixels, k: 5);

      final cf = result.getColorFrequency(0);
      expect(cf.color, equals(result.colors[0]));
      expect(cf.frequency, equals(result.frequencies[0]));
    });
  });
}
