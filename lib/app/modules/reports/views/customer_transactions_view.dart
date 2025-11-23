import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors_extension.dart';
import '../../../widgets/app_background.dart';
import '../controllers/customer_transactions_controller.dart';

class CustomerTransactionsView extends GetView<CustomerTransactionsController> {
  const CustomerTransactionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('customer_transactions'.tr),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          }

          if (controller.transactionsList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: context.colors.onSurface.withOpacity(0.3),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'no_transactions_data'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      color: context.colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: controller.refreshTransactions,
                    icon: Icon(Icons.refresh),
                    label: Text('refresh'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.only(top: 100, left: 8, right: 8, bottom: 8),
            child: RefreshIndicator(
              onRefresh: controller.refreshTransactions,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.transactionsList.length,
                itemBuilder: (context, index) {
                  final customerTransaction =
                      controller.transactionsList[index];
                  return _buildCustomerCard(context, customerTransaction);
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, customerTransaction) {
    // Calculate balance (total debits - total credits)
    // Negative amounts are debits, positive amounts are credits
    double totalDebits = 0;
    double totalCredits = 0;

    for (var transaction in customerTransaction.transactions) {
      if (transaction.amount < 0) {
        totalDebits += transaction.amount.abs();
      } else {
        totalCredits += transaction.amount;
      }
    }

    final balance = totalDebits - totalCredits;
    final balanceColor = balance > 0
        ? context.colors.error
        : (balance < 0 ? Colors.green : context.colors.onSurface);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.only(bottom: 8),
          leading: CircleAvatar(
            backgroundColor: context.colors.primary.withOpacity(0.2),
            child: Icon(Icons.person, color: context.colors.primary),
          ),
          title: Text(
            customerTransaction.customerName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: context.colors.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${customerTransaction.transactions.length} ${'transactions'.tr}',
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${'balance'.tr}: ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.colors.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    balance.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: balanceColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            ...customerTransaction.transactions.map((transaction) {
              return _buildTransactionItem(context, transaction);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, transaction) {
    final isNegative = transaction.amount < 0;
    final amountColor = isNegative ? context.colors.error : Colors.green;

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final formattedDate = dateFormat.format(transaction.createdAt);

    IconData typeIcon;
    Color typeIconColor;
    switch (transaction.type) {
      case 1:
        typeIcon = Icons.receipt;
        typeIconColor = Colors.green;
        break;
      case 2:
        typeIcon = Icons.shopping_cart;
        typeIconColor = Colors.blue;
        break;
      case 4:
        typeIcon = Icons.keyboard_return;
        typeIconColor = Colors.orange;
        break;
      default:
        typeIcon = Icons.help_outline;
        typeIconColor = context.colors.onSurface.withOpacity(0.5);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.divider.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(typeIcon, size: 20, color: typeIconColor),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  transaction.typeLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
              Text(
                transaction.amount.toStringAsFixed(2),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: amountColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: context.colors.onSurface.withOpacity(0.5),
              ),
              SizedBox(width: 4),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.onSurface.withOpacity(0.6),
                ),
              ),
              if (transaction.invoiceId != null) ...[
                SizedBox(width: 16),
                Icon(
                  Icons.tag,
                  size: 14,
                  color: context.colors.onSurface.withOpacity(0.5),
                ),
                SizedBox(width: 4),
                Text(
                  'Invoice #${transaction.invoiceId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          if (transaction.notes.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              transaction.notes,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.onSurface.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
