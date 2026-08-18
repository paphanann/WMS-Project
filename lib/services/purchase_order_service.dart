import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/purchase_order.dart';
import 'server_config_service.dart';
import 'session_store.dart';

class PurchaseOrderService {
  static Future<List<PurchaseOrderSummary>> fetchList() async {
    await SessionStore.requireSessionId();
    final username = await SessionStore.username() ?? '';

    final baseUrl = await ServerConfigService.getBaseUrl();
    final uri = Uri.parse('$baseUrl/api/receive/purchase-orders').replace(
      queryParameters: username.isEmpty ? null : {'username': username},
    );

    final res = await http
        .get(uri, headers: await SessionStore.headers())
        .timeout(const Duration(seconds: 30));

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
    await SessionStore.requireSessionId();

    final baseUrl = await ServerConfigService.getBaseUrl();
    final uri = Uri.parse('$baseUrl/api/receive/purchase-orders/$docEntry');

    final res = await http
        .get(uri, headers: await SessionStore.headers())
        .timeout(const Duration(seconds: 30));

    if (res.statusCode != 200) {
      throw Exception('โหลดรายละเอียด PO ไม่สำเร็จ (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] == false) {
      throw Exception(
        body['message']?.toString() ?? 'โหลดรายละเอียด PO ไม่สำเร็จ',
      );
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return PurchaseOrderSummary.fromJson(data);
    }
    throw Exception('ข้อมูล PO ไม่ถูกต้อง');
  }

  static Future<Map<String, dynamic>> saveReceipt({
    required int docEntry,
    required String receiveDate,
    required String deliveryNote,
    required List<Map<String, dynamic>> lines,
  }) async {
    await SessionStore.requireSessionId();
    final warehouse = await SessionStore.requireWarehouseCode();

    final baseUrl = await ServerConfigService.getBaseUrl();
    final uri =
        Uri.parse('$baseUrl/api/receive/purchase-orders/$docEntry/receipt');

    final res = await http
        .post(
          uri,
          headers: await SessionStore.headers(),
          body: jsonEncode({
            'warehouse': warehouse,
            'receiveDate': receiveDate,
            'deliveryNote': deliveryNote,
            'lines': lines,
          }),
        )
        .timeout(const Duration(seconds: 60));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message']?.toString() ?? 'บันทึกรับสินค้าไม่สำเร็จ');
    }

    return body;
  }
}
