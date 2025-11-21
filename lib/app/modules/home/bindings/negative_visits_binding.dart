import 'package:get/get.dart';
import '../controllers/negative_visits_controller.dart';

class NegativeVisitsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NegativeVisitsController>(() => NegativeVisitsController());
  }
}
