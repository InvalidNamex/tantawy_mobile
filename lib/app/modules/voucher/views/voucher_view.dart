import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/voucher_controller.dart';
import '../../../widgets/app_background.dart';

class VoucherView extends GetView<VoucherController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('voucher'.tr),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'customer'.tr}: ${controller.customer.customerName}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            TextField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'amount'.tr,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'notes'.tr,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),
            SizedBox(height: 16),
            Obx(() => SwitchListTile(
              title: Text(controller.isReceive.value ? 'receive'.tr : 'payment'.tr),
              value: controller.isReceive.value,
              onChanged: (value) => controller.isReceive.value = value,
              secondary: Icon(
                controller.isReceive.value ? Icons.arrow_downward : Icons.arrow_upward,
                color: controller.isReceive.value ? Colors.green : Colors.red,
              ),
            )),
            SizedBox(height: 24),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.submitVoucher,
                child: controller.isLoading.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('submit'.tr),
              ),
            )),
          ],
        ),
      ),
      ),
    );
  }
}
