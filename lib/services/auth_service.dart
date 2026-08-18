import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'server_config_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final baseUrl = await ServerConfigService.getBaseUrl();
    final user = username.trim().toUpperCase();

    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': user, 'password': password}),
    ).timeout(const Duration(seconds: 15));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('เซิร์ฟเวอร์ตอบกลับไม่ถูกต้อง (${res.statusCode})');
    }
    if (res.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message']?.toString() ?? 'เข้าสู่ระบบไม่สำเร็จ');
    }

    final prefs = await SharedPreferences.getInstance();
    final session = data['session'] as Map<String, dynamic>? ?? {};

    await prefs.setString('sessionId', session['sessionId']?.toString() ?? '');
    await prefs.setString('routeId', session['routeId']?.toString() ?? '');
    await prefs.setString('username', user);

    return data;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('sessionId') ?? '';
    final routeId = prefs.getString('routeId') ?? '';

    try {
      final baseUrl = await ServerConfigService.getBaseUrl();
      await http.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId, 'routeId': routeId}),
      );
    } catch (_) {}

    await prefs.remove('sessionId');
    await prefs.remove('routeId');
    await prefs.remove('username');
    await prefs.remove('warehouseCode');
    await prefs.remove('warehouseName');
    await prefs.remove('warehouse');
    await prefs.remove('database');
  }
}
