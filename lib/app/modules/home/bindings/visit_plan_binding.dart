import 'package:get/get.dart';
import '../controllers/visit_plan_controller.dart';

class VisitPlanBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VisitPlanController>(() => VisitPlanController());
  }
}
