import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/visit_controller.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/loading_button.dart';

class VisitView extends GetView<VisitController> {
  const VisitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('negative_visit'.tr),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: kToolbarHeight + 30),
            Text(
              '${'customer'.tr}: ${controller.customer.customerName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller.notesController,
                maxLines: 7,
                decoration: InputDecoration(
                  labelText: 'notes'.tr,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
            ),
            Spacer(),
            Obx(
              () => LoadingButton(
                isLoading: controller.isLoading.value,
                onPressed: controller.submitVisit,
                text: 'submit'.tr,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
