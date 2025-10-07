import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/md_to_pdf/logic/pdf_exporter.dart';

void main() {
  group('ExportOptions Tests', () {
    test('should create ExportOptions with all parameters', () {
      const margins = PageMargins(
        top: 20,
        bottom: 20,
        left: 15,
        right: 15,
      );

      const options = ExportOptions(
        theme: 'github',
        pageSize: 'a4',
        includePageNumbers: true,
        margins: margins,
      );

      expect(options.theme, 'github');
      expect(options.pageSize, 'a4');
      expect(options.includePageNumbers, true);
      expect(options.margins.top, 20);
    });

    test('should convert ExportOptions to map', () {
      const margins = PageMargins(
        top: 20,
        bottom: 20,
        left: 15,
        right: 15,
      );

      const options = ExportOptions(
        theme: 'clean',
        pageSize: 'letter',
        includePageNumbers: false,
        margins: margins,
      );

      final map = options.toMap();

      expect(map['theme'], 'clean');
      expect(map['pageSize'], 'letter');
      expect(map['includePageNumbers'], false);
      expect(map['margins'], isA<Map>());
    });
  });

  group('PageMargins Tests', () {
    test('should create PageMargins with all values', () {
      const margins = PageMargins(
        top: 10,
        bottom: 15,
        left: 20,
        right: 25,
      );

      expect(margins.top, 10);
      expect(margins.bottom, 15);
      expect(margins.left, 20);
      expect(margins.right, 25);
    });

    test('should convert PageMargins to map', () {
      const margins = PageMargins(
        top: 10,
        bottom: 15,
        left: 20,
        right: 25,
      );

      final map = margins.toMap();

      expect(map['top'], 10);
      expect(map['bottom'], 15);
      expect(map['left'], 20);
      expect(map['right'], 25);
    });
  });
}
