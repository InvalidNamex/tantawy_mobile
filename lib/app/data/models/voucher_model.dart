import 'package:hive/hive.dart';

part 'voucher_model.g.dart';

// Model for creating vouchers (POST)
class VoucherModel {
  final int type;
  final int customerVendorId;
  final double amount;
  final int storeId;
  final String notes;
  final String voucherDate;
  final int accountId;

  VoucherModel({
    required this.type,
    required this.customerVendorId,
    required this.amount,
    required this.storeId,
    required this.notes,
    required this.voucherDate,
    required this.accountId,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'customerVendorId': customerVendorId,
    'amount': amount,
    'storeId': storeId,
    'notes': notes,
    'voucherDate': voucherDate,
    'accountId': accountId,
  };
}

// Model for receiving vouchers from API (GET)
@HiveType(typeId: 11)
class VoucherResponseModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int type;

  @HiveField(2)
  final String? voucherNumber;

  @HiveField(3)
  final String customerVendorName;

  @HiveField(4)
  final int customerVendorId;

  @HiveField(5)
  final double amount;

  @HiveField(6)
  final String notes;

  @HiveField(7)
  final DateTime voucherDate;

  @HiveField(8)
  final int storeId;

  @HiveField(9)
  final int agentId;

  VoucherResponseModel({
    required this.id,
    required this.type,
    this.voucherNumber,
    required this.customerVendorName,
    required this.customerVendorId,
    required this.amount,
    required this.notes,
    required this.voucherDate,
    required this.storeId,
    required this.agentId,
  });

  factory VoucherResponseModel.fromJson(Map<String, dynamic> json) {
    return VoucherResponseModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? json['transaction_type'] ?? 0,
      voucherNumber:
          json['voucherNumber']?.toString() ??
          json['voucher_number']?.toString(),
      customerVendorName:
          json['customerName'] ??
          json['customer_vendor_name'] ??
          json['customerVendorName'] ??
          '',
      customerVendorId:
          json['customerId'] ??
          json['customer_vendor_id'] ??
          json['customerVendorId'] ??
          0,
      amount: (json['amount'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
      voucherDate: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['voucher_date'] != null || json['voucherDate'] != null
                ? DateTime.parse(json['voucher_date'] ?? json['voucherDate'])
                : DateTime.now()),
      storeId: json['storeId'] ?? json['store_id'] ?? 0,
      agentId: json['agentId'] ?? json['agent_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'voucher_number': voucherNumber,
    'customer_vendor_name': customerVendorName,
    'customer_vendor_id': customerVendorId,
    'amount': amount,
    'notes': notes,
    'voucher_date': voucherDate.toIso8601String(),
    'store_id': storeId,
    'agent_id': agentId,
  };
}
