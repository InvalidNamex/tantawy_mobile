import 'package:get/get.dart';
import '../controllers/visit_controller.dart';

class VisitBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VisitController>(() => VisitController());
  }
}
