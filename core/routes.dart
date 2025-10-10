import 'package:flutter/material.dart';
import 'package:toolspace/tools/invoice_lite/invoice_lite_screen.dart';
import 'package:toolspace/tools/file_compressor/file_compressor_screen.dart';
import 'package:toolspace/tools/audio_converter/audio_converter_screen.dart';

// Central router for Toolspace micro-tools
class ToolspaceRouter {
  static const String home = '/';
  static const String quickInvoice = '/tools/quick-invoice';
  static const String invoiceLite = '/tools/invoice-lite';
  static const String fileCompressor = '/tools/file-compressor';
  static const String audioConverter = '/tools/audio-converter';
  static const String textTools = '/tools/text-tools';
  static const String fileMerger = '/tools/file-merger';
  static const String auth = '/auth';
  static const String billing = '/billing';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case quickInvoice:
        return MaterialPageRoute(
          builder: (_) => const QuickInvoiceScreen(),
        );
      case invoiceLite:
        return MaterialPageRoute(
          builder: (_) => const InvoiceLiteScreen(),
        );
      case fileCompressor:
        return MaterialPageRoute(
          builder: (_) => const FileCompressorScreen(),
        );
      case audioConverter:
        return MaterialPageRoute(
          builder: (_) => const AudioConverterScreen(),
        );
      case textTools:
        return MaterialPageRoute(
          builder: (_) => const TextToolsScreen(),
        );
      case fileMerger:
        return MaterialPageRoute(
          builder: (_) => const FileMergerScreen(),
        );
      case auth:
        return MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        );
      case billing:
        return MaterialPageRoute(
          builder: (_) => const BillingScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
        );
    }
  }
}

// Placeholder screens - will be implemented in respective tool directories
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toolspace')),
      body: const Center(
          child: Text('Welcome to Toolspace — micro tools coming soon.')),
    );
  }
}

class QuickInvoiceScreen extends StatelessWidget {
  const QuickInvoiceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Invoice')),
      body: const Center(child: Text('Quick Invoice tool — coming soon')),
    );
  }
}

class TextToolsScreen extends StatelessWidget {
  const TextToolsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Tools')),
      body: const Center(child: Text('Text Tools — coming soon')),
    );
  }
}

class FileMergerScreen extends StatelessWidget {
  const FileMergerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Merger')),
      body: const Center(child: Text('File Merger tool — coming soon')),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication')),
      body: const Center(child: Text('Authentication — coming soon')),
    );
  }
}

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing')),
      body: const Center(child: Text('Billing management — coming soon')),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('404 - Page Not Found'),
            SizedBox(height: 16),
            Text('The requested page does not exist.'),
          ],
        ),
      ),
    );
  }
}
