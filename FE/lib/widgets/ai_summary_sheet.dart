import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AISummarySheet extends StatelessWidget {
  final String docTitle;
  final List<String> summaryBullets;
  final List<List<String>> glossary; // [term, def]
  final List<String> rights;

  const AISummarySheet({
    super.key,
    required this.docTitle,
    required this.summaryBullets,
    required this.glossary,
    required this.rights,
  });

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(24);
    return DraggableScrollableSheet(
      initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 44, height: 5,
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4))),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _header(context),
                  const SizedBox(height: 12),
                  _docTag(),
                  const SizedBox(height: 16),
                  _summaryPanel(),
                  const SizedBox(height: 16),
                  _glossaryPanel(),
                  const SizedBox(height: 16),
                  _rightsPanel(),
                  const SizedBox(height: 16),
                  _disclaimer(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인했어요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Row(children: [
    const CircleAvatar(backgroundColor: Color(0xFFE6FFF2), child: Icon(Icons.auto_awesome, color: Colors.green)),
    const SizedBox(width: 12),
    const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('AI 약관 요약', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      Text('iyou AI가 요약해드려요', style: TextStyle(color: Colors.black54)),
    ]),
    const Spacer(),
    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
  ]);

  Widget _docTag() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: const Color(0xFFEFFAF6), borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      const Icon(Icons.receipt_long, color: AppTheme.green),
      const SizedBox(width: 8),
      Flexible(child: Text(docTitle, style: const TextStyle(fontWeight: FontWeight.w700))),
    ]),
  );

  Widget _panel({required String title, required Widget child, Color? bg}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: bg ?? const Color(0xFFF6FFFB), borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(999)),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      const SizedBox(height: 12),
      child,
    ]),
  );

  Widget _summaryPanel() => _panel(
    title: '핵심 내용',
    bg: const Color(0xFFEFFFF6),
    child: Column(
      children: List.generate(summaryBullets.length, (i) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 24, height: 24, alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFFFF3C7), borderRadius: BorderRadius.circular(999)),
            child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(summaryBullets[i])),
        ]),
      )),
    ),
  );

  Widget _glossaryPanel() => _panel(
    title: '주요 용어',
    bg: const Color(0xFFFFF8E7),
    child: Column(
      children: glossary.map((pair) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.label_important, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pair[0], style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(pair[1]),
          ])),
        ]),
      )).toList(),
    ),
  );

  Widget _rightsPanel() => _panel(
    title: '주의가 필요해요',
    child: Column(
      children: rights.map((r) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFEAF3FF), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.verified, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(r, style: const TextStyle(fontWeight: FontWeight.w600))),
        ]),
      )).toList(),
    ),
  );

  Widget _disclaimer() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(16)),
    child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(radius: 14, backgroundColor: Color(0xFFE6FFF2),
        child: Icon(Icons.auto_awesome, color: Colors.green, size: 18)),
      SizedBox(width: 10),
      Expanded(child: Text(
        'AI 요약 안내\n이 요약은 iyou AI가 약관 내용을 분석하여 제공하는 참고용 정보입니다. 정확한 내용은 전체 약관을 확인해주세요.',
        style: TextStyle(height: 1.4),
      )),
    ]),
  );
}
