import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  Future<void> loadTheme() async {_isDark = (await SharedPreferences.getInstance()).getBool('isDark') ?? false; notifyListeners();}
  Future<void> toggleTheme() async {_isDark = !_isDark; (await SharedPreferences.getInstance()).setBool('isDark', _isDark); notifyListeners();}
}
