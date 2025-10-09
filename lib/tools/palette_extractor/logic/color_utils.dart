import 'dart:math';
import 'dart:ui';

/// Utility functions for color manipulation and conversion
class ColorUtils {
  /// Convert Color to hex string (e.g., "#FF5733")
  static String toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Convert Color to RGB string (e.g., "rgb(255, 87, 51)")
  static String toRgb(Color color) {
    final r = (color.r * 255.0).round() & 0xff;
    final g = (color.g * 255.0).round() & 0xff;
    final b = (color.b * 255.0).round() & 0xff;
    return 'rgb($r, $g, $b)';
  }

  /// Convert hex string to Color
  static Color fromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// Calculate Euclidean distance between two colors in RGB space
  static double colorDistance(Color a, Color b) {
    final ar = (a.r * 255.0).round() & 0xff;
    final ag = (a.g * 255.0).round() & 0xff;
    final ab = (a.b * 255.0).round() & 0xff;
    final br = (b.r * 255.0).round() & 0xff;
    final bg = (b.g * 255.0).round() & 0xff;
    final bb = (b.b * 255.0).round() & 0xff;
    final dr = ar - br;
    final dg = ag - bg;
    final db = ab - bb;
    return sqrt(dr * dr + dg * dg + db * db);
  }

  /// Calculate perceptual brightness of a color (0-255)
  static double brightness(Color color) {
    final r = (color.r * 255.0).round() & 0xff;
    final g = (color.g * 255.0).round() & 0xff;
    final b = (color.b * 255.0).round() & 0xff;
    // Using relative luminance formula
    return 0.299 * r + 0.587 * g + 0.114 * b;
  }

  /// Check if color is light (for contrast determination)
  static bool isLight(Color color) {
    return brightness(color) > 128;
  }

  /// Get contrasting text color (black or white) for given background
  static Color getContrastColor(Color backgroundColor) {
    return isLight(backgroundColor)
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
  }

  /// Mix two colors with given weight (0.0 to 1.0)
  static Color mix(Color a, Color b, double weight) {
    final ar = (a.r * 255.0).round() & 0xff;
    final ag = (a.g * 255.0).round() & 0xff;
    final ab = (a.b * 255.0).round() & 0xff;
    final br = (b.r * 255.0).round() & 0xff;
    final bg = (b.g * 255.0).round() & 0xff;
    final bb = (b.b * 255.0).round() & 0xff;
    final r = (ar * (1 - weight) + br * weight).round();
    final g = (ag * (1 - weight) + bg * weight).round();
    final bl = (ab * (1 - weight) + bb * weight).round();
    return Color.fromARGB(255, r, g, bl);
  }
}
