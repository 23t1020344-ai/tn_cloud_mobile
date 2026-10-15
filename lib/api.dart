import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Web/Windows: localhost. Android emulator: 10.0.2.2.
/// Điện thoại thật: chạy với --dart-define=API_BASE=http://IP_MAY_TINH:3000
String get apiBase {
  const fromEnv = String.fromEnvironment('API_BASE');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}

class ApiException implements Exception {
  final int status;
  final String code;
  final String message;
  const ApiException(this.status, this.code, this.message);
  @override
  String toString() => message;
}

class Api {
  static String? _token;
  static bool get hasToken => _token != null;

  /// Được gọi khi server báo token hết hạn / không hợp lệ.
  static void Function()? onUnauthorized;

  static Future<void> loadToken() async {
    final p = await SharedPreferences.getInstance();
    _token = p.getString('token');
  }

  static Future<void> setToken(String? t) async {
    _token = t;
    final p = await SharedPreferences.getInstance();
    if (t == null) {
      await p.remove('token');
    } else {
      await p.setString('token', t);
    }
  }

  static Future<dynamic> get(String path) => _send('GET', path);
  static Future<dynamic> delete(String path) => _send('DELETE', path);
  static Future<dynamic> post(String path, Map<String, dynamic> body,
          {bool auth = true}) =>
      _send('POST', path, body: body, auth: auth);

  static Future<dynamic> _send(String method, String path,
      {Map<String, dynamic>? body, bool auth = true}) async {
    final req = http.Request(method, Uri.parse('$apiBase$path'));
    req.headers['Content-Type'] = 'application/json';
    if (auth && _token != null) req.headers['Authorization'] = 'Bearer $_token';
    if (body != null) req.body = jsonEncode(body);

    http.Response res;
    try {
      final streamed = await req.send().timeout(const Duration(seconds: 20));
      res = await http.Response.fromStream(streamed);
    } catch (_) {
      throw const ApiException(
          0, 'network', 'Không kết nối được máy chủ. Vui lòng thử lại.');
    }

    dynamic data = {};
    try {
      if (res.body.isNotEmpty) data = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {}

    if (res.statusCode >= 200 && res.statusCode < 300) return data;

    if (res.statusCode == 401 && auth) {
      await setToken(null);
      onUnauthorized?.call();
    }
    final m = data is Map ? data : const {};
    throw ApiException(res.statusCode, '${m['error'] ?? 'error'}',
        '${m['message'] ?? 'Có lỗi xảy ra, vui lòng thử lại'}');
  }
}