import 'package:get/get.dart';
import 'package:dio/dio.dart';
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

      // Fetch stock from API - force fresh data on pull-to-refresh
      final response = await _apiProvider.getAgentStock(
        agent.storeID,
        forceRefresh: true,
      );

      if (response.statusCode == 200 && response.data != null) {
        // Handle both List and Map responses
        List<dynamic> data;
        if (response.data is List) {
          data = response.data as List<dynamic>;
        } else if (response.data is Map) {
          // Try common wrapper keys
          final map = response.data as Map<String, dynamic>;
          if (map.containsKey('results')) {
            data = map['results'] as List<dynamic>;
          } else if (map.containsKey('data')) {
            data = map['data'] as List<dynamic>;
          } else if (map.containsKey('items')) {
            data = map['items'] as List<dynamic>;
          } else {
            logger.e('❌ Unexpected API response structure: $map');
            throw Exception('Invalid API response format');
          }
        } else {
          throw Exception(
            'Unexpected response type: ${response.data.runtimeType}',
          );
        }

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
