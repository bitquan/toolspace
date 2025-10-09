import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'color_utils.dart';

/// Export palette in various formats
class PaletteExporter {
  /// Export palette as JSON
  ///
  /// Format:
  /// ```json
  /// {
  ///   "name": "My Palette",
  ///   "colors": [
  ///     {"hex": "#FF5733", "rgb": "rgb(255, 87, 51)"},
  ///     ...
  ///   ]
  /// }
  /// ```
  static String exportJson(List<Color> colors,
      {String name = 'Extracted Palette'}) {
    final colorData = colors
        .map((color) => {
              'hex': ColorUtils.toHex(color),
              'rgb': ColorUtils.toRgb(color),
              'r': (color.r * 255.0).round() & 0xff,
              'g': (color.g * 255.0).round() & 0xff,
              'b': (color.b * 255.0).round() & 0xff,
            })
        .toList();

    final palette = {
      'name': name,
      'colors': colorData,
      'count': colors.length,
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(palette);
  }

  /// Export palette as Adobe Color (.aco) format
  ///
  /// ACO format specification:
  /// - Version 1: Simple color list
  /// - Version 2: With color names (optional)
  ///
  /// We export Version 1 format which is simpler and widely compatible
  static Uint8List exportAco(List<Color> colors) {
    final bytes = ByteData(4 + colors.length * 10);
    var offset = 0;

    // Version (2 bytes, big-endian)
    bytes.setUint16(offset, 1, Endian.big);
    offset += 2;

    // Number of colors (2 bytes, big-endian)
    bytes.setUint16(offset, colors.length, Endian.big);
    offset += 2;

    // Color data
    for (final color in colors) {
      // Color space (2 bytes, 0 = RGB)
      bytes.setUint16(offset, 0, Endian.big);
      offset += 2;

      // RGB values (6 bytes total, 2 bytes each, 0-65535 range)
      final r = (color.r * 255.0).round() & 0xff;
      final g = (color.g * 255.0).round() & 0xff;
      final b = (color.b * 255.0).round() & 0xff;
      bytes.setUint16(offset, (r * 257), Endian.big); // 257 = 65535/255
      offset += 2;
      bytes.setUint16(offset, (g * 257), Endian.big);
      offset += 2;
      bytes.setUint16(offset, (b * 257), Endian.big);
      offset += 2;
    }

    return bytes.buffer.asUint8List();
  }

  /// Export palette as CSS variables
  ///
  /// Format:
  /// ```css
  /// :root {
  ///   --color-1: #FF5733;
  ///   --color-2: #33FF57;
  /// }
  /// ```
  static String exportCss(List<Color> colors, {String prefix = 'color'}) {
    final buffer = StringBuffer();
    buffer.writeln(':root {');

    for (var i = 0; i < colors.length; i++) {
      final hex = ColorUtils.toHex(colors[i]);
      buffer.writeln('  --$prefix-${i + 1}: $hex;');
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  /// Export palette as SCSS variables
  ///
  /// Format:
  /// ```scss
  /// $color-1: #FF5733;
  /// $color-2: #33FF57;
  /// ```
  static String exportScss(List<Color> colors, {String prefix = 'color'}) {
    final buffer = StringBuffer();

    for (var i = 0; i < colors.length; i++) {
      final hex = ColorUtils.toHex(colors[i]);
      buffer.writeln('\$$prefix-${i + 1}: $hex;');
    }

    return buffer.toString();
  }

  /// Export palette as plain text (one hex color per line)
  static String exportPlainText(List<Color> colors) {
    return colors.map((color) => ColorUtils.toHex(color)).join('\n');
  }

  /// Get file extension for export format
  static String getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'json';
      case ExportFormat.aco:
        return 'aco';
      case ExportFormat.css:
        return 'css';
      case ExportFormat.scss:
        return 'scss';
      case ExportFormat.txt:
        return 'txt';
    }
  }

  /// Get MIME type for export format
  static String getMimeType(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'application/json';
      case ExportFormat.aco:
        return 'application/octet-stream';
      case ExportFormat.css:
      case ExportFormat.scss:
        return 'text/css';
      case ExportFormat.txt:
        return 'text/plain';
    }
  }
}

/// Available export formats
enum ExportFormat {
  json,
  aco,
  css,
  scss,
  txt,
}
