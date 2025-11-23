import 'package:hive/hive.dart';

part 'customer_transaction_model.g.dart';

@HiveType(typeId: 20)
class CustomerTransactionModel {
  @HiveField(0)
  final int customerId;

  @HiveField(1)
  final String customerName;

  @HiveField(2)
  final List<TransactionModel> transactions;

  CustomerTransactionModel({
    required this.customerId,
    required this.customerName,
    required this.transactions,
  });

  factory CustomerTransactionModel.fromJson(Map<String, dynamic> json) {
    return CustomerTransactionModel(
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      transactions: (json['transactions'] as List)
          .map((t) => TransactionModel.fromJson(t))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 21)
class TransactionModel {
  @HiveField(0)
  final DateTime createdAt;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String notes;

  @HiveField(3)
  final int type;

  @HiveField(4)
  final int? invoiceId;

  TransactionModel({
    required this.createdAt,
    required this.amount,
    required this.notes,
    required this.type,
    this.invoiceId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      createdAt: DateTime.parse(json['created_at']),
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'] ?? '',
      type: json['type'],
      invoiceId: json['invoiceID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'amount': amount,
      'notes': notes,
      'type': type,
      'invoiceID': invoiceId,
    };
  }

  String get typeLabel {
    switch (type) {
      case 1:
        return 'Receipt';
      case 2:
        return 'Invoice';
      case 4:
        return 'Return';
      default:
        return 'Unknown';
    }
  }
}
