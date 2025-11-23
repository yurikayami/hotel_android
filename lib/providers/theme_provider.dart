import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _hideStatusBar = true;
  bool _pureDarkMode = false; // Pure dark mode (true black background)
  
  ThemeMode get themeMode => _themeMode;
  bool get hideStatusBar => _hideStatusBar;
  bool get pureDarkMode => _pureDarkMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
    _loadStatusBarSetting();
    _loadPureDarkModeSetting();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('themeMode') ?? 'system';
    
    switch (themeModeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    String themeModeString;
    
    switch (mode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }
    
    await prefs.setString('themeMode', themeModeString);
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  Future<void> _loadStatusBarSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _hideStatusBar = prefs.getBool('hideStatusBar') ?? true;
    notifyListeners();
  }

  Future<void> setHideStatusBar(bool value) async {
    _hideStatusBar = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hideStatusBar', value);
  }

  Future<void> _loadPureDarkModeSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _pureDarkMode = prefs.getBool('pureDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> setPureDarkMode(bool value) async {
    _pureDarkMode = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pureDarkMode', value);
  }
}

