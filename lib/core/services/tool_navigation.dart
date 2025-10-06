import 'package:flutter/material.dart';
import '../../tools/text_tools/text_tools_screen.dart';
import '../../tools/json_doctor/json_doctor_screen.dart';
import '../../tools/qr_maker/qr_maker_screen.dart';
import '../../tools/text_diff/text_diff_screen.dart';
import '../../tools/file_merger/file_merger_screen.dart';
import '../ui/tool_transition.dart';
import 'tool_integration_service.dart';

/// Navigation helper for cross-tool workflows
class ToolNavigation {
  static final _integrationService = ToolIntegrationService();

  /// Navigate to a tool with optional data sharing
  static Future<void> navigateToTool(
    BuildContext context,
    String toolId, {
    Map<String, dynamic>? sharedData,
  }) async {
    // Store shared data if provided
    if (sharedData != null) {
      for (final entry in sharedData.entries) {
        _integrationService.shareData(entry.key, entry.value);
      }
    }

    // Get the tool screen
    final Widget? screen = _getToolScreen(toolId);
    if (screen == null) {
      debugPrint('Tool not found: $toolId');
      return;
    }

    // Navigate with animation
    await Navigator.of(context).push(
      ToolTransition.createRoute(screen),
    );
  }

  /// Navigate to Text Tools with optional text input
  static Future<void> toTextTools(
    BuildContext context, {
    String? initialText,
  }) async {
    await navigateToTool(
      context,
      'text-tools',
      sharedData: initialText != null ? {'input_text': initialText} : null,
    );
  }

  /// Navigate to JSON Doctor with optional JSON input
  static Future<void> toJsonDoctor(
    BuildContext context, {
    String? initialJson,
  }) async {
    await navigateToTool(
      context,
      'json-doctor',
      sharedData: initialJson != null ? {'input_json': initialJson} : null,
    );
  }

  /// Navigate to QR Maker with optional data
  static Future<void> toQrMaker(
    BuildContext context, {
    String? qrData,
  }) async {
    await navigateToTool(
      context,
      'qr-maker',
      sharedData: qrData != null ? {'qr_data': qrData} : null,
    );
  }

  /// Navigate to Text Diff with optional texts
  static Future<void> toTextDiff(
    BuildContext context, {
    String? text1,
    String? text2,
  }) async {
    final data = <String, dynamic>{};
    if (text1 != null) data['text1'] = text1;
    if (text2 != null) data['text2'] = text2;

    await navigateToTool(
      context,
      'text-diff',
      sharedData: data.isNotEmpty ? data : null,
    );
  }

  /// Navigate to File Merger
  static Future<void> toFileMerger(BuildContext context) async {
    await navigateToTool(context, 'file-merger');
  }

  static Widget? _getToolScreen(String toolId) {
    switch (toolId) {
      case 'text-tools':
        return const TextToolsScreen();
      case 'json-doctor':
        return const JsonDoctorScreen();
      case 'qr-maker':
        return const QrMakerScreen();
      case 'text-diff':
        return const TextDiffScreen();
      case 'file-merger':
        return const FileMergerScreen();
      default:
        return null;
    }
  }
}
