// lib/screens/signuplogin.dart
// iyou - 회원가입 및 로그인 화면

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'welcome.dart';

class SignupIdPhoneScreen extends StatelessWidget {
  const SignupIdPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mint,
      appBar: AppBar(
        backgroundColor: AppTheme.mint,
        elevation: 0,
        title: const Row(children: [
          Icon(Icons.diversity_3_outlined, color: Colors.black87),
          SizedBox(width: 8),
          Text('iyou', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800)),
        ]),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.menu, color: Colors.black87),
          )
        ],
      ),
      body: Column(
        children: [
          // 상단 설명 텍스트
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('iyou 인증으로 간편 로그인', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                SizedBox(height: 10),
                Text('금융에서 생활까지 한 번에, 지문·페이스로 로그인',
                    style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 아이콘 영역
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.face, size: 64, color: AppTheme.lightgreen),
              SizedBox(width: 40),
              Icon(Icons.pattern, size: 64, color: AppTheme.lightgreen),
            ],
          ),

          // 버튼과 하단 내용이 화면 하단으로 가도록 Spacer 추가
          const Spacer(),

          // 로그인 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const WelcomeScreen())),
                child: const Text('간편하게 로그인하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 하단 링크
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              TextButton(
                onPressed: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WelcomeScreen())),
                child: const Text('회원가입'),
              ),
              const Text(' | '),
              TextButton(onPressed: () {}, child: const Text('인증센터')),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('다른 로그인 방법 선택 >')),
            ]),
          ),
          const SizedBox(height: 16),

          // 하단 박스
          Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 10, offset: const Offset(0, 6))],
            ),
            child: const Row(children: [
              Text('🪄  간편송금·결제', style: TextStyle(fontWeight: FontWeight.w700)),
              Spacer(),
              Icon(Icons.chevron_right),
            ]),
          )
        ],
      ),
    );
  }
}
