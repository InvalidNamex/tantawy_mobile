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
