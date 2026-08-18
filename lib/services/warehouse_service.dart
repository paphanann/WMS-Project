import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/warehouse.dart';
import 'server_config_service.dart';
import 'session_store.dart';

class WarehouseService {
  static Future<List<Warehouse>> fetchList() async {
    await SessionStore.requireSessionId();

    final baseUrl = await ServerConfigService.getBaseUrl();
    final res = await http
        .get(
          Uri.parse('$baseUrl/api/warehouses'),
          headers: await SessionStore.headers(),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('โหลดคลังสินค้าไม่สำเร็จ (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] == false) {
      throw Exception(body['message']?.toString() ?? 'โหลดคลังสินค้าไม่สำเร็จ');
    }

    final list = body['data'];
    if (list is! List) return [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(Warehouse.fromJson)
        .where((w) => w.code.isNotEmpty)
        .toList();
  }
}
