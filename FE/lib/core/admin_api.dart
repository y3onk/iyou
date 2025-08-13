// lib/core/admin_api.dart
import '../services/api_service.dart';

class AdminTermsApi {
  final ApiService _api;
  final String adminToken; // 관리자 인증 토큰
  AdminTermsApi(this._api, {required this.adminToken});

  Map<String, String> get _auth => {'Authorization': 'Bearer $adminToken'};

  /// 목록 (관리자만)  GET /admin/terms
  Future<List<Map<String, dynamic>>> list({String q = ''}) async {
    final res = await _api.get('/admin/terms', headers: _auth, query: {'q': q});
    if (res is List) {
      return res.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw StateError('Unexpected response type for list: ${res.runtimeType}');
  }
  
  /// 상세 (관리자만)  GET /admin/terms/{id}
  Future<Map<String, dynamic>> getDetail(int id) async {
    final res = await _api.get('/admin/terms/$id', headers: _auth);
    if (res is Map) return Map<String, dynamic>.from(res);
    throw StateError('Unexpected detail response: ${res.runtimeType}');
  }

  /// 생성  POST /admin/terms
  Future<int> create(Map<String, dynamic> payload) async {
    final res = await _api.post('/admin/terms', headers: _auth, body: payload);
    if (res is Map && res['id'] != null) return (res['id'] as num).toInt();
    throw StateError('Unexpected response type for create: ${res.runtimeType}');
  }

  /// 수정  PUT /admin/terms/{id}
  Future<void> update(int id, Map<String, dynamic> payload) async {
    await _api.put('/admin/terms/$id', headers: _auth, body: payload);
  }

  /// 삭제  DELETE /admin/terms/{id}
  Future<void> deleteTerm(int id) async {
    await _api.delete('/admin/terms/$id', headers: _auth);
  }
}
