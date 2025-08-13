import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash.dart';
import 'screens/admin_landing.dart';
import 'screens/admin_termlist.dart';
import 'screens/signuplogin.dart';

const bool kAdminMode = bool.fromEnvironment('ADMIN_MODE', defaultValue: false);
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
      routes:{
        '/home': (_) => const SignupIdPhoneScreen(),
        if (kAdminMode) '/admin': (_) => const AdminLandingScreen(),
        if (kAdminMode) '/admin/terms': (_) => const AdminTermsScreen(),
      }
    );
  }
}
