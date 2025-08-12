enum TermsType { uniqueId, eFinanceService, standardEFT, marketing }

class TermItem {
  final String title;
  final bool required;
  final TermsType type;
  bool checked;
  TermItem({
    required this.title,
    required this.required,
    required this.type,
    this.checked = false,
  });
}
