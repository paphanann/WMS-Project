class ProductItem {
  const ProductItem({
    required this.itemCode,
    required this.itemName,
    this.sizeText = '',
    this.imageUrl,
  });

  final String itemCode;
  final String itemName;
  final String sizeText;
  final String? imageUrl;

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      itemCode: json['itemCode']?.toString() ??
          json['sku']?.toString() ??
          '',
      itemName: json['itemName']?.toString() ??
          json['itemDescription']?.toString() ??
          json['name']?.toString() ??
          '',
      sizeText: json['sizeText']?.toString() ??
          json['size']?.toString() ??
          '',
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}
