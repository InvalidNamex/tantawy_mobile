import 'package:get/get.dart';
import '../controllers/cash_balance_controller.dart';

class CashBalanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashBalanceController>(() => CashBalanceController());
  }
}
