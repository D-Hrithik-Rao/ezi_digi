import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Language Model
// ─────────────────────────────────────────────────────────────────────────────

class AppLanguage {
  final String code;
  final String name;        // Native name shown in picker
  final String flag;
  final String englishName;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.flag,
    required this.englishName,
  });

  static const List<AppLanguage> all = [
    AppLanguage(code: 'en', name: 'English',  flag: '🇬🇧', englishName: 'English'),
    AppLanguage(code: 'hi', name: 'हिन्दी',   flag: '🇮🇳', englishName: 'Hindi'),
    AppLanguage(code: 'te', name: 'తెలుగు',   flag: '🇮🇳', englishName: 'Telugu'),
    AppLanguage(code: 'ta', name: 'தமிழ்',    flag: '🇮🇳', englishName: 'Tamil'),
    AppLanguage(code: 'ml', name: 'മലയാളം',   flag: '🇮🇳', englishName: 'Malayalam'),
    AppLanguage(code: 'kn', name: 'ಕನ್ನಡ',    flag: '🇮🇳', englishName: 'Kannada'),
    AppLanguage(code: 'bn', name: 'বাংলা',     flag: '🇮🇳', englishName: 'Bengali'),
    AppLanguage(code: 'or', name: 'ଓଡ଼ିଆ',    flag: '🇮🇳', englishName: 'Odia'),
  ];

  static AppLanguage byCode(String code) =>
      all.firstWhere((l) => l.code == code, orElse: () => all.first);
}

// ─────────────────────────────────────────────────────────────────────────────
// LocalizationService — Singleton ChangeNotifier
// ─────────────────────────────────────────────────────────────────────────────

class LocalizationService extends ChangeNotifier {
  LocalizationService._();
  static final LocalizationService instance = LocalizationService._();

  AppLanguage _currentLanguage = AppLanguage.all.first;
  AppLanguage get currentLanguage => _currentLanguage;

  final Map<String, Map<String, String>> _cache = {};
  Map<String, String> _fallback = {};

  static const String _prefKey = 'app_language_code';

  // ── Init (called once before runApp) ──────────────────────────────────────
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefKey) ?? 'en';

    await instance._loadLanguage('en');
    instance._fallback = Map.unmodifiable(instance._cache['en'] ?? {});

    if (savedCode != 'en') {
      await instance._loadLanguage(savedCode);
    }
    instance._currentLanguage = AppLanguage.byCode(savedCode);
  }

  // ── Safe translation lookup ───────────────────────────────────────────────
  /// Returns translated string for [key].  
  /// Falls back to English, then returns the key itself — never throws.
  String get(String key) {
    final map = _cache[_currentLanguage.code];
    if (map != null && map.containsKey(key)) return map[key]!;
    if (_fallback.containsKey(key)) return _fallback[key]!;
    return key;
  }

  // ── Switch language ───────────────────────────────────────────────────────
  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage.code == language.code) return;

    if (!_cache.containsKey(language.code)) {
      await _loadLanguage(language.code);
    }

    _currentLanguage = language;
    notifyListeners(); // ← triggers InheritedNotifier → re-renders every
                       //   widget that called AppStrings.of(context, ...)

    // Persist asynchronously (after UI already updated)
    SharedPreferences.getInstance()
        .then((p) => p.setString(_prefKey, language.code));
  }

  // ── Private: load JSON from assets ───────────────────────────────────────
  Future<void> _loadLanguage(String code) async {
    if (_cache.containsKey(code)) return;
    try {
      final raw = await rootBundle.loadString('assets/l10n/$code.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      _cache[code] = decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (e) {
      debugPrint('[LocalizationService] Cannot load "$code": $e');
      _cache[code] = {};
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LocalizationScope — InheritedNotifier
//
// Wraps MaterialApp. Any widget that calls AppStrings.of(context, key)
// automatically subscribes: when language changes, only those widgets rebuild.
// Pages already pushed onto the Navigator stack also rebuild — no restart needed.
// ─────────────────────────────────────────────────────────────────────────────

class LocalizationScope extends InheritedNotifier<LocalizationService> {
  // NOT const — LocalizationService.instance is a runtime singleton,
  // not a compile-time constant.
  LocalizationScope({super.key, required super.child})
      : super(notifier: LocalizationService.instance);

  /// Registers a dependency on this scope so the calling widget rebuilds on
  /// every language change.  Returns the service for use if needed.
  static LocalizationService of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LocalizationScope>();
    assert(scope != null,
        'LocalizationScope.of() called outside of a LocalizationScope. '
        'Ensure LocalizationScope wraps your MaterialApp.');
    return scope!.notifier!;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppStrings — convenience API used everywhere in the UI
//
//   AppStrings.of(context, 'dashboard')
//     → registers rebuild dependency (PREFERRED in build() methods)
//
//   AppStrings.get('dashboard')
//     → no rebuild dependency (use only outside build trees)
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppStrings {
  /// Context-aware lookup — widget will rebuild when language changes.
  /// Use this inside build() methods for automatic reactivity.
  static String of(BuildContext context, String key) {
    final svc = LocalizationScope.of(context);
    return svc.get(key);
  }

  /// Stateless lookup — no rebuild dependency.
  /// Use for callbacks, services, or places where context is unavailable.
  static String get(String key) => LocalizationService.instance.get(key);
}
