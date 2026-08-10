import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/purchase_order.dart';

class PurchaseOrderService {
  PurchaseOrderService._();

  static Future<List<PurchaseOrderSummary>> fetchPurchaseOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('sessionId') ?? '';
    final routeId = prefs.getString('routeId') ?? '';
    final username = prefs.getString('username') ?? '';

    if (sessionId.isEmpty) {
      throw Exception('กรุณาเข้าสู่ระบบก่อน');
    }

    final baseUrl = await ApiConfig.getBaseUrl();
    final uri = Uri.parse('$baseUrl/api/receive/purchase-orders').replace(
      queryParameters:
          username.isNotEmpty ? {'username': username} : null,
    );

    final res = await http
        .get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'X-Session-Id': sessionId,
            'X-Route-Id': routeId,
          },
        )
        .timeout(const Duration(seconds: 30));

    if (res.statusCode == 404) {
      throw Exception(
        'Backend ยังไม่มี API /api/receive/purchase-orders '
        'กรุณาเพิ่ม endpoint ฝั่ง Node.js',
      );
    }

    if (res.statusCode != 200) {
      throw Exception(
        'ดึงข้อมูล Purchase Order ไม่สำเร็จ (${res.statusCode})',
      );
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('รูปแบบข้อมูลจาก server ไม่ถูกต้อง');
    }

    if (decoded['success'] == false) {
      throw Exception(
        decoded['message']?.toString() ??
            'ดึงข้อมูล Purchase Order ไม่สำเร็จ',
      );
    }

    return _parseOrders(decoded);
  }

  static List<PurchaseOrderSummary> _parseOrders(
    Map<String, dynamic> decoded,
  ) {
    final apiOrders = _extractApiOrders(decoded);
    if (apiOrders.isNotEmpty) {
      return apiOrders;
    }

    return _aggregateCrossJoinRows(_extractCrossJoinRows(decoded));
  }

  static List<PurchaseOrderSummary> _extractApiOrders(
    Map<String, dynamic> decoded,
  ) {
    final rawData = decoded['data'];
    if (rawData is! List) return const [];

    final orders = rawData
        .whereType<Map<String, dynamic>>()
        .map(PurchaseOrderSummary.fromApiMap)
        .where((order) => order.docEntry > 0)
        .toList();

    orders.sort((a, b) => b.docNum.compareTo(a.docNum));
    return orders;
  }

  static List<dynamic> _extractCrossJoinRows(Map<String, dynamic> decoded) {
    final value = decoded['value'];
    if (value is List) return value;

    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      final nested = data['value'];
      if (nested is List) return nested;
    }

    final orders = decoded['orders'];
    if (orders is List) return orders;

    return const [];
  }

  static List<PurchaseOrderSummary> _aggregateCrossJoinRows(
    List<dynamic> rows,
  ) {
    final grouped = <int, _PurchaseOrderAccumulator>{};

    for (final row in rows) {
      if (row is! Map<String, dynamic>) continue;

      final header = _readHeader(row);
      final line = _readLine(row);
      if (header == null) continue;

      final cancelStatus = header['CancelStatus']?.toString() ?? 'csNo';
      if (cancelStatus == 'csYes') continue;

      final docEntry = _asInt(header['DocEntry'] ?? header['docEntry']);
      grouped.putIfAbsent(
        docEntry,
        () => _PurchaseOrderAccumulator(header: header),
      );
      if (line != null) {
        grouped[docEntry]!.lines.add(line);
      }
    }

    final orders = grouped.values
        .map(
          (item) => PurchaseOrderSummary.fromRows(
            header: item.header,
            lineRows: item.lines,
          ),
        )
        .toList();

    orders.sort((a, b) => b.docNum.compareTo(a.docNum));
    return orders;
  }

  static Map<String, dynamic>? _readHeader(Map<String, dynamic> row) {
    final header = row['PurchaseOrders'];
    if (header is Map<String, dynamic>) return header;

    if (row.containsKey('DocEntry') || row.containsKey('docEntry')) {
      return row;
    }
    return null;
  }

  static Map<String, dynamic>? _readLine(Map<String, dynamic> row) {
    final line = row['PurchaseOrders/DocumentLines'];
    if (line is Map<String, dynamic>) return line;

    if (row.containsKey('LineNum') ||
        row.containsKey('lineNum') ||
        row.containsKey('ItemCode') ||
        row.containsKey('itemCode')) {
      return row;
    }
    return null;
  }
}

class _PurchaseOrderAccumulator {
  _PurchaseOrderAccumulator({required this.header});

  final Map<String, dynamic> header;
  final List<Map<String, dynamic>> lines = [];
}

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}
