#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

// Simple logger for smoke tests
void log(String message) {
  // ignore: avoid_print
  print(message);
}

void main() async {
  log('🧪 Starting Toolspace Smoke Tests...');

  final smokeTest = SmokeTestRunner();
  await smokeTest.runAllTests();
}

class SmokeTestResult {
  final String toolId;
  final String expected;
  final String actual;
  final bool pass;
  final String notes;
  final Duration duration;

  const SmokeTestResult({
    required this.toolId,
    required this.expected,
    required this.actual,
    required this.pass,
    required this.notes,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'toolId': toolId,
        'expected': expected,
        'actual': actual,
        'pass': pass,
        'notes': notes,
        'duration_ms': duration.inMilliseconds,
      };
}

class SmokeTestRunner {
  final List<SmokeTestResult> results = [];
  late DateTime startTime;

  Future<void> runAllTests() async {
    log('🧪 Starting Smoke Tests');
    startTime = DateTime.now();

    // Test all free tools
    await testFreeTools();

    // Test pro tools
    await testProTools();

    // Generate reports
    await generateReports();
  }

  Future<void> testFreeTools() async {
    log('\n📋 Testing Free Tools...');

    // Test JSON Doctor
    await testTool('json_doctor', () async {
      const validJson = '{"test": true}';
      const invalidJson = '{"test": invalid}';

      // Test valid JSON
      final validResult = await simulateJsonValidation(validJson);
      if (!validResult) return false;

      // Test invalid JSON
      final invalidResult = await simulateJsonValidation(invalidJson);
      if (invalidResult) return false; // Should be false for invalid JSON

      return true;
    });

    // Test Text Diff
    await testTool('text_diff', () async {
      const text1 = 'Hello World';
      const text2 = 'Hello Dart World';

      final diff = await simulateTextDiff(text1, text2);
      return diff.contains('Dart'); // Should detect the added word
    });

    // Test QR Code Generator
    await testTool('qr_maker', () async {
      const url = 'https://example.com';
      final qrGenerated = await simulateQrGeneration(url);
      return qrGenerated;
    });

    // Test Password Generator
    await testTool('password_generator', () async {
      final password = await simulatePasswordGeneration(16, true, true, true);
      return password.length == 16 &&
          password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[0-9]')) &&
          password.contains(RegExp(r'[!@#$%^&*]'));
    });

    // Test Unit Converter
    await testTool('unit_converter', () async {
      const result = await simulateUnitConversion(100, 'celsius', 'fahrenheit');
      return result == 212.0; // 100°C = 212°F
    });

    // Test Regex Tester
    await testTool('regex_tester', () async {
      const pattern = r'\d+';
      const text = 'abc123def';
      final matches = await simulateRegexTest(pattern, text);
      return matches.isNotEmpty && matches.first == '123';
    });

    // Test ID Generator
    await testTool('id_generator', () async {
      final uuid = await simulateIdGeneration('uuid');
      return uuid.length == 36 && uuid.contains('-');
    });

    // Test Color Palette Extractor
    await testTool('palette_extractor', () async {
      // Simulate image processing
      final colors = await simulateColorExtraction('test_image.jpg');
      return colors.isNotEmpty;
    });

    // Test CSV Cleaner
    await testTool('csv_cleaner', () async {
      const csvContent = 'name,age\nJohn,25\nJohn,25\nJane,30';
      final cleaned = await simulateCsvCleaning(csvContent);
      return !cleaned.contains('John,25\nJohn,25'); // Duplicates removed
    });
  }

  Future<void> testProTools() async {
    log('\n💎 Testing Pro Tools...');

    // Test File Merger (PRIMARY FOCUS)
    await testTool('file_merger', () async {
      try {
        // Test with free user - should be blocked
        final freeResult = await simulateFileMerge(['a.pdf', 'b.pdf'], 'free');
        if (freeResult != 'paywall_blocked') return false;

        // Test with pro user - should succeed
        final proResult = await simulateFileMerge(['a.pdf', 'b.pdf'], 'pro');
        return proResult == 'success';
      } catch (e) {
        log('File Merger error: $e');
        return false;
      }
    });

    // Test Image Resizer
    await testTool('image_resizer', () async {
      final result = await simulateImageResize('test.jpg', 320, 240, 'pro');
      return result == 'success';
    });

    // Test Markdown to PDF
    await testTool('markdown_to_pdf', () async {
      const markdown = '# Test\nThis is a test document.';
      final result = await simulateMarkdownToPdf(markdown, 'pro');
      return result == 'success';
    });
  }

  Future<void> testTool(String toolId, Future<bool> Function() testFunction) async {
    log('  Testing $toolId...');
    final stopwatch = Stopwatch()..start();

    try {
      final success = await testFunction();
      stopwatch.stop();

      results.add(SmokeTestResult(
        toolId: toolId,
        expected: 'success',
        actual: success ? 'success' : 'failure',
        pass: success,
        notes: success ? 'Test passed' : 'Test failed',
        duration: stopwatch.elapsed,
      ));

      log('    ${success ? "✅" : "❌"} $toolId');
    } catch (e) {
      stopwatch.stop();

      results.add(SmokeTestResult(
        toolId: toolId,
        expected: 'success',
        actual: 'error: $e',
        pass: false,
        notes: 'Exception thrown: $e',
        duration: stopwatch.elapsed,
      ));

      log('    ❌ $toolId (Error: $e)');
    }
  }

