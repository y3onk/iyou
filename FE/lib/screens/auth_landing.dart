// lib/screens/auth_landing.dart
// iyou - 휴대폰 본인인증 화면

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'detailterms.dart';
import 'terms_model.dart';

class AuthLandingScreen extends StatefulWidget {
  const AuthLandingScreen({super.key});
  @override
  State<AuthLandingScreen> createState() => _AuthLandingScreenState();
}

class _AuthLandingScreenState extends State<AuthLandingScreen> {
  // Controllers
  final birthCtl = TextEditingController(); // YYMMDD(6)
  final rrnCtl   = TextEditingController(); // 주민번호 뒤 7
  final phoneCtl = TextEditingController(); // 010-0000-0000
  final otpCtl   = TextEditingController(); // 6자리

  // Focus
  final birthFn = FocusNode();
  final rrnFn   = FocusNode();
  final phoneFn = FocusNode();
  final otpFn   = FocusNode();

  // 통신사
  final _carriers = const ['KT', 'SKT', 'LGU+', '알뜰폰'];
  String _carrier = 'KT';

  // 약관 리스트 (원하는 순서로 정렬)
  bool allAgree = false;
  final List<TermItem> terms = [
    TermItem(title: '고유식별정보 처리 동의', required: true,  type: TermsType.uniqueId),
    TermItem(title: '전자금융서비스 이용약관', required: true,  type: TermsType.eFinanceService), // ← 마케팅 위로
    TermItem(title: '표준 전자금융거래 기본약관 동의', required: true, type: TermsType.standardEFT),
    TermItem(title: '마케팅 정보 수신 동의', required: false, type: TermsType.marketing),
  ];

  // OTP 흐름 상태
  bool otpRequested = false; // 인증요청 버튼 눌렀는가
  bool otpVerified  = false; // 인증 검증 완료

  // 재전송 타이머
  int secondsLeft = 0;
  Timer? _timer;

  // ===== 유효성 =====
  bool get validBirth => RegExp(r'^\d{6}$').hasMatch(birthCtl.text);
  bool get validRRN   => RegExp(r'^\d{7}$').hasMatch(rrnCtl.text);
  bool get validPhone => RegExp(r'^010-\d{4}-\d{4}$').hasMatch(phoneCtl.text);
  bool get validOTP   => RegExp(r'^\d{6}$').hasMatch(otpCtl.text);
  bool get requiredConsents => terms.where((t) => t.required).every((t) => t.checked);
  // “다음” 버튼 활성화는 인증 ‘완료’ 기준
  bool get formReady =>
      validBirth && validRRN && validPhone && requiredConsents && otpVerified;

