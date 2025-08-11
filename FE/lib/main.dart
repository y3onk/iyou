import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash.dart';

void main() => runApp(const IYouApp());

class IYouApp extends StatelessWidget {
  const IYouApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iyou',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
