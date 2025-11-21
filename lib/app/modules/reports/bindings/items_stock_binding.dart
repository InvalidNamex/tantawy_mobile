import 'package:get/get.dart';
import '../controllers/items_stock_controller.dart';

class ItemsStockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItemsStockController>(() => ItemsStockController());
  }
}
