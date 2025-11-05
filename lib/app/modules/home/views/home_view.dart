import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(controller.agentName)),
          actions: [
            Obx(() => Stack(
              children: [
                IconButton(
                  icon: controller.isSyncing.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Icon(Icons.sync),
                  onPressed: controller.isSyncing.value ? null : controller.syncData,
                ),
                if (controller.hasPendingData)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            )),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  Get.find<AuthController>().logout();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'visit_plan'.tr),
              Tab(text: 'sales'.tr),
              Tab(text: 'return_sales'.tr),
              Tab(text: 'negative_visits'.tr),
              Tab(text: 'receive_vouchers'.tr),
              Tab(text: 'payment_vouchers'.tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildVisitPlanTab(),
            _buildPlaceholderTab('sales'.tr),
            _buildPlaceholderTab('return_sales'.tr),
            _buildPlaceholderTab('negative_visits'.tr),
            _buildPlaceholderTab('receive_vouchers'.tr),
            _buildPlaceholderTab('payment_vouchers'.tr),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitPlanTab() {
    return Obx(() => ListView.builder(
      itemCount: controller.customers.length,
      itemBuilder: (context, index) {
        final customer = controller.customers[index];
        return ExpansionTile(
          title: Text(customer.customerName),
          subtitle: Text(customer.phoneOne),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.shopping_cart,
                    label: 'sale'.tr,
                    onTap: () => Get.toNamed(
                      AppRoutes.invoice,
                      arguments: {
                        'customer': customer,
                        'invoiceType': AppConstants.invoiceTypeSales,
                      },
                    ),
                  ),
                  _buildActionButton(
                    icon: Icons.assignment_return,
                    label: 'return_sale'.tr,
                    onTap: () => Get.toNamed(
                      AppRoutes.invoice,
                      arguments: {
                        'customer': customer,
                        'invoiceType': AppConstants.invoiceTypeReturnSales,
                      },
                    ),
                  ),
                  _buildActionButton(
                    icon: Icons.receipt,
                    label: 'voucher'.tr,
                    onTap: () => Get.toNamed(
                      AppRoutes.voucher,
                      arguments: {'customer': customer},
                    ),
                  ),
                  _buildActionButton(
                    icon: Icons.cancel,
                    label: 'negative_visit'.tr,
                    onTap: () => Get.toNamed(
                      AppRoutes.visit,
                      arguments: {'customer': customer},
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ));
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.green),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Text('$title - Coming Soon'),
    );
  }
}
