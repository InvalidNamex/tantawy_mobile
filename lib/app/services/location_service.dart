import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';

class LocationService extends GetxService {
  /// Request location permissions from the user
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestLocationPermission() async {
    logger.i('Checking if location services are enabled...');
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    logger.i('Location services enabled: $serviceEnabled');
    if (!serviceEnabled) {
      return await _showLocationServiceDialog();
    }

    logger.i('Checking current permission status...');
    // Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();
    logger.i('Current permission: $permission');

    if (permission == LocationPermission.denied) {
      logger.i('Permission denied, requesting...');
      // Request permission
      permission = await Geolocator.requestPermission();
      logger.i('Permission after request: $permission');
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'location_permission_denied'.tr,
          'location_required_for_transactions'.tr,
          duration: Duration(seconds: 4),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      logger.w('Permission denied forever');
      // Permissions are permanently denied
      return await _showPermissionDeniedDialog();
    }

    logger.i('Location permission granted');
    return true;
  }

  /// Show dialog when location services are disabled
  Future<bool> _showLocationServiceDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('location_service_disabled'.tr),
        content: Text('please_enable_location_services'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(result: true);
              await Geolocator.openLocationSettings();
            },
            child: Text('open_settings'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  /// Show dialog when location permission is permanently denied
  Future<bool> _showPermissionDeniedDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('location_permission_denied'.tr),
        content: Text('please_enable_location_in_settings'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(result: true);
              await Geolocator.openAppSettings();
            },
            child: Text('open_settings'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  /// Check if location permission is granted without requesting
  Future<bool> hasLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Get current location with permission check
  /// Returns Position if successful, null if permission denied or location unavailable
  Future<Position?> getCurrentLocation() async {
    logger.i('getCurrentLocation called');
    // Check and request permission if needed
    bool hasPermission = await requestLocationPermission();
    logger.i('Has permission: $hasPermission');
    if (!hasPermission) return null;

    try {
      logger.i('Attempting to get current position with timeout...');
      final position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ).timeout(
            Duration(seconds: 15),
            onTimeout: () {
              logger.w('Location request timed out');
              Get.snackbar(
                'error'.tr,
                'Location request timed out. Please check GPS is enabled.',
                backgroundColor: Colors.orange.withOpacity(0.8),
                colorText: Colors.white,
                duration: Duration(seconds: 3),
              );
              throw Exception('Location timeout');
            },
          );
      logger.i(
        'Position obtained: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      logger.e('Error getting location: $e');
      Get.snackbar(
        'error'.tr,
        'Cannot get location: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return null;
    }
  }
}
