import 'package:hive/hive.dart';

part 'stock_model.g.dart';

@HiveType(typeId: 13)
class StockModel {
  @HiveField(0)
  final int itemId;

  @HiveField(1)
  final double stock;

  @HiveField(2)
  final String itemName;

  StockModel({
    required this.itemId,
    required this.stock,
    required this.itemName,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) => StockModel(
    itemId: json['item_id'],
    stock: (json['stock'] as num).toDouble(),
    itemName: json['item_name'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'stock': stock,
    'item_name': itemName,
  };
}
