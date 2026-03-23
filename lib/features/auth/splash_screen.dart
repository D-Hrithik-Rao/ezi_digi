import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/services/offline_mode_service.dart';
import '../offline/offline_dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_goNext());
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final connectivity = await Connectivity().checkConnectivity();
    final noNetwork = connectivity.contains(ConnectivityResult.none);
    if (!mounted) return;

    if (noNetwork) {
      await OfflineModeService.instance.setOfflineMode(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const OfflineDashboardScreen(),
        ),
      );
      return;
    }

    // If internet is available, always start in online mode.
    // This prevents "stale" offline flag from showing the offline dashboard first.
    await OfflineModeService.instance.setOfflineMode(false);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/Animated Dashboards.json',
                width: 220,
                height: 220,
              ),
              const SizedBox(height: AppSizes.paddingL),
              const Text(
                'Ezy Cable Digi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              const Text(
                'Smart field app for cable operators',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
