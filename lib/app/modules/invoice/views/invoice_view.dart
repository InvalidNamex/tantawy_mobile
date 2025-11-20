import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../controllers/invoice_controller.dart';
import '../../../utils/constants.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/loading_button.dart';
import '../../../data/models/item_model.dart';

class InvoiceView extends GetView<InvoiceController> {
  const InvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '${'customer'.tr}: ${controller.customer.customerName}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showItemSearchDialog(context),
            tooltip: 'add_items'.tr,
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: kToolbarHeight + 16),
              Expanded(child: _buildItemsTable()),
              SizedBox(height: 16),
              controller.invoiceType != AppConstants.invoiceTypeReturnSales
                  ? Row(
                      children: [
                        Expanded(child: _buildTaxInvoiceCheckbox()),
                        Expanded(child: _buildDiscountField()),
                      ],
                    )
                  : SizedBox(),
              SizedBox(height: 16),
              _buildPaymentTypeDropdown(),
              SizedBox(height: 16),
              _buildStatusDropdown(),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => TextField(
                        controller: controller.totalPaidController,
                        keyboardType: TextInputType.number,
                        enabled: controller.isTotalPaidEnabled,
                        decoration: InputDecoration(
                          labelText: 'total_paid'.tr,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Obx(
                    () => Text(
                      '${'net_total'.tr}: ${controller.netTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Obx(
                () => LoadingButton(
                  isLoading: controller.isLoading.value,
                  onPressed: controller.submitInvoice,
                  text: 'save_and_print'.tr,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemSearchDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'select_items'.tr,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              DropdownSearch<ItemModel>(
                items: (filter, infiniteScrollProps) =>
                    controller.availableItems,
                itemAsString: (ItemModel item) =>
                    '${item.itemName} - ${item.barcode}',
                compareFn: (item1, item2) => item1.id == item2.id,
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    labelText: 'search_items'.tr,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: 'type_to_search'.tr,
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  itemBuilder: (context, item, isDisabled, isSelected) {
                    return ListTile(
                      title: Text(item.itemName),
                      subtitle: Text('${item.barcode} - ${item.sign}'),
                    );
                  },
                ),
                onChanged: (ItemModel? item) {
                  if (item != null) {
                    controller.addItem(item);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  Widget _buildItemsTable() {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => DataTable(
            border: TableBorder.all(color: Colors.grey),
            columns: [
              DataColumn(label: Text('item_name'.tr)),
              DataColumn(label: Text('quantity'.tr)),
              DataColumn(label: Text('price'.tr)),
              DataColumn(label: Text('total'.tr)),
              DataColumn(label: Text('')),
            ],
            rows: controller.selectedItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text(item.item.itemName)),
                  DataCell(
                    SizedBox(
                      width: 60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: item.quantity.value.toString(),
                        ),
                        onChanged: (value) {
                          item.quantity.value = double.tryParse(value) ?? 1.0;
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,

                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 80,
                      child: Obx(
                        () => TextField(
                          keyboardType: TextInputType.number,
                          controller:
                              TextEditingController(
                                  text: item.price.value.toStringAsFixed(2),
                                )
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(
                                    offset: item.price.value
                                        .toStringAsFixed(2)
                                        .length,
                                  ),
                                ),
                          onChanged: (value) {
                            final newPrice = double.tryParse(value) ?? 0.0;
                            if (controller.validatePrice(item, newPrice)) {
                              item.price.value = newPrice;
                            }
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(Obx(() => Text(item.total.toStringAsFixed(2)))),
                  DataCell(
                    SizedBox(
                      width: 20,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.removeItem(index),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountField() {
    return TextField(
      controller: controller.discountAmountController,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        final discountValue = double.tryParse(value) ?? 0.0;
        if (discountValue > controller.subtotal) {
          Get.snackbar('error'.tr, 'discount_cannot_exceed_subtotal'.tr);
          controller.discountAmountController.text = controller.subtotal
              .toStringAsFixed(2);
        }
      },
      decoration: InputDecoration(
        labelText: 'discount_amount'.tr,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildTaxInvoiceCheckbox() {
    return Obx(
      () => CheckboxListTile(
        title: Text('tax_invoice'.tr),
        value: controller.isTaxInvoice.value,
        onChanged: (value) => controller.isTaxInvoice.value = value ?? false,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildPaymentTypeDropdown() {
    return Obx(
      () => DropdownButtonFormField<int>(
        value: controller.paymentType.value,
        decoration: InputDecoration(
          labelText: 'payment_type'.tr,
          border: OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem(
            value: AppConstants.paymentTypeCash,
            child: Text('cash'.tr),
          ),
          DropdownMenuItem(
            value: AppConstants.paymentTypeVisa,
            child: Text('visa'.tr),
          ),
          DropdownMenuItem(
            value: AppConstants.paymentTypeDeferred,
            child: Text('deferred'.tr),
          ),
        ],
        onChanged: (value) => controller.paymentType.value = value!,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Obx(
      () => DropdownButtonFormField<int>(
        value: controller.status.value,
        decoration: InputDecoration(
          labelText: 'status'.tr,
          border: OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem(
            value: AppConstants.statusPaid,
            child: Text('paid'.tr),
          ),
          DropdownMenuItem(
            value: AppConstants.statusUnpaid,
            child: Text('unpaid'.tr),
          ),
          DropdownMenuItem(
            value: AppConstants.statusPartiallyPaid,
            child: Text('partially_paid'.tr),
          ),
        ],
        onChanged: (value) => controller.status.value = value!,
      ),
    );
  }
}
