import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  SessionStore._();

  static Future<Map<String, String>> headers() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'Content-Type': 'application/json',
      'X-Session-Id': prefs.getString('sessionId') ?? '',
      'X-Route-Id': prefs.getString('routeId') ?? '',
    };
  }

  static Future<String> requireSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('sessionId') ?? '';
    if (id.isEmpty) throw Exception('กรุณาเข้าสู่ระบบก่อน');
    return id;
  }

  static Future<String?> warehouseCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('warehouseCode');
  }

  static Future<String?> warehouseName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('warehouseName');
  }

  static Future<String> requireWarehouseCode() async {
    final code = await warehouseCode();
    if (code == null || code.isEmpty) {
      throw Exception('กรุณาเลือกคลังสินค้า');
    }
    return code;
  }

  static Future<String?> username() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
}
