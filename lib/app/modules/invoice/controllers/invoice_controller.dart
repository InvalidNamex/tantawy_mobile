import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/item_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../services/storage_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../data/providers/api_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/logger.dart';

class InvoiceItemRow {
  final ItemModel item;
  final RxDouble quantity;
  final RxDouble price;
  final RxDouble discount;
  final RxDouble vat;

  InvoiceItemRow({
    required this.item,
    double quantity = 1.0,
    required double price,
    double discount = 0.0,
    double vat = 0.0,
  })  : quantity = quantity.obs,
        price = price.obs,
        discount = discount.obs,
        vat = vat.obs;

  double get total => (quantity.value * price.value) - discount.value + vat.value;
}

class InvoiceController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final ApiProvider _apiProvider = ApiProvider();

  late CustomerModel customer;
  late int invoiceType;
  
  final RxList<InvoiceItemRow> selectedItems = <InvoiceItemRow>[].obs;
  final RxList<ItemModel> availableItems = <ItemModel>[].obs;
  final RxInt paymentType = AppConstants.paymentTypeCash.obs;
  final RxInt status = AppConstants.statusPaid.obs;
  final totalPaidController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    customer = Get.arguments['customer'];
    invoiceType = Get.arguments['invoiceType'];
    availableItems.value = _storage.getItems();
  }

  double get netTotal => selectedItems.fold(0.0, (sum, item) => sum + item.total);

  void showItemSelectionDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          height: Get.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('select_items'.tr, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: availableItems.length,
                  itemBuilder: (context, index) {
                    final item = availableItems[index];
                    return CheckboxListTile(
                      title: Text(item.itemName),
                      subtitle: Text('${item.barcode} - ${item.sign}'),
                      value: selectedItems.any((i) => i.item.id == item.id),
                      onChanged: (selected) {
                        if (selected == true) {
                          _addItem(item);
                        } else {
                          selectedItems.removeWhere((i) => i.item.id == item.id);
                        }
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('add_items'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addItem(ItemModel item) {
    double defaultPrice = 0.0;
    
    // Only get price list details if customer has a price list
    if (customer.priceList != null) {
      final priceListDetails = _storage.getPriceListDetails(customer.priceList!.id);
      final priceDetail = priceListDetails.firstWhereOrNull((p) => p.item.id == item.id);
      defaultPrice = priceDetail?.price ?? 0.0;
    }

    selectedItems.add(InvoiceItemRow(
      item: item,
      price: defaultPrice,
    ));
  }

  void removeItem(int index) {
    selectedItems.removeAt(index);
  }

  Future<void> submitInvoice() async {
    if (selectedItems.isEmpty) {
      Get.snackbar('error'.tr, 'Please add items');
      return;
    }

    final agent = _storage.getAgent();
    if (agent == null) return;

    final invoice = InvoiceModel(
      invoiceMaster: InvoiceMaster(
        invoiceType: invoiceType,
        customerOrVendorID: customer.id,
        storeId: agent.storeID,
        agentID: agent.id,
        status: status.value,
        paymentType: paymentType.value,
        netTotal: netTotal,
        totalPaid: double.tryParse(totalPaidController.text) ?? 0.0,
      ),
      invoiceDetails: selectedItems.map((item) => InvoiceDetail(
        item: item.item.id,
        quantity: item.quantity.value,
        price: item.price.value,
        discount: item.discount.value,
        vat: item.vat.value,
      )).toList(),
    );

    final hasConnection = await _connectivity.checkConnection();

    try {
      isLoading.value = true;
      logger.i('Submitting invoice for customer: ${customer.customerName}');

      if (hasConnection) {
        await _apiProvider.batchCreateInvoices([invoice.toJson()]);
        logger.i('Invoice created successfully online');
        Get.snackbar('success'.tr, 'Invoice created successfully');
      } else {
        await _storage.addPendingInvoice(invoice.toJson());
        logger.i('Invoice saved offline for sync');
        Get.snackbar('offline_mode'.tr, 'Invoice saved for sync');
      }

      Get.back();
    } catch (e, stackTrace) {
      logger.e('Failed to submit invoice', error: e, stackTrace: stackTrace);
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    totalPaidController.dispose();
    super.onClose();
  }
}
