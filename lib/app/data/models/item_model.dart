import 'package:hive/hive.dart';

part 'item_model.g.dart';

@HiveType(typeId: 3)
class ItemModel {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String itemName;
  
  @HiveField(2)
  final int itemGroupId;
  
  @HiveField(3)
  final String barcode;
  
  @HiveField(4)
  final String sign;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.itemGroupId,
    required this.barcode,
    required this.sign,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
    id: json['id'],
    itemName: json['itemName'],
    itemGroupId: json['itemGroupId'],
    barcode: json['barcode'] ?? '',
    sign: json['sign'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemName': itemName,
    'itemGroupId': itemGroupId,
    'barcode': barcode,
    'sign': sign,
  };
}
