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
            SizedBox(height: 10),
            // Location display with refresh button
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[700]),
                  SizedBox(width: 5),
                  Text(
                    controller.location.value.isEmpty
                        ? 'Getting location...'
                        : controller.location.value,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  SizedBox(width: 5),
                  IconButton(
                    icon: Icon(Icons.refresh, size: 20),
                    onPressed: controller.refreshLocation,
                    tooltip: 'Refresh location',
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
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
