import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/item_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../services/storage_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/location_service.dart';
import '../../../data/providers/api_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/logger.dart';
import '../../../utils/api_error_handler.dart';
import '../../../utils/server_error_dialog.dart';
import '../../../utils/auth_session_manager.dart';

class InvoiceItemRow {
  final ItemModel item;
  final RxDouble quantity;
  final RxDouble price;
  final double priceListPrice; // Store the original price list price

  InvoiceItemRow({
    required this.item,
    double quantity = 1.0,
    required double price,
    required this.priceListPrice,
  }) : quantity = quantity.obs,
       price = price.obs;

  double get total => quantity.value * price.value;
}

class InvoiceController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final LocationService _locationService = Get.put(LocationService());
  final ApiProvider _apiProvider = ApiProvider();

  late CustomerModel customer;
  late int invoiceType;

  final RxList<InvoiceItemRow> selectedItems = <InvoiceItemRow>[].obs;
  final RxList<ItemModel> availableItems = <ItemModel>[].obs;
  final RxInt paymentType = AppConstants.paymentTypeCash.obs;
  final RxInt status = AppConstants.statusPaid.obs;
  final totalPaidController = TextEditingController();
  final discountAmountController = TextEditingController(text: '0');
  final RxBool isTaxInvoice = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    customer = Get.arguments['customer'];
    invoiceType = Get.arguments['invoiceType'];
    availableItems.value = _storage.getItems();

    // Listen to status changes
    ever(status, (_) => _handleStatusChange());

    // Listen to payment type changes
    ever(paymentType, (_) => _handlePaymentTypeChange());

    // Listen to discount changes
    discountAmountController.addListener(_updateNetTotal);

    // Listen to tax invoice changes
    ever(isTaxInvoice, (_) => _updateNetTotal());
  }

  double get subtotal =>
      selectedItems.fold(0.0, (sum, item) => sum + item.total);

  double get discountAmount {
    return double.tryParse(discountAmountController.text) ?? 0.0;
  }

  double get taxAmount {
    return isTaxInvoice.value ? (subtotal - discountAmount) * 0.14 : 0.0;
  }

  double get netTotal => subtotal - discountAmount + taxAmount;

  void _updateNetTotal() {
    // Trigger rebuild by adding and removing a dummy item or using update
    selectedItems.value = List.from(selectedItems);
  }

  void _handleStatusChange() {
    if (status.value == AppConstants.statusPaid) {
      totalPaidController.text = netTotal.toStringAsFixed(2);
    } else if (status.value == AppConstants.statusUnpaid) {
      totalPaidController.text = '0';
    }
  }

  void _handlePaymentTypeChange() {
    if (paymentType.value == AppConstants.paymentTypeDeferred) {
      status.value = AppConstants.statusUnpaid;
      totalPaidController.text = '0';
    }
  }

  bool get isTotalPaidEnabled {
    // Disable if status is paid, unpaid, or payment type is deferred
    return status.value != AppConstants.statusPaid &&
        status.value != AppConstants.statusUnpaid &&
        paymentType.value != AppConstants.paymentTypeDeferred;
  }

  void addItem(ItemModel item) {
    // Check if item already exists
    final existingItemIndex = selectedItems.indexWhere(
      (i) => i.item.id == item.id,
    );
    if (existingItemIndex != -1) {
      // Item already exists, increase quantity by 1
      selectedItems[existingItemIndex].quantity.value += 1;
      return;
    }

    double defaultPrice = 0.0;

    // Only get price list details if customer has a price list
    if (customer.priceList != null) {
      final priceListDetails = _storage.getPriceListDetails(
        customer.priceList!.id,
      );
      final priceDetail = priceListDetails.firstWhereOrNull(
        (p) => p.item.id == item.id,
      );
      defaultPrice = priceDetail?.price ?? 0.0;
    }

    selectedItems.add(
      InvoiceItemRow(
        item: item,
        price: defaultPrice,
        priceListPrice: defaultPrice,
      ),
    );
  }

  void removeItem(int index) {
    selectedItems.removeAt(index);
  }

  bool validatePrice(InvoiceItemRow item, double newPrice) {
    if (newPrice < item.priceListPrice) {
      Get.snackbar('error'.tr, 'price_cannot_be_lower_than_pricelist'.tr);
      return false;
    }
    return true;
  }

  void showItemSelectionDialog() {
    // This will be called from the view
    // The view will handle the dropdown_search widget
  }

  Future<void> submitInvoice() async {
    if (selectedItems.isEmpty) {
      Get.snackbar('error'.tr, 'please_add_items'.tr);
      return;
    }

    // Validate discount amount
    if (discountAmount > subtotal) {
      Get.snackbar('error'.tr, 'discount_cannot_exceed_subtotal'.tr);
      return;
    }

    // Validate partially paid status
    if (status.value == AppConstants.statusPartiallyPaid) {
      final totalPaid = double.tryParse(totalPaidController.text) ?? 0.0;
      if (totalPaid <= 0) {
        Get.snackbar('error'.tr, 'partially_paid_must_have_amount'.tr);
        return;
      }
    }

    // Check location permission before proceeding
    bool hasPermission = await _locationService.requestLocationPermission();
    if (!hasPermission) {
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
        discountAmount: discountAmount > 0 ? discountAmount : null,
        taxAmount: taxAmount > 0 ? taxAmount : null,
      ),
      invoiceDetails: selectedItems
          .map(
            (item) => InvoiceDetail(
              item: item.item.id,
              quantity: item.quantity.value,
              price: item.price.value,
            ),
          )
          .toList(),
    );

    final hasConnection = await _connectivity.checkConnection();

    try {
      isLoading.value = true;
      logger.i('Submitting invoice for customer: ${customer.customerName}');

      if (hasConnection) {
        // Try to submit online
        await _apiProvider.batchCreateInvoices([invoice.toJson()]);
        logger.i('Invoice created successfully online');
        Get.snackbar('success'.tr, 'invoice_created'.tr);
      } else {
        // No internet - save offline
        await _storage.addPendingInvoice(invoice.toJson());
        logger.i('Invoice saved offline for sync');
        Get.snackbar('offline_mode'.tr, 'invoice_saved_sync'.tr);
      }

      Get.back();
    } catch (e, stackTrace) {
      logger.e('Failed to submit invoice', error: e, stackTrace: stackTrace);

      // Check for authentication errors
      if (AuthSessionManager.isAuthenticationError(e)) {
        logger.w('❌ Authentication failed - using AuthSessionManager');
        await AuthSessionManager.handleAuthenticationFailure();
        return;
      }

      // Check if it's a server error with internet connection
      if (hasConnection && ApiErrorHandler.isServerErrorWithInternet(e)) {
        logger.w('🔄 Server error with internet - saving invoice offline');

        // Save the invoice offline
        await _storage.addPendingInvoice(invoice.toJson());

        // Show server error dialog
        ServerErrorDialog.showServerErrorSavedOffline(
          dataType: 'invoice',
          error: e,
        );

        // Close the invoice screen after a brief delay
        Future.delayed(Duration(milliseconds: 1500), () {
          Get.back();
        });
        return;
      }

      // For other errors, show generic error message
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    totalPaidController.dispose();
    discountAmountController.dispose();
    super.onClose();
  }
}
