enum PoTab { open, closed }

class PurchaseOrderLine {
  const PurchaseOrderLine({
    required this.lineNum,
    required this.itemCode,
    required this.itemDescription,
    required this.quantity,
    required this.warehouseCode,
    this.warehouseName = '',
    this.binLocation = '',
  });

  final int lineNum;
  final String itemCode;
  final String itemDescription;
  final double quantity;
  final String warehouseCode;
  final String warehouseName;
  final String binLocation;

  factory PurchaseOrderLine.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderLine(
      lineNum: _toInt(json['lineNum']),
      itemCode: json['itemCode']?.toString() ?? '',
      itemDescription: json['itemDescription']?.toString() ?? '',
      quantity: _toDouble(json['quantity'] ?? json['orderedQty']),
      warehouseCode: json['warehouseCode']?.toString() ??
          json['WarehouseCode']?.toString() ??
          json['WhsCode']?.toString() ??
          '',
      warehouseName: json['warehouseName']?.toString() ??
          json['WarehouseName']?.toString() ??
          json['whsName']?.toString() ??
          json['WhsName']?.toString() ??
          '',
      binLocation: json['binLocation']?.toString() ??
          json['binCode']?.toString() ??
          json['BinCode']?.toString() ??
          '',
    );
  }

  /// ชื่อคลังจาก SAP (บรรทัด PO หรือ lookup จาก master)
  String binLocationDisplay(Map<String, String> warehouseNames) {
    if (warehouseCode.isEmpty) return '-';

    final name = warehouseName.isNotEmpty
        ? warehouseName
        : (warehouseNames[warehouseCode] ?? '');

    if (name.isNotEmpty) return '$warehouseCode / $name';
    if (binLocation.isNotEmpty) return '$warehouseCode / $binLocation';
    return '$warehouseCode / -';
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
    this.totalQtyValue = 0,
  });

  final int docEntry;
  final int docNum;
  final String cardCode;
  final String cardName;
  final DateTime? docDate;
  final String documentStatus;
  final List<PurchaseOrderLine> lines;
  final int openLineCount;
  final double totalQtyValue;

  bool get isClosed => documentStatus == 'C';

  PoTab get tab => isClosed ? PoTab.closed : PoTab.open;

  int get lineCount => lines.isNotEmpty ? lines.length : openLineCount;

  double get totalQty {
    if (lines.isNotEmpty) {
      return lines.fold(0.0, (sum, line) => sum + line.quantity);
    }
    return totalQtyValue;
  }

  String get totalQtyText {
    if (totalQty <= 0) return '-';
    final whole = totalQty == totalQty.roundToDouble();
    return '${totalQty.toStringAsFixed(whole ? 0 : 1)} ชิ้น';
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
      totalQtyValue: _toDouble(
        json['totalQty'] ??
            json['openQty'] ??
            json['totalQuantity'] ??
            json['TotalQty'] ??
            json['OpenQty'],
      ),
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
