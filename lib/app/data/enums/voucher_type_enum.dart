/// Enum representing the type of voucher transaction
enum VoucherType {
  /// Receipt voucher - receiving money from customer
  receipt(1),

  /// Payment voucher - paying money to vendor/supplier
  payment(2);

  const VoucherType(this.value);

  /// The numeric value used in the API
  final int value;

  /// Get VoucherType from integer value
  static VoucherType fromValue(int value) {
    return VoucherType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => VoucherType.receipt,
    );
  }

  /// Check if this is a receipt voucher
  bool get isReceipt => this == VoucherType.receipt;

  /// Check if this is a payment voucher
  bool get isPayment => this == VoucherType.payment;

  /// Get the translation key for this voucher type
  String get translationKey {
    switch (this) {
      case VoucherType.receipt:
        return 'receive_voucher';
      case VoucherType.payment:
        return 'payment_voucher';
    }
  }
}
