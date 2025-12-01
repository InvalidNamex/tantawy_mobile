import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/invoices_controller.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/date_picker_field.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/app_bottom_navigation.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/invoice_card_widget.dart';
import '../../../utils/constants.dart';
import '../../settings/controllers/settings_controller.dart';

class InvoicesView extends GetView<InvoicesController> {
  const InvoicesView({Key? key}) : super(key: key);

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
            title: Text('invoices'.tr),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          drawer: AppDrawer(),
          body: Stack(
            children: [
              AppBackground(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 70),
                      // Invoice Type Filter Dropdown
                      CustomDropdown<int>(
                        value: controller.selectedInvoiceType.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.setInvoiceType(value);
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: AppConstants.invoiceTypeSales,
                            child: Text('sales_invoices'.tr),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.invoiceTypeReturnSales,
                            child: Text('return_sales_invoices'.tr),
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
                      SizedBox(height: 16),
                      // Invoices List
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: controller.syncInvoices,
                          child: controller.isLoading.value
                              ? Center(child: CircularProgressIndicator())
                              : controller.filteredInvoices.isEmpty
                              ? EmptyStateWidget(
                                  icon: Icons.receipt_long_outlined,
                                  message: 'no_invoices_found'.tr,
                                )
                              : ListView.builder(
                                  itemCount: controller.filteredInvoices.length,
                                  padding: EdgeInsets.only(bottom: 80),
                                  itemBuilder: (context, index) {
                                    final invoice = controller
                                        .filteredInvoices
                                        .reversed
                                        .toList()[index];
                                    return InvoiceCardWidget(
                                      invoice: invoice,
                                      getStatusText: controller.getStatusText,
                                      getPaymentTypeText:
                                          controller.getPaymentTypeText,
                                    );
                                  },
                                ),
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
