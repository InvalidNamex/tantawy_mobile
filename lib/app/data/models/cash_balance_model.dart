import 'package:hive/hive.dart';

part 'cash_balance_model.g.dart';

@HiveType(typeId: 14)
class CashBalanceModel {
  @HiveField(0)
  final int agentId;

  @HiveField(1)
  final String agentName;

  @HiveField(2)
  final String agentUsername;

  @HiveField(3)
  final double totalDebit;

  @HiveField(4)
  final double totalCredit;

  @HiveField(5)
  final double balance;

  CashBalanceModel({
    required this.agentId,
    required this.agentName,
    required this.agentUsername,
    required this.totalDebit,
    required this.totalCredit,
    required this.balance,
  });

  factory CashBalanceModel.fromJson(Map<String, dynamic> json) =>
      CashBalanceModel(
        agentId: json['agent_id'],
        agentName: json['agent_name'] ?? '',
        agentUsername: json['agent_username'] ?? '',
        totalDebit: (json['total_debit'] as num).toDouble(),
        totalCredit: (json['total_credit'] as num).toDouble(),
        balance: (json['balance'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'agent_id': agentId,
    'agent_name': agentName,
    'agent_username': agentUsername,
    'total_debit': totalDebit,
    'total_credit': totalCredit,
    'balance': balance,
  };
}
