import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../dashboard/dashboard_screen.dart';

class SignInSuccessScreen extends StatefulWidget {
  const SignInSuccessScreen({super.key});

  @override
  State<SignInSuccessScreen> createState() => _SignInSuccessScreenState();
}

class _SignInSuccessScreenState extends State<SignInSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/Sign In Successful.json',
              width: 240,
              height: 240,
            ),
            const SizedBox(height: AppSizes.paddingM),
            const Text(
              'Sign In Successful',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

