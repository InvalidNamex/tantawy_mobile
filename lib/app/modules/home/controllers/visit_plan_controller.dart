import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/customer_model.dart';
import '../../../services/storage_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/shorebird_update_service.dart';
import '../../../data/repositories/sync_repository.dart';
import '../../../data/repositories/data_repository.dart';
import '../../../utils/logger.dart';
import '../../../widgets/sync_progress_dialog.dart';

class VisitPlanController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final SyncRepository _syncRepository = SyncRepository();
  final DataRepository _dataRepository = DataRepository();

  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxBool isSyncing = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxInt currentIndex = 2.obs;
  final Rxn<int> expandedTileIndex = Rxn<int>();

  // Sync progress tracking
  final RxDouble syncProgress = 0.0.obs;
  final RxString syncStatus = ''.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  void setExpandedTile(int? index) {
    expandedTileIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _loadCustomers();
    _checkAndFetchDataIfNeeded();
    _checkForUpdates();
  }

  void _checkForUpdates() {
    // Check for Shorebird updates after home screen is loaded
    try {
      final shorebirdService = Get.find<ShorebirdUpdateService>();
      // Longer delay to ensure UI and overlay are fully ready
      Future.delayed(Duration(seconds: 2), () {
        shorebirdService.checkForUpdates(showNotification: true);
      });
    } catch (e) {
      logger.w('Shorebird update check failed', error: e);
    }
  }

  void _loadCustomers() {
    customers.value = _storage.getCustomers();
    logger.i('📋 Loaded ${customers.length} customers from cache');
  }

  Future<void> _checkAndFetchDataIfNeeded() async {
    if (customers.isEmpty) {
      logger.w('⚠️ VISIT_PLAN: Cache is empty! Attempting to fetch data...');
      final agent = _storage.getAgent();
      if (agent != null) {
        final hasConnection = await _connectivity.checkConnection();
        if (hasConnection) {
          logger.d(
            '📥 VISIT_PLAN: Fetching initial data for agent ${agent.id}...',
          );
          try {
            final fetchedCustomers = await _dataRepository.getActiveVisitPlan();
            await _storage.saveCustomers(fetchedCustomers);
            _loadCustomers();

            // Also fetch all other data on initial load
            await _dataRepository.fetchAndSaveAllInvoices(agent.id);
            await _dataRepository.fetchAndSaveAllVouchers(agent.id);
            await _dataRepository.fetchAndSaveAllVisits(agent.id);
            await _dataRepository.fetchAndSaveItemsGroups();

            logger.i('✅ VISIT_PLAN: Data fetched and cached successfully');
          } catch (e) {
            logger.e('❌ VISIT_PLAN: Failed to fetch data - $e');
            logger.e('Failed to fetch data on visit plan load', error: e);
          }
        } else {
          logger.w('❌ VISIT_PLAN: No internet connection to fetch data');
        }
      }
    }
  }

  Future<void> syncData() async {
    final hasConnection = await _connectivity.checkConnection();
    if (!hasConnection) {
      Get.snackbar('error'.tr, 'no_internet'.tr);
      return;
    }

    // Get counts before starting
    final pendingInvoices = _storage.getPendingInvoices();
    final pendingVouchers = _storage.getPendingVouchers();
    final pendingVisits = _storage.getPendingVisits();

    final invoiceCount = pendingInvoices.length;
    final voucherCount = pendingVouchers.length;
    final visitCount = pendingVisits.length;

    if (invoiceCount == 0 && voucherCount == 0 && visitCount == 0) {
      Get.snackbar(
        'info'.tr,
        'no_pending_data_to_sync'.tr,
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // Calculate total steps (sync 3 types + fetch data = 4 steps)
    int totalSteps = 0;
    if (invoiceCount > 0) totalSteps++;
    if (voucherCount > 0) totalSteps++;
    if (visitCount > 0) totalSteps++;
    totalSteps++; // Add step for fetching latest data

    int completedSteps = 0;

    try {
      isSyncing.value = true;
      syncProgress.value = 0.0;
      syncStatus.value = 'preparing'.tr;

      // Show progress dialog
      Get.dialog(
        SyncProgressDialog(
          progress: syncProgress,
          status: syncStatus,
          invoiceCount: invoiceCount,
          voucherCount: voucherCount,
          visitCount: visitCount,
        ),
        barrierDismissible: false,
      );

      logger.i('Starting sync...');
      logger.i(
        'Syncing $invoiceCount invoices, $voucherCount vouchers, $visitCount visits',
      );

      // Sync with individual error handling
      bool hasErrors = false;
      String errorMessage = '';

      // Sync invoices
      if (invoiceCount > 0) {
        try {
          syncStatus.value = 'syncing_invoices'.trParams({
            '0': invoiceCount.toString(),
          });
          logger.i('Syncing invoices...');
          await _syncRepository.syncPendingInvoices(pendingInvoices);
          logger.i('✅ Invoices synced successfully');
          await _storage.clearPendingInvoices();
          completedSteps++;
          syncProgress.value = completedSteps / totalSteps;
        } catch (e) {
          logger.e('❌ Failed to sync invoices: $e');
          hasErrors = true;
          errorMessage += 'invoices_error'.trParams({'0': e.toString()}) + '\n';
          completedSteps++;
          syncProgress.value = completedSteps / totalSteps;
          // Don't clear if failed - keep for retry
        }
      }

      // Sync vouchers
      if (voucherCount > 0) {
        try {
          syncStatus.value = 'syncing_vouchers'.trParams({
            '0': voucherCount.toString(),
          });
          logger.i('Syncing vouchers...');
          await _syncRepository.syncPendingVouchers(pendingVouchers);
          logger.i('✅ Vouchers synced successfully');
          await _storage.clearPendingVouchers();
          completedSteps++;
          syncProgress.value = completedSteps / totalSteps;
        } catch (e) {
          logger.e('❌ Failed to sync vouchers: $e');
          hasErrors = true;
          errorMessage += 'vouchers_error'.trParams({'0': e.toString()}) + '\n';
          completedSteps++;
          syncProgress.value = completedSteps / totalSteps;
          // Don't clear if failed - keep for retry
        }
      }

      // Sync visits
      if (visitCount > 0) {
        try {
          syncStatus.value = 'syncing_visits'.trParams({
            '0': visitCount.toString(),
          });
          logger.i('Syncing visits...');
          await _syncRepository.syncPendingVisits(pendingVisits);
          logger.i('✅ Visits synced successfully');
          await _storage.clearPendingVisits();
          completedSteps++;
          syncProgress.value = completedSteps / totalSteps;
        } catch (e) {
          logger.e('❌ Failed to sync visits: $e');
          hasErrors = true;
          errorMessage += 'visits_error'.trParams({'0': e.toString()}) + '\n';
          completedSteps++;
          syncProgress.value = completedSteps / totalSteps;
          // Don't clear if failed - keep for retry
        }
      }

      // Fetch latest data from server
      final agent = _storage.getAgent();
      if (agent != null && !hasErrors) {
        try {
          syncStatus.value = 'fetching_latest_data'.tr;
          logger.i('Fetching latest data from server...');
          final newCustomers = await _dataRepository.getActiveVisitPlan();
          await _storage.saveCustomers(newCustomers);
          _loadCustomers();

          // Sync all data from server
          await _dataRepository.fetchAndSaveAllInvoices(agent.id);
          await _dataRepository.fetchAndSaveAllVouchers(agent.id);
          await _dataRepository.fetchAndSaveAllVisits(agent.id);
          await _dataRepository.fetchAndSaveItemsGroups();
          logger.i('✅ Latest data fetched successfully');
          completedSteps++;
          syncProgress.value = 1.0;
        } catch (e) {
          logger.e('❌ Failed to fetch latest data: $e');
          completedSteps++;
          syncProgress.value = 1.0;
          // Non-critical error, don't mark as failed
        }
      } else if (hasErrors) {
        // Complete progress even if skipping fetch due to errors
        completedSteps++;
        syncProgress.value = 1.0;
      }

      // Small delay to show 100% completion
      await Future.delayed(Duration(milliseconds: 500));

      // Close dialog using Navigator for more reliable dismissal
      logger.i('🔍 Attempting to close sync dialog...');
      try {
        // Get the current context and close using Navigator
        if (Get.context != null) {
          Navigator.of(Get.context!).pop();
          logger.i('✅ Dialog closed using Navigator.pop()');
        } else {
          // Fallback to Get.back()
          Get.back();
          logger.i('✅ Dialog closed using Get.back()');
        }
      } catch (e) {
        logger.e('❌ Error closing dialog: $e');
        // Force close with Get.back as last resort
        Get.back();
      }

      // Wait a bit to ensure dialog is fully closed
      await Future.delayed(Duration(milliseconds: 300));

      if (hasErrors) {
        logger.w('Sync completed with errors');
        Get.dialog(
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('sync_partial'.tr),
              ],
            ),
            content: SingleChildScrollView(
              child: Text('${'sync_items_failed'.tr}\n\n$errorMessage'),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text('ok'.tr)),
            ],
          ),
        );
      } else {
        logger.i('✅ Sync completed successfully');
        Get.snackbar(
          'success'.tr,
          'synced_items'.tr
              .replaceFirst('{0}', invoiceCount.toString())
              .replaceFirst('{1}', voucherCount.toString())
              .replaceFirst('{2}', visitCount.toString()),
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      logger.e('Sync failed critically', error: e, stackTrace: stackTrace);

      // Close dialog if open
      logger.i('🔍 Error occurred, attempting to close dialog...');
      try {
        if (Get.context != null) {
          Navigator.of(Get.context!).pop();
          logger.i('✅ Dialog closed after error using Navigator.pop()');
        } else {
          Get.back();
          logger.i('✅ Dialog closed after error using Get.back()');
        }
      } catch (dialogError) {
        logger.e('❌ Could not close dialog: $dialogError');
        Get.back(); // Force close
      }

      // Wait to ensure dialog is closed
      await Future.delayed(Duration(milliseconds: 300));

      Get.snackbar(
        'error'.tr,
        'Sync failed: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isSyncing.value = false;
      syncProgress.value = 0.0;
      syncStatus.value = '';
    }
  }

  bool get hasPendingData => _storage.hasPendingData;

  String get agentName => _storage.getAgent()?.name ?? '';

  /// Pull to refresh - fetches fresh data from server when online
  Future<void> refreshData() async {
    final hasConnection = await _connectivity.checkConnection();
    if (!hasConnection) {
      Get.snackbar(
        'offline_mode'.tr,
        'no_internet'.tr,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
      return;
    }

    final agent = _storage.getAgent();
    if (agent == null) {
      logger.w('⚠️ REFRESH: No agent found in storage');
      return;
    }

    try {
      isRefreshing.value = true;
      logger.i('🔄 REFRESH: Fetching fresh data from server...');

      // Fetch visit plan and customers
      final freshCustomers = await _dataRepository.getActiveVisitPlan();
      await _storage.saveCustomers(freshCustomers);
      _loadCustomers();
      logger.i(
        '✅ REFRESH: Customers updated (${freshCustomers.length} customers)',
      );

      // Fetch all other data in parallel
      await Future.wait([
        _dataRepository.fetchAndSaveAllInvoices(agent.id),
        _dataRepository.fetchAndSaveAllVouchers(agent.id),
        _dataRepository.fetchAndSaveAllVisits(agent.id),
        _dataRepository.fetchAndSaveItemsGroups(),
      ]);

      logger.i('✅ REFRESH: All data refreshed successfully');
      Get.snackbar(
        'success'.tr,
        'data_refreshed'.tr,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e, stackTrace) {
      logger.e(
        '❌ REFRESH: Failed to refresh data',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        'error'.tr,
        '${'failed_to_refresh'.tr}: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isRefreshing.value = false;
    }
  }
}
