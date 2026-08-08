import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServerConfigService {
  ServerConfigService._();

  static const defaultDatabase = 'WMS_W9';
  static const databases = [defaultDatabase];

  /// คืนชื่อ DB ที่ใช้ได้ — ถ้าเคยบันทึกชื่อเก่า (เช่น SBO_PRD_CT) จะเปลี่ยนเป็น WMS_W9
  static String resolveDatabase(String? saved) {
    if (saved != null && databases.contains(saved)) return saved;
    return defaultDatabase;
  }

  static Future<({String ip, String port, String database})> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawDatabase = prefs.getString('serverDatabase');
    final database = resolveDatabase(rawDatabase);

    if (rawDatabase != database) {
      await prefs.setString('serverDatabase', database);
    }

    return (
      ip: prefs.getString('serverIp') ?? '',
      port: prefs.getString('serverPort') ?? '3001',
      database: database,
    );
  }

  static Future<DateTime> testAndSave({
    required String ip,
    required String port,
    required String database,
  }) async {
    final baseUrl = 'http://$ip:$port';

    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode >= 500) {
        throw Exception('เซิร์ฟเวอร์ตอบกลับไม่สำเร็จ (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverIp', ip);
    await prefs.setString('serverPort', port);
    await prefs.setString('serverDatabase', database);

    final connectedAt = DateTime.now();
    await prefs.setString('serverConnectedAt', connectedAt.toIso8601String());

    return connectedAt;
  }

  static Future<void> clearConnection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('serverIp');
    await prefs.remove('serverPort');
    await prefs.remove('serverDatabase');
    await prefs.remove('serverConnectedAt');
  }

  static Future<Map<String, dynamic>?> getSavedConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('serverIp');
    if (ip == null || ip.isEmpty) return null;

    return {
      'ip': ip,
      'port': prefs.getString('serverPort') ?? '',
      'database': prefs.getString('serverDatabase') ?? '',
      'connectedAt': prefs.getString('serverConnectedAt'),
    };
  }

  static String formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
