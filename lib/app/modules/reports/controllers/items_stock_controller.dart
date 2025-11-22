import 'package:get/get.dart';
import '../../../data/models/stock_model.dart';
import '../../../services/storage_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../data/providers/api_provider.dart';
import '../../../utils/logger.dart';

class ItemsStockController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final ApiProvider _apiProvider = ApiProvider();

  final isLoading = true.obs;
  final stockList = <StockModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStock();
  }

  Future<void> loadStock() async {
    try {
      isLoading.value = true;

      // Load from storage (updated during sync)
      final stocks = _storage.getStock();
      stockList.value = stocks;

      // Sort by item name
      stockList.sort((a, b) => a.itemName.compareTo(b.itemName));

      logger.i('📊 Loaded ${stockList.length} stock items from cache');
    } catch (e, stackTrace) {
      logger.e('❌ Error loading stock', error: e, stackTrace: stackTrace);
      Get.snackbar('error'.tr, '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStock() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      Get.snackbar('offline_mode'.tr, 'cannot_refresh_offline'.tr);
      return;
    }

    try {
      final agent = _storage.getAgent();
      if (agent == null) return;

      // Fetch stock from API
      final response = await _apiProvider.getAgentStock(agent.storeID);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        final List<StockModel> stocks = data
            .map((json) => StockModel.fromJson(json))
            .toList();

        // Update storage
        await _storage.saveStock(stocks);

        // Reload from storage to update UI
        await loadStock();

        Get.snackbar('success'.tr, 'stock_updated'.tr);
      }
    } catch (e) {
      logger.e('❌ Error refreshing stock', error: e);
      Get.snackbar('error'.tr, 'failed_to_refresh_stock'.tr);
    }
  }
}
