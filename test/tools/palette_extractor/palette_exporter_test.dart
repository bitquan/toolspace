import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/palette_extractor/logic/palette_exporter.dart';

void main() {
  group('PaletteExporter Tests', () {
    final testColors = [
      const Color(0xFFFF5733),
      const Color(0xFF33FF57),
      const Color(0xFF3357FF),
    ];

    test('exports JSON correctly', () {
      final json = PaletteExporter.exportJson(testColors);
      final decoded = jsonDecode(json);

      expect(decoded['name'], equals('Extracted Palette'));
      expect(decoded['count'], equals(3));
      expect(decoded['colors'].length, equals(3));
      expect(decoded['colors'][0]['hex'], equals('#FF5733'));
      expect(decoded['colors'][0]['rgb'], equals('rgb(255, 87, 51)'));
    });

    test('exports JSON with custom name', () {
      final json = PaletteExporter.exportJson(testColors, name: 'My Custom Palette');
      final decoded = jsonDecode(json);

      expect(decoded['name'], equals('My Custom Palette'));
    });

    test('exports ACO format correctly', () {
      final aco = PaletteExporter.exportAco(testColors);

      expect(aco.length, equals(4 + testColors.length * 10));

      // Check version (first 2 bytes)
      expect(aco[0], equals(0));
      expect(aco[1], equals(1));

      // Check color count (next 2 bytes)
      expect(aco[2], equals(0));
      expect(aco[3], equals(3));
    });

    test('exports CSS correctly', () {
      final css = PaletteExporter.exportCss(testColors);

      expect(css, contains(':root {'));
      expect(css, contains('--color-1: #FF5733;'));
      expect(css, contains('--color-2: #33FF57;'));
      expect(css, contains('--color-3: #3357FF;'));
      expect(css, contains('}'));
    });

    test('exports CSS with custom prefix', () {
      final css = PaletteExporter.exportCss(testColors, prefix: 'palette');

      expect(css, contains('--palette-1: #FF5733;'));
      expect(css, contains('--palette-2: #33FF57;'));
    });

    test('exports SCSS correctly', () {
      final scss = PaletteExporter.exportScss(testColors);

      expect(scss, contains('\$color-1: #FF5733;'));
      expect(scss, contains('\$color-2: #33FF57;'));
      expect(scss, contains('\$color-3: #3357FF;'));
    });

    test('exports SCSS with custom prefix', () {
      final scss = PaletteExporter.exportScss(testColors, prefix: 'palette');

      expect(scss, contains('\$palette-1: #FF5733;'));
      expect(scss, contains('\$palette-2: #33FF57;'));
    });

    test('exports plain text correctly', () {
      final txt = PaletteExporter.exportPlainText(testColors);

      expect(txt, equals('#FF5733\n#33FF57\n#3357FF'));
    });

    test('returns correct file extension for each format', () {
      expect(PaletteExporter.getFileExtension(ExportFormat.json), equals('json'));
      expect(PaletteExporter.getFileExtension(ExportFormat.aco), equals('aco'));
      expect(PaletteExporter.getFileExtension(ExportFormat.css), equals('css'));
      expect(PaletteExporter.getFileExtension(ExportFormat.scss), equals('scss'));
      expect(PaletteExporter.getFileExtension(ExportFormat.txt), equals('txt'));
    });

    test('returns correct MIME type for each format', () {
      expect(PaletteExporter.getMimeType(ExportFormat.json), equals('application/json'));
      expect(PaletteExporter.getMimeType(ExportFormat.aco), equals('application/octet-stream'));
      expect(PaletteExporter.getMimeType(ExportFormat.css), equals('text/css'));
      expect(PaletteExporter.getMimeType(ExportFormat.scss), equals('text/css'));
      expect(PaletteExporter.getMimeType(ExportFormat.txt), equals('text/plain'));
    });

    test('handles empty color list', () {
      final emptyColors = <Color>[];

      final json = PaletteExporter.exportJson(emptyColors);
      final decoded = jsonDecode(json);
      expect(decoded['count'], equals(0));
      expect(decoded['colors'].length, equals(0));

      final css = PaletteExporter.exportCss(emptyColors);
      expect(css, equals(':root {\n}\n'));

      final txt = PaletteExporter.exportPlainText(emptyColors);
      expect(txt, equals(''));
    });

    test('ACO format includes RGB values correctly', () {
      final singleColor = [const Color(0xFFFF0000)]; // Pure red
      final aco = PaletteExporter.exportAco(singleColor);

      // Color space should be 0 (RGB)
      expect(aco[4], equals(0));
      expect(aco[5], equals(0));

      // Red value (2 bytes, big-endian, 0-65535 range)
      final redValue = (aco[6] << 8) | aco[7];
      expect(redValue, equals(255 * 257));

      // Green value
      final greenValue = (aco[8] << 8) | aco[9];
      expect(greenValue, equals(0));

      // Blue value
      final blueValue = (aco[10] << 8) | aco[11];
      expect(blueValue, equals(0));
    });
  });
}
