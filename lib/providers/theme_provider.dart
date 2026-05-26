import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Gerencia a troca reativa de temas (Claro/Escuro/Sistema) e persiste a escolha do usuário
class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  ThemeProvider(this._prefs) {
    _loadThemeFromPrefs();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Retorna true se o sistema operacional estiver em modo escuro
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Carrega a escolha persistida do SharedPreferences no boot
  void _loadThemeFromPrefs() {
    final savedThemeIndex = _prefs.getInt(AppConstants.prefThemeKey);
    if (savedThemeIndex != null && savedThemeIndex >= 0 && savedThemeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[savedThemeIndex];
    }
  }

  /// Altera o tema reativamente e salva a escolha localmente
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs.setInt(AppConstants.prefThemeKey, mode.index);
  }

  /// Alterna diretamente entre Light e Dark
  Future<void> toggleTheme() async {
    final nextMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }
}
