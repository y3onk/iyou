// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final Duration timeout;

  ApiService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 15),
  });

  Uri _u(String endpoint, [Map<String, dynamic>? query]) =>
      Uri.parse('$baseUrl$endpoint').replace(queryParameters: query);

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? query,
  }) async {
    final res = await http.get(_u(endpoint, query), headers: headers).timeout(timeout);
    return _process(res);
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final res = await http
        .post(
          _u(endpoint),
          headers: _jsonHeader(headers),
          body: body is String ? body : jsonEncode(body ?? {}),
        )
        .timeout(timeout);
    return _process(res);
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final res = await http
        .put(
          _u(endpoint),
          headers: _jsonHeader(headers),
          body: body is String ? body : jsonEncode(body ?? {}),
        )
        .timeout(timeout);
    return _process(res);
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final res = await http.delete(_u(endpoint), headers: headers).timeout(timeout);
    return _process(res);
  }

  Map<String, String> _jsonHeader(Map<String, String>? h) =>
      {'Content-Type': 'application/json', ...?h};

  dynamic _process(http.Response res) {
    final code = res.statusCode;
    final body = res.body.isEmpty ? null : jsonDecode(res.body);

    if (code >= 200 && code < 300) return body;

    // 에러 메시지 통일
    final msg = body is Map && body['detail'] != null
        ? body['detail'].toString()
        : 'HTTP $code';
    throw ApiException(code: code, message: msg);
  }
}

class ApiException implements Exception {
  final int code;
  final String message;
  ApiException({required this.code, required this.message});
  @override
  String toString() => 'ApiException($code): $message';
}
