import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class AuthService {
  AuthService._();

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      final session = data['session'] as Map<String, dynamic>? ?? {};
      final user = data['user'] as Map<String, dynamic>? ?? {};

      await prefs.setString('sessionId', session['sessionId']?.toString() ?? '');
      await prefs.setString('routeId', session['routeId']?.toString() ?? '');
      await prefs.setString(
        'username',
        user['username']?.toString() ?? username,
      );
      return data;
    }

    throw Exception(data['message']?.toString() ?? 'เข้าสู่ระบบไม่สำเร็จ');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('sessionId') ?? '';
    final routeId = prefs.getString('routeId') ?? '';

    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/logout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sessionId': sessionId,
        'routeId': routeId,
      }),
    );

    await prefs.clear();
  }
}
