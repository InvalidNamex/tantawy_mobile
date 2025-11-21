import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'api_error_handler.dart';
import 'logger.dart';

/// Utility class to show server error dialogs when there's internet but server issues
class ServerErrorDialog {
  /// Show a dialog indicating the data was saved offline due to server issues
  /// This should only be shown when there is internet connection but server errors occur
  static void showServerErrorSavedOffline({
    required String dataType, // 'invoice', 'voucher', 'visit'
    required dynamic error,
  }) {
    logger.i('🔄 Showing server error dialog for $dataType');

    // Get user-friendly error message
    final errorMessage = ApiErrorHandler.getServerErrorMessage(error);

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('server_error_title'.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              errorMessage,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.offline_pin, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'data_saved_offline'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'will_sync_when_server_available'.tr,
                    style: TextStyle(fontSize: 14, color: Colors.blue.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('ok'.tr),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Show a snackbar for server error offline save (alternative to dialog)
  static void showServerErrorSnackbar({
    required String dataType,
    required dynamic error,
  }) {
    logger.i('🔄 Showing server error snackbar for $dataType');

    // Create message with dataType parameter
    final message = 'server_error_offline_saved'.tr.replaceAll(
      '{0}',
      dataType.tr,
    );

    Get.snackbar(
      'server_error_title'.tr,
      message,
      backgroundColor: Colors.orange.withOpacity(0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 5),
      icon: Icon(Icons.warning_amber_rounded, color: Colors.white),
      shouldIconPulse: true,
      isDismissible: true,
      snackPosition: SnackPosition.bottom,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}
