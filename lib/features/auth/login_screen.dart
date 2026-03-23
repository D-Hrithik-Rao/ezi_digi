import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ezi_cable_digi/features/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/services/location_sync_service.dart';
import '../../core/services/offline_mode_service.dart';
import '../offline/offline_dashboard_screen.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    LocationSyncService.instance.onScreenOpened(TrackingScreen.login);
  }

  Future<void> _handleLogin() async {
    final username = _userController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (username == 'admin' && password == '123456') {
      if (!mounted) return;
      final connectivity = await Connectivity().checkConnectivity();
      final noNetwork = connectivity.contains(ConnectivityResult.none);
      if (!mounted) return;

      // If internet is available, go online (and clear any stale offline flag).
      // If internet is not available, go offline dashboard.
      await OfflineModeService.instance.setOfflineMode(noNetwork);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => noNetwork
              ? const OfflineDashboardScreen()
              : const DashboardScreen(),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.55,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  const Text(
                    'Welcome to',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ezy Cable Digi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Container(
                              margin: const EdgeInsets.only(top: 38),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusXL),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    blurRadius: 30,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: GlassmorphicContainer(
                                width: double.infinity,
                                height: 440,
                                borderRadius: AppSizes.radiusXL,
                                blur: 18,
                                alignment: Alignment.center,
                                border: 1.6,
                                linearGradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.68),
                                    Colors.white.withValues(alpha: 0.22),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderGradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.95),
                                    Colors.white.withValues(alpha: 0.35),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSizes.paddingL,
                                    56,
                                    AppSizes.paddingL,
                                    AppSizes.paddingL,
                                  ),
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.only(
                                      bottom: bottomInset > 0 ? 12 : 0,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _GlassTextField(
                                          controller: _userController,
                                          hint: 'Username',
                                          lottieAsset:
                                              'assets/Profile Icon.json',
                                        ),
                                        const SizedBox(height: AppSizes.paddingM),
                                        _GlassTextField(
                                          controller: _passwordController,
                                          hint: 'Password',
                                          obscureText: true,
                                          lottieAsset: 'assets/Login.json',
                                        ),
                                        const SizedBox(height: AppSizes.paddingS),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: _rememberMe,
                                              onChanged: (value) {
                                                setState(() {
                                                  _rememberMe =
                                                      value ?? false;
                                                });
                                              },
                                              activeColor: AppColors.accent,
                                            ),
                                            const Text(
                                              'Remember Me',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSizes.paddingM),
                                        PrimaryButton(
                                          label: 'SIGN IN',
                                          isLoading: _isLoading,
                                          onPressed: _handleLogin,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 78,
                          width: 78,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.45),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.14),
                                blurRadius: 16,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset('assets/ezy_digi_pics.png'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'itpworld.com, All Rights Reserved',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final String lottieAsset;

  const _GlassTextField({
    required this.controller,
    required this.hint,
    required this.lottieAsset,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.primary.withValues(alpha: 0.35);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          RepaintBoundary(
            child: SizedBox(
              height: 40,
              width: 40,
              child: Lottie.asset(
                lottieAsset,
                fit: BoxFit.contain,
                renderCache: RenderCache.raster,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

