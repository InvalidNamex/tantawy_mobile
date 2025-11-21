import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../data/models/voucher_model.dart';
import '../../../data/repositories/data_repository.dart';
import '../../../services/storage_service.dart';
import '../../../utils/logger.dart';

class VouchersController extends GetxController {
  final RxInt currentIndex = 3.obs;
  final StorageService _storage = Get.find<StorageService>();
  final DataRepository _repository = DataRepository();

  // Filtering
  final selectedVoucherType = RxnInt(1); // Default to receipt voucher
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();

  final RxList<VoucherResponseModel> filteredVouchers =
      <VoucherResponseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSyncing = false.obs;

  // Track last error notification to prevent spam
  static DateTime? _lastErrorNotification;
  static const Duration _errorNotificationCooldown = Duration(seconds: 10);

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    loadVouchersFromStorage();
  }

  @override
  void onReady() {
    super.onReady();
  }

  void loadVouchersFromStorage() {
    logger.i('📂 Loading vouchers from storage...');
    isLoading.value = true;
    try {
      _applyFilters();
      logger.i('✅ Loaded ${filteredVouchers.length} vouchers from storage');
    } catch (e) {
      logger.e('❌ Error loading vouchers from storage: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncVouchers() async {
    final agent = _storage.getAgent();
    if (agent == null) {
      _showThrottledError('error'.tr, 'no_agent_found'.tr);
      return;
    }

    try {
      isSyncing.value = true;
      logger.i('🔄 Syncing vouchers from API...');

      await _repository.fetchAndSaveAllVouchers(agent.id);
      _applyFilters();

      logger.i('✅ Vouchers synced successfully');
      // Only show success message, no notification spam
    } on DioException catch (e) {
      logger.e('❌ Error syncing vouchers: $e');

      // Handle 429 rate limit silently - data already loaded from cache/storage
      if (e.response?.statusCode == 429) {
        logger.w('🚦 Rate limited - using cached data');
        // Don't show error to user, interceptor already handled it
        return;
      }

      // For other errors, show throttled notification
      _showThrottledError(
        'error'.tr,
        'Failed to sync vouchers. Using cached data.',
      );
    } catch (e) {
      logger.e('❌ Unexpected error syncing vouchers: $e');
      _showThrottledError(
        'error'.tr,
        'Failed to sync vouchers. Using cached data.',
      );
    } finally {
      isSyncing.value = false;
    }
  }

  /// Show error notification with throttling to prevent spam
  void _showThrottledError(String title, String message) {
    final now = DateTime.now();
    if (_lastErrorNotification != null) {
      final timeSinceLastError = now.difference(_lastErrorNotification!);
      if (timeSinceLastError < _errorNotificationCooldown) {
        logger.d(
          '🔇 Suppressing error notification (cooldown: ${_errorNotificationCooldown.inSeconds - timeSinceLastError.inSeconds}s remaining)',
        );
        return;
      }
    }

    _lastErrorNotification = now;
    Get.snackbar(title, message);
    logger.i('📢 Showed error notification to user');
  }

  void setVoucherType(int? type) {
    selectedVoucherType.value = type;
    _applyFilters();
  }

  void setFromDate(DateTime? date) {
    fromDate.value = date;
    _applyFilters();
  }

  void setToDate(DateTime? date) {
    toDate.value = date;
    _applyFilters();
  }

  void clearFilters() {
    selectedVoucherType.value = null;
    fromDate.value = null;
    toDate.value = null;
    _applyFilters();
  }

  void _applyFilters() {
    logger.d('🔍 Applying filters:');
    logger.d('   Type: ${selectedVoucherType.value}');
    logger.d('   From Date: ${fromDate.value}');
    logger.d('   To Date: ${toDate.value}');

    final vouchers = _storage.getFilteredVouchers(
      type: selectedVoucherType.value,
      fromDate: fromDate.value,
      toDate: toDate.value,
    );

    logger.d('📊 Filtered vouchers count: ${vouchers.length}');
    if (vouchers.isNotEmpty) {
      logger.d('   First voucher type: ${vouchers.first.type}');
      logger.d('   First voucher date: ${vouchers.first.voucherDate}');
    }

    // Debug: show all vouchers in storage
    final allVouchers = _storage.getVouchers();
    logger.d('📦 Total vouchers in storage: ${allVouchers.length}');
    if (allVouchers.isNotEmpty) {
      logger.d(
        '   Voucher types in storage: ${allVouchers.map((v) => v.type).toSet()}',
      );
    }

    filteredVouchers.value = vouchers;
  }

  String getVoucherTypeText(int type) {
    switch (type) {
      case 1:
        return 'receipt_voucher'.tr;
      case 2:
        return 'payment_voucher'.tr;
      default:
        return 'unknown'.tr;
    }
  }
}
