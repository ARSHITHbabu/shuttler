import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/services/storage_service.dart';

part 'theme_provider.g.dart';

/// Theme mode state notifier
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    // Load saved theme or default to dark
    _loadTheme();
    return ThemeMode.dark; // Default to dark mode
  }

  Future<void> _loadTheme() async {
    final storageService = ref.read(storageServiceProvider);
    final savedTheme = await storageService.getString(_themeKey);

    if (savedTheme != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeMode.dark,
      );
    }
  }

  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newTheme;

    // Persist theme
    final storageService = ref.read(storageServiceProvider);
    await storageService.setString(_themeKey, newTheme.toString());
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;

    // Persist theme
    final storageService = ref.read(storageServiceProvider);
    await storageService.setString(_themeKey, mode.toString());
  }

  bool get isDarkMode => state == ThemeMode.dark;
}

/// Storage service provider
@riverpod
StorageService storageService(StorageServiceRef ref) {
  throw UnimplementedError('Storage service must be overridden');
}
