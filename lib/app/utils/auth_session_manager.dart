import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';
import 'logger.dart';

/// Centralized authentication session management
/// Handles automatic logout and re-login prompts when authentication fails
class AuthSessionManager {
  static final StorageService _storage = Get.find<StorageService>();

  /// Handle authentication failure by logging out user and prompting re-login
  /// This should be called when API returns 401/403 authentication errors
  static Future<void> handleAuthenticationFailure({
    String? customMessage,
    bool forceLogout = true,
  }) async {
    logger.w('🔐 Authentication failure detected - handling logout');

    try {
      if (forceLogout) {
        // Clear stored credentials
        await _storage.clearAgent();
        logger.i('🗑️ Cleared stored agent credentials');
      }

      // Show authentication failure dialog
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('authentication_failed'.tr),
            ],
          ),
          content: Text(
            customMessage ?? 'session_expired_please_login'.tr,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close dialog
                AuthSessionManager._navigateToLogin();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('login_again'.tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      logger.e('❌ Error handling authentication failure: $e');
      // Fallback - just navigate to login
      AuthSessionManager._navigateToLogin();
    }
  }

  /// Check if an error is an authentication error (401 or 403)
  static bool isAuthenticationError(dynamic error) {
    if (error.toString().contains('403') || error.toString().contains('401')) {
      return true;
    }

    // Check for specific authentication error messages
    final errorString = error.toString().toLowerCase();
    return errorString.contains('authentication') ||
        errorString.contains('unauthorized') ||
        errorString.contains('invalid username') ||
        errorString.contains('invalid password') ||
        errorString.contains('session expired') ||
        errorString.contains('credentials');
  }

  /// Navigate to login screen and clear navigation stack
  static void _navigateToLogin() {
    logger.i('🔄 Navigating to login screen');
    Get.offAllNamed(AppRoutes.login);
  }

  /// Check if user is currently logged in
  static bool get isLoggedIn => _storage.isLoggedIn;

  /// Get current agent if logged in
  static dynamic get currentAgent => _storage.getAgent();
}
