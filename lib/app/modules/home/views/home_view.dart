import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import 'tabs/visit_plan_tab.dart';
import 'tabs/invoices_tab.dart';
import 'tabs/vouchers_tab.dart';
import 'tabs/orders_tab.dart';
import 'tabs/negative_visits_tab.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
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
              Tab(text: 'invoices'.tr),
              Tab(text: 'vouchers'.tr),
              Tab(text: 'orders'.tr),
              Tab(text: 'negative_visits'.tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            VisitPlanTab(),
            InvoicesTab(),
            VouchersTab(),
            OrdersTab(),
            NegativeVisitsTab(),
          ],
        ),
      ),
    );
  }
}
