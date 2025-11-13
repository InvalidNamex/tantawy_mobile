import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/data_repository.dart';
import '../../../services/storage_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/cache_manager.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/logger.dart';
import '../../../utils/api_error_handler.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final DataRepository _dataRepository = DataRepository();
  final StorageService _storage = Get.find<StorageService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final CacheManager _cacheManager = Get.find<CacheManager>();

  final RxBool isLoading = false.obs;

  // Flag to ensure login check runs only once
  bool _hasCheckedLoginStatus = false;

  // Cache key for initial data fetch timestamp
  static const String _lastFetchKey = 'last_initial_data_fetch';

  // Minimum time between data fetches (5 minutes)
  static const Duration _minFetchInterval = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    logger.d('🔧 AuthController initialized');
  }

  @override
  void onReady() {
    super.onReady();
    // Only check login status once on first initialization
    if (!_hasCheckedLoginStatus) {
      _hasCheckedLoginStatus = true;
      _checkLoginStatus();
    }
  }

  void _checkLoginStatus() {
    if (_storage.isLoggedIn) {
      logger.i('⚠️ ALREADY LOGGED IN: User is authenticated');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final hasConnection = await _connectivity.checkConnection();
        if (hasConnection) {
          logger.i(
            '📡 Internet available - checking if data refresh needed...',
          );
          final agent = _storage.getAgent();
          if (agent != null) {
            try {
              // Check if we need to fetch fresh data
              if (_shouldFetchData()) {
                logger.i('🔄 Data is stale - fetching fresh data...');
                await _fetchInitialData(agent.id);
                _recordFetchTime();
                logger.i('✅ Fresh data fetched successfully');
              } else {
                logger.i('✅ Using cached data (still fresh)');
              }
              Get.offAllNamed(AppRoutes.home);
            } catch (e) {
              logger.e('Failed to fetch initial data', error: e);

              // Handle specific error types
              if (ApiErrorHandler.isAuthError(e)) {
                logger.w(
                  '🔐 Authentication failed - credentials may be expired. Logging out...',
                );
                await _storage.clearAgent();
                Get.snackbar('error'.tr, 'session_expired'.tr);
                // Stay on login screen
              } else if (ApiErrorHandler.isRateLimitError(e)) {
                logger.w('🚦 Rate limited - continuing with cached data');
                Get.offAllNamed(AppRoutes.home);
              } else {
                // For other errors, continue to home with cached data
                logger.w('⚠️ Error occurred but continuing with cached data');
                Get.offAllNamed(AppRoutes.home);
              }
            }
          } else {
            Get.offAllNamed(AppRoutes.home);
          }
        } else {
          logger.i('📴 Offline - will load cached data from Hive');
          Get.offAllNamed(AppRoutes.home);
        }
      });
    } else {
      logger.d('✅ Not logged in - will show login screen');
    }
  }

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('error'.tr, 'please_fill_all_fields'.tr);
      return;
    }

    final hasConnection = await _connectivity.checkConnection();
    if (!hasConnection && !_storage.isLoggedIn) {
      Get.dialog(
        AlertDialog(
          title: Text('no_internet'.tr),
          content: Text('no_internet'.tr),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('retry'.tr)),
          ],
        ),
      );
      return;
    }

    if (!hasConnection && _storage.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
      return;
    }

    try {
      isLoading.value = true;
      logger.i('Attempting login for user: $username');
      logger.d('🔑 LOGIN: Starting login process...');

      final agent = await _authRepository.login(username, password);
      logger.i('✅ LOGIN: Agent authenticated - ${agent.name}');

      await _storage.saveAgent(agent);
      logger.d('💾 LOGIN: Agent saved to storage');

      // Fetch initial data - if this fails, still allow login but show warning
      try {
        logger.d('📥 LOGIN: Starting _fetchInitialData...');
        await _fetchInitialData(agent.id);
        _recordFetchTime();
        logger.i('Login successful for agent: ${agent.name}');
        logger.i('✅ LOGIN: Initial data fetch completed successfully');
      } catch (dataError, dataStackTrace) {
        logger.e('❌ LOGIN ERROR: Failed to fetch initial data - $dataError');
        logger.e(
          'Failed to fetch initial data, but login successful',
          error: dataError,
          stackTrace: dataStackTrace,
        );

        // Show appropriate error message based on error type
        if (ApiErrorHandler.isRateLimitError(dataError)) {
          Get.snackbar('rate_limited'.tr, 'rate_limited_message'.tr);
        } else {
          Get.snackbar('warning'.tr, 'login_sync_failed'.tr);
        }
      }

      logger.d('🏠 LOGIN: Navigating to home screen...');
      Get.offAllNamed(AppRoutes.home);
    } catch (e, stackTrace) {
      logger.e('Login failed', error: e, stackTrace: stackTrace);
      ApiErrorHandler.showErrorSnackbar(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if we should fetch fresh data based on last fetch time
  bool _shouldFetchData() {
    final lastFetch = _cacheManager.get<DateTime>(_lastFetchKey);
    if (lastFetch == null) {
      logger.d('📊 No previous fetch recorded - will fetch data');
      return true;
    }

    final timeSinceLastFetch = DateTime.now().difference(lastFetch);
    final shouldFetch = timeSinceLastFetch > _minFetchInterval;

    if (shouldFetch) {
      logger.d(
        '📊 Last fetch was ${timeSinceLastFetch.inMinutes}m ago - data is stale',
      );
    } else {
      logger.d(
        '📊 Last fetch was ${timeSinceLastFetch.inSeconds}s ago - data is fresh',
      );
    }

    return shouldFetch;
  }

  void _recordFetchTime() {
    _cacheManager.set(
      _lastFetchKey,
      DateTime.now(),
      ttl: const Duration(days: 1),
    );
    logger.d('⏰ Recorded fetch time: ${DateTime.now()}');
  }

  Future<void> _fetchInitialData(int agentId) async {
    try {
      logger.d('📊 FETCH: Starting getActiveVisitPlan for agent $agentId...');
      final customers = await _dataRepository.getActiveVisitPlan();
      logger.d(
        '📊 FETCH: Received ${customers.length} customers from repository',
      );

      logger.i('💾 Saving ${customers.length} customers to cache...');
      await _storage.saveCustomers(customers);
      logger.i('✅ Customers saved to cache successfully');

      final items = await _dataRepository.getItems();
      await _storage.saveItems(items);

      for (var customer in customers) {
        if (customer.priceList != null) {
          final priceListDetails = await _dataRepository.getPriceListDetails(
            customer.priceList!.id,
          );
          await _storage.savePriceListDetails(priceListDetails);
        } else {
          logger.w(
            '⚠️ Customer ${customer.customerName} (ID: ${customer.id}) has no price list',
          );
        }
      }

      await _dataRepository.syncData(agentId);
      logger.i('Initial data fetched successfully');
    } catch (e, stackTrace) {
      logger.e('Error fetching initial data', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> logout() async {
    try {
      logger.d('🚪 LOGOUT: Clearing agent data...');
      await _storage.clearAgent();
      logger.i('✅ LOGOUT: Logged out successfully');

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      logger.e('Logout failed', error: e);
      Get.snackbar('error'.tr, '${'failed_to_logout'.tr}: $e');
    }
  }
}
