import 'package:get/get.dart';
import '../controllers/customer_transactions_controller.dart';

class CustomerTransactionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerTransactionsController>(
      () => CustomerTransactionsController(),
    );
  }
}
