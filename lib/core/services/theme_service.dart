import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme index values:
///   0 = Theme 1 — Default Blue (dark blue scaffold, matching reference screenshots)
///   1 = Theme 2 — Premium Light (warm ivory/pearl scaffold, exclusive feel)
class ThemeService extends ChangeNotifier {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  static const String _prefKey = 'app_theme_index';

  int _themeIndex = 0;
  int get themeIndex => _themeIndex;
  bool get isPremiumLight => _themeIndex == 1;

  /// Call once before runApp. Restores persisted choice with zero perceived lag.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    instance._themeIndex = prefs.getInt(_prefKey) ?? 0;
    // No notifyListeners() here — app hasn't built yet.
  }

  /// Switch theme. UI updates immediately; persistence happens async.
  Future<void> setTheme(int index) async {
    if (index < 0 || index > 1) return; // guard
    if (_themeIndex == index) return;
    _themeIndex = index;
    notifyListeners();
    // Persist after UI update to keep frames smooth
    SharedPreferences.getInstance().then((p) => p.setInt(_prefKey, index));
  }

  void toggleTheme() => setTheme(_themeIndex == 0 ? 1 : 0);
}
