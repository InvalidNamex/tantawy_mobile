import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'logger.dart';

/// Centralized API error handling with user-friendly messages
class ApiErrorHandler {
  /// Handle Dio errors and return user-friendly messages
  static String handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }

    logger.e('❌ Unknown error: $error');
    return 'An unexpected error occurred. Please try again.';
  }

  /// Handle specific Dio exception types
  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        logger.w('⏱️ Timeout error: ${error.message}');
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.connectionError:
        logger.w('📡 Connection error: ${error.message}');
        return 'No internet connection. Please check your network.';

      case DioExceptionType.cancel:
        logger.w('❌ Request cancelled');
        return 'Request was cancelled.';

      default:
        logger.e('❌ Unexpected error: ${error.message}');
        return 'Something went wrong. Please try again.';
    }
  }

  /// Handle HTTP response errors based on status code
  static String _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    switch (statusCode) {
      case 400:
        logger.w('⚠️ Bad request (400): $data');
        return _extractErrorMessage(
          data,
          'Invalid request. Please check your input.',
        );

      case 401:
        logger.w('🔐 Unauthorized (401): $data');
        return 'Session expired. Please login again.';

      case 403:
        logger.w('🚫 Forbidden (403): $data');
        return 'Access denied. You don\'t have permission.';

      case 404:
        logger.w('🔍 Not found (404): $data');
        return 'Resource not found.';

      case 429:
        return _handle429RateLimit(data);

      case 500:
      case 502:
      case 503:
      case 504:
        logger.e('🔥 Server error ($statusCode): $data');
        return 'Server error. Please try again later.';

      default:
        logger.e('❌ HTTP error ($statusCode): $data');
        return 'Error: ${statusCode ?? 'Unknown'}. Please try again.';
    }
  }

  /// Handle 429 Rate Limit errors with retry information
  static String _handle429RateLimit(dynamic data) {
    logger.w('🚦 Rate limit exceeded (429)');

    if (data is Map && data.containsKey('detail')) {
      final detail = data['detail'].toString();

      // Extract wait time if available
      final regex = RegExp(r'(\d+)\s*seconds');
      final match = regex.firstMatch(detail);

      if (match != null) {
        final seconds = int.parse(match.group(1)!);
        final minutes = (seconds / 60).ceil();

        logger.w('⏰ Rate limit retry available in ${minutes}m');
        return 'Too many requests. Please wait ${minutes} minute${minutes > 1 ? 's' : ''}.';
      }
    }

    return 'Too many requests. Please wait a moment and try again.';
  }

  /// Extract detailed error message from response data
  static String _extractErrorMessage(dynamic data, String fallback) {
    if (data == null) return fallback;

    if (data is Map) {
      // Common error message fields
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('error')) return data['error'].toString();
      if (data.containsKey('detail')) return data['detail'].toString();

      // Handle validation errors
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }
    }

    if (data is String) return data;

    return fallback;
  }

  /// Show user-friendly error snackbar
  static void showErrorSnackbar(dynamic error, {String? title}) {
    final message = handleError(error);
    Get.snackbar(
      title ?? 'error'.tr,
      message,
      duration: const Duration(seconds: 4),
    );
  }

  /// Check if error is a rate limit error
  static bool isRateLimitError(dynamic error) {
    if (error is DioException && error.response?.statusCode == 429) {
      return true;
    }
    return false;
  }

  /// Check if error is an authentication error
  static bool isAuthError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      return statusCode == 401 || statusCode == 403;
    }
    return false;
  }

  /// Check if error is a network error (no internet)
  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout;
    }
    return false;
  }

  /// Check if error is a server error (5xx status codes)
  static bool isServerError(dynamic error) {
    if (error is DioException && error.response?.statusCode != null) {
      final statusCode = error.response!.statusCode!;
      return statusCode >= 500 && statusCode < 600;
    }
    return false;
  }

  /// Check if error indicates we have internet but server issues
  static bool isServerErrorWithInternet(dynamic error) {
    return isServerError(error) && !isNetworkError(error);
  }

  /// Get user-friendly message for server errors
  static String getServerErrorMessage(dynamic error) {
    if (error is DioException && error.response?.statusCode != null) {
      final statusCode = error.response!.statusCode!;
      switch (statusCode) {
        case 500:
          return 'server_internal_error'.tr;
        case 502:
          return 'server_bad_gateway'.tr;
        case 503:
          return 'server_unavailable'.tr;
        case 504:
          return 'server_timeout'.tr;
        default:
          return 'server_error_generic'.tr;
      }
    }
    return 'server_error_generic'.tr;
  }

  /// Handle login-specific errors with detailed messages
  static String handleLoginError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          logger.w('⏱️ Login timeout: ${error.message}');
          return 'login_timeout_message'.tr;

        case DioExceptionType.connectionError:
          logger.w('📡 Login connection error: ${error.message}');
          return 'login_network_error_message'.tr;

        case DioExceptionType.badResponse:
          return _handleLoginResponseError(error);

        case DioExceptionType.cancel:
          logger.w('❌ Login request cancelled');
          return 'Request was cancelled.';

        default:
          logger.e('❌ Unexpected login error: ${error.message}');
          return 'login_unknown_error_message'.tr;
      }
    }

    logger.e('❌ Unknown login error: $error');
    return 'login_unknown_error_message'.tr;
  }

  /// Handle login-specific HTTP response errors
  static String _handleLoginResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    logger.e('🔐 Login response error ($statusCode): $data');

    switch (statusCode) {
      case 400:
        // Invalid credentials or validation error
        final message = _extractErrorMessage(
          data,
          'invalid_username_or_password'.tr,
        );
        logger.w('⚠️ Login bad request (400): $message');
        return message;

      case 401:
        // Unauthorized - invalid username/password
        logger.w('🔐 Unauthorized login (401): Invalid credentials');
        return 'invalid_username_or_password'.tr;

      case 403:
        // Forbidden - account inactive or deleted
        final message = _extractErrorMessage(data, 'Access denied');
        // Check if message mentions inactive or deleted account
        final lowerMessage = message.toLowerCase();
        if (lowerMessage.contains('inactive')) {
          logger.w('🚫 Account inactive (403)');
          return 'account_inactive_message'.tr;
        } else if (lowerMessage.contains('deleted')) {
          logger.w('🚫 Account deleted (403)');
          return 'account_deleted_message'.tr;
        }
        logger.w('🚫 Forbidden (403): Access denied');
        return 'account_inactive_message'.tr;

      case 404:
        logger.w('🔍 Not found (404): User not found');
        return 'invalid_username_or_password'.tr;

      case 429:
        return _handle429RateLimit(data);

      case 500:
      case 502:
      case 503:
      case 504:
        logger.e('🔥 Server error during login ($statusCode): $data');
        return 'login_server_error_message'.tr;

      default:
        logger.e('❌ Unexpected HTTP error during login ($statusCode): $data');
        return 'login_unknown_error_message'.tr;
    }
  }

  /// Show login-specific error dialog or snackbar
  static void showLoginError(dynamic error) {
    final message = handleLoginError(error);

    // Determine title based on error type
    String title = 'login_failed'.tr;
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 400 || statusCode == 404) {
        title = 'invalid_credentials'.tr;
      } else if (statusCode == 403) {
        title = 'account_inactive'.tr;
      } else if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        title = 'login_network_error'.tr;
      } else if (statusCode != null && statusCode >= 500) {
        title = 'login_server_error'.tr;
      }
    }

    Get.snackbar(title, message, duration: const Duration(seconds: 5));
  }
}
