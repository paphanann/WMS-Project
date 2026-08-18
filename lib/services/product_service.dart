import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_item.dart';
import 'server_config_service.dart';
import 'session_store.dart';

class ProductService {
  static Future<List<ProductItem>> search({String query = ''}) async {
    await SessionStore.requireSessionId();

    final baseUrl = await ServerConfigService.getBaseUrl();
    final q = query.trim();
    final uri = Uri.parse('$baseUrl/api/products').replace(
      queryParameters: q.isEmpty ? null : {'q': q},
    );

    final res = await http
        .get(uri, headers: await SessionStore.headers())
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('โหลดสินค้าไม่สำเร็จ (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] == false) {
      throw Exception(body['message']?.toString() ?? 'โหลดสินค้าไม่สำเร็จ');
    }

    final list = body['data'];
    if (list is! List) return [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(ProductItem.fromJson)
        .where((p) => p.itemCode.isNotEmpty)
        .toList();
  }
}
