import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/utils/translations.dart';
import 'app/services/dependency_injection.dart';
import 'app/services/sentry_service.dart';
import 'app/services/shorebird_update_service.dart';
import 'app/modules/settings/controllers/settings_controller.dart';
import 'app/utils/logger.dart';

void main() async {
  await SentryService.initialize(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Preserve native splash until app is ready
    FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

    try {
      await DependencyInjection.init();

      // Add breadcrumb for successful initialization
      SentryService.addBreadcrumb(
        message: 'App dependencies initialized successfully',
        category: 'initialization',
        level: SentryLevel.info,
      );

      // Check for Shorebird updates after initialization
      try {
        final shorebirdService = Get.find<ShorebirdUpdateService>();
        shorebirdService.checkForUpdatesOnLaunch();
      } catch (e) {
        logger.w('Shorebird update check skipped', error: e);
      }
    } catch (e, stackTrace) {
      logger.e(
        'Failed to initialize dependencies',
        error: e,
        stackTrace: stackTrace,
      );

      // Report initialization error to Sentry
      await SentryService.captureException(
        e,
        stackTrace: stackTrace,
        level: SentryLevel.fatal,
        extras: {'context': 'dependency_injection'},
      );
    }

    // Run the app with Sentry error handling
    runApp(SentryWidget(child: MyApp()));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
