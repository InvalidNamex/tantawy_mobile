import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/invoice_controller.dart';
import '../../../utils/constants.dart';
import '../../../widgets/app_background.dart';

class InvoiceView extends GetView<InvoiceController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          controller.invoiceType == AppConstants.invoiceTypeSales
              ? 'sale'.tr
              : 'return_sale'.tr,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'customer'.tr}: ${controller.customer.customerName}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: controller.showItemSelectionDialog,
                icon: Icon(Icons.add),
                label: Text('select_items'.tr),
              ),
              SizedBox(height: 16),
              Obx(
                () => controller.selectedItems.isEmpty
                    ? Center(child: Text('no_items_selected'.tr))
                    : _buildItemsTable(),
              ),
              SizedBox(height: 16),
              _buildPaymentTypeDropdown(),
              SizedBox(height: 16),
              _buildStatusDropdown(),
              SizedBox(height: 16),
              TextField(
                controller: controller.totalPaidController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'total_paid'.tr,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Obx(
                () => Text(
                  '${'net_total'.tr}: ${controller.netTotal.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.submitInvoice,
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('submit'.tr),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(
        () => DataTable(
          columns: [
            DataColumn(label: Text('item_name'.tr)),
            DataColumn(label: Text('quantity'.tr)),
            DataColumn(label: Text('price'.tr)),
            DataColumn(label: Text('discount'.tr)),
            DataColumn(label: Text('vat'.tr)),
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
                      onChanged: (value) =>
                          item.quantity.value = double.tryParse(value) ?? 1.0,
                      decoration: InputDecoration(
                        hintText: item.quantity.value.toString(),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 80,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          item.price.value = double.tryParse(value) ?? 0.0,
                      decoration: InputDecoration(
                        hintText: item.price.value.toString(),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          item.discount.value = double.tryParse(value) ?? 0.0,
                      decoration: InputDecoration(
                        hintText: item.discount.value.toString(),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          item.vat.value = double.tryParse(value) ?? 0.0,
                      decoration: InputDecoration(
                        hintText: item.vat.value.toString(),
                      ),
                    ),
                  ),
                ),
                DataCell(Obx(() => Text(item.total.toStringAsFixed(2)))),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => controller.removeItem(index),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
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
