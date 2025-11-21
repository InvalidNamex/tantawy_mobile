import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../services/cache_manager.dart';
import '../services/storage_service.dart';
import 'logger.dart';

/// Custom Dio interceptor to handle 429 rate limit errors gracefully
/// Falls back to cached data when rate limited
class RateLimitInterceptor extends Interceptor {
  final CacheManager _cacheManager = getx.Get.find<CacheManager>();
  final StorageService _storageService = getx.Get.find<StorageService>();

  // Track last notification time to prevent spam
  static DateTime? _lastNotificationTime;
  static const Duration _notificationCooldown = Duration(seconds: 10);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 429 Rate Limit errors
    if (err.response?.statusCode == 429) {
      logger.w('🚦 Rate limit hit for: ${err.requestOptions.path}');

      // Try to use cached response
      final cacheKey = _getCacheKey(err.requestOptions);
      final cachedData = _cacheManager.get<Map<String, dynamic>>(cacheKey);

      if (cachedData != null) {
        logger.i('✅ Using cached data for rate-limited request');

        // Create a successful response from cached data
        final response = Response(
          requestOptions: err.requestOptions,
          data: cachedData,
          statusCode: 200,
          headers: Headers.fromMap({
            'x-from-cache': ['true'],
            'x-cache-age': ['${_cacheManager.getCacheAge(cacheKey)}'],
          }),
        );

        // Silently use cached data - no notification needed
        return handler.resolve(response);
      } else {
        logger.w('⚠️ No cached data available for rate-limited request');

        // Try to use Hive storage as ultimate fallback
        final fallbackData = _getFallbackData(err.requestOptions.path);
        if (fallbackData != null) {
          logger.i('✅ Using Hive storage fallback data');

          final response = Response(
            requestOptions: err.requestOptions,
            data: fallbackData,
            statusCode: 200,
            headers: Headers.fromMap({
              'x-from-storage': ['true'],
            }),
          );

          // Silently use fallback data - no notification needed
          return handler.resolve(response);
        }

        // Only show notification if no cache/fallback available AND cooldown expired
        _showRateLimitNotificationIfNeeded();
      }
    }

    // Handle authentication errors (401/403)
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      logger.w('🔐 Authentication error detected');
      // Let the auth controller handle this
    }

    // Continue with error
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Cache successful responses for GET requests
    if (response.requestOptions.method == 'GET' && response.statusCode == 200) {
      final cacheKey = _getCacheKey(response.requestOptions);

      // Determine cache duration based on endpoint
      final cacheDuration = _getCacheDuration(response.requestOptions.path);

      if (response.data != null) {
        _cacheManager.set(cacheKey, response.data, ttl: cacheDuration);
        logger.d('💾 Cached response for: ${response.requestOptions.path}');
      }
    }

    handler.next(response);
  }

  /// Generate cache key from request options
  String _getCacheKey(RequestOptions options) {
    final path = options.path;
    final queryParams = options.queryParameters.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return queryParams.isEmpty ? path : '$path?$queryParams';
  }

  /// Get appropriate cache duration for different endpoints
  Duration _getCacheDuration(String path) {
    if (path.contains('visit-plans')) {
      // Visit plans change less frequently - cache longer
      return const Duration(minutes: 10);
    } else if (path.contains('items') || path.contains('price-list')) {
      // Product/price data - cache for 15 minutes
      return const Duration(minutes: 15);
    } else if (path.contains('invoices') || path.contains('transactions')) {
      // Transaction data - shorter cache
      return const Duration(minutes: 3);
    }

    // Default cache duration
    return const Duration(minutes: 5);
  }

  /// Get fallback data from Hive storage
  Map<String, dynamic>? _getFallbackData(String path) {
    try {
      if (path.contains('visit-plans')) {
        final customers = _storageService.getCustomers();
        if (customers.isNotEmpty) {
          return {
            'data': {'customers': customers.map((c) => c.toJson()).toList()},
          };
        }
      } else if (path.contains('items')) {
        final items = _storageService.getItems();
        if (items.isNotEmpty) {
          return items.map((i) => i.toJson()).toList() as Map<String, dynamic>?;
        }
      }
    } catch (e) {
      logger.e('Failed to get fallback data: $e');
    }

    return null;
  }

  /// Show user-friendly notification about rate limiting (with throttling)
  void _showRateLimitNotificationIfNeeded() {
    final now = DateTime.now();

    // Check if we're still in cooldown period
    if (_lastNotificationTime != null) {
      final timeSinceLastNotification = now.difference(_lastNotificationTime!);
      if (timeSinceLastNotification < _notificationCooldown) {
        logger.d(
          '🔇 Suppressing rate limit notification (cooldown: ${_notificationCooldown.inSeconds - timeSinceLastNotification.inSeconds}s remaining)',
        );
        return;
      }
    }

    // Update last notification time
    _lastNotificationTime = now;

    // Show subtle, user-friendly message
    getx.Get.snackbar(
      'using_saved_data'.tr,
      'showing_cached_data'.tr,
      duration: const Duration(seconds: 3),
    );

    logger.i('📢 Showed rate limit notification to user');
  }
}
