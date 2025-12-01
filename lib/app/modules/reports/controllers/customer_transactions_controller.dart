import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../../../data/models/customer_transaction_model.dart';
import '../../../services/storage_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../data/providers/api_provider.dart';
import '../../../utils/logger.dart';

class CustomerTransactionsController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final ApiProvider _apiProvider = ApiProvider();

  final isLoading = true.obs;
  final transactionsList = <CustomerTransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;

      // Load from storage (updated during sync)
      final transactions = _storage.getCustomerTransactions();
      transactionsList.value = transactions;

      // Sort by customer name
      transactionsList.sort((a, b) => a.customerName.compareTo(b.customerName));

      logger.i(
        '📊 Loaded ${transactionsList.length} customer transactions from cache',
      );
    } catch (e, stackTrace) {
      logger.e(
        '❌ Error loading customer transactions',
        error: e,
        stackTrace: stackTrace,
      );
      _showSnackbar('error'.tr, '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTransactions() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      _showSnackbar('offline_mode'.tr, 'cannot_refresh_offline'.tr);
      return;
    }

    try {
      // Fetch customer transactions from API
      final response = await _apiProvider.getCustomerTransactions();

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'];
        final List<CustomerTransactionModel> transactions = data
            .map((json) => CustomerTransactionModel.fromJson(json))
            .toList();

        // Update storage
        await _storage.saveCustomerTransactions(transactions);

        // Reload from storage to update UI
        await loadTransactions();

        _showSnackbar('success'.tr, 'customer_transactions_updated'.tr);
      }
    } catch (e) {
      logger.e('❌ Error refreshing customer transactions', error: e);
      _showSnackbar('error'.tr, 'failed_to_refresh_customer_transactions'.tr);
    }
  }

  void _showSnackbar(String title, String message) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.overlayContext != null) {
        Get.snackbar(title, message);
      }
    });
  }
}
