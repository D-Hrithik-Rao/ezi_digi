import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_theme.dart';

/// ── AppThemeConst ─────────────────────────────────────────────────────────────
/// Reads the active theme from [BuildContext] and exposes strongly-typed,
/// theme-aware color/style accessors.
///
/// Usage inside any build():
///   final t = AppThemeConst.of(context);
///   Scaffold(backgroundColor: t.scaffoldBg)
///
/// Internally calls [Theme.of(context)] so the widget rebuilds automatically
/// when the parent MaterialApp switches ThemeData — zero extra subscriptions.
/// ─────────────────────────────────────────────────────────────────────────────
class AppThemeConst {
  final bool isLight;

  const AppThemeConst._({required this.isLight});

  /// Factory reads the [AppThemeExtension] injected by [AppTheme].
  factory AppThemeConst.of(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>();
    return AppThemeConst._(isLight: ext?.isPremiumLight ?? false);
  }

  // ── Scaffold / Page ───────────────────────────────────────────────────────
  Color get scaffoldBg =>
      isLight ? const Color(0xFFF5F7FF) : AppColors.primary;

  // ── AppBar ────────────────────────────────────────────────────────────────
  Color get appBarBg => isLight ? Colors.white : AppColors.primary;
  Color get appBarFg => isLight ? const Color(0xFF1A3C6E) : Colors.white;
  Color get appBarBorderColor =>
      isLight ? const Color(0xFFDDE3F5) : Colors.transparent;

  // ── Back / icon button ────────────────────────────────────────────────────
  Color get backBtnBg =>
      isLight ? const Color(0xFF1A3C6E).withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.15);
  Color get backBtnIcon =>
      isLight ? const Color(0xFF1A3C6E) : Colors.white;

  // ── Cards ─────────────────────────────────────────────────────────────────
  Color get cardBg => Colors.white;
  Color get cardShadowColor => isLight
      ? const Color(0xFF1A3C6E).withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.10);
  BorderRadius get cardBorderRadius =>
      BorderRadius.circular(isLight ? 18 : 14);

  // ── Typography ────────────────────────────────────────────────────────────
  Color get headingText =>
      isLight ? const Color(0xFF1A3C6E) : Colors.white;
  Color get bodyText =>
      isLight ? AppColors.textPrimary : Colors.white.withValues(alpha: 0.92);
  Color get subtitleText =>
      isLight ? AppColors.textSecondary : Colors.white.withValues(alpha: 0.65);

  // ── On-Card Typography (Because cards are white in both themes) ───────────
  Color get cardHeadingText =>
      isLight ? const Color(0xFF1A3C6E) : AppColors.primary;
  Color get cardBodyText => AppColors.textPrimary;
  Color get cardSubtitleText => AppColors.textSecondary;

  // ── Input fields ──────────────────────────────────────────────────────────
  Color get inputBg => isLight ? Colors.white : Colors.grey.shade50;
  Color get inputBorderColor =>
      isLight ? const Color(0xFFDDE3F5) : Colors.grey.shade300;
  Color get inputHintColor => AppColors.textSecondary;

  // ── Accent / Primary action ───────────────────────────────────────────────
  Color get accent =>
      isLight ? const Color(0xFF1A3C6E) : AppColors.primary;

  // ── Section header gradient ───────────────────────────────────────────────
  List<Color> get headerGradient => isLight
      ? [const Color(0xFF1A3C6E), const Color(0xFF2563EB)]
      : [const Color(0xFF0288D1), const Color(0xFF26C6DA)];

  // ── Divider ───────────────────────────────────────────────────────────────
  Color get dividerColor =>
      isLight ? const Color(0xFFE4EAF8) : Colors.white.withValues(alpha: 0.10);

  // ── Subtle section background ─────────────────────────────────────────────
  Color get sectionBg => isLight
      ? const Color(0xFFEEF2FF)
      : Colors.white.withValues(alpha: 0.07);

  // ── Toggle / pill buttons ─────────────────────────────────────────────────
  Color get toggleActiveBg =>
      isLight ? const Color(0xFF1A3C6E) : Colors.white;
  Color get toggleInactiveBg =>
      isLight ? Colors.white : Colors.white.withValues(alpha: 0.10);
  Color get toggleActiveText =>
      isLight ? Colors.white : AppColors.primary;
  Color get toggleInactiveText =>
      isLight ? AppColors.textSecondary : Colors.white.withValues(alpha: 0.60);

  // ── Tab Bar ───────────────────────────────────────────────────────────────
  Color get tabBarActiveColor =>
      isLight ? const Color(0xFF1A3C6E) : Colors.white;


  // ── Loading indicator ─────────────────────────────────────────────────────
  Color get loadingColor =>
      isLight ? const Color(0xFF1A3C6E) : Colors.white;

  // ── Empty state ───────────────────────────────────────────────────────────
  Color get emptyStateBg =>
      isLight ? const Color(0xFFEEF2FF) : Colors.white.withValues(alpha: 0.12);
  Color get emptyStateIconColor =>
      isLight ? const Color(0xFF1A3C6E).withValues(alpha: 0.30) : Colors.white.withValues(alpha: 0.45);
}
