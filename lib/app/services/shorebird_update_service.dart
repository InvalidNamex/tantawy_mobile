import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import '../utils/logger.dart';

/// Service to handle Shorebird code push updates
class ShorebirdUpdateService extends GetxService {
  final _shorebirdCodePush = ShorebirdUpdater();

  // Observable to track if an update is available
  final RxBool isUpdateAvailable = false.obs;
  final RxBool isCheckingForUpdate = false.obs;
  final RxBool isDownloadingUpdate = false.obs;

  /// Check if Shorebird is available on this platform
  Future<bool> isShorebirdAvailable() async {
    try {
      return _shorebirdCodePush.isAvailable;
    } catch (e) {
      logger.e('Error checking Shorebird availability', error: e);
      return false;
    }
  }

  /// Get the current patch number
  Future<int?> getCurrentPatchNumber() async {
    try {
      final patch = await _shorebirdCodePush.readCurrentPatch();
      return patch?.number;
    } catch (e) {
      logger.e('Error getting current patch number', error: e);
      return null;
    }
  }

  /// Check for available updates
  Future<void> checkForUpdates({bool showNotification = true}) async {
    try {
      // Check if Shorebird is available first
      final isAvailable = await isShorebirdAvailable();
      if (!isAvailable) {
        logger.i('Shorebird is not available on this platform');
        return;
      }

      isCheckingForUpdate.value = true;
      logger.i('Checking for Shorebird updates...');

      // Check if an update is available
      final status = await _shorebirdCodePush.checkForUpdate();
      final updateAvailable = status == UpdateStatus.outdated;

      isUpdateAvailable.value = updateAvailable;

      if (updateAvailable) {
        final currentPatch = await getCurrentPatchNumber();
        logger.i('Update available! Current patch: $currentPatch');

        if (showNotification) {
          _showUpdateNotification();
        }
      } else {
        logger.i('No updates available. App is up to date.');
      }
    } catch (e, stackTrace) {
      logger.e('Error checking for updates', error: e, stackTrace: stackTrace);
    } finally {
      isCheckingForUpdate.value = false;
    }
  }

  /// Download and install the available update
  Future<void> downloadAndInstallUpdate() async {
    try {
      if (!isUpdateAvailable.value) {
        logger.w('No update available to download');
        return;
      }

      isDownloadingUpdate.value = true;
      logger.i('Downloading Shorebird update...');

      // Show downloading dialog
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('update_downloading'.tr),
              ],
            ),
            content: Text('update_downloading_message'.tr),
          ),
        ),
        barrierDismissible: false,
      );

      // Download the update
      await _shorebirdCodePush.update();

      logger.i('Update downloaded successfully');

      // Close downloading dialog
      Get.back();

      // Show restart prompt
      _showRestartPrompt();

      isUpdateAvailable.value = false;
    } catch (e, stackTrace) {
      logger.e('Error downloading update', error: e, stackTrace: stackTrace);

      // Close downloading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'error'.tr,
        'update_download_failed'.tr,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isDownloadingUpdate.value = false;
    }
  }

  /// Show notification when update is available
  void _showUpdateNotification() {
    Get.snackbar(
      'update_available'.tr,
      'update_available_message'.tr,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () {
          Get.back(); // Close snackbar
          _showUpdateDialog();
        },
        child: Text(
          'update_now'.tr,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Show dialog asking user to update
  void _showUpdateDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('update_available'.tr),
        content: Text('update_available_dialog_message'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('later'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              downloadAndInstallUpdate();
            },
            child: Text('update_now'.tr),
          ),
        ],
      ),
    );
  }

  /// Show prompt to restart app after update
  void _showRestartPrompt() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text('update_complete'.tr),
          content: Text('update_restart_message'.tr),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back();
                // The update will be applied on next app restart
                // For now, just inform the user
                Get.snackbar(
                  'success'.tr,
                  'update_applied_on_restart'.tr,
                  backgroundColor: Colors.green.withOpacity(0.8),
                  colorText: Colors.white,
                  duration: Duration(seconds: 3),
                );
              },
              child: Text('ok'.tr),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Check for updates on app launch
  Future<void> checkForUpdatesOnLaunch() async {
    // Wait a bit before checking to avoid blocking app startup
    await Future.delayed(Duration(seconds: 2));
    await checkForUpdates(showNotification: true);
  }
}
