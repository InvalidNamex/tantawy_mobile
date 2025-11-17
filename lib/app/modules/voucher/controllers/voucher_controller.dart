import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/voucher_model.dart';
import '../../../data/enums/voucher_type_enum.dart';
import '../../../services/storage_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/location_service.dart';
import '../../../data/providers/api_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/logger.dart';

class VoucherController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final LocationService _locationService = Get.put(LocationService());
  final ApiProvider _apiProvider = ApiProvider();

  late CustomerModel? customer;
  late VoucherType voucherType;

  final amountController = TextEditingController();
  final notesController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get customer from arguments (can be null for payment vouchers)
    customer = Get.arguments?['customer'];

    // Get voucher type from arguments, default to receipt
    final typeValue = Get.arguments?['voucherType'] as int?;
    voucherType = typeValue != null
        ? VoucherType.fromValue(typeValue)
        : VoucherType.receipt;
  }

  /// Get the title for the voucher screen
  String get title => voucherType.translationKey.tr;

  /// Get the customer/vendor name
  String get customerVendorName => customer?.customerName ?? '';

  /// Check if customer selection is required (for standalone voucher entry)
  bool get requiresCustomer => customer == null;

  Future<void> submitVoucher() async {
    if (amountController.text.isEmpty) {
      Get.snackbar('error'.tr, 'please_enter_amount'.tr);
      return;
    }

    // Validate customer is selected only for receipt vouchers
    if (voucherType.isReceipt && customer == null) {
      Get.snackbar('error'.tr, 'please_select_customer'.tr);
      return;
    }

    // Check location permission before proceeding
    bool hasPermission = await _locationService.requestLocationPermission();
    if (!hasPermission) {
      return;
    }

    final agent = _storage.getAgent();
    if (agent == null) return;

    final voucher = VoucherModel(
      type: voucherType.value,
      customerVendorId:
          customer?.id ?? 0, // Use 0 if no customer for payment vouchers
      amount: double.parse(amountController.text),
      storeId: agent.storeID,
      notes: notesController.text,
      voucherDate: DateTime.now().toIso8601String(),
      accountId: AppConstants.storeCashAccountId,
    );

    // Debug logging
    logger.d('📝 Voucher notes from controller: "${notesController.text}"');
    logger.d('📦 Voucher JSON being sent: ${voucher.toJson()}');

    final hasConnection = await _connectivity.checkConnection();

    try {
      isLoading.value = true;
      logger.i(
        'Submitting ${voucherType.translationKey}${customer != null ? ' for customer: ${customer!.customerName}' : ''}',
      );

      if (hasConnection) {
        await _apiProvider.batchCreateVouchers([voucher.toJson()]);
        logger.i('Voucher created successfully online');
        Get.snackbar('success'.tr, 'voucher_created'.tr);
      } else {
        await _storage.addPendingVoucher(voucher.toJson());
        logger.i('Voucher saved offline for sync');
        Get.snackbar('offline_mode'.tr, 'voucher_saved_sync'.tr);
      }

      Get.back();
    } catch (e, stackTrace) {
      logger.e('Failed to submit voucher', error: e, stackTrace: stackTrace);
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
