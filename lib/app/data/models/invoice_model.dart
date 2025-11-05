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

  InvoiceMaster({
    required this.invoiceType,
    required this.customerOrVendorID,
    required this.storeId,
    required this.agentID,
    required this.status,
    required this.paymentType,
    required this.netTotal,
    required this.totalPaid,
  });

  Map<String, dynamic> toJson() => {
    'invoiceType': invoiceType,
    'customerOrVendorID': customerOrVendorID,
    'storeId': storeId,
    'agentID': agentID,
    'status': status,
    'paymentType': paymentType,
    'netTotal': netTotal,
    'totalPaid': totalPaid,
  };
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
    final json = {
      'item': item,
      'quantity': quantity,
      'price': price,
    };
    if (discount != null) json['discount'] = discount!;
    if (vat != null) json['vat'] = vat!;
    return json;
  }
}
