import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extension on BuildContext to easily access theme-aware colors
/// Usage: context.colors.primary, context.colors.error, etc.
extension AppColorsExtension on BuildContext {
  AppColorsProvider get colors => AppColorsProvider(this);
}

/// Provider class that returns appropriate colors based on current theme
class AppColorsProvider {
  final BuildContext context;

  AppColorsProvider(this.context);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // ==================== Primary Colors ====================
  Color get primary => _isDark ? AppColors.primaryDark : AppColors.primaryLight;
  Color get onPrimary =>
      _isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight;
  Color get primaryContainer => _isDark
      ? AppColors.primaryContainerDark
      : AppColors.primaryContainerLight;

  // ==================== Secondary Colors ====================
  Color get secondary =>
      _isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
  Color get onSecondary =>
      _isDark ? AppColors.onSecondaryDark : AppColors.onSecondaryLight;
  Color get secondaryContainer => _isDark
      ? AppColors.secondaryContainerDark
      : AppColors.secondaryContainerLight;

  // ==================== Background Colors ====================
  Color get background =>
      _isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get surface => _isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get onSurface =>
      _isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;

  // ==================== Error Colors ====================
  Color get error => _isDark ? AppColors.errorDark : AppColors.errorLight;
  Color get onError => _isDark ? AppColors.onErrorDark : AppColors.onErrorLight;
  Color get errorContainer =>
      _isDark ? AppColors.errorContainerDark : AppColors.errorContainerLight;

  // ==================== Outline Colors ====================
  Color get outline => _isDark ? AppColors.outlineDark : AppColors.outlineLight;
  Color get outlineVariant =>
      _isDark ? AppColors.outlineVariantDark : AppColors.outlineVariantLight;

  // ==================== Custom Semantic Colors ====================
  Color get success => _isDark ? AppColors.successDark : AppColors.successLight;
  Color get warning => _isDark ? AppColors.warningDark : AppColors.warningLight;
  Color get info => _isDark ? AppColors.infoDark : AppColors.infoLight;

  // ==================== Navigation Colors ====================
  Color get navBar => _isDark ? AppColors.navBarDark : AppColors.navBarLight;
  Color get navBarActive =>
      _isDark ? AppColors.navBarActiveDark : AppColors.navBarActiveLight;
  Color get navBarInactive =>
      _isDark ? AppColors.navBarInactiveDark : AppColors.navBarInactiveLight;

  // ==================== Shadow Colors ====================
  Color get shadow => _isDark ? AppColors.shadowDark : AppColors.shadowLight;

  // ==================== Divider Colors ====================
  Color get divider => _isDark ? AppColors.dividerDark : AppColors.dividerLight;

  // ==================== Disabled Colors ====================
  Color get disabled =>
      _isDark ? AppColors.disabledDark : AppColors.disabledLight;

  // ==================== Indicator Colors ====================
  Color get pendingIndicator => _isDark
      ? AppColors.pendingIndicatorDark
      : AppColors.pendingIndicatorLight;
  Color get syncingIndicator => _isDark
      ? AppColors.syncingIndicatorDark
      : AppColors.syncingIndicatorLight;

  // ==================== Card Colors ====================
  Color get card => _isDark ? AppColors.cardDark : AppColors.cardLight;

  // ==================== AppBar Colors ====================
  Color get appBar => _isDark ? AppColors.appBarDark : AppColors.appBarLight;
  Color get appBarForeground => _isDark
      ? AppColors.appBarForegroundDark
      : AppColors.appBarForegroundLight;

  // ==================== Placeholder Colors ====================
  Color get placeholderIcon =>
      _isDark ? AppColors.placeholderIconDark : AppColors.placeholderIconLight;
  Color get placeholderText =>
      _isDark ? AppColors.placeholderTextDark : AppColors.placeholderTextLight;
  Color get placeholderTitle => _isDark
      ? AppColors.placeholderTitleDark
      : AppColors.placeholderTitleLight;
}
