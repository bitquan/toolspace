/// Landing Page - Marketing website homepage
///
/// Features:
/// - Hero section with CTAs
/// - Features showcase
/// - Pricing section
/// - Social proof
/// - FAQ
/// - Footer
library;

import 'package:flutter/material.dart';
import 'widgets/hero_section.dart';
import 'widgets/features_grid.dart';
import 'widgets/pricing_section.dart';
import 'widgets/social_proof_section.dart';
import 'widgets/landing_footer.dart';
import 'widgets/landing_nav_bar.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: LandingNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            HeroSection(),

            SizedBox(height: 80),

            // Features Grid
            FeaturesGrid(),

            SizedBox(height: 80),

            // Pricing Section
            PricingSection(),

            SizedBox(height: 80),

            // Social Proof Section
            SocialProofSection(),

            SizedBox(height: 80),

            // Footer
            LandingFooter(),
          ],
        ),
      ),
    );
  }
}
