import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const EzyCableDigiApp());
}
class EzyCableDigiApp extends StatelessWidget {
  const EzyCableDigiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ezy Cable Digi',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      navigatorObservers: [routeObserver],
      home: const SplashScreen(),
    );
  }
}