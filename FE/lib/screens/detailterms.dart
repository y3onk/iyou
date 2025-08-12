import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_summary_sheet.dart';
import '../core/api_locator.dart';

class TermsDetailScreen extends StatefulWidget {
  const TermsDetailScreen({
    super.key,
    this.termId = 1,
    this.title = '표준 전자 금융거래 기본약관',
  });

  final int termId;
  final String title;

  @override
  State<TermsDetailScreen> createState() => _TermsDetailScreenState();
}

class _TermsDetailScreenState extends State<TermsDetailScreen> {
  final _api = provideApi();
  bool _loading = false;

  Future<void> _openAISummary() async {
  setState(() => _loading = true);
  try {
    final data = await _api.get('/terms/${widget.termId}/summary');

    final title = (data['title'] ?? widget.title) as String;

    // 1) 서버가 구조화 응답을 주면 그대로 사용
    final bullets = (data['bullets'] as List?)?.cast<String>() ?? <String>[];
    final rights  = (data['rights']  as List?)?.cast<String>() ?? <String>[];
    final glossary = (data['glossary'] as List?)
        ?.map((e) => [(e['term'] ?? '').toString(), (e['def'] ?? e['defn'] ?? '').toString()])
        .toList()
        ?? <List<String>>[];

    // 2) 구조화가 없으면 summary_text/summary 문자열을 문장 단위로 분해 (fallback)
    if (bullets.isEmpty) {
      final summaryText = (data['summary_text'] ?? data['summary'] ?? '') as String;
      final fallback = summaryText
          .split(RegExp(r'[\r\n]+|•|\u2022|^- |\d+[.)]\s+', multiLine: true))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      bullets.addAll(fallback);
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AISummarySheet(
        docTitle: title,
        summaryBullets: bullets.isEmpty
            ? const ['요약 결과가 비어 있습니다. (모델/데이터 확인 필요)']
            : bullets,
        glossary: glossary,
        rights: rights,
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('요약 불러오기 실패: $e')),
    );
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final title = widget.title;

    return Scaffold(
      backgroundColor: const Color(0xFF07131B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07131B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              icon: _loading
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome, color: Colors.black),
              label: const Text('AI 요약',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF8D648)),
              onPressed: _loading ? null : _openAISummary, // ✅ API 연동
            ),
          ),
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
        decoration:
            BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.push_pin, color: Color(0xFFF8D648)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 6),
              const Text('우상단 AI 요약 버튼을 눌러 간편하게 핵심 내용을 확인해보세요',
                  style: TextStyle(color: Colors.white70)),
            ]),
          ),
        ]),
      );

  Widget _clauseCard(String h, String body) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1B24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(h,
              style: const TextStyle(
                  color: Color(0xFFF8D648), fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: Colors.white, height: 1.5)),
        ]),
      );
}
