import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ezi_cable_digi/core/services/auth_service.dart';
import 'package:ezi_cable_digi/core/services/error_handler_service.dart';
import 'package:ezi_cable_digi/features/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/services/location_sync_service.dart';
import '../../core/services/offline_mode_service.dart';
import '../offline/offline_dashboard_screen.dart';
import '../../widgets/primary_button.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/app_strings.dart';
import '../../core/theme/app_theme.dart';

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
    _requestPermissions();
  }

  /// Asks for Location + Nearby Devices (Bluetooth) as soon as login screen opens.
  Future<void> _requestPermissions() async {
    await [
      Permission.locationWhenInUse,  // shows Location dialog
      Permission.bluetoothScan,      // shows "Nearby devices" dialog on Android 12+
      Permission.bluetoothConnect,
    ].request();
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

    try {
      final result = await AuthService.instance.login(
        username: username,
        password: password,
      );

      if (!mounted) return;

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
        return;
      }

      final connectivity = await Connectivity().checkConnectivity();
      final noNetwork = connectivity.contains(ConnectivityResult.none);
      if (!mounted) return;

      await OfflineModeService.instance.setOfflineMode(noNetwork);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => noNetwork
              ? const OfflineDashboardScreen()
              : const DashboardScreen(),
        ),
      );
    } catch (error, stackTrace) {
      ErrorHandlerService.recordError(error, stackTrace, reason: 'LoginScreen._handleLogin');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Theme(
      data: AppTheme.theme1,
      child: Scaffold(
        backgroundColor: AppTheme.theme1.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
DropdownButton<String>(
  value: AppStrings.currentLang,
  items: const [
    DropdownMenuItem(value: 'en', child: Text('English')),
    DropdownMenuItem(value: 'hi', child: Text('Hindi')),
    DropdownMenuItem(value: 'te', child: Text('Telugu')),
    DropdownMenuItem(value: 'ta', child: Text('Tamil')),
    DropdownMenuItem(value: 'or', child: Text('Odia')),
    DropdownMenuItem(value: 'bn', child: Text('Bengali')),
    DropdownMenuItem(value: 'ml', child: Text('Malayalam')),
  ],
  onChanged: (value) {
    AppStrings.currentLang = value!;
    setState(() {});
  },
),
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
                   Text(
                    AppConfig.instance.appName,
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
                                                  _rememberMe = value ?? false;
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