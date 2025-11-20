import 'package:hive/hive.dart';

part 'invoice_model.g.dart';

// Model for creating invoices (POST)
class InvoiceModel {
  final InvoiceMaster invoiceMaster;
  final List<InvoiceDetail> invoiceDetails;

  InvoiceModel({required this.invoiceMaster, required this.invoiceDetails});

  Map<String, dynamic> toJson() => {
    'invoiceMaster': invoiceMaster.toJson(),
    'invoiceDetails': invoiceDetails.map((e) => e.toJson()).toList(),
  };
}

class InvoiceMaster {
  final int invoiceType;
  final int customerOrVendorID;
  final int storeId;
  final int agentID;
  final int status;
  final int paymentType;
  final double netTotal;
  final double totalPaid;
  final double? discountAmount;
  final double? taxAmount;

  InvoiceMaster({
    required this.invoiceType,
    required this.customerOrVendorID,
    required this.storeId,
    required this.agentID,
    required this.status,
    required this.paymentType,
    required this.netTotal,
    required this.totalPaid,
    this.discountAmount,
    this.taxAmount,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'invoiceType': invoiceType,
      'customerOrVendorID': customerOrVendorID,
      'storeId': storeId,
      'agentID': agentID,
      'status': status,
      'paymentType': paymentType,
      'netTotal': netTotal,
      'totalPaid': totalPaid,
    };
    if (discountAmount != null) json['discountAmount'] = discountAmount!;
    if (taxAmount != null) json['taxAmount'] = taxAmount!;
    return json;
  }
}

class InvoiceDetail {
  final int item;
  final double quantity;
  final double price;
  final double? discount;
  final double? vat;

  InvoiceDetail({
    required this.item,
    required this.quantity,
    required this.price,
    this.discount,
    this.vat,
  });

  Map<String, dynamic> toJson() {
    final json = {'item': item, 'quantity': quantity, 'price': price};
    if (discount != null) json['discount'] = discount!;
    if (vat != null) json['vat'] = vat!;
    return json;
  }
}

// Model for receiving invoices from API (GET)
@HiveType(typeId: 10)
class InvoiceResponseModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int invoiceType;

  @HiveField(2)
  final String? invoiceNumber;

  @HiveField(3)
  final String customerVendorName;

  @HiveField(4)
  final int customerVendorId;

  @HiveField(5)
  final double netTotal;

  @HiveField(6)
  final double totalPaid;

  @HiveField(7)
  final int status;

  @HiveField(8)
  final int paymentType;

  @HiveField(9)
  final DateTime invoiceDate;

  @HiveField(10)
  final int storeId;

  @HiveField(11)
  final int agentId;

  @HiveField(12)
  final String? storeName;

  @HiveField(13)
  final double discountAmount;

  @HiveField(14)
  final double taxAmount;

  @HiveField(15)
  final String? notes;

  @HiveField(16)
  final List<InvoiceDetailResponse>? invoiceDetails;

  InvoiceResponseModel({
    required this.id,
    required this.invoiceType,
    this.invoiceNumber,
    required this.customerVendorName,
    required this.customerVendorId,
    required this.netTotal,
    required this.totalPaid,
    required this.status,
    required this.paymentType,
    required this.invoiceDate,
    required this.storeId,
    required this.agentId,
    this.storeName,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.notes,
    this.invoiceDetails,
  });

  factory InvoiceResponseModel.fromJson(Map<String, dynamic> json) {
    List<InvoiceDetailResponse>? details;
    if (json['invoiceDetails'] != null) {
      details = (json['invoiceDetails'] as List)
          .map((item) => InvoiceDetailResponse.fromJson(item))
          .toList();
    }

    return InvoiceResponseModel(
      id: json['id'] ?? 0,
      invoiceType: json['invoiceType'] ?? json['invoice_type'] ?? 0,
      invoiceNumber:
          json['invoiceNumber']?.toString() ??
          json['invoice_number']?.toString(),
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
      netTotal: (json['netTotal'] ?? json['net_total'] ?? 0.0).toDouble(),
      totalPaid: (json['totalPaid'] ?? json['total_paid'] ?? 0.0).toDouble(),
      status: json['status'] ?? 0,
      paymentType: json['paymentType'] ?? json['payment_type'] ?? 1,
      invoiceDate: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['invoice_date'] != null || json['invoiceDate'] != null
                ? DateTime.parse(json['invoice_date'] ?? json['invoiceDate'])
                : DateTime.now()),
      storeId: json['storeId'] ?? json['store_id'] ?? 0,
      agentId: json['agentId'] ?? json['agent_id'] ?? 0,
      storeName: json['storeName'] ?? json['store_name'],
      discountAmount: (json['discountAmount'] ?? json['discount_amount'] ?? 0.0)
          .toDouble(),
      taxAmount: (json['taxAmount'] ?? json['tax_amount'] ?? 0.0).toDouble(),
      notes: json['notes'],
      invoiceDetails: details,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'invoice_type': invoiceType,
    'invoice_number': invoiceNumber,
    'customer_vendor_name': customerVendorName,
    'customer_vendor_id': customerVendorId,
    'net_total': netTotal,
    'total_paid': totalPaid,
    'status': status,
    'payment_type': paymentType,
    'invoice_date': invoiceDate.toIso8601String(),
    'store_id': storeId,
    'agent_id': agentId,
    'store_name': storeName,
    'discount_amount': discountAmount,
    'tax_amount': taxAmount,
    'notes': notes,
    'invoice_details': invoiceDetails?.map((e) => e.toJson()).toList(),
  };
}

// Model for invoice detail response from API
@HiveType(typeId: 15)
class InvoiceDetailResponse extends HiveObject {
  @HiveField(0)
  final int itemID;

  @HiveField(1)
  final String itemName;

  @HiveField(2)
  final double itemQuantity;

  InvoiceDetailResponse({
    required this.itemID,
    required this.itemName,
    required this.itemQuantity,
  });

  factory InvoiceDetailResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailResponse(
      itemID: json['itemID'] ?? json['item_id'] ?? 0,
      itemName: json['itemName'] ?? json['item_name'] ?? '',
      itemQuantity: (json['itemQuantity'] ?? json['item_quantity'] ?? 0.0)
          .toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'itemID': itemID,
    'itemName': itemName,
    'itemQuantity': itemQuantity,
  };
}
