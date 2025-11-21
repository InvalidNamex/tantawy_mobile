/// Model for invoice details (line items)
/// This represents individual items in an invoice
class InvoiceDetailModel {
  final String itemName;
  final double quantity;
  final double price;
  final double discount;
  final double vat;
  final double total;

  InvoiceDetailModel({
    required this.itemName,
    required this.quantity,
    required this.price,
    this.discount = 0.0,
    this.vat = 0.0,
    required this.total,
  });

  factory InvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailModel(
      itemName: json['item_name'] ?? json['itemName'] ?? '',
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      vat: (json['vat'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'item_name': itemName,
    'quantity': quantity,
    'price': price,
    'discount': discount,
    'vat': vat,
    'total': total,
  };
}
