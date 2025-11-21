import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/storage_service.dart';

class SettingsController extends GetxController {
  final _storage = Get.find<StorageService>();

  // Theme mode
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  // Language
  final RxString currentLocale = 'ar'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    // Load theme mode from storage
    final savedTheme = _storage.getThemeMode();
    themeMode.value = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

    // Load locale from storage
    final savedLanguage = _storage.getLanguage();
    currentLocale.value = savedLanguage;

    // Update GetX locale to match saved language
    Get.updateLocale(Locale(savedLanguage));
  }

  void toggleTheme() {
    if (themeMode.value == ThemeMode.light) {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.light;
    }
    Get.changeThemeMode(themeMode.value);
    _saveTheme();
  }

  void toggleLanguage() {
    if (currentLocale.value == 'ar') {
      currentLocale.value = 'en';
      Get.updateLocale(Locale('en'));
    } else {
      currentLocale.value = 'ar';
      Get.updateLocale(Locale('ar'));
    }
    _saveLanguage();
  }

  void _saveTheme() {
    _storage.saveThemeMode(
      themeMode.value == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  void _saveLanguage() {
    _storage.saveLanguage(currentLocale.value);
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;
  bool get isArabic => currentLocale.value == 'ar';
}
