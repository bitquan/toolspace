import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/palette_extractor/logic/color_utils.dart';

void main() {
  group('ColorUtils Tests', () {
    test('converts Color to hex string correctly', () {
      const color = Color(0xFFFF5733);
      final hex = ColorUtils.toHex(color);

      expect(hex, equals('#FF5733'));
    });

    test('converts Color to RGB string correctly', () {
      const color = Color(0xFFFF5733);
      final rgb = ColorUtils.toRgb(color);

      expect(rgb, equals('rgb(255, 87, 51)'));
    });

    test('converts hex string to Color correctly', () {
      const hex = '#FF5733';
      final color = ColorUtils.fromHex(hex);

      expect(((color.r * 255.0).round() & 0xff), equals(255));
      expect(((color.g * 255.0).round() & 0xff), equals(87));
      expect(((color.b * 255.0).round() & 0xff), equals(51));
    });

    test('converts hex string without # to Color correctly', () {
      const hex = 'FF5733';
      final color = ColorUtils.fromHex(hex);

      expect(((color.r * 255.0).round() & 0xff), equals(255));
      expect(((color.g * 255.0).round() & 0xff), equals(87));
      expect(((color.b * 255.0).round() & 0xff), equals(51));
    });

    test('calculates color distance correctly', () {
      const color1 = Color(0xFFFF0000); // Red
      const color2 = Color(0xFF00FF00); // Green

      final distance = ColorUtils.colorDistance(color1, color2);

      expect(distance, greaterThan(0));
      expect(distance, closeTo(360.62, 0.1)); // sqrt(255^2 + 255^2)
    });

    test('calculates color distance for same color as zero', () {
      const color1 = Color(0xFFFF5733);
      const color2 = Color(0xFFFF5733);

      final distance = ColorUtils.colorDistance(color1, color2);

      expect(distance, equals(0));
    });

    test('calculates brightness correctly for white', () {
      const white = Color(0xFFFFFFFF);
      final brightness = ColorUtils.brightness(white);

      expect(brightness, equals(255));
    });

    test('calculates brightness correctly for black', () {
      const black = Color(0xFF000000);
      final brightness = ColorUtils.brightness(black);

      expect(brightness, equals(0));
    });

    test('identifies light colors correctly', () {
      const lightColor = Color(0xFFFFFFFF);
      const darkColor = Color(0xFF000000);

      expect(ColorUtils.isLight(lightColor), isTrue);
      expect(ColorUtils.isLight(darkColor), isFalse);
    });

    test('gets correct contrast color for light background', () {
      const lightBg = Color(0xFFFFFFFF);
      final textColor = ColorUtils.getContrastColor(lightBg);

      expect(textColor, equals(const Color(0xFF000000)));
    });

    test('gets correct contrast color for dark background', () {
      const darkBg = Color(0xFF000000);
      final textColor = ColorUtils.getContrastColor(darkBg);

      expect(textColor, equals(const Color(0xFFFFFFFF)));
    });

    test('mixes two colors correctly', () {
      const red = Color(0xFFFF0000);
      const blue = Color(0xFF0000FF);

      final mixed = ColorUtils.mix(red, blue, 0.5);

      // Should be purple-ish (mix of red and blue)
      expect(((mixed.r * 255.0).round() & 0xff), lessThan(255));
      expect(((mixed.b * 255.0).round() & 0xff), greaterThan(0));
    });

    test('mixes colors with weight 0 returns first color', () {
      const red = Color(0xFFFF0000);
      const blue = Color(0xFF0000FF);

      final mixed = ColorUtils.mix(red, blue, 0.0);

      expect(((mixed.r * 255.0).round() & 0xff),
          equals(((red.r * 255.0).round() & 0xff)));
      expect(((mixed.b * 255.0).round() & 0xff),
          equals(((red.b * 255.0).round() & 0xff)));
    });

    test('mixes colors with weight 1 returns second color', () {
      const red = Color(0xFFFF0000);
      const blue = Color(0xFF0000FF);

      final mixed = ColorUtils.mix(red, blue, 1.0);

      expect(((mixed.r * 255.0).round() & 0xff),
          equals(((blue.r * 255.0).round() & 0xff)));
      expect(((mixed.b * 255.0).round() & 0xff),
          equals(((blue.b * 255.0).round() & 0xff)));
    });
  });
}
