import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class StaticContentScreen extends StatelessWidget {
  final String title;
  final String body;

  const StaticContentScreen({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          body,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

const String kDummyAboutUs = '''
Ezy Cable Digi is a field collection and customer management solution for LCO operations.

This application helps agents collect payments, print receipts, track customer locations, and work in offline mode when connectivity is limited.

Version: 1.0.0 (demo build)

For support, contact your administrator.
''';

const String kDummyPrivacyPolicy = '''
Privacy Policy (Demo)

We respect your privacy. This demo app stores customer and payment data locally on your device using SQLite for offline operations.

When you use sync features, data may be transmitted to your organization server as configured by your administrator.

Location data is used only for field tracking and customer location updates as enabled in the app.

We do not sell personal data. Contact your LCO for the full privacy policy applicable to your deployment.
''';
