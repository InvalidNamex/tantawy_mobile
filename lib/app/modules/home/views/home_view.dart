import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Redirect to visit plan by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offNamed(AppRoutes.visitPlan);
    });
    
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
