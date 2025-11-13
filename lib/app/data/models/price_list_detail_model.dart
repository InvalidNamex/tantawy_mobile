import 'package:hive/hive.dart';

part 'price_list_detail_model.g.dart';

@HiveType(typeId: 4)
class PriceListDetailModel {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final ItemInfo item;
  
  @HiveField(2)
  final PriceListInfoDetail priceList;
  
  @HiveField(3)
  final double price;

  PriceListDetailModel({
    required this.id,
    required this.item,
    required this.priceList,
    required this.price,
  });

  factory PriceListDetailModel.fromJson(Map<String, dynamic> json) => PriceListDetailModel(
    id: json['id'],
    item: json['item'] is Map<String, dynamic> 
        ? ItemInfo.fromJson(json['item'])
        : ItemInfo(id: json['item'] as int, itemName: ''),
    priceList: json['priceList'] is Map<String, dynamic>
        ? PriceListInfoDetail.fromJson(json['priceList'])
        : PriceListInfoDetail(id: json['priceList'] as int, priceListName: ''),
    price: (json['price'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'item': item.toJson(),
    'priceList': priceList.toJson(),
    'price': price,
  };
}

@HiveType(typeId: 5)
class ItemInfo {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String itemName;

  ItemInfo({required this.id, required this.itemName});

  factory ItemInfo.fromJson(Map<String, dynamic> json) => ItemInfo(
    id: json['id'],
    itemName: json['itemName'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'itemName': itemName};
}

@HiveType(typeId: 6)
class PriceListInfoDetail {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String priceListName;

  PriceListInfoDetail({required this.id, required this.priceListName});

  factory PriceListInfoDetail.fromJson(Map<String, dynamic> json) => PriceListInfoDetail(
    id: json['id'],
    priceListName: json['priceListName'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'priceListName': priceListName};
}
