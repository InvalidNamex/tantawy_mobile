import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [
      Bind.lazyPut<AuthController>(() => AuthController()),
    ];
  }
}
