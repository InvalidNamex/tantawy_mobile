import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/visit_model.dart';
import '../../../services/storage_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/location_service.dart';
import '../../../data/providers/api_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/logger.dart';

class VisitController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final LocationService _locationService = Get.put(LocationService());
  final ApiProvider _apiProvider = ApiProvider();

  late CustomerModel customer;
  
  final notesController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxString location = ''.obs;

  @override
  void onInit() {
    super.onInit();
    customer = Get.arguments['customer'];
    _getLocation();
  }

  Future<void> _getLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      location.value = '${position.latitude}, ${position.longitude}';
    } else {
      location.value = 'Location unavailable';
    }
  }

  Future<void> submitVisit() async {
    if (notesController.text.isEmpty) {
      Get.snackbar('error'.tr, 'Please enter notes');
      return;
    }

    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      Get.snackbar('error'.tr, 'Cannot get location');
      return;
    }

    final visit = VisitModel(
      transType: AppConstants.transTypeNegativeVisit,
      customerVendor: customer.id,
      date: DateTime.now().toIso8601String(),
      latitude: position.latitude,
      longitude: position.longitude,
      notes: notesController.text,
    );

    final hasConnection = await _connectivity.checkConnection();

    try {
      isLoading.value = true;
      logger.i('Submitting visit for customer: ${customer.customerName}');

      if (hasConnection) {
        await _apiProvider.batchCreateVisits([visit.toJson()]);
        logger.i('Visit recorded successfully online');
        Get.snackbar('success'.tr, 'Visit recorded successfully');
      } else {
        await _storage.addPendingVisit(visit.toJson());
        logger.i('Visit saved offline for sync');
        Get.snackbar('offline_mode'.tr, 'Visit saved for sync');
      }

      Get.back();
    } catch (e, stackTrace) {
      logger.e('Failed to submit visit', error: e, stackTrace: stackTrace);
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
