import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/cash_balance_model.dart';
import '../../../data/repositories/data_repository.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/storage_service.dart';
import '../../../utils/logger.dart';

class CashBalanceController extends GetxController {
  final DataRepository _dataRepository = DataRepository();
  final StorageService _storage = Get.find<StorageService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();

  final isLoading = false.obs;
  final cashBalance = Rxn<CashBalanceModel>();

  final fromDate = Rx<DateTime>(DateTime.now());
  final toDate = Rx<DateTime>(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    // Set both dates to today by default
    final today = DateTime.now();
    fromDate.value = today;
    toDate.value = today;
    loadCashBalance(); // Load from cache first, then fetch online data
  }

  Future<void> loadCashBalance() async {
    try {
      isLoading.value = true;

      // Load from storage first
      final cached = _storage.getCashBalance();
      if (cached != null) {
        cashBalance.value = cached;
      }

      logger.i('📊 Loaded cash balance from cache');

      // Check connectivity and fetch fresh data filtered by today's date
      final hasConnection = await _connectivity.checkConnection();
      if (hasConnection) {
        // Fetch new data with today's date filter in background
        isLoading.value = false; // Show cached data immediately
        await fetchCashBalance();
      }
    } catch (e, stackTrace) {
      logger.e(
        '❌ Error loading cash balance',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar('error'.tr, '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCashBalance() async {
    try {
      isLoading.value = true;

      // Check connectivity first
      final hasConnection = await _connectivity.checkConnection();
      if (!hasConnection) {
        Get.snackbar(
          'error'.tr,
          'no_internet'.tr,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      final agent = _storage.getAgent();
      if (agent == null) {
        Get.snackbar('error'.tr, 'no_agent_found'.tr);
        return;
      }

      final dateFormat = DateFormat('dd/MM/yyyy');
      final dateFrom = dateFormat.format(fromDate.value);
      final dateTo = dateFormat.format(toDate.value);

      logger.d(
        '📅 Fetching cash balance: agent=${agent.id}, from=$dateFrom, to=$dateTo',
      );

      final balance = await _dataRepository.getCashBalance(
        agent.id,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      if (balance != null) {
        await _storage.saveCashBalance(balance);
        cashBalance.value = balance;
        logger.i('✅ Fetched cash balance from API');
      } else {
        logger.i(
          'ℹ️ Cash balance not available due to permission restrictions',
        );
        Get.snackbar(
          'info'.tr,
          'Cash balance data is not available. You may not have permission to access this information.',
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
      // Removed annoying snackbar - data syncs silently like items stock
    } catch (e, stackTrace) {
      logger.e(
        '❌ Error fetching cash balance',
        error: e,
        stackTrace: stackTrace,
      );

      // Show user-friendly error message
      String errorMsg = 'failed_to_fetch_cash_balance'.tr;
      if (e.toString().contains('No address associated with hostname')) {
        errorMsg = 'no_internet'.tr;
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMsg = 'session_expired'.tr;
      }

      Get.snackbar('error'.tr, errorMsg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectDateRange(BuildContext context) async {
    // Check if online before allowing date selection
    final hasConnection = await _connectivity.checkConnection();
    if (!hasConnection) {
      Get.snackbar(
        'error'.tr,
        'no_internet'.tr,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: fromDate.value, end: toDate.value),
    );

    if (picked != null) {
      fromDate.value = picked.start;
      toDate.value = picked.end;
      // Fetch new data with updated date range
      await fetchCashBalance();
    }
  }
}
