import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/utils/translations.dart';
import 'app/services/storage_service.dart';
import 'app/services/connectivity_service.dart';
import 'app/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final storageService = await StorageService().init();
    Get.put(storageService);
    final connectivityService = await ConnectivityService().init();
    Get.put(connectivityService);
    logger.i('Services initialized successfully');
  } catch (e, stackTrace) {
    logger.e('Failed to initialize services', error: e, stackTrace: stackTrace);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tantawy',
      translations: AppTranslations(),
      locale: Locale('ar'),
      fallbackLocale: Locale('en'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.login,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
