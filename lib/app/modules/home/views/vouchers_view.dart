import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vouchers_controller.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/date_picker_field.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/app_bottom_navigation.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/voucher_card_widget.dart';
import '../../settings/controllers/settings_controller.dart';

class VouchersView extends GetView<VouchersController> {
  const VouchersView({super.key});

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
            title: Text('vouchers'.tr),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          drawer: AppDrawer(),
          body: Stack(
            children: [
              AppBackground(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Filters
                        Column(
                          children: [
                            // Voucher Type Dropdown
                            CustomDropdown<int>(
                              value: controller.selectedVoucherType.value,
                              onChanged: controller.setVoucherType,
                              items: [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text('receipt_voucher'.tr),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text('payment_voucher'.tr),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // Date Filters
                            Row(
                              children: [
                                Expanded(
                                  child: DatePickerField(
                                    label: 'from_date'.tr,
                                    onDateChanged: (date) {
                                      controller.setFromDate(date);
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: DatePickerField(
                                    label: 'to_date'.tr,
                                    onDateChanged: (date) {
                                      controller.setToDate(date);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Vouchers List
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: controller.syncVouchers,
                            child: controller.isLoading.value
                                ? Center(child: CircularProgressIndicator())
                                : controller.filteredVouchers.isEmpty
                                ? EmptyStateWidget(
                                    icon: Icons.receipt_long,
                                    message: 'no_vouchers_found'.tr,
                                  )
                                : ListView.builder(
                                    itemCount:
                                        controller.filteredVouchers.length,
                                    itemBuilder: (context, index) {
                                      final voucher =
                                          controller.filteredVouchers[index];
                                      return VoucherCardWidget(
                                        voucher: voucher,
                                        getVoucherTypeText:
                                            controller.getVoucherTypeText,
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
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
}
