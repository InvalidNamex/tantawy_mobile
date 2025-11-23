import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors_extension.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/app_background.dart';
import '../../../routes/app_routes.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('reports'.tr),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: AppDrawer(),
      body: AppBackground(
        child: ListView(
          padding: EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 16),
          children: [
            _buildReportCard(
              context: context,
              icon: Icons.inventory_2,
              title: 'items_stock'.tr,
              subtitle: 'view_items_stock_report'.tr,
              onTap: () => Get.toNamed(AppRoutes.itemsStock),
            ),
            _buildReportCard(
              context: context,
              icon: Icons.account_balance_wallet,
              title: 'cash_balance'.tr,
              subtitle: 'view_cash_balance_report'.tr,
              onTap: () => Get.toNamed(AppRoutes.cashBalance),
            ),
            _buildReportCard(
              context: context,
              icon: Icons.receipt_long,
              title: 'customer_transactions'.tr,
              subtitle: 'view_customer_transactions_report'.tr,
              onTap: () => Get.toNamed(AppRoutes.customerTransactions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: context.colors.surface,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: context.colors.primary, size: 28),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: context.colors.onSurface.withOpacity(0.3),
          size: 18,
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }
}
