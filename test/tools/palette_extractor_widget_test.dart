import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/tools/palette_extractor/palette_extractor_screen.dart';
import 'package:toolspace/tools/palette_extractor/widgets/image_upload_zone.dart';
import 'package:toolspace/tools/palette_extractor/widgets/color_swatch_card.dart';

void main() {
  group('PaletteExtractorScreen Widget Tests', () {
    testWidgets('displays app bar with correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaletteExtractorScreen(),
        ),
      );

      expect(find.text('Color Palette Extractor'), findsOneWidget);
      expect(find.byIcon(Icons.palette), findsOneWidget);
    });

    testWidgets('displays image upload zone', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaletteExtractorScreen(),
        ),
      );

      expect(find.byType(ImageUploadZone), findsOneWidget);
    });

    testWidgets('displays empty state message initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaletteExtractorScreen(),
        ),
      );

      expect(find.text('Upload an image to extract its color palette'),
          findsOneWidget);
      expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
    });

    testWidgets('displays color count slider', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaletteExtractorScreen(),
        ),
      );

      expect(find.byType(Slider), findsOneWidget);
      expect(find.textContaining('Number of colors:'), findsOneWidget);
    });

    testWidgets('does not show export button without palette',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaletteExtractorScreen(),
        ),
      );

      expect(find.byIcon(Icons.download), findsNothing);
    });

    testWidgets('slider adjusts color count', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaletteExtractorScreen(),
        ),
      );

      // Initial value
      expect(find.text('Number of colors: 10'), findsOneWidget);

      // Move slider
      await tester.drag(find.byType(Slider), const Offset(100, 0));
      await tester.pump();

      // Value should have changed
      expect(find.text('Number of colors: 10'), findsNothing);
    });
  });

  group('ImageUploadZone Widget Tests', () {
    testWidgets('displays upload prompt when no image',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageUploadZone(
              onImageSelected: () {},
              hasImage: false,
            ),
          ),
        ),
      );

      expect(
          find.text('Tap to select an image or drag & drop'), findsOneWidget);
      expect(find.text('PNG, JPG, WebP • Max 10MB'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('displays different message when image loaded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageUploadZone(
              onImageSelected: () {},
              hasImage: true,
            ),
          ),
        ),
      );

      expect(find.text('Tap to select a different image'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays extracting message when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageUploadZone(
              onImageSelected: () {},
              isEnabled: false,
            ),
          ),
        ),
      );

      expect(find.text('Extracting colors...'), findsOneWidget);
    });

    testWidgets('calls onImageSelected when tapped',
        (WidgetTester tester) async {
      var called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageUploadZone(
              onImageSelected: () => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ImageUploadZone));
      await tester.pump();

      expect(called, isTrue);
    });
  });

  group('ColorSwatchCard Widget Tests', () {
    testWidgets('displays color information', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColorSwatchCard(
              color: Color(0xFFFF5733),
              index: 0,
              percentage: 45.5,
            ),
          ),
        ),
      );

      expect(find.text('#1'), findsOneWidget);
      expect(find.text('45.5%'), findsOneWidget);
      expect(find.text('#FF5733'), findsOneWidget);
      expect(find.text('rgb(255, 87, 51)'), findsOneWidget);
    });

    testWidgets('displays copy buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColorSwatchCard(
              color: Color(0xFFFF5733),
              index: 0,
            ),
          ),
        ),
      );

      expect(find.text('HEX'), findsOneWidget);
      expect(find.text('RGB'), findsOneWidget);
    });

    testWidgets('works without percentage', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColorSwatchCard(
              color: Color(0xFFFF5733),
              index: 0,
            ),
          ),
        ),
      );

      expect(find.text('#1'), findsOneWidget);
      expect(find.text('#FF5733'), findsOneWidget);
      // Percentage should not be displayed
      expect(find.textContaining('%'), findsNothing);
    });
  });
}
