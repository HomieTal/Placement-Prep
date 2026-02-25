import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = StorageService.getString(StorageService.keyThemeMode);
    if (savedTheme == 'dark') {
      state = ThemeMode.dark;
    }
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    StorageService.setString(
      StorageService.keyThemeMode,
      state == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    StorageService.setString(
      StorageService.keyThemeMode,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}

