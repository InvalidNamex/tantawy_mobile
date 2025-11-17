import 'package:get/get.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    // AuthController is now a global permanent singleton initialized in main.dart
    // No need to bind it here
  }
}
