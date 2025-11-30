import 'package:hive/hive.dart';

part 'item_model.g.dart';

@HiveType(typeId: 3)
class ItemModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String itemName;

  @HiveField(2)
  final int? itemGroupId;

  @HiveField(3)
  final String barcode;

  @HiveField(4)
  final String sign;

  @HiveField(5)
  final String? mainUnitName;

  @HiveField(6)
  final String? subUnitName;

  @HiveField(7)
  final String? smallUnitName;

  @HiveField(8)
  final double? mainUnitPack;

  @HiveField(9)
  final double? subUnitPack;

  ItemModel({
    required this.id,
    required this.itemName,
    this.itemGroupId,
    required this.barcode,
    required this.sign,
    this.mainUnitName,
    this.subUnitName,
    this.smallUnitName,
    this.mainUnitPack,
    this.subUnitPack,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
    id: json['id'],
    itemName: json['itemName'],
    itemGroupId: json['itemGroupId'],
    barcode: json['barcode'] ?? '',
    sign: json['sign'] ?? '',
    mainUnitName: json['mainUnitName'],
    subUnitName: json['subUnitName'],
    smallUnitName: json['smallUnitName'],
    mainUnitPack: json['mainUnitPack']?.toDouble(),
    subUnitPack: json['subUnitPack']?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemName': itemName,
    'itemGroupId': itemGroupId,
    'barcode': barcode,
    'sign': sign,
    'mainUnitName': mainUnitName,
    'subUnitName': subUnitName,
    'smallUnitName': smallUnitName,
    'mainUnitPack': mainUnitPack,
    'subUnitPack': subUnitPack,
  };
}
