import 'package:get/get.dart';

class AuthBinding extends Binding {
  @override
  List<Bind> dependencies() {
    // AuthController is now a global permanent singleton initialized in main.dart
    // No need to bind it here
    return [];
  }
}
