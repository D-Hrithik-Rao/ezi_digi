import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // ── Theme 1 : Default Blue (matches reference screenshots) ──────────────────
  static ThemeData get theme1 {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: AppColors.border.a * 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: AppColors.border.a * 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: Colors.white.a * 0.08),
      ),
      extensions: const [AppThemeExtension(isPremiumLight: false)],
    );
  }

  // ── Theme 2 : Premium Light (exclusive ivory/pearl look) ────────────────────
  static ThemeData get theme2 {
    const Color t2Primary = Color(0xFF1A3C6E);   // deep navy
    const Color t2Accent  = Color(0xFFC49A2A);   // warm gold
    const Color t2Bg      = Color(0xFFF5F7FF);   // pearl blue-white
    const Color t2Surface = Color(0xFFFFFFFF);   // pure white
    const Color t2Border  = Color(0xFFDDE3F5);   // cool-grey border

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: t2Primary,
        onPrimary: Colors.white,
        secondary: t2Accent,
        onSecondary: Colors.white,
        surface: t2Surface,
        onSurface: const Color(0xFF1B1F3B),
        error: const Color(0xFFEF4444),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: t2Bg,
      appBarTheme: AppBarTheme(
        backgroundColor: t2Surface,
        foregroundColor: t2Primary,
        elevation: 0,
        centerTitle: true,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        surfaceTintColor: Colors.transparent,
        // Premium bottom border shadow via shape
        shape: Border(
          bottom: BorderSide(
            color: t2Border,
            width: 1,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: t2Surface,
        elevation: 4,
        shadowColor: const Color(0xFF1A3C6E).withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: t2Border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: t2Border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: t2Primary, width: 1.5),
        ),
        filled: true,
        fillColor: t2Surface,
      ),
      extensions: const [AppThemeExtension(isPremiumLight: true)],
    );
  }

  // Convenience getter used by main.dart
  static ThemeData forIndex(int index) => index == 1 ? theme2 : theme1;
}

// ── AppThemeExtension — lets any widget ask "am I in premium light theme?" ────
// Usage: Theme.of(context).extension<AppThemeExtension>()?.isPremiumLight ?? false
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final bool isPremiumLight;
  const AppThemeExtension({required this.isPremiumLight});

  @override
  AppThemeExtension copyWith({bool? isPremiumLight}) =>
      AppThemeExtension(isPremiumLight: isPremiumLight ?? this.isPremiumLight);

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}
