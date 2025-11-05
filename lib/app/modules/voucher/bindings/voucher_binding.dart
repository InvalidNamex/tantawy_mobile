import 'package:get/get.dart';
import '../controllers/voucher_controller.dart';

class VoucherBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [
      Bind.lazyPut<VoucherController>(() => VoucherController()),
    ];
  }
}
