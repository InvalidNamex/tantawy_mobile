import 'package:get/get.dart';
import 'storage_service.dart';
import 'connectivity_service.dart';
import 'cache_manager.dart';
import 'sentry_service.dart';
import '../modules/settings/controllers/settings_controller.dart';
import '../modules/auth/controllers/auth_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    await _initServices();
    _initControllers();
  }

  static Future<void> _initServices() async {
    final storageService = await StorageService().init();
    Get.put(storageService, permanent: true);
    final connectivityService = await ConnectivityService().init();
    Get.put(connectivityService, permanent: true);
    Get.put(CacheManager(), permanent: true);
  }

  static void _initControllers() {
    Get.put(SettingsController(), permanent: true);
    Get.put(AuthController(), permanent: true);
  }
}
