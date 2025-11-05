import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/visit_controller.dart';

class VisitView extends GetView<VisitController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('negative_visit'.tr),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'customer'.tr}: ${controller.customer.customerName}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            TextField(
              controller: controller.notesController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'notes'.tr,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),
            SizedBox(height: 16),
            Obx(() => ListTile(
              leading: Icon(Icons.location_on, color: Colors.green),
              title: Text('location'.tr),
              subtitle: Text(controller.location.value),
            )),
            SizedBox(height: 24),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.submitVisit,
                child: controller.isLoading.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('submit'.tr),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
