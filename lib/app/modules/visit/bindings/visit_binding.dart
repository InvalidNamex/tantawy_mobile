import 'package:get/get.dart';
import '../controllers/visit_controller.dart';

class VisitBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [
      Bind.lazyPut<VisitController>(() => VisitController()),
    ];
  }
}
