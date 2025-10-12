import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Simple widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Test Widget'),
        ),
      ),
    );

    expect(find.text('Test Widget'), findsOneWidget);
  });

  testWidgets('Basic Material app test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Simple Test')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Hello World'),
                Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Simple Test'), findsOneWidget);
    expect(find.text('Hello World'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
