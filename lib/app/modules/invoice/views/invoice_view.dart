import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/invoice_controller.dart';
import '../../../utils/constants.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/loading_button.dart';

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
            onPressed: controller.showItemSelectionDialog,
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
              _buildPaymentTypeDropdown(),
              SizedBox(height: 16),
              _buildStatusDropdown(),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.totalPaidController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'total_paid'.tr,
                        border: OutlineInputBorder(),
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
                  text: 'submit'.tr,
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => DataTable(
            border: TableBorder.all(color: Colors.grey),
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
