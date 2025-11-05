import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/data_repository.dart';
import '../../../services/storage_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/logger.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final DataRepository _dataRepository = DataRepository();
  final StorageService _storage = Get.find<StorageService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    if (_storage.isLoggedIn) {
      logger.i('⚠️ ALREADY LOGGED IN: User is authenticated');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final hasConnection = await _connectivity.checkConnection();
        if (hasConnection) {
          logger.i('📡 Internet available - fetching initial data...');
          final agent = _storage.getAgent();
          if (agent != null) {
            try {
              await _fetchInitialData(agent.id);
              logger.i('✅ Initial data fetched successfully');
              Get.offAllNamed(AppRoutes.home);
            } catch (e) {
              logger.e('Failed to fetch initial data', error: e);
              // Check if it's an authentication error (401)
              if (e.toString().contains('401') || e.toString().contains('INVALID_CREDENTIALS')) {
                logger.w('🔐 Authentication failed - credentials may be expired. Logging out...');
                await _storage.clearAgent();
                Get.snackbar('error'.tr, 'Session expired. Please login again.');
                // Stay on login screen
              } else {
                // For other errors, continue to home with cached data
                logger.w('Continuing to home with cached data');
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

  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('error'.tr, 'Please fill all fields');
      return;
    }

    final hasConnection = await _connectivity.checkConnection();
    if (!hasConnection && !_storage.isLoggedIn) {
      Get.dialog(
        AlertDialog(
          title: Text('no_internet'.tr),
          content: Text('no_internet'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('retry'.tr),
            ),
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
      logger.i('Attempting login for user: ${usernameController.text}');
      logger.d('🔑 LOGIN: Starting login process...');
      
      final agent = await _authRepository.login(
        usernameController.text,
        passwordController.text,
      );
      logger.i('✅ LOGIN: Agent authenticated - ${agent.name}');
      
      await _storage.saveAgent(agent);
      logger.d('💾 LOGIN: Agent saved to storage');
      
      // Fetch initial data - if this fails, still allow login but show warning
      try {
        logger.d('📥 LOGIN: Starting _fetchInitialData...');
        await _fetchInitialData(agent.id);
        logger.i('Login successful for agent: ${agent.name}');
        logger.i('✅ LOGIN: Initial data fetch completed successfully');
      } catch (dataError, dataStackTrace) {
        logger.e('❌ LOGIN ERROR: Failed to fetch initial data - $dataError');
        logger.e('Failed to fetch initial data, but login successful', 
                 error: dataError, stackTrace: dataStackTrace);
        Get.snackbar('warning'.tr, 'Login successful but data sync failed. You can sync later.');
      }
      
      logger.d('🏠 LOGIN: Navigating to home screen...');
      Get.offAllNamed(AppRoutes.home);
    } catch (e, stackTrace) {
      logger.e('Login failed', error: e, stackTrace: stackTrace);
      Get.snackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchInitialData(int agentId) async {
    try {
      logger.d('📊 FETCH: Starting getActiveVisitPlan for agent $agentId...');
      final customers = await _dataRepository.getActiveVisitPlan();
      logger.d('📊 FETCH: Received ${customers.length} customers from repository');
      
      logger.i('💾 Saving ${customers.length} customers to cache...');
      await _storage.saveCustomers(customers);
      logger.i('✅ Customers saved to cache successfully');

      final items = await _dataRepository.getItems();
      await _storage.saveItems(items);

      for (var customer in customers) {
        final priceListDetails = await _dataRepository.getPriceListDetails(customer.priceList.id);
        await _storage.savePriceListDetails(priceListDetails);
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
      Get.snackbar('error'.tr, 'Failed to logout: $e');
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
