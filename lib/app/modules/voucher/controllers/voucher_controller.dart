import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/voucher_model.dart';
import '../../../services/storage_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../data/providers/api_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/logger.dart';

class VoucherController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final ApiProvider _apiProvider = ApiProvider();

  late CustomerModel customer;

  final amountController = TextEditingController();
  final notesController = TextEditingController();
  final RxBool isReceive = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    customer = Get.arguments['customer'];
  }

  Future<void> submitVoucher() async {
    if (amountController.text.isEmpty) {
      Get.snackbar('error'.tr, 'please_enter_amount'.tr);
      return;
    }

    final agent = _storage.getAgent();
    if (agent == null) return;

    final voucher = VoucherModel(
      type: isReceive.value
          ? AppConstants.voucherTypeReceipt
          : AppConstants.voucherTypePayment,
      customerVendorId: customer.id,
      amount: double.parse(amountController.text),
      storeId: agent.storeID,
      notes: notesController.text,
      voucherDate: DateTime.now().toIso8601String(),
      accountId: AppConstants.storeCashAccountId,
    );

    final hasConnection = await _connectivity.checkConnection();

    try {
      isLoading.value = true;
      logger.i('Submitting voucher for customer: ${customer.customerName}');

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
