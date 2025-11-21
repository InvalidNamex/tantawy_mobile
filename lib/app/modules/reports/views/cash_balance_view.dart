import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors_extension.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/date_picker_field.dart';
import '../controllers/cash_balance_controller.dart';

class CashBalanceView extends GetView<CashBalanceController> {
  const CashBalanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('cash_balance'.tr),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.cashBalance.value == null) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          }

          final balance = controller.cashBalance.value;

          if (balance == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: context.colors.onSurface.withOpacity(0.3),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'no_cash_balance_data'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      color: context.colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: controller.fetchCashBalance,
                    icon: Icon(Icons.download),
                    label: Text('fetch_data'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchCashBalance,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: 100,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Column(
                      children: [
                        // Date Filters using custom date picker
                        Row(
                          children: [
                            Expanded(
                              child: DatePickerField(
                                label: 'from_date'.tr,
                                initialDate: controller.fromDate.value,
                                onDateChanged: (date) {
                                  controller.fromDate.value = date;
                                  controller.fetchCashBalance();
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: DatePickerField(
                                label: 'to_date'.tr,
                                initialDate: controller.toDate.value,
                                onDateChanged: (date) {
                                  controller.toDate.value = date;
                                  controller.fetchCashBalance();
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Agent Info Card
                        Card(
                          color: context.colors.surface,
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: context.colors.primary,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'agent_info'.tr,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: context.colors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 24),
                                _buildInfoRow(
                                  context,
                                  'agent_name'.tr,
                                  balance.agentName,
                                ),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  'username'.tr,
                                  balance.agentUsername,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Financial Summary Card
                        Card(
                          color: context.colors.surface,
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet,
                                      color: context.colors.primary,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'financial_summary'.tr,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: context.colors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 24),
                                _buildAmountRow(
                                  context,
                                  'total_debit'.tr,
                                  balance.totalDebit,
                                  Colors.red,
                                ),
                                SizedBox(height: 12),
                                _buildAmountRow(
                                  context,
                                  'total_credit'.tr,
                                  balance.totalCredit,
                                  Colors.green,
                                ),
                                Divider(height: 24),
                                _buildAmountRow(
                                  context,
                                  'balance'.tr,
                                  balance.balance,
                                  balance.balance >= 0
                                      ? Colors.green
                                      : Colors.red,
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: context.colors.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    double amount,
    Color color, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: context.colors.onSurface,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ${'currency'.tr}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
