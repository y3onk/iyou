// lib/core/api_locator.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/api_service.dart';

/// 환경에 맞는 baseUrl을 자동 선택.
/// --dart-define=BASE_URL=... 로 언제든 덮어쓰기 가능.
ApiService provideApi() {
  const defined = String.fromEnvironment('BASE_URL', defaultValue: '');
  if (defined.isNotEmpty) {
    return ApiService(baseUrl: _trim(defined));
  }

  late final String baseUrl;
  if (kIsWeb) {
    baseUrl = 'http://127.0.0.1:8000';
  } else if (Platform.isAndroid) {
    // Android 에뮬레이터에서 PC의 localhost 접근
    baseUrl = 'http://10.0.2.2:8000';
  } else if (Platform.isIOS) {
    baseUrl = 'http://127.0.0.1:8000';
  } else {
    // Windows/Mac/Linux 데스크톱
    baseUrl = 'http://127.0.0.1:8000';
  }
  return ApiService(baseUrl: _trim(baseUrl));
}

String _trim(String s) => s.endsWith('/') ? s.substring(0, s.length - 1) : s;

class TermsApi {
  final ApiService _api;
  TermsApi(this._api);

  /// 상세 (public)
  Future<Map<String, dynamic>> getDetail(int id) async {
    final res = await _api.get('/public/terms/$id');
    if (res is Map) return Map<String, dynamic>.from(res);
    throw StateError('Unexpected response type for detail: ${res.runtimeType}');
  }

  /// 요약 (public)
  Future<Map<String, dynamic>> getSummary(int id) async {
    final res = await _api.get('/public/terms/$id/summary');
    if (res is Map) return Map<String, dynamic>.from(res);
    throw StateError('Unexpected response type for summary: ${res.runtimeType}');
  }
}
