import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeController extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  static const _key = 'theme_mode';

  ThemeMode themeMode = ThemeMode.light;

  ThemeController() {
    _loadSavedTheme();
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  Future<void> _loadSavedTheme() async {
    final saved = await _storage.read(key: _key);
    if (saved == 'dark') {
      themeMode = ThemeMode.dark;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode(bool isDark) async {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // update UI dulu, baru simpan — biar switch terasa instan
    await _storage.write(key: _key, value: isDark ? 'dark' : 'light');
  }
}