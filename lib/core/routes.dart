import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/neo_home_screen.dart';
import '../screens/landing/landing_page.dart';
import '../marketing/features_screen.dart';
import '../marketing/pricing_screen.dart';
import '../tools/text_tools/text_tools_screen.dart';
import '../tools/file_merger/file_merger_screen.dart';
import '../tools/json_doctor/json_doctor_screen.dart';
import '../tools/text_diff/text_diff_screen.dart';
import '../tools/qr_maker/qr_maker_screen.dart';
import '../tools/url_short/url_short_screen.dart';
import '../tools/codec_lab/codec_lab_screen.dart';
import '../tools/time_convert/time_convert_screen.dart';
import '../tools/regex_tester/regex_tester_screen.dart';
import '../tools/id_gen/id_gen_screen.dart';
import '../tools/palette_extractor/palette_extractor_screen.dart';
import '../tools/md_to_pdf/md_to_pdf_screen.dart';
import '../tools/csv_cleaner/csv_cleaner_screen.dart';
import '../tools/image_resizer/image_resizer_screen.dart';
import '../tools/password_gen/password_gen_screen.dart';
import '../tools/json_flatten/json_flatten_screen.dart';
import '../tools/unit_converter/unit_converter_screen.dart';
import '../auth/screens/signin_screen.dart';
import '../auth/screens/signup_screen.dart';
import '../auth/screens/password_reset_screen.dart';
import '../auth/screens/email_verification_screen.dart';
import '../auth/screens/account_screen.dart';

// Central router for Toolspace micro-tools
class ToolspaceRouter {
  static const String home = '/';
  static const String dashboard = '/dashboard';
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
  static const String auth = '/auth';
  static const String authSignIn = '/auth/signin';
  static const String authSignUp = '/auth/signup';
  static const String authReset = '/auth/reset';
  static const String authVerify = '/auth/verify';
  static const String account = '/account';
  static const String billing = '/billing';
  static const String features = '/features';
  static const String pricing = '/pricing';
  static const String signup = '/signup';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        // TEMPORARY: Skip landing page due to rendering issues, go straight to dashboard
        return MaterialPageRoute(
          builder: (_) => const NeoHomeScreen(),
        );
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const NeoHomeScreen(),
        );
      case textTools:
        return MaterialPageRoute(
          builder: (_) => const TextToolsScreen(),
        );
      case fileMerger:
        return MaterialPageRoute(
          builder: (_) => const FileMergerScreen(),
        );
      case jsonDoctor:
        return MaterialPageRoute(
          builder: (_) => const JsonDoctorScreen(),
        );
      case textDiff:
        return MaterialPageRoute(
          builder: (_) => const TextDiffScreen(),
        );
      case qrMaker:
        return MaterialPageRoute(
          builder: (_) => const QrMakerScreen(),
        );
      case urlShort:
        return MaterialPageRoute(
          builder: (_) => const UrlShortScreen(),
        );
      case codecLab:
        return MaterialPageRoute(
          builder: (_) => const CodecLabScreen(),
        );
      case timeConvert:
        return MaterialPageRoute(
          builder: (_) => const TimeConvertScreen(),
        );
      case regexTester:
        return MaterialPageRoute(
          builder: (_) => const RegexTesterScreen(),
        );
      case idGen:
        return MaterialPageRoute(
          builder: (_) => const IdGenScreen(),
        );
      case paletteExtractor:
        return MaterialPageRoute(
          builder: (_) => const PaletteExtractorScreen(),
        );
      case mdToPdf:
        return MaterialPageRoute(
          builder: (_) => const MdToPdfScreen(),
        );
      case csvCleaner:
        return MaterialPageRoute(
          builder: (_) => const CsvCleanerScreen(),
        );
      case imageResizer:
        return MaterialPageRoute(
          builder: (_) => const ImageResizerScreen(),
        );
      case passwordGen:
        return MaterialPageRoute(
          builder: (_) => const PasswordGenScreen(),
        );
      case jsonFlatten:
        return MaterialPageRoute(
          builder: (_) => const JsonFlattenScreen(),
        );
      case unitConverter:
        return MaterialPageRoute(
          builder: (_) => const UnitConverterScreen(),
        );
      case auth:
        return MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        );
      case authSignIn:
        return MaterialPageRoute(
          builder: (_) => const SignInScreen(),
        );
      case authSignUp:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
        );
      case authReset:
        return MaterialPageRoute(
          builder: (_) => const PasswordResetScreen(),
        );
      case authVerify:
        return MaterialPageRoute(
          builder: (_) => const EmailVerificationScreen(),
        );
      case account:
        return MaterialPageRoute(
          builder: (_) => const AccountScreen(),
        );
      case billing:
        return MaterialPageRoute(
          builder: (_) => const BillingScreen(),
        );
      case features:
        return MaterialPageRoute(
          builder: (_) => const FeaturesScreen(),
        );
      case pricing:
        return MaterialPageRoute(
          builder: (_) => const PricingScreen(),
        );
      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
        );
    }
  }
}

// Placeholder screens for future features
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
