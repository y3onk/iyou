import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'detailterms.dart';


class AuthLandingScreen extends StatefulWidget {
  const AuthLandingScreen({super.key});
  @override
  State<AuthLandingScreen> createState() => _SignupIdPhoneScreenState();
}

class _SignupIdPhoneScreenState extends State<AuthLandingScreen> {
  bool allAgree = false;
  final Map<String, bool> agree = {
    '약관 전체동의 [필수]': false,
    '고유식별정보 처리 동의': false,
    '표준 전자금융거래 기본약관 동의': false,
  };

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
          const Text('본인 정보를 입력해주세요', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextField(
              decoration: InputDecoration(labelText: '생년월일 6자리', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            )),
            const SizedBox(width: 12),
            Expanded(child: TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: '주민번호 뒤 7자리', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            )),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(flex: 1, child: DropdownButtonFormField<String>(
              value: 'KT',
              items: const [
                DropdownMenuItem(value: 'KT', child: Text('KT')),
                DropdownMenuItem(value: 'SKT', child: Text('SKT')),
                DropdownMenuItem(value: 'LGU+', child: Text('LGU+')),
              ],
              onChanged: (_) {},
              decoration: InputDecoration(labelText: '통신사', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            )),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: TextField(
              decoration: InputDecoration(labelText: '010-0000-0000', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            )),
          ]),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(labelText: '인증번호 입력', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 24),
          _termsSection(context),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green, foregroundColor: Colors.white),
              onPressed: () {},
              child: const Text('다음'),
            ),
          )
        ],
      ),
    );
  }

  Widget _termsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.mint, borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        title: const Text('약관동의', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        subtitle: const Text('💡 iyou 이용을 위한 약관동의가 필요해요.'),
        trailing: const Icon(Icons.close),
        children: [
          CheckboxListTile(
            value: allAgree,
            onChanged: (v) {
              setState(() {
                allAgree = v ?? false;
                for (final k in agree.keys) { agree[k] = allAgree; }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('약관 전체동의 [필수]', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const Divider(height: 0),
          ...agree.entries.map((e) {
            final isMaster = e.key.startsWith('약관 전체동의');
            return ListTile(
              leading: Checkbox(
                value: e.value,
                onChanged: (v) {
                  setState(() {
                    agree[e.key] = v ?? false;
                    if (!isMaster) { allAgree = agree.values.every((x) => x); }
                  });
                },
              ),
              title: Text(e.key),
              trailing: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsDetailScreen())),
              ),
            );
          })
        ],
      ),
    );
  }
}
