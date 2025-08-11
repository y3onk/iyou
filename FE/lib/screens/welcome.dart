import 'package:flutter/material.dart';
import 'package:iyou_demo/screens/auth_landing.dart';
import '../theme/app_theme.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppTheme.mint,
    appBar: AppBar(
      backgroundColor: AppTheme.mint, elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('회원가입', style: TextStyle(color: Colors.black87)),
      actions: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.home_outlined, color: Colors.black87),
        ),
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.menu, color: Colors.black87),
        ),
      ],
    ),
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // 큰 타이틀
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('iyou에', style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                SizedBox(height: 6),
                Text('오신 것을 환영합니다.', style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                SizedBox(height: 14),
                Text('당신만의 특별한 금융 파트너',
                  style: TextStyle(color: Color(0xFF0EA371), fontSize: 16)),
              ],
            ),
          ),

          const Spacer(),

          // 중앙 그린 카드 + 둥둥 떠있는 배지들
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 280, height: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF10B981), Color(0xFF0D9B70)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.15),
                        blurRadius: 28, offset: const Offset(0, 14)),
                    ],
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('iyou',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900)),
                        SizedBox(height: 6),
                        Text('아이유',
                          style: TextStyle(
                            color: Colors.white70, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),

                // 좌상단 노란 배지
                const Positioned(
                  left: -22, top: -22,
                  child: _BadgeCircle(
                    bg: Color(0xFFFFE88C), emoji: '💰',
                  ),
                ),
                // 우상단 민트 배지
                const Positioned(
                  right: -22, top: -18,
                  child: _BadgeCircle(
                    bg: Color(0xFFE4FFF6), emoji: '✨',
                  ),
                ),
                // 좌하단 노랑(계산기)
                const Positioned(
                  left: -18, bottom: -22,
                  child: _BadgeCircle(
                    bg: Color(0xFFFFF0B2), emoji: '🧮',
                  ),
                ),
                // 우하단 민트(타깃)
                const Positioned(
                  right: -12, bottom: -20,
                  child: _BadgeCircle(
                    bg: Color(0xFFE6FFFA), emoji: '🎯',
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // 시작 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                icon: const Text('🚀', style: TextStyle(fontSize: 18)),
                label: const Text('iyou 시작하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.green,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthLandingScreen()),
                  );
                },
              ),
            ),
          ),

          // 하단 그라데이션 프로그레스 바 느낌
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              children: [
                SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: .65, // 데모용 진행도
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFFFFC72C)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}

class _BadgeCircle extends StatelessWidget {
  final Color bg;
  final String emoji;
  const _BadgeCircle({required this.bg, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62, height: 62,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 14, offset: const Offset(0, 8)),
        ],
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
