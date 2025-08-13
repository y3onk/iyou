import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iyou_demo/theme/app_theme.dart';
import 'signuplogin.dart';

const bool kAdminMode = bool.fromEnvironment('ADMIN_MODE', defaultValue: false);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introC =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..forward();
  late final Animation<double> _fade =
      CurvedAnimation(parent: _introC, curve: Curves.easeOutCubic);
  late final Animation<double> _scale = Tween(begin: .94, end: 1.0).animate(
      CurvedAnimation(parent: _introC, curve: Curves.easeOutBack));

  // 별 둥둥 애니메이션
  late final AnimationController _floatC =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
        ..repeat(reverse: true);
  late final Animation<Offset> _floatUpDown =
      Tween(begin: const Offset(0, -0.02), end: const Offset(0, 0.02))
          .animate(CurvedAnimation(parent: _floatC, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      if (kAdminMode) {
        // 관리자 모드일 때는 관리자 화면으로 이동
        // --dart-define=ADMIN_MODE=true 로 빌드 시 활성화
        Navigator.of(context).pushReplacementNamed('/admin');
      } else {
        // 일반 사용자 모드로 이동
        Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, __, ___) => const SignupIdPhoneScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
        ),
        );
      }
      
    });
  }

  @override
  void dispose() {
    _introC.dispose();
    _floatC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imgWidth = (size.width * 0.5).clamp(180.0, 320.0);

    return Scaffold(
      backgroundColor: AppTheme.lightgreen,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Stack(
            children: [
              const Positioned(
                left: 24, top: 24,
                child: Text(
                  '당신의\n평생 금융 파트너',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
              ),

              // 중앙: 고양이 + 텍스트형 로고
              Center(
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 떠다니는 작은 별 이모지
                      SlideTransition(
                        position: _floatUpDown,
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text('✨', style: TextStyle(fontSize: 20)),
                        ),
                      ),


                      // 텍스트형 로고 PNG (iyou)
                      Image.asset(
                        'assets/images/iyou_text_logo.png',
                        height: 60,
                        fit: BoxFit.contain,
                      ),

                      
                      const SizedBox(height: 12),

                      // 고양이 PNG
                      Image.asset(
                        'assets/images/cat.png',
                        width: imgWidth,
                        fit: BoxFit.contain,
                      ),


                      // 반짝이 하나 더
                      SlideTransition(
                        position: _floatUpDown,
                        child: const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text('🌟', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 하단 진행 영역
              const Positioned(
                bottom: 28, left: 24, right: 24,
                child: Column(
                  children: [
                    Text('iyou 금융', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    LinearProgressIndicator(minHeight: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
