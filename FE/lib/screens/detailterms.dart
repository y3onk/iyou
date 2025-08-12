// lib/screens/detailterms.dart
// iyou - 약관 상세 화면

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_summary_sheet.dart';
import '../core/api_locator.dart';
import 'terms_model.dart'; // ← 새 enum/모델

/// 약관 메타(백엔드 termId & 기본 제목)
class TermsMeta {
  final int id;
  final String title;
  const TermsMeta(this.id, this.title);
}

/// TODO: termId는 백엔드에 맞게 수정
const Map<TermsType, TermsMeta> kTermsMeta = {
  TermsType.uniqueId:       TermsMeta(1, '고유식별정보 처리 동의'),
  TermsType.eFinanceService:TermsMeta(2, '전자금융서비스 이용약관'),
  TermsType.standardEFT:    TermsMeta(3, '표준 전자금융거래 기본약관'),
  TermsType.marketing:      TermsMeta(4, '마케팅 정보 수신 동의'),
};

class TermsDetailScreen extends StatefulWidget {
  const TermsDetailScreen({
    super.key,
    this.type,            // 새 경로: 약관 타입으로 진입
    this.termId,          // 기존 경로: termId 직접 지정
    this.title,           // 기존 경로: 제목 직접 지정
  });

  final TermsType? type;
  final int? termId;
  final String? title;

  @override
  State<TermsDetailScreen> createState() => _TermsDetailScreenState();
}

class _TermsDetailScreenState extends State<TermsDetailScreen> {
  final _api = provideApi();

  // 로딩 상태
  bool _loading = false;
  bool _loadingDetail = true;
  String? _detailError;

  // 파싱된 조/본문
  List<Clause> _clauses = [];

  int get _resolvedTermId {
    if (widget.termId != null) return widget.termId!;
    if (widget.type != null)   return kTermsMeta[widget.type]!.id;
    return 1; // fallback
  }

  String get _resolvedTitle {
    if (widget.title != null && widget.title!.trim().isNotEmpty) return widget.title!;
    if (widget.type != null) return kTermsMeta[widget.type]!.title;
    return '약관 상세';
  }

  @override
  void initState() {
    super.initState();
    _fetchTermDetail();
  }

  /// 약관 본문을 불러와 조 단위로 파싱
  Future<void> _fetchTermDetail() async {
    setState(() {
      _loadingDetail = true;
      _detailError = null;
    });
    try {
      final id = _resolvedTermId;
      final data = await _api.get('/terms/$id');
      final content = (data['content'] ?? '') as String;

      // (선택) BE가 clauses 배열을 주면 그걸 우선 사용
      final serverClauses = (data['clauses'] as List?)
          ?.map((e) => Clause(
                (e['heading'] ?? '').toString(),
                (e['body'] ?? e['content'] ?? '').toString(),
              ))
          .where((c) => c.heading.isNotEmpty || c.body.isNotEmpty)
          .toList();

      if (serverClauses != null && serverClauses.isNotEmpty) {
        setState(() => _clauses = serverClauses);
      } else {
        setState(() => _clauses = _parseKoreanClauses(content));
      }
    } catch (e) {
      setState(() => _detailError = '약관 본문 불러오기 실패: $e');
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  /// AI 요약 모달
  Future<void> _openAISummary() async {
    setState(() => _loading = true);
    try {
      final id = _resolvedTermId;
      final data = await _api.get('/terms/$id/summary');

      final docTitle = (data['title'] ?? _resolvedTitle) as String;

      final bullets = (data['bullets'] as List?)?.cast<String>() ?? <String>[];
      final rights  = (data['rights']  as List?)?.cast<String>() ?? <String>[];
      final glossary = (data['glossary'] as List?)
              ?.map((e) => [
                    (e['term'] ?? '').toString(),
                    (e['def'] ?? e['defn'] ?? '').toString()
                  ])
              .cast<List<String>>()
              .toList() ??
          <List<String>>[];

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
          docTitle: docTitle,
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
    final title = _resolvedTitle;

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
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome, color: Colors.black),
              label: const Text('AI 요약', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF8D648)),
              onPressed: _loading ? null : _openAISummary,
            ),
          ),
        ],
      ),
      body: _loadingDetail
          ? const Center(child: CircularProgressIndicator())
          : _detailError != null
              ? Center(child: Text(_detailError!, style: const TextStyle(color: Colors.white70)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _heroCard(title),
                    const SizedBox(height: 12),
                    ..._clauses.map((c) => _clauseCard(c.heading, c.body)),
                    const SizedBox(height: 40),
                  ],
                ),
    );
  }

  Widget _heroCard(String title) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.push_pin, color: Color(0xFFF8D648)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
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
          Text(h, style: const TextStyle(color: Color(0xFFF8D648), fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: Colors.white, height: 1.5)),
        ]),
      );
}

/// ----- 조 파서 (존치) -----
/// 항/호는 제외하고, '제n조', '제n조의m', '부칙', '별표n'을 섹션 헤더로 간주.
/// 실패하면 통짜 본문으로 반환.
class Clause {
  final String heading;
  final String body;
  Clause(this.heading, this.body);
}

/// 섹션 본문이 비어 있을 때 대체 표시
const String kEmptySectionBody = '…';

List<Clause> _parseKoreanClauses(String raw) {
  final text = raw.replaceAll('\r\n', '\n').trim();
  if (text.isEmpty) return [Clause('본문', '내용이 없습니다.')];

  final headerRe = RegExp(
    r'^(?:\s*제\s*\d+\s*조(?:의\s*\d+)?(?:\s*\([^)]+\))?\s*|\s*부칙(?:\s*\d+)?\s*|\s*별표\s*\d+\s*)',
    multiLine: true,
  );

  final matches = headerRe.allMatches(text).toList();
  if (matches.isEmpty) return [Clause('본문', text)];

  final List<Clause> out = [];
  for (var i = 0; i < matches.length; i++) {
    final m = matches[i];
    final startHeader = m.start;
    final endHeader = m.end;
    final nextStart = (i + 1 < matches.length) ? matches[i + 1].start : text.length;

    final heading = text.substring(startHeader, endHeader).trim();
    var body = text.substring(endHeader, nextStart).trim();
    if (body.isEmpty) body = kEmptySectionBody;
    out.add(Clause(heading, body));
  }
  return out;
}
