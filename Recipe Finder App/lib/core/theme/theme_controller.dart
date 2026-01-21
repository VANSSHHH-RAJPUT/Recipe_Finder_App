import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemePreference { system, light, dark }

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  void setPreference(ThemePreference preference) {
    switch (preference) {
      case ThemePreference.system:
        state = ThemeMode.system;
        break;
      case ThemePreference.light:
        state = ThemeMode.light;
        break;
      case ThemePreference.dark:
        state = ThemeMode.dark;
        break;
    }
  }

  void toggle() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>(
      (ref) => ThemeController(),
    );
