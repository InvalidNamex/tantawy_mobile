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
import '../../../utils/api_error_handler.dart';
import '../../../utils/server_error_dialog.dart';
import '../../../utils/auth_session_manager.dart';

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

  Future<void> refreshLocation() async {
    location.value = 'Getting location...';
    await _getLocation();
  }

  Future<void> submitVisit() async {
    // Validate notes
    if (notesController.text.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'please_enter_notes'.tr,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    logger.i(
      'Starting visit submission for customer: ${customer.customerName}',
    );

    // Check location permission before proceeding
    logger.i('Requesting location permission...');
    bool hasPermission = await _locationService.requestLocationPermission();
    if (!hasPermission) {
      logger.w('Location permission denied');
      isLoading.value = false;
      Get.snackbar(
        'error'.tr,
        'location_permission_required'.tr,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // Get current location
    logger.i('Getting current location...');
    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      logger.w('Could not get current location');
      isLoading.value = false;
      Get.snackbar(
        'error'.tr,
        'cannot_get_location'.tr,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    logger.i('Location acquired: ${position.latitude}, ${position.longitude}');

    // Create visit model
    final visit = VisitModel(
      transType: AppConstants.transTypeNegativeVisit,
      customerVendor: customer.id,
      date: DateTime.now().toIso8601String(),
      latitude: position.latitude,
      longitude: position.longitude,
      notes: notesController.text,
    );

    // Check connectivity
    logger.i('Checking internet connection...');
    final hasConnection = await _connectivity.checkConnection();
    logger.i('Connection status: ${hasConnection ? "Online" : "Offline"}');

    try {
      if (hasConnection) {
        logger.i('Submitting visit online...');
        await _apiProvider.batchCreateVisits([visit.toJson()]);
        logger.i('Visit recorded successfully online');
        Get.snackbar(
          'success'.tr,
          'visit_recorded_successfully'.tr,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        logger.i('Saving visit offline...');
        await _storage.addPendingVisit(visit.toJson());
        logger.i('Visit saved offline for sync');
        Get.snackbar(
          'offline_mode'.tr,
          'visit_saved_for_sync'.tr,
          backgroundColor: Colors.blue.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }

      // Navigate back on success
      Get.back();
      ;
    } catch (e, stackTrace) {
      logger.e('Failed to submit visit', error: e, stackTrace: stackTrace);

      // Check for authentication errors
      if (AuthSessionManager.isAuthenticationError(e)) {
        logger.w('❌ Authentication failed - using AuthSessionManager');
        await AuthSessionManager.handleAuthenticationFailure();
        return;
      }

      // Check if it's a server error with internet connection
      if (hasConnection && ApiErrorHandler.isServerErrorWithInternet(e)) {
        logger.w('🔄 Server error with internet - saving visit offline');

        // Save the visit offline
        await _storage.addPendingVisit(visit.toJson());

        // Show server error dialog
        ServerErrorDialog.showServerErrorSavedOffline(
          dataType: 'visit',
          error: e,
        );

        // Close the visit screen after a brief delay
        Future.delayed(Duration(milliseconds: 1500), () {
          Get.back();
        });
        return;
      }

      // For other errors, show generic error message
      Get.snackbar(
        'error'.tr,
        'Failed to submit visit: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
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
