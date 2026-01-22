import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;

  PreferencesProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    // Load Theme
    // ThemeMode.system (0), ThemeMode.light (1), ThemeMode.dark (2)
    final themeIndex = _prefs?.getInt('themeMode') ?? 0;
    if (themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    // Load Locale
    final languageCode = _prefs?.getString('languageCode') ?? 'en';
    _locale = Locale(languageCode);

    // Load Notifications
    _notificationsEnabled = _prefs?.getBool('notificationsEnabled') ?? true;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _prefs?.setInt('themeMode', mode.index);
  }

  Future<void> setLocale(Locale loc) async {
    _locale = loc;
    notifyListeners();
    await _prefs?.setString('languageCode', loc.languageCode);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    await _prefs?.setBool('notificationsEnabled', enabled);
  }
}
