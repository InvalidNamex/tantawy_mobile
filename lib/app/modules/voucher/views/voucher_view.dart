import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/voucher_controller.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/loading_button.dart';

class VoucherView extends GetView<VoucherController> {
  const VoucherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(controller.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: kToolbarHeight + 24),
              (controller.customerVendorName.isNotEmpty)
                  ? Text(
                      '${'customer'.tr}: ${controller.customerVendorName}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  :
                    //todo: dropdownsearch for customer/vendor selection
                    SizedBox(),
              Spacer(),
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
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Obx(
                  () => LoadingButton(
                    isLoading: controller.isLoading.value,
                    onPressed: controller.submitVoucher,
                    text: 'submit'.tr,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
