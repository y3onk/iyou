import 'package:flutter/material.dart';

class AppTheme {
  static const Color mint = Color(0xFFE8FFF2);
  static const Color lightgreen= Color.fromARGB(255, 155, 227, 191);
  static const Color green = Color(0xFF10B981);
  static const Color cardDark = Color(0xFF0F1E29);

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: green),
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w800),
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
    ),
  );
}
