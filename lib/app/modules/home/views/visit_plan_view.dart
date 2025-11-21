import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/visit_plan_controller.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_bottom_navigation.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants.dart';

class VisitPlanView extends GetView<VisitPlanController> {
  const VisitPlanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Obx(
      () => Directionality(
        textDirection: settingsController.isArabic
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            title: Text(controller.agentName),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          drawer: AppDrawer(),
          body: Stack(
            children: [
              AppBackground(
                child: Obx(
                  () => RefreshIndicator(
                    onRefresh: controller.refreshData,
                    child: ListView.builder(
                      itemCount: controller.customers.length,
                      itemBuilder: (context, index) {
                        final customer = controller.customers[index];
                        return Obx(
                          () => ExpansionTile(
                            key: ValueKey(
                              'tile_${index}_${controller.expandedTileIndex.value}',
                            ),
                            initiallyExpanded:
                                controller.expandedTileIndex.value == index,
                            onExpansionChanged: (isExpanded) {
                              controller.setExpandedTile(
                                isExpanded ? index : null,
                              );
                            },
                            title: Text(customer.customerName),
                            subtitle: Text(customer.phoneOne),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildActionButton(
                                      context: context,
                                      imagePath:
                                          'assets/images/transactions/new-invoice.png',
                                      label: 'sale'.tr,
                                      onTap: () => Get.toNamed(
                                        AppRoutes.invoice,
                                        arguments: {
                                          'customer': customer,
                                          'invoiceType':
                                              AppConstants.invoiceTypeSales,
                                        },
                                      ),
                                    ),
                                    _buildActionButton(
                                      context: context,
                                      imagePath:
                                          'assets/images/transactions/new-return-invoice.png',
                                      label: 'return_sale'.tr,
                                      onTap: () => Get.toNamed(
                                        AppRoutes.invoice,
                                        arguments: {
                                          'customer': customer,
                                          'invoiceType': AppConstants
                                              .invoiceTypeReturnSales,
                                        },
                                      ),
                                    ),
                                    _buildActionButton(
                                      context: context,
                                      imagePath:
                                          'assets/images/transactions/new-receipt.png',
                                      label: 'receive_voucher'.tr,
                                      onTap: () => Get.toNamed(
                                        AppRoutes.voucher,
                                        arguments: {
                                          'customer': customer,
                                          'voucherType':
                                              AppConstants.voucherTypeReceipt,
                                        },
                                      ),
                                    ),
                                    _buildActionButton(
                                      context: context,
                                      imagePath:
                                          'assets/images/transactions/new-negative-visit.png',
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
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AppBottomNavigation(
                  currentIndex: controller.currentIndex.value,
                  onIndexChanged: controller.changeIndex,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(imagePath, width: 32, height: 32),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
