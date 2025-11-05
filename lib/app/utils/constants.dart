class AppConstants {
  static const String baseURL = 'https://d0b6bcfc920e.ngrok-free.app'; 
  static const int customerAccountId = 36;
  static const int storeCashAccountId = 35;
  
  // Invoice Types
  static const int invoiceTypeSales = 2;
  static const int invoiceTypeReturnSales = 4;
  
  // Payment Types
  static const int paymentTypeCash = 1;
  static const int paymentTypeVisa = 2;
  static const int paymentTypeDeferred = 3;
  
  // Payment Status
  static const int statusPaid = 0;
  static const int statusUnpaid = 1;
  static const int statusPartiallyPaid = 2;
  
  // Voucher Types
  static const int voucherTypeReceipt = 1;
  static const int voucherTypePayment = 2;
  
  // Visit Transaction Types
  static const int transTypeSales = 1;
  static const int transTypeReturnSales = 2;
  static const int transTypeReceiveVoucher = 3;
  static const int transTypePayVoucher = 4;
  static const int transTypeNegativeVisit = 5;
}
