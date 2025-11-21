import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/repositories/data_repository.dart';
import '../../../services/storage_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/logger.dart';

class InvoicesController extends GetxController {
  final DataRepository _dataRepository = DataRepository();
  final StorageService _storage = Get.find<StorageService>();

  final RxInt currentIndex = 0.obs;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);
  final RxInt selectedInvoiceType = AppConstants.invoiceTypeSales.obs;
  final RxList<InvoiceResponseModel> invoices = <InvoiceResponseModel>[].obs;
  final RxList<InvoiceResponseModel> filteredInvoices =
      <InvoiceResponseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSyncing = false.obs;

  // Track last error notification to prevent spam
  static DateTime? _lastErrorNotification;
  static const Duration _errorNotificationCooldown = Duration(seconds: 10);

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  void setFromDate(DateTime date) {
    fromDate.value = date;
    _applyFilters();
  }

  void setToDate(DateTime date) {
    toDate.value = date;
    _applyFilters();
  }

  void setInvoiceType(int type) {
    selectedInvoiceType.value = type;
    _applyFilters();
  }

  void _applyFilters() {
    filteredInvoices.value = _storage.getFilteredInvoices(
      invoiceType: selectedInvoiceType.value,
      fromDate: fromDate.value,
      toDate: toDate.value,
    );

    // Debug logging
    final allInvoices = _storage.getInvoices();
    logger.d('📊 Total invoices in storage: ${allInvoices.length}');
    logger.d('📊 Selected invoice type: ${selectedInvoiceType.value}');
    logger.d(
      '📊 Invoice types in storage: ${allInvoices.map((i) => i.invoiceType).toSet()}',
    );
    logger.d('📊 Filtered invoices: ${filteredInvoices.length}');

    if (filteredInvoices.isEmpty && allInvoices.isNotEmpty) {
      logger.w(
        '⚠️ No invoices match filter! Sample invoice type: ${allInvoices.first.invoiceType} (${allInvoices.first.invoiceType.runtimeType})',
      );
      logger.w(
        '⚠️ Filter invoice type: ${selectedInvoiceType.value} (${selectedInvoiceType.value.runtimeType})',
      );
    }
  }

  Future<void> loadInvoicesFromStorage() async {
    try {
      isLoading.value = true;
      invoices.value = _storage.getInvoices();
      _applyFilters();
      logger.i('✅ Loaded ${invoices.length} invoices from storage');
    } catch (e) {
      logger.e('❌ Error loading invoices from storage: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncInvoices() async {
    final agent = _storage.getAgent();
    if (agent == null) {
      _showThrottledError('error'.tr, 'no_agent_found'.tr);
      return;
    }

    try {
      isSyncing.value = true;
      logger.i('🔄 Syncing ALL invoices without filters...');

      // Fetch all invoices (no type or date filters)
      await _dataRepository.fetchAndSaveAllInvoices(agent.id);

      // Reload from storage
      await loadInvoicesFromStorage();

      logger.i('✅ Invoices synced successfully');
      // Only show success message, no notification spam
    } on DioException catch (e) {
      logger.e('❌ Error syncing invoices: $e');

      // Handle 429 rate limit silently - data already loaded from cache/storage
      if (e.response?.statusCode == 429) {
        logger.w('🚦 Rate limited - using cached data');
        // Don't show error to user, interceptor already handled it
        return;
      }

      // For other errors, show throttled notification
      _showThrottledError(
        'error'.tr,
        'Failed to sync invoices. Using cached data.',
      );
    } catch (e) {
      logger.e('❌ Unexpected error syncing invoices: $e');
      _showThrottledError(
        'error'.tr,
        'Failed to sync invoices. Using cached data.',
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

  String getStatusText(int status) {
    switch (status) {
      case AppConstants.statusPaid:
        return 'paid'.tr;
      case AppConstants.statusUnpaid:
        return 'unpaid'.tr;
      case AppConstants.statusPartiallyPaid:
        return 'partially_paid'.tr;
      default:
        return 'unknown'.tr;
    }
  }

  String getPaymentTypeText(int paymentType) {
    switch (paymentType) {
      case AppConstants.paymentTypeCash:
        return 'cash'.tr;
      case AppConstants.paymentTypeVisa:
        return 'visa'.tr;
      case AppConstants.paymentTypeDeferred:
        return 'deferred'.tr;
      default:
        return 'unknown'.tr;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadInvoicesFromStorage();
  }

  @override
  void onReady() {
    super.onReady();
  }
}
