// theme_provider.dart - Управление темой приложения
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Провайдер темы с сохранением настроек
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  // Загрузка темы из хранилища
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false;
    notifyListeners();
  }

  // Переключение темы
  Future<void> toggle() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
    notifyListeners();
  }
}
