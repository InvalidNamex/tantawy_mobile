import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/utils/translations.dart';
import 'app/services/dependency_injection.dart';
import 'app/modules/settings/controllers/settings_controller.dart';
import 'app/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await DependencyInjection.init();
  } catch (e, stackTrace) {
    logger.e(
      'Failed to initialize dependencies',
      error: e,
      stackTrace: stackTrace,
    );
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Tantawy',
        translations: AppTranslations(),
        locale: Locale(settingsController.currentLocale.value),
        fallbackLocale: Locale('en'),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settingsController.themeMode.value,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
