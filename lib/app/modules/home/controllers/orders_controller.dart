import 'package:get/get.dart';

class OrdersController extends GetxController {
  final RxInt currentIndex = 1.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize data if needed
  }

  @override
  void onReady() {
    super.onReady();
    // Load data when view is ready
  }
}
