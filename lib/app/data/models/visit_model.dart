import 'package:hive/hive.dart';

part 'visit_model.g.dart';

// Model for creating visits (POST)
class VisitModel {
  final int transType;
  final int customerVendor;
  final String date;
  final double latitude;
  final double longitude;
  final String notes;

  VisitModel({
    required this.transType,
    required this.customerVendor,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
    'transType': transType,
    'customerVendor': customerVendor,
    'date': date,
    'latitude': latitude,
    'longitude': longitude,
    'notes': notes,
  };
}

// Model for receiving visits from API (GET)
@HiveType(typeId: 12)
class VisitResponseModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int transType;

  @HiveField(2)
  final String customerVendorName;

  @HiveField(3)
  final int customerVendorId;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final double latitude;

  @HiveField(6)
  final double longitude;

  @HiveField(7)
  final String notes;

  @HiveField(8)
  final int agentId;

  VisitResponseModel({
    required this.id,
    required this.transType,
    required this.customerVendorName,
    required this.customerVendorId,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.notes,
    required this.agentId,
  });

  factory VisitResponseModel.fromJson(Map<String, dynamic> json) {
    return VisitResponseModel(
      id: json['id'] ?? 0,
      transType: json['transType'] ?? json['trans_type'] ?? 5,
      customerVendorName:
          json['customer_name'] ??
          json['customerName'] ??
          json['customer_vendor_name'] ??
          json['customerVendorName'] ??
          '',
      customerVendorId:
          json['customerId'] ??
          json['customer_vendor_id'] ??
          json['customerVendorId'] ??
          json['customerVendor'] ??
          0,
      date: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['date'] != null
                ? DateTime.parse(json['date'])
                : DateTime.now()),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
      agentId: json['agentId'] ?? json['agent_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trans_type': transType,
    'customer_vendor_name': customerVendorName,
    'customer_vendor_id': customerVendorId,
    'date': date.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'notes': notes,
    'agent_id': agentId,
  };
}
