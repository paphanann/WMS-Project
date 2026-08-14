enum PoTab { open, closed }

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
      lineNum: _toInt(json['lineNum']),
      itemCode: json['itemCode']?.toString() ?? '',
      itemDescription: json['itemDescription']?.toString() ?? '',
      quantity: _toDouble(json['quantity'] ?? json['orderedQty']),
      warehouseCode: json['warehouseCode']?.toString() ?? '',
    );
  }

  String get displayName =>
      itemDescription.isNotEmpty ? itemDescription : itemCode;
}

class PurchaseOrderSummary {
  PurchaseOrderSummary({
    required this.docEntry,
    required this.docNum,
    required this.cardCode,
    required this.cardName,
    required this.docDate,
    required this.documentStatus,
    required this.lines,
    this.openLineCount = 0,
  });

  final int docEntry;
  final int docNum;
  final String cardCode;
  final String cardName;
  final DateTime? docDate;
  final String documentStatus;
  final List<PurchaseOrderLine> lines;
  final int openLineCount;

  bool get isClosed => documentStatus == 'C';

  PoTab get tab => isClosed ? PoTab.closed : PoTab.open;

  int get lineCount => lines.isNotEmpty ? lines.length : openLineCount;

  double get totalQty {
    if (lines.isEmpty) return 0;
    return lines.fold(0.0, (sum, line) => sum + line.quantity);
  }

  String get poNo => 'PO$docNum';

  String get statusText => isClosed ? 'รับครบ' : 'รอรับ';

  String get dateText {
    if (docDate == null) return '-';
    final d = docDate!;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  bool matchQuery(String q) {
    if (q.isEmpty) return true;
    final query = q.toLowerCase();
    return poNo.toLowerCase().contains(query) ||
        docNum.toString().contains(query) ||
        cardName.toLowerCase().contains(query) ||
        cardCode.toLowerCase().contains(query);
  }

  factory PurchaseOrderSummary.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'];
    final lines = rawLines is List
        ? rawLines
            .whereType<Map<String, dynamic>>()
            .map(PurchaseOrderLine.fromJson)
            .toList()
        : <PurchaseOrderLine>[];

    return PurchaseOrderSummary(
      docEntry: _toInt(json['docEntry']),
      docNum: _toInt(json['docNum']),
      cardCode: json['cardCode']?.toString() ?? '',
      cardName: json['cardName']?.toString() ?? '',
      docDate: DateTime.tryParse(json['docDate']?.toString() ?? ''),
      documentStatus: json['documentStatus']?.toString() ?? 'O',
      lines: lines,
      openLineCount: _toInt(json['openLineCount']),
    );
  }
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}
