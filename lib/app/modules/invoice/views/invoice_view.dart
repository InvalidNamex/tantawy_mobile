import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../controllers/invoice_controller.dart';
import '../../../utils/constants.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/loading_button.dart';
import '../../../data/models/item_model.dart';
import '../../../data/models/items_groups_model.dart';

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
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildItemsTable(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => Text(
                        '${'net_total'.tr}: ${controller.netTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showInvoiceDetailsBottomSheet(context),
                    icon: Icon(Icons.settings),
                    label: Text('invoice_details'.tr),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoiceDetailsBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'invoice_details'.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                controller.invoiceType != AppConstants.invoiceTypeReturnSales
                    ? Row(
                        children: [
                          Expanded(child: _buildTaxInvoiceCheckbox()),
                          SizedBox(width: 8),
                          Expanded(child: _buildDiscountField()),
                        ],
                      )
                    : SizedBox(),
                SizedBox(height: 16),
                _buildPaymentTypeDropdown(),
                SizedBox(height: 16),
                _buildStatusDropdown(),
                SizedBox(height: 16),
                Obx(
                  () => TextFormField(
                    controller: controller.totalPaidController,
                    keyboardType: TextInputType.number,
                    enabled: controller.isTotalPaidEnabled,
                    decoration: InputDecoration(
                      labelText: 'total_paid'.tr,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Obx(
                  () => Text(
                    '${'net_total'.tr}: ${controller.netTotal.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24),
                Obx(
                  () => LoadingButton(
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      controller.submitInvoice();
                    },
                    text: 'save_and_print'.tr,
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
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
              SizedBox(height: 16),
              // Items Groups Dropdown
              Obx(
                () => controller.itemsGroups.isEmpty
                    ? SizedBox.shrink()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownSearch<ItemsGroupsModel>(
                            items: (filter, infiniteScrollProps) =>
                                controller.itemsGroups,
                            selectedItem: controller.selectedGroup.value,
                            itemAsString: (ItemsGroupsModel group) =>
                                group.groupName,
                            compareFn: (item1, item2) => item1.id == item2.id,
                            decoratorProps: DropDownDecoratorProps(
                              decoration: InputDecoration(
                                labelText: 'filter_by_group'.tr,
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                                suffixIcon:
                                    controller.selectedGroup.value != null
                                    ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          controller.selectedGroup.value = null;
                                        },
                                      )
                                    : null,
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
                              itemBuilder:
                                  (context, item, isDisabled, isSelected) {
                                    return ListTile(
                                      title: Text(item.groupName),
                                      selected: isSelected,
                                    );
                                  },
                            ),
                            onChanged: (ItemsGroupsModel? group) {
                              controller.selectedGroup.value = group;
                            },
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
              ),
              // Items Dropdown
              DropdownSearch<ItemModel>(
                items: (filter, infiniteScrollProps) =>
                    controller.filteredItems,
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
                    Get.dialog(
                      Dialog(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(item.itemName),
                              ),
                            ),
                            ListTile(
                              leading: Text(
                                item.mainUnitName ?? 'main_unit'.tr,
                              ),
                              title: TextField(),
                            ),
                            item.subUnitName != null
                                ? ListTile(
                                    leading: Text(item.subUnitName ?? ''),
                                    title: TextField(),
                                    trailing: Text(
                                      item.mainUnitPack.toString(),
                                    ),
                                  )
                                : SizedBox(),
                            item.smallUnitName != null
                                ? ListTile(
                                    leading: Text(item.smallUnitName ?? ''),
                                    title: TextField(),
                                    trailing: Text(item.subUnitPack.toString()),
                                  )
                                : SizedBox(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  controller.addItem(item);
                                },
                                child: Text('add'.tr),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
    ).then((_) {
      // Reset selected group when dialog is dismissed
      controller.selectedGroup.value = null;
    });
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
                      child: TextFormField(
                        key: ValueKey('quantity_${item.item.id}'),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        initialValue: item.quantity.value % 1 == 0
                            ? item.quantity.value.toInt().toString()
                            : item.quantity.value.toString(),
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
                      child: TextFormField(
                        key: ValueKey('price_${item.item.id}'),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        initialValue: item.price.value % 1 == 0
                            ? item.price.value.toInt().toString()
                            : item.price.value.toString(),
                        validator: (value) {
                          final price = double.tryParse(value ?? '') ?? 0.0;
                          if (price < item.priceListPrice) {
                            return 'Min: ${item.priceListPrice}';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (value) {
                          final newPrice = double.tryParse(value) ?? 0.0;
                          if (newPrice < item.priceListPrice && newPrice > 0) {
                            item.price.value = item.priceListPrice;
                          } else if (newPrice >= item.priceListPrice) {
                            item.price.value = newPrice;
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                          errorStyle: TextStyle(fontSize: 10, height: 0.5),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Obx(
                      () => Text(
                        item.total % 1 == 0
                            ? item.total.toInt().toString()
                            : item.total.toStringAsFixed(2),
                      ),
                    ),
                  ),
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
    return TextFormField(
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
