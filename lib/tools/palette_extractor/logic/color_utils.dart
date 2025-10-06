import 'dart:math';
import 'dart:ui';

/// Utility functions for color manipulation and conversion
class ColorUtils {
  /// Convert Color to hex string (e.g., "#FF5733")
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Convert Color to RGB string (e.g., "rgb(255, 87, 51)")
  static String toRgb(Color color) {
    return 'rgb(${color.red}, ${color.green}, ${color.blue})';
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
    final dr = a.red - b.red;
    final dg = a.green - b.green;
    final db = a.blue - b.blue;
    return sqrt(dr * dr + dg * dg + db * db);
  }

  /// Calculate perceptual brightness of a color (0-255)
  static double brightness(Color color) {
    // Using relative luminance formula
    return 0.299 * color.red + 0.587 * color.green + 0.114 * color.blue;
  }

  /// Check if color is light (for contrast determination)
  static bool isLight(Color color) {
    return brightness(color) > 128;
  }

  /// Get contrasting text color (black or white) for given background
  static Color getContrastColor(Color backgroundColor) {
    return isLight(backgroundColor) ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  /// Mix two colors with given weight (0.0 to 1.0)
  static Color mix(Color a, Color b, double weight) {
    final r = (a.red * (1 - weight) + b.red * weight).round();
    final g = (a.green * (1 - weight) + b.green * weight).round();
    final bl = (a.blue * (1 - weight) + b.blue * weight).round();
    return Color.fromARGB(255, r, g, bl);
  }
}
