class Warehouse {
  const Warehouse({required this.code, required this.name});

  final String code;
  final String name;

  String get displayLabel {
    if (name.isEmpty) return code;
    return '$code - $name';
  }

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      code: json['warehouseCode']?.toString() ??
          json['code']?.toString() ??
          '',
      name: json['warehouseName']?.toString() ??
          json['name']?.toString() ??
          '',
    );
  }
}
