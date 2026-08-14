import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'server_config_service.dart';
import '../models/purchase_order.dart';

class PurchaseOrderService {
  static Future<List<PurchaseOrderSummary>> fetchList() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('sessionId') ?? '';
    final routeId = prefs.getString('routeId') ?? '';
    final username = prefs.getString('username') ?? '';

    if (sessionId.isEmpty) {
      throw Exception('กรุณาเข้าสู่ระบบก่อน');
    }

    final baseUrl = await ServerConfigService.getBaseUrl();
    final uri = Uri.parse('$baseUrl/api/receive/purchase-orders').replace(
      queryParameters: username.isEmpty ? null : {'username': username},
    );

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Session-Id': sessionId,
        'X-Route-Id': routeId,
      },
    ).timeout(const Duration(seconds: 30));

    if (res.statusCode != 200) {
      throw Exception('โหลด PO ไม่สำเร็จ (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] == false) {
      throw Exception(body['message']?.toString() ?? 'โหลด PO ไม่สำเร็จ');
    }

    final list = body['data'];
    if (list is! List) return [];

    final orders = list
        .whereType<Map<String, dynamic>>()
        .map(PurchaseOrderSummary.fromJson)
        .toList();

    orders.sort((a, b) => b.docNum.compareTo(a.docNum));
    return orders;
  }

  static Future<PurchaseOrderSummary> fetchDetail(int docEntry) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('sessionId') ?? '';
    final routeId = prefs.getString('routeId') ?? '';

    if (sessionId.isEmpty) {
      throw Exception('กรุณาเข้าสู่ระบบก่อน');
    }

    final baseUrl = await ServerConfigService.getBaseUrl();
    final uri = Uri.parse('$baseUrl/api/receive/purchase-orders/$docEntry');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Session-Id': sessionId,
        'X-Route-Id': routeId,
      },
    ).timeout(const Duration(seconds: 30));

    if (res.statusCode != 200) {
      throw Exception('โหลดรายละเอียด PO ไม่สำเร็จ (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] == false) {
      throw Exception(body['message']?.toString() ?? 'โหลดรายละเอียด PO ไม่สำเร็จ');
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return PurchaseOrderSummary.fromJson(data);
    }
    throw Exception('ข้อมูล PO ไม่ถูกต้อง');
  }
}
