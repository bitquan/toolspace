import 'package:flutter/material.dart';
import 'package:toolspace/auth/screens/account_screen.dart';
import 'package:toolspace/auth/screens/password_reset_screen.dart';
import 'package:toolspace/auth/screens/signin_screen.dart';
import 'package:toolspace/auth/screens/signup_screen.dart';
import 'package:toolspace/auth/screens/email_verification_screen.dart';
import 'package:toolspace/screens/billing/billing_cancel_screen.dart';
import 'package:toolspace/screens/billing/billing_success_screen.dart';
import 'package:toolspace/screens/home_screen.dart';
import 'package:toolspace/marketing/features_screen.dart';
import 'package:toolspace/marketing/pricing_screen.dart';
import 'package:toolspace/tools/audio_converter/audio_converter_screen.dart';
import 'package:toolspace/tools/audio_transcriber/audio_transcriber_screen.dart';
import 'package:toolspace/tools/codec_lab/codec_lab_screen.dart';
import 'package:toolspace/tools/csv_cleaner/csv_cleaner_screen.dart';
import 'package:toolspace/tools/file_compressor/file_compressor_screen.dart';
import 'package:toolspace/tools/file_merger/file_merger_screen.dart';
import 'package:toolspace/tools/id_gen/id_gen_screen.dart';
import 'package:toolspace/tools/image_resizer/image_resizer_screen.dart';
import 'package:toolspace/tools/invoice_lite/invoice_lite_screen.dart';
import 'package:toolspace/tools/json_doctor/json_doctor_screen.dart';
import 'package:toolspace/tools/json_flatten/json_flatten_screen.dart';
import 'package:toolspace/tools/md_to_pdf/md_to_pdf_screen.dart';
import 'package:toolspace/tools/palette_extractor/palette_extractor_screen.dart';
import 'package:toolspace/tools/password_gen/password_gen_screen.dart';
import 'package:toolspace/tools/qr_maker/qr_maker_screen.dart';
import 'package:toolspace/tools/regex_tester/regex_tester_screen.dart';
import 'package:toolspace/tools/subtitle_maker/subtitle_maker_screen.dart';
import 'package:toolspace/tools/text_diff/text_diff_screen.dart';
import 'package:toolspace/tools/text_tools/text_tools_screen.dart';
import 'package:toolspace/tools/time_convert/time_convert_screen.dart';
import 'package:toolspace/tools/unit_converter/unit_converter_screen.dart';
import 'package:toolspace/tools/url_short/url_short_screen.dart';
import 'package:toolspace/tools/video_converter/video_converter_screen.dart';

// Central router for Toolspace micro-tools
class ToolspaceRouter {
  // Core navigation
  static const String home = '/';
  static const String dashboard = '/dashboard';

  // Tool routes (23 tools total) - exactly matching docs/platform/routes.md
  static const String textTools = '/tools/text-tools';
  static const String fileMerger = '/tools/file-merger';
  static const String jsonDoctor = '/tools/json-doctor';
  static const String textDiff = '/tools/text-diff';
  static const String qrMaker = '/tools/qr-maker';
  static const String urlShort = '/tools/url-short';
  static const String codecLab = '/tools/codec-lab';
  static const String timeConvert = '/tools/time-convert';
  static const String regexTester = '/tools/regex-tester';
  static const String idGen = '/tools/id-gen';
  static const String paletteExtractor = '/tools/palette-extractor';
  static const String mdToPdf = '/tools/md-to-pdf';
  static const String csvCleaner = '/tools/csv-cleaner';
  static const String imageResizer = '/tools/image-resizer';
  static const String passwordGen = '/tools/password-gen';
  static const String jsonFlatten = '/tools/json-flatten';
  static const String unitConverter = '/tools/unit-converter';
  static const String invoiceLite = '/tools/invoice-lite';
  static const String audioConverter = '/tools/audio-converter';
  static const String fileCompressor = '/tools/file-compressor';
  static const String videoConverter = '/tools/video-converter';
  static const String audioTranscriber = '/tools/audio-transcriber';
  static const String subtitleMaker = '/tools/subtitle-maker';

  // Authentication routes
  static const String auth = '/auth';
  static const String authSignIn = '/auth/signin';
  static const String authSignUp = '/auth/signup';
  static const String authReset = '/auth/reset';
  static const String authVerify = '/auth/verify';
  static const String account = '/account';

  // Billing routes
  static const String billing = '/billing';
  static const String billingSuccess = '/billing/success';
  static const String billingCancel = '/billing/cancel';

