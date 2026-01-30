import 'package:flutter/material.dart';
import '../services/database_service.dart';

enum AppThemeMode { light, dark, system }

class ThemeViewModel extends ChangeNotifier {
  static const String _themePreferenceKey = 'app_theme_mode';

  AppThemeMode _themeMode = AppThemeMode.system;
  bool _isInitialized = false;

  AppThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  /// Get the actual ThemeMode for MaterialApp
  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Check if dark mode is active (considering system setting)
  bool isDarkMode(BuildContext context) {
    if (_themeMode == AppThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == AppThemeMode.dark;
  }

  /// Initialize theme from persisted preference
  Future<void> initialize() async {
    if (_isInitialized) return;

    final savedTheme = await DatabaseService.instance.getPreference(_themePreferenceKey);
    if (savedTheme != null) {
      _themeMode = _parseThemeMode(savedTheme);
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Set theme mode and persist
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    await DatabaseService.instance.setPreference(
      _themePreferenceKey,
      mode.name,
    );
  }

  /// Toggle between light and dark (ignores system)
  Future<void> toggleTheme() async {
    final newMode = _themeMode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Cycle through all theme modes: light -> dark -> system -> light
  Future<void> cycleThemeMode() async {
    AppThemeMode newMode;
    switch (_themeMode) {
      case AppThemeMode.light:
        newMode = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        newMode = AppThemeMode.system;
        break;
      case AppThemeMode.system:
        newMode = AppThemeMode.light;
        break;
    }
    await setThemeMode(newMode);
  }

  AppThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }

  /// Get icon for current theme mode
  IconData get themeModeIcon {
    switch (_themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// Get label for current theme mode
  String get themeModeLabel {
    switch (_themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }
}
