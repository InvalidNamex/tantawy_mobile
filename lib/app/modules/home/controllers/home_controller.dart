import 'package:get/get.dart';
import '../../../data/models/customer_model.dart';
import '../../../services/storage_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../data/repositories/sync_repository.dart';
import '../../../data/repositories/data_repository.dart';
import '../../../utils/logger.dart';

class HomeController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final SyncRepository _syncRepository = SyncRepository();
  final DataRepository _dataRepository = DataRepository();

  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxBool isSyncing = false.obs;
  final RxInt currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCustomers();
    _checkAndFetchDataIfNeeded();
  }

  void _loadCustomers() {
    customers.value = _storage.getCustomers();
    logger.i('📋 Loaded ${customers.length} customers from cache');
  }

  Future<void> _checkAndFetchDataIfNeeded() async {
    if (customers.isEmpty) {
      logger.w('⚠️ HOME: Cache is empty! Attempting to fetch data...');
      final agent = _storage.getAgent();
      if (agent != null) {
        final hasConnection = await _connectivity.checkConnection();
        if (hasConnection) {
          logger.d('📥 HOME: Fetching initial data for agent ${agent.id}...');
          try {
            final fetchedCustomers = await _dataRepository.getActiveVisitPlan();
            await _storage.saveCustomers(fetchedCustomers);
            _loadCustomers();
            logger.i('✅ HOME: Data fetched and cached successfully');
          } catch (e) {
            logger.e('❌ HOME: Failed to fetch data - $e');
            logger.e('Failed to fetch data on home load', error: e);
          }
        } else {
          logger.w('❌ HOME: No internet connection to fetch data');
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

    try {
      isSyncing.value = true;
      logger.i('Starting sync...');
      
      final pendingInvoices = _storage.getPendingInvoices();
      final pendingVouchers = _storage.getPendingVouchers();
      final pendingVisits = _storage.getPendingVisits();

      await _syncRepository.syncPendingInvoices(pendingInvoices);
      await _syncRepository.syncPendingVouchers(pendingVouchers);
      await _syncRepository.syncPendingVisits(pendingVisits);

      await _storage.clearPendingInvoices();
      await _storage.clearPendingVouchers();
      await _storage.clearPendingVisits();

      final agent = _storage.getAgent();
      if (agent != null) {
        final newCustomers = await _dataRepository.getActiveVisitPlan();
        await _storage.saveCustomers(newCustomers);
        _loadCustomers();
      }

      logger.i('Sync completed successfully');
      Get.snackbar('success'.tr, 'sync_success'.tr);
    } catch (e, stackTrace) {
      logger.e('Sync failed', error: e, stackTrace: stackTrace);
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isSyncing.value = false;
    }
  }

  bool get hasPendingData => _storage.hasPendingData;

  String get agentName => _storage.getAgent()?.name ?? '';
}