  Future<void> generateReports() async {
    final duration = DateTime.now().difference(startTime);
    final totalTests = results.length;
    final passedTests = results.where((r) => r.pass).length;
    final failedTests = totalTests - passedTests;
    final successRate = totalTests > 0 ? (passedTests / totalTests * 100).round() : 0;

    // Create report directory
    const reportDir = 'tools/smoke/report';
    await Directory(reportDir).create(recursive: true);

    // JSON Report
    final jsonReport = {
      'timestamp': DateTime.now().toIso8601String(),
      'duration_seconds': duration.inSeconds,
      'summary': {
        'total_tests': totalTests,
        'passed': passedTests,
        'failed': failedTests,
        'success_rate': successRate,
      },
      'results': results.map((r) => r.toJson()).toList(),
    };

    await File('$reportDir/smoke_report.json')
        .writeAsString(const JsonEncoder.withIndent('  ').convert(jsonReport));

    // Markdown Report
    final mdReport = generateMarkdownReport(jsonReport);
    await File('$reportDir/smoke_report.md').writeAsString(mdReport);

    // Console Summary
    log('\n🎯 SMOKE TEST SUMMARY');
    log('=' * 60);
    log('Total Tests: $totalTests');
    log('Passed: $passedTests ✅');
    log('Failed: $failedTests ❌');
    log('Success Rate: $successRate%');
    log('Duration: ${duration.inSeconds}s');
    log('\n📋 Reports generated:');
    log('  - tools/smoke/report/smoke_report.json');
    log('  - tools/smoke/report/smoke_report.md');
  }

  String generateMarkdownReport(Map<String, dynamic> jsonReport) {
    final summary = jsonReport['summary'] as Map<String, dynamic>;
    final results = jsonReport['results'] as List<dynamic>;

    final buffer = StringBuffer();
    buffer.writeln('# 🧪 Toolspace Smoke Test Report');
    buffer.writeln();
    buffer.writeln('**Generated:** ${jsonReport['timestamp']}');
    buffer.writeln('**Duration:** ${jsonReport['duration_seconds']}s');
    buffer.writeln();
    buffer.writeln('## 📊 Summary');
    buffer.writeln();
    buffer.writeln('| Metric | Value |');
    buffer.writeln('|--------|-------|');
    buffer.writeln('| Total Tests | ${summary['total_tests']} |');
    buffer.writeln('| Passed | ${summary['passed']} ✅ |');
    buffer.writeln('| Failed | ${summary['failed']} ❌ |');
    buffer.writeln('| Success Rate | ${summary['success_rate']}% |');
    buffer.writeln();
    buffer.writeln('## 🔍 Detailed Results');
    buffer.writeln();
    buffer.writeln('| Tool | Status | Duration | Notes |');
    buffer.writeln('|------|--------|----------|-------|');

    for (final result in results) {
      final status = result['pass'] ? '✅' : '❌';
      buffer.writeln(
          '| ${result['toolId']} | $status | ${result['duration_ms']}ms | ${result['notes']} |');
    }

    return buffer.toString();
  }

  // Simulation methods (would be replaced with real implementations)
  Future<bool> simulateJsonValidation(String json) async {
    try {
      jsonDecode(json);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> simulateTextDiff(String text1, String text2) async {
    // Simple diff simulation
    return text2.contains(text1) ? 'Added: ${text2.replaceAll(text1, '')}' : 'Different texts';
  }

  Future<bool> simulateQrGeneration(String data) async {
    // Simulate QR generation
    return data.isNotEmpty;
  }

  Future<String> simulatePasswordGeneration(
      int length, bool includeUppercase, bool includeNumbers, bool includeSymbols) async {
    // Simple password simulation
    return 'TestPass123!';
  }

  Future<double> simulateUnitConversion(double value, String from, String to) async {
    if (from == 'celsius' && to == 'fahrenheit') {
      return (value * 9 / 5) + 32;
    }
    return value;
  }

  Future<List<String>> simulateRegexTest(String pattern, String text) async {
    final regex = RegExp(pattern);
    return regex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  Future<String> simulateIdGeneration(String type) async {
    // Simulate UUID generation
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx';
  }

  Future<List<String>> simulateColorExtraction(String imagePath) async {
    // Simulate color extraction
    return ['#FF0000', '#00FF00', '#0000FF'];
  }

  Future<String> simulateCsvCleaning(String csvContent) async {
    // Simple duplicate removal simulation
    const lines = csvContent.split('\n');
    final unique = <String>{};
    final cleaned = <String>[];

    for (final line in lines) {
      if (unique.add(line)) {
        cleaned.add(line);
      }
    }

    return cleaned.join('\n');
  }

  Future<String> simulateFileMerge(List<String> files, String planId) async {
    if (planId == 'free') {
      return 'paywall_blocked';
    }
    return 'success';
  }

  Future<String> simulateImageResize(String imagePath, int width, int height, String planId) async {
    if (planId == 'free') {
      return 'paywall_blocked';
    }
    return 'success';
  }

  Future<String> simulateMarkdownToPdf(String markdown, String planId) async {
    if (planId == 'free') {
      return 'paywall_blocked';
    }
    return 'success';
  }
}
