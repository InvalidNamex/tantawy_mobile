import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 1)
class CustomerModel {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String customerName;
  
  @HiveField(2)
  final String phoneOne;
  
  @HiveField(3)
  final PriceListInfo? priceList;

  CustomerModel({
    required this.id,
    required this.customerName,
    required this.phoneOne,
    this.priceList,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: json['id'],
    customerName: json['customer_name'],
    phoneOne: json['phone_one'] ?? '',
    priceList: json['price_list'] != null 
        ? PriceListInfo.fromJson(json['price_list']) 
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer_name': customerName,
    'phone_one': phoneOne,
    'price_list': priceList?.toJson(),
  };
}

@HiveType(typeId: 2)
class PriceListInfo {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;

  PriceListInfo({required this.id, required this.name});

  factory PriceListInfo.fromJson(Map<String, dynamic> json) => PriceListInfo(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
