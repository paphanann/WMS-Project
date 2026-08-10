enum PurchaseOrderTab { waiting, partial, complete }

class PurchaseOrderLine {
  const PurchaseOrderLine({
    required this.lineNum,
    required this.itemCode,
    required this.itemDescription,
    required this.quantity,
    required this.warehouseCode,
  });

  final int lineNum;
  final String itemCode;
  final String itemDescription;
  final double quantity;
  final String warehouseCode;

  factory PurchaseOrderLine.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderLine(
      lineNum: _asInt(json['LineNum'] ?? json['lineNum']),
      itemCode: (json['ItemCode'] ?? json['itemCode'])?.toString() ?? '',
      itemDescription:
          (json['ItemDescription'] ?? json['itemDescription'])?.toString() ??
              '',
      quantity: _asDouble(json['Quantity'] ?? json['quantity']),
      warehouseCode:
          (json['WarehouseCode'] ?? json['warehouseCode'])?.toString() ?? '',
    );
  }
}

class PurchaseOrderSummary {
  PurchaseOrderSummary({
    required this.docEntry,
    required this.docNum,
    required this.cardCode,
    required this.cardName,
    required this.docDate,
    required this.documentStatus,
    required this.cancelStatus,
    required this.lines,
    this.openLineCount = 0,
  });

  final int docEntry;
  final int docNum;
  final String cardCode;
  final String cardName;
  final DateTime? docDate;
  final String documentStatus;
  final String cancelStatus;
  final List<PurchaseOrderLine> lines;
  final int openLineCount;

  int get lineCount =>
      lines.isNotEmpty ? lines.length : openLineCount;

  double get totalQuantity {
    if (lines.isNotEmpty) {
      return lines.fold(0, (sum, line) => sum + line.quantity);
    }
    return 0;
  }

  String get displayDocNum {
    final raw = docNum.toString();
    if (raw.startsWith('PO')) return raw;
    return 'PO$raw';
  }

  String get statusLabel {
    if (_isClosedStatus(documentStatus)) return 'รับครบ';
    if (tab == PurchaseOrderTab.partial) return 'บางส่วน';
    return 'รอรับ';
  }

  PurchaseOrderTab get tab {
    if (_isClosedStatus(documentStatus)) return PurchaseOrderTab.complete;
    return PurchaseOrderTab.waiting;
  }

  String get formattedDate {
    if (docDate == null) return '-';
    final d = docDate!;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return displayDocNum.toLowerCase().contains(q) ||
        docNum.toString().contains(q) ||
        cardName.toLowerCase().contains(q) ||
        cardCode.toLowerCase().contains(q);
  }

  static PurchaseOrderSummary fromApiMap(Map<String, dynamic> json) {
    final rawLines = json['lines'];
    final lines = rawLines is List
        ? rawLines
            .whereType<Map<String, dynamic>>()
            .map(PurchaseOrderLine.fromJson)
            .toList()
        : <PurchaseOrderLine>[];

    return PurchaseOrderSummary(
      docEntry: _asInt(json['docEntry'] ?? json['DocEntry']),
      docNum: _asInt(json['docNum'] ?? json['DocNum']),
      cardCode: (json['cardCode'] ?? json['CardCode'])?.toString() ?? '',
      cardName: (json['cardName'] ?? json['CardName'])?.toString() ?? '',
      docDate: _parseDate(json['docDate'] ?? json['DocDate']),
      documentStatus:
          (json['documentStatus'] ?? json['DocumentStatus'])?.toString() ?? 'O',
      cancelStatus:
          (json['cancelStatus'] ?? json['CancelStatus'])?.toString() ?? 'csNo',
      lines: lines,
      openLineCount: _asInt(json['openLineCount'] ?? lines.length),
    );
  }

  static PurchaseOrderSummary fromRows({
    required Map<String, dynamic> header,
    required List<Map<String, dynamic>> lineRows,
  }) {
    return PurchaseOrderSummary(
      docEntry: _asInt(header['DocEntry']),
      docNum: _asInt(header['DocNum']),
      cardCode: header['CardCode']?.toString() ?? '',
      cardName: header['CardName']?.toString() ?? '',
      docDate: _parseDate(header['DocDate']),
      documentStatus: header['DocumentStatus']?.toString() ?? 'O',
      cancelStatus: header['CancelStatus']?.toString() ?? 'csNo',
      lines: lineRows.map(PurchaseOrderLine.fromJson).toList(),
    );
  }
}

bool _isClosedStatus(String status) {
  final normalized = status.trim().toLowerCase();
  return normalized == 'c' ||
      normalized == 'bost_close' ||
      normalized.contains('close');
}

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

double _asDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final raw = value.toString();
  return DateTime.tryParse(raw);
}
