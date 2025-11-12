import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/constants.dart';

class VisitPlanTab extends GetView<HomeController> {
  const VisitPlanTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
