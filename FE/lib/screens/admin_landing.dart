import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'signuplogin.dart';         // 사용자 화면
import 'admin_termlist.dart';  // 약관 관리 화면

class AdminLandingScreen extends StatelessWidget {
  const AdminLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mint,
      appBar: AppBar(
        title: const Text('관리자 모드'),
        backgroundColor: AppTheme.mint,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('무엇을 할까요?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),

            // 1) 약관 조회/관리
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.description_outlined),
                label: const Text('약관 조회 / 관리', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                onPressed: () {
                  // 라우트로 가도 되고, 직접 위젯으로 가도 됨
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminTermsScreen()),
                  );
                  // 또는: Navigator.pushReplacementNamed(context, '/admin/terms');
                },
              ),
            ),
            const SizedBox(height: 12),

            // 2) 사용자 화면 모드
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.person_outline),
                label: const Text('사용자 화면 모드', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                onPressed: () {
                  // Splash를 거치지 않고 직접 교체 → 루프 방지
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupIdPhoneScreen()),
                  );
                  // (원하면 Named: Navigator.pushReplacementNamed(context, '/home'); )
                },
              ),
            ),

            const Spacer(),
            const Text('관리자에게만 보이는 화면이에요.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
