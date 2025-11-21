import 'package:get/get.dart';
import '../controllers/vouchers_controller.dart';

class VouchersBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VouchersController>(() => VouchersController());
  }
}
