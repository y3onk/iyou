import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_summary_sheet.dart';

class TermsDetailScreen extends StatelessWidget {
  const TermsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const title = '표준 전자 금융거래 기본약관';
    return Scaffold(
      backgroundColor: const Color(0xFF07131B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07131B), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
        title: const Text(title, style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome, color: Colors.black),
              label: const Text('AI', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF8D648)),
              onPressed: () async {
                // TODO: 여기에 Colab/백엔드 호출 넣기
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AISummarySheet(
                    docTitle: title,
                    summaryBullets: [
                      '본 약관은 iyou가 제공하는 위치기반서비스 이용 조건을 정의합니다.',
                      '위치정보는 서비스 제공 목적에 한해 수집·이용되며 법정 보관기간에 따릅니다.',
                      '이용·제공 사실 통지는 온라인/서면으로 제공됩니다.',
                      '사용자는 언제든 동의를 철회할 수 있습니다.',
                    ],
                    glossary: [
                      ['위치기반서비스', '이용자의 위치정보를 활용해 제공하는 서비스'],
                      ['개인위치정보', '특정 개인의 위치를 알 수 있는 정보'],
                      ['법정대리인', '미성년자의 법적 권리를 대리하는 자'],
                    ],
                    rights: [
                      '위치정보 수집·이용·제공 동의 철회권',
                      '이용·제공 사실 통지 요구권',
                      '개인위치정보 삭제·정지 요구권',
                      '손해배상청구권',
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _heroCard(title),
          const SizedBox(height: 12),
          _clauseCard('제1조 (목적)', '… 약관 본문 예시 텍스트 …'),
          _clauseCard('제2조 (용어의 정의)', '… 약관 본문 예시 텍스트 …'),
          _clauseCard('제3조 (계약의 성립)', '… 약관 본문 예시 텍스트 …'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _heroCard(String title) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
    child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.push_pin, color: Color(0xFFF8D648)),
      SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('표준 전자금융거래 기본약관', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        SizedBox(height: 6),
        Text('우상단 AI 요약 버튼을 눌러 간편하게 핵심 내용을 확인해보세요', style: TextStyle(color: Colors.white70)),
      ])),
    ]),
  );

  Widget _clauseCard(String h, String body) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF0E1B24), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(h, style: const TextStyle(color: Color(0xFFF8D648), fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 8),
      Text(body, style: const TextStyle(color: Colors.white, height: 1.5)),
    ]),
  );
}
