import 'dart:async';

import 'package:ezi_cable_digi/core/services/error_handler_service.dart';
import 'package:ezi_cable_digi/core/services/localization_service.dart';
import 'package:ezi_cable_digi/core/services/theme_service.dart';
import 'package:ezi_cable_digi/features/customers/customer_list_provider.dart';
import 'package:ezi_cable_digi/features/search/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';
import 'core/services/notification_service.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

Future<void> mainEntry() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorHandlerService.init();

  await runZonedGuarded(() async {
    await NotificationService.init();
    // Restore saved language before the first frame — zero perceived lag
    await LocalizationService.init();
    // Restore saved theme before the first frame
    await ThemeService.init();
    runApp(const EzyCableDigiApp());
  }, (error, stack) {
    ErrorHandlerService.recordError(error, stack, reason: 'Uncaught app error');
  });
}

class EzyCableDigiApp extends StatelessWidget {
  const EzyCableDigiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // LocalizationScope (InheritedNotifier) sits ABOVE MaterialApp.
    // Any widget that calls AppStrings.of(context, key) registers a rebuild
    // dependency here — when the language changes, only those widgets rebuild.
    // MultiProvider sits above everything — providers survive full navigation.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => CustomerListProvider()),
      ],
      child: LocalizationScope(
        child: ListenableBuilder(
          listenable: ThemeService.instance,
          builder: (context, _) {
            final themeData = AppTheme.forIndex(ThemeService.instance.themeIndex)
                .copyWith(textTheme: GoogleFonts.poppinsTextTheme());
            return MaterialApp(
              title: AppConfig.instance.appName,
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.light,
              theme: themeData,
              navigatorObservers: [routeObserver],
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}