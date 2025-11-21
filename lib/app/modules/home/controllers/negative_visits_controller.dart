import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/visit_model.dart';
import '../../../data/repositories/data_repository.dart';
import '../../../services/storage_service.dart';
import '../../../utils/logger.dart';

class NegativeVisitsController extends GetxController {
  final RxInt currentIndex = 4.obs;
  final StorageService _storage = Get.find<StorageService>();
  final DataRepository _repository = DataRepository();

  // Filtering
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();

  final RxList<VisitResponseModel> filteredVisits = <VisitResponseModel>[].obs;
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
    loadVisitsFromStorage();
  }

  @override
  void onReady() {
    super.onReady();
  }

  void loadVisitsFromStorage() {
    logger.i('📂 Loading visits from storage...');
    isLoading.value = true;
    try {
      _applyFilters();
      logger.i('✅ Loaded ${filteredVisits.length} visits from storage');
    } catch (e) {
      logger.e('❌ Error loading visits from storage: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncVisits() async {
    final agent = _storage.getAgent();
    if (agent == null) {
      _showThrottledError('error'.tr, 'no_agent_found'.tr);
      return;
    }

    try {
      isSyncing.value = true;
      logger.i('🔄 Syncing visits from API...');

      await _repository.fetchAndSaveAllVisits(agent.id);
      _applyFilters();

      logger.i('✅ Visits synced successfully');
      // Only show success message, no notification spam
    } on DioException catch (e) {
      logger.e('❌ Error syncing visits: $e');

      // Handle 429 rate limit silently - data already loaded from cache/storage
      if (e.response?.statusCode == 429) {
        logger.w('🚦 Rate limited - using cached data');
        // Don't show error to user, interceptor already handled it
        return;
      }

      // For other errors, show throttled notification
      _showThrottledError(
        'error'.tr,
        'Failed to sync visits. Using cached data.',
      );
    } catch (e) {
      logger.e('❌ Unexpected error syncing visits: $e');
      _showThrottledError(
        'error'.tr,
        'Failed to sync visits. Using cached data.',
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

  void setFromDate(DateTime? date) {
    fromDate.value = date;
    _applyFilters();
  }

  void setToDate(DateTime? date) {
    toDate.value = date;
    _applyFilters();
  }

  void clearFilters() {
    fromDate.value = null;
    toDate.value = null;
    _applyFilters();
  }

  void _applyFilters() {
    logger.d('🔍 Applying filters:');
    logger.d('   From Date: ${fromDate.value}');
    logger.d('   To Date: ${toDate.value}');

    final visits = _storage.getFilteredVisits(
      fromDate: fromDate.value,
      toDate: toDate.value,
    );

    logger.d('📊 Filtered visits count: ${visits.length}');
    if (visits.isNotEmpty) {
      logger.d('   First visit date: ${visits.first.date}');
    }

    // Debug: show all visits in storage
    final allVisits = _storage.getVisits();
    logger.d('📦 Total visits in storage: ${allVisits.length}');

    filteredVisits.value = visits;
  }

  Future<void> openMap(double latitude, double longitude) async {
    try {
      // Use OpenStreetMap - no API key required, works universally
      final osmUrl = Uri.parse(
        'https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=16/$latitude/$longitude',
      );

      await launchUrl(osmUrl, mode: LaunchMode.externalApplication);
      logger.i('📍 Opened location in OpenStreetMap');
    } catch (e) {
      logger.e('❌ Error opening map: $e');
      Get.snackbar(
        'error'.tr,
        'Failed to open map',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
}