  // Marketing routes
  static const String features = '/features';
  static const String pricing = '/pricing';

  // Development routes
  static const String devE2ePlayground = '/dev/e2e-playground';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Core navigation
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const HomeScreen()); // Dashboard redirects to home

      // Tool routes - all 23 tools using imported screens
      case textTools:
        return MaterialPageRoute(builder: (_) => const TextToolsScreen());
      case fileMerger:
        return MaterialPageRoute(builder: (_) => const FileMergerScreen());
      case jsonDoctor:
        return MaterialPageRoute(builder: (_) => const JsonDoctorScreen());
      case textDiff:
        return MaterialPageRoute(builder: (_) => const TextDiffScreen());
      case qrMaker:
        return MaterialPageRoute(builder: (_) => const QrMakerScreen());
      case urlShort:
        return MaterialPageRoute(builder: (_) => const UrlShortScreen());
      case codecLab:
        return MaterialPageRoute(builder: (_) => const CodecLabScreen());
      case timeConvert:
        return MaterialPageRoute(builder: (_) => const TimeConvertScreen());
      case regexTester:
        return MaterialPageRoute(builder: (_) => const RegexTesterScreen());
      case idGen:
        return MaterialPageRoute(builder: (_) => const IdGenScreen());
      case paletteExtractor:
        return MaterialPageRoute(builder: (_) => const PaletteExtractorScreen());
      case mdToPdf:
        return MaterialPageRoute(builder: (_) => const MdToPdfScreen());
      case csvCleaner:
        return MaterialPageRoute(builder: (_) => const CsvCleanerScreen());
      case imageResizer:
        return MaterialPageRoute(builder: (_) => const ImageResizerScreen());
      case passwordGen:
        return MaterialPageRoute(builder: (_) => const PasswordGenScreen());
      case jsonFlatten:
        return MaterialPageRoute(builder: (_) => const JsonFlattenScreen());
      case unitConverter:
        return MaterialPageRoute(builder: (_) => const UnitConverterScreen());
      case invoiceLite:
        return MaterialPageRoute(builder: (_) => const InvoiceLiteScreen());
      case audioConverter:
        return MaterialPageRoute(builder: (_) => const AudioConverterScreen());
      case fileCompressor:
        return MaterialPageRoute(builder: (_) => const FileCompressorScreen());
      case videoConverter:
        return MaterialPageRoute(builder: (_) => const VideoConverterScreen());
      case audioTranscriber:
        return MaterialPageRoute(builder: (_) => const AudioTranscriberScreen());
      case subtitleMaker:
        return MaterialPageRoute(builder: (_) => const SubtitleMakerScreen());

      // Authentication routes
      case auth:
      case authSignIn:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case authSignUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case authReset:
        return MaterialPageRoute(builder: (_) => const PasswordResetScreen());
      case authVerify:
        return MaterialPageRoute(builder: (_) => const EmailVerificationScreen());
      case account:
        return MaterialPageRoute(builder: (_) => const AccountScreen());

      // Billing routes
      case billing:
        return MaterialPageRoute(builder: (_) => const _BillingScreenPlaceholder());
      case billingSuccess:
        return MaterialPageRoute(builder: (_) => const BillingSuccessScreen());
      case billingCancel:
        return MaterialPageRoute(builder: (_) => const BillingCancelScreen());

      // Marketing routes
      case features:
        return MaterialPageRoute(builder: (_) => const FeaturesScreen());
      case pricing:
        return MaterialPageRoute(builder: (_) => const PricingScreen());

      // Development routes
      case devE2ePlayground:
        return MaterialPageRoute(builder: (_) => const _DevE2ePlaygroundScreenPlaceholder());

      default:
        return MaterialPageRoute(builder: (_) => const _NotFoundScreenPlaceholder());
    }
  }
}

// Temporary placeholder screens for missing implementations
class _BillingScreenPlaceholder extends StatelessWidget {
  const _BillingScreenPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing')),
      body: const Center(child: Text('Billing management — implementation needed')),
    );
  }
}

class _DevE2ePlaygroundScreenPlaceholder extends StatelessWidget {
  const _DevE2ePlaygroundScreenPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E2E Playground')),
      body: const Center(child: Text('E2E Testing Playground — development only')),
    );
  }
}

class _NotFoundScreenPlaceholder extends StatelessWidget {
  const _NotFoundScreenPlaceholder();
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