  // ===== 타이머 =====
  void _startResendCooldown([int sec = 60]) {
    _timer?.cancel();
    setState(() => secondsLeft = sec);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft <= 1) { t.cancel(); setState(() => secondsLeft = 0); }
      else setState(() => secondsLeft--);
    });
  }

  // 약관: 마스터 ↔ 하위 동기화
  void _toggleAll(bool v) {
    setState(() {
      allAgree = v;
      for (final t in terms) { t.checked = v; }
    });
  }
  void _syncAll() {
    setState(() { allAgree = terms.every((t) => t.checked); });
  }

  // 프로토타입용: 가짜 OTP 발송/자동 채움
  Future<void> _requestOtp() async {
    // TODO(실서비스): 서버에서 SMS 발송 + 앱 해시 포함(SMS Retriever)로 대체
    setState(() {
      otpRequested = true;
      otpVerified  = false;
    });
    _startResendCooldown(60);
    await Future.delayed(const Duration(milliseconds: 200));
    otpCtl.text = '123456'; // 프로토타입: 자동 채움
    FocusScope.of(context).requestFocus(otpFn);
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    birthCtl.dispose(); rrnCtl.dispose(); phoneCtl.dispose(); otpCtl.dispose();
    birthFn.dispose(); rrnFn.dispose(); phoneFn.dispose(); otpFn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)),
        title: const Text('휴대폰 본인인증'),
        actions: [TextButton(onPressed: () {}, child: const Text('취소'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('개인정보를 입력해주세요', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),

          // 생년월일 + 주민번호
          Row(children: [
            Expanded(child: TextField(
              controller: birthCtl,
              focusNode: birthFn,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: (v) { if (v.length == 6) FocusScope.of(context).requestFocus(rrnFn); setState(() {}); },
              decoration: InputDecoration(
                labelText: '생년월일 6자리',
                helperText: validBirth ? null : '예: 990101',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: TextField(
              controller: rrnCtl,
              focusNode: rrnFn,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              obscureText: true, // 마스킹 권장
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              onChanged: (v) { if (v.length == 7) FocusScope.of(context).requestFocus(phoneFn); setState(() {}); },
              decoration: InputDecoration(
                labelText: '주민번호 뒤 7자리',
                helperText: validRRN ? null : '예: 1234567',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )),
          ]),
          const SizedBox(height: 12),

          // 통신사 + 휴대폰번호(자동 하이픈)
          Row(children: [
            Expanded(flex: 1, child: DropdownButtonFormField<String>(
              value: _carrier,
              items: _carriers.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _carrier = v ?? _carrier),
              decoration: InputDecoration(labelText: '통신사', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            )),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: TextField(
              controller: phoneCtl,
              focusNode: phoneFn,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _PhoneHyphenFormatter(),
              ],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: '010-0000-0000',
                helperText: validPhone ? null : '번호를 입력해주세요',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )),
          ]),
          const SizedBox(height: 12),

          // 인증 흐름
          if (!otpRequested) ...[
            // 인증요청 버튼 (전화번호 유효 시 활성화)
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: validPhone ? _requestOtp : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green, foregroundColor: Colors.white),
                child: const Text('인증요청'),
              ),
            ),
          ] else ...[
            // OTP 입력 + 재전송/인증하기
            TextField(
              controller: otpCtl,
              focusNode: otpFn,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: '인증번호 입력',
                helperText: validOTP
                    ? (otpVerified ? '인증 완료' : '6자리 입력 후 인증하기를 눌러주세요')
                    : '인증번호를 입력해주세요',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: otpVerified ? const Icon(Icons.check_circle, color: Colors.green) : null,
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: (validPhone && secondsLeft == 0)
                      ? () {
                          _startResendCooldown(60);
                          // TODO: 실제 재전송 API
                        }
                      : null,
                  child: Text(secondsLeft == 0 ? '재전송' : '재전송(${secondsLeft}s)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: validOTP ? () {
                    // TODO: 실제 서버 검증. (프로토타입: 통과 처리)
                    setState(() { otpVerified = true; });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('인증 완료!')),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green, foregroundColor: Colors.white),
                  child: const Text('인증하기'),
                ),
              ),
            ]),
          ],

          const SizedBox(height: 24),

          // 약관(마스터 1개 + 하위 동기화, 왼쪽 패딩 줄임)
          Container(
            decoration: BoxDecoration(color: AppTheme.mint, borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              initiallyExpanded: true,
              // 왼쪽 패딩을 좀 더 붙임
              tilePadding: const EdgeInsetsDirectional.fromSTEB(8, 8, 12, 8),
              childrenPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 8, 12),
              title: const Text('약관동의', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              subtitle: const Text('💡 iyou 이용을 위한 약관동의가 필요해요.'),
              trailing: const Icon(Icons.close),
              children: [
                CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  value: allAgree,
                  onChanged: (v) => _toggleAll(v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('약관 전체동의', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('필수/선택 포함'),
                ),
                const Divider(height: 0),
                ...terms.map((t) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: Checkbox(
                    value: t.checked,
                    onChanged: (v) { t.checked = v ?? false; _syncAll(); },
                  ),
                  title: Text('${t.title} ${t.required ? "[필수]" : "[선택]"}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TermsDetailScreen(type: t.type)),
                      );
                    },
                  ),
                )),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // CTA: 조건 충족 전 비활성화 (인증 완료 포함)
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: formReady ? AppTheme.green : Colors.grey.shade400,
                foregroundColor: Colors.white,
              ),
              onPressed: formReady ? () {
                // TODO: 다음 단계
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('회원 가입 완료!')),
                );
              } : null,
              child: const Text('다음'),
            ),
          ),
        ],
      ),
    );
  }
}

// 휴대폰 번호 자동 하이픈(붙여넣기 포함)
class _PhoneHyphenFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) {
    final digits = newV.text.replaceAll(RegExp(r'\D'), '');
    String out = digits;
    if (digits.length > 3 && digits.length <= 7) {
      out = '${digits.substring(0,3)}-${digits.substring(3)}';
    } else if (digits.length > 7) {
      final end = digits.length.clamp(7, 11);
      out = '${digits.substring(0,3)}-${digits.substring(3,7)}-${digits.substring(7, end)}';
    }
    return TextEditingValue(text: out, selection: TextSelection.collapsed(offset: out.length));
  }
}

