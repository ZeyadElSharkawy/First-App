import 'package:flutter/material.dart';

class AppState {
  static final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
  static final localeNotifier = ValueNotifier<Locale>(const Locale('en'));
}
