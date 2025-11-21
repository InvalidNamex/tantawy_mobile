import 'package:get/get.dart';
import '../../../data/models/stock_model.dart';
import '../../../services/storage_service.dart';
import '../../../utils/logger.dart';

class ItemsStockController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

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
    await loadStock();
  }
}
