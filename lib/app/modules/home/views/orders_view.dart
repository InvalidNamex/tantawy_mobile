import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/orders_controller.dart';
import '../../../theme/app_colors_extension.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_bottom_navigation.dart';
import '../../settings/controllers/settings_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({Key? key}) : super(key: key);

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
            title: Text('orders'.tr),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          drawer: AppDrawer(),
          body: Stack(
            children: [
              AppBackground(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        size: 64,
                        color: context.colors.placeholderIcon,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'orders'.tr,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: context.colors.placeholderTitle,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'coming_soon'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.colors.placeholderText,
                        ),
                      ),
                    ],
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
}
