import 'package:flutter/material.dart';
import '../core/api_locator.dart';
import '../core/admin_api.dart';

enum AdminMode { list, create, edit }

class AdminTermsScreen extends StatefulWidget {
  const AdminTermsScreen({super.key});
  @override
  State<AdminTermsScreen> createState() => _AdminTermsScreenState();
}

class _AdminTermsScreenState extends State<AdminTermsScreen> {
  late final AdminTermsApi _admin = AdminTermsApi(
    provideApi(),
    adminToken: const String.fromEnvironment('ADMIN_TOKEN', defaultValue: ''),
  );

  AdminMode _mode = AdminMode.list;
  bool _loading = false;        // 목록 로딩
  bool _loadingDetail = false;  // 상세 로딩

  final _q = TextEditingController();
  final _title = TextEditingController();
  final _version = TextEditingController(text: 'v1.0');
  final _effective = TextEditingController();
  final _content = TextEditingController();
  bool _active = true;

  List<Map<String, dynamic>> _rows = [];
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _q.dispose();
    _title.dispose();
    _version.dispose();
    _effective.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final q = _q.text.trim();
      _rows = await _admin.list(q: q);
      if (mounted) setState(() {});
    } catch (e) {
      _snack('목록 실패: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    try {
      final id = await _admin.create(_payload());
      _snack('생성 완료 (id=$id)');
      _clear();
      await _load();
      if (mounted) setState(() => _mode = AdminMode.list);
    } catch (e) {
      _snack('생성 실패: $e');
    }
  }

  Future<void> _update() async {
    if (_selectedId == null) return;
    try {
      await _admin.update(_selectedId!, _payload());
      _snack('수정 완료');
      await _load();
      if (mounted) setState(() => _mode = AdminMode.list);
    } catch (e) {
      _snack('수정 실패: $e');
    }
  }

  // soft delete: is_active=0 으로 업데이트
  Future<void> _delete() async {
    if (_selectedId == null) return;
    try {
      await _admin.update(_selectedId!, {'is_active': 0});
      _snack('비활성 처리 완료');
      _clear();
      await _load();
      if (mounted) setState(() => _mode = AdminMode.list);
    } catch (e) {
      _snack('비활성 처리 실패: $e');
    }
  }

  // 삭제 확인 팝업 → 확정 시 soft delete 처리
  Future<void> _confirmAndDelete(Map<String, dynamic> r) async {
    await _pick(r); // 폼/선택 상태 맞추기

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('정말 삭제하시겠습니까?'),
        content: Text(
          "ID ${r['id']} / ${r['title'] ?? ''}\n"
          "삭제 후에는 목록에서 숨겨집니다. (복구 가능)",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _delete();
    }
  }

  Map<String, dynamic> _payload() => {
        'title': _title.text.trim(),
        'version': _version.text.trim().isEmpty ? 'v1.0' : _version.text.trim(),
        'content': _content.text.trim(),
        'effective_date': _effective.text.trim().isEmpty ? null : _effective.text.trim(),
        'is_active': _active ? 1 : 0,
      };

  // 리스트 아이템 클릭 시: 상세 API로 전문(content) 로드 (비활성 상세 404면 프리뷰로 폴백)
  Future<void> _pick(Map<String, dynamic> r) async {
    setState(() {
      _selectedId = (r['id'] as num).toInt();
      _mode = AdminMode.edit;
      _loadingDetail = true;
    });
    try {
      final detail = await _admin.getDetail(_selectedId!); // /admin/terms/{id}
      _title.text = (detail['title'] ?? '').toString();
      _content.text = (detail['content'] ?? '').toString();
    } catch (e) {
      // 비활성 항목이라 admin 상세가 404일 수 있음 → 목록의 프리뷰로라도 채우기
      _title.text = (r['title'] ?? '').toString();
      _content.text = (r['content'] ?? '').toString();
      _snack('상세 불러오기 실패(프리뷰로 표시): $e');
    } finally {
      // 목록 메타 채우기(자리값)
      _version.text = (r['version'] ?? 'v1.0').toString();
      _effective.text = (r['effective_date'] ?? '').toString();
      _active = (r['is_active'] ?? 1) == 1;

      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  void _clear() {
    setState(() {
      _selectedId = null;
      _title.clear();
      _version.text = 'v1.0';
      _effective.clear();
      _active = true;
      _content.clear();
    });
  }

  void _startCreate() {
    setState(() {
      _mode = AdminMode.create;
      _selectedId = null;
      _title.clear();
      _version.text = 'v1.0';
      _effective.clear();
      _active = true;
      _content.clear();
    });
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약관 관리자'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            child: const Text('사용자 보기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startCreate, // "새 약관 등록" 버튼
        icon: const Icon(Icons.add),
        label: const Text('새 약관 등록'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 좌측: 리스트 (항상 표시)
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _q,
                                decoration: const InputDecoration(labelText: '검색'),
                                onSubmitted: (_) => _load(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: _load, child: const Text('조회')),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _rows.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final r = _rows[i];
                            final active = (r['is_active'] ?? 1) == 1;
                            return ListTile(
                              title: Text('${r['title']}  (${r['version'] ?? ''})'),
                              subtitle: Text('ID ${r['id']} | 활성: ${active ? "Y":"N"}'),
                              onTap: () => _pick(r),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _confirmAndDelete(r), // ✅ 확인 팝업 후 소프트 삭제
                                tooltip: '삭제(비활성화)',
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const VerticalDivider(width: 1),

                // 우측: 에디터 (create/edit일 때만 표시)
                if (_mode != AdminMode.list)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AbsorbPointer(
                        absorbing: _loadingDetail,
                        child: Stack(
                          children: [
                            ListView(
                              children: [
                                if (_mode == AdminMode.edit)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      '편집 중: ID $_selectedId',
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                TextField(
                                  controller: _title,
                                  decoration: const InputDecoration(labelText: '제목'),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _version,
                                  decoration: const InputDecoration(labelText: '버전 (예: v1.0)'),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _effective,
                                  decoration: const InputDecoration(labelText: '시행일 (YYYY-MM-DD)'),
                                ),
                                const SizedBox(height: 8),
                                SwitchListTile(
                                  value: _active,
                                  onChanged: (v) => setState(() => _active = v),
                                  title: const Text('활성화'),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _content,
                                  decoration: const InputDecoration(labelText: '약관 전문'),
                                  maxLines: 14,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: _mode == AdminMode.create ? _create : _update,
                                      child: Text(_mode == AdminMode.create ? '등록' : '수정 저장'),
                                    ),
                                    const SizedBox(width: 8),
                                    if (_mode == AdminMode.edit)
                                      OutlinedButton(
                                        onPressed: () {
                                          // 현재 선택된 것을 맵으로 만들어 팝업에 넘김
                                          final r = {
                                            'id': _selectedId,
                                            'title': _title.text,
                                          };
                                          _confirmAndDelete(r);
                                        },
                                        child: const Text('삭제'),
                                      ),
                                    const SizedBox(width: 8),
                                    if (_mode == AdminMode.edit && _active == false)
                                      OutlinedButton(
                                        onPressed: () async {
                                          if (_selectedId == null) return;
                                          try {
                                            await _admin.update(_selectedId!, {'is_active': 1});
                                            _snack('복구 완료');
                                            await _load();
                                            setState(() => _mode = AdminMode.list);
                                          } catch (e) {
                                            _snack('복구 실패: $e');
                                          }
                                        },
                                        child: const Text('복구'),
                                      ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () => setState(() => _mode = AdminMode.list),
                                      child: const Text('닫기'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (_loadingDetail)
                              const Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
