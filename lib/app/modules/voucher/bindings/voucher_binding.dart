import 'package:get/get.dart';
import '../controllers/voucher_controller.dart';

class VoucherBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VoucherController>(() => VoucherController());
  }
}
