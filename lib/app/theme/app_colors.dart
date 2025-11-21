import 'package:flutter/material.dart';

/// App Color Palette
/// This class defines all colors used in the application
/// Following Material Design 3 best practices with light and dark mode support
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ==================== Primary Colors ====================
  static const Color primaryLight = Color(0xFF66BB6A); // Lighter green
  static const Color primaryDark = Color(
    0xFF66BB6A,
  ); // Lighter green for dark mode

  static const Color primaryContainerLight = Color(0xFFE8F5E9);
  static const Color primaryContainerDark = Color(0xFF1B5E20);

  // ==================== Secondary Colors ====================
  static const Color secondaryLight = Color(0xFF81C784); // Light green
  static const Color secondaryDark = Color(0xFF4CAF50);

  static const Color secondaryContainerLight = Color(0xFFC8E6C9);
  static const Color secondaryContainerDark = Color(0xFF2E7D32);

  // ==================== Background Colors ====================
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // ==================== Error Colors ====================
  static const Color errorLight = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFEF5350);

  static const Color errorContainerLight = Color(0xFFFFCDD2);
  static const Color errorContainerDark = Color(0xFFB71C1C);

  // ==================== Text Colors ====================
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF000000);

  static const Color onSecondaryLight = Color(0xFF000000);
  static const Color onSecondaryDark = Color(0xFFFFFFFF);

  static const Color onBackgroundLight = Color(0xFF000000);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);

  static const Color onSurfaceLight = Color(0xFF000000);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);

  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color onErrorDark = Color(0xFF000000);

  // ==================== Outline Colors ====================
  static const Color outlineLight = Color(0xFFBDBDBD);
  static const Color outlineDark = Color(0xFF616161);

  static const Color outlineVariantLight = Color(0xFFE0E0E0);
  static const Color outlineVariantDark = Color(0xFF424242);

  // ==================== Custom Semantic Colors ====================
  /// Success color (for positive actions, confirmations)
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF66BB6A);

  /// Warning color (for alerts, warnings)
  static const Color warningLight = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFFFB74D);

  /// Info color (for information messages)
  static const Color infoLight = Color(0xFF2196F3);
  static const Color infoDark = Color(0xFF42A5F5);

  // ==================== Navigation Colors ====================
  static const Color navBarLight = Color(0xFFFFFFFF);
  static const Color navBarDark = Color(0xFF1E1E1E);

  static const Color navBarActiveLight = Color(0xFF4CAF50);
  static const Color navBarActiveDark = Color(0xFF66BB6A);

  static const Color navBarInactiveLight = Color(0xFF9E9E9E);
  static const Color navBarInactiveDark = Color(0xFF757575);

  // ==================== Shadow Colors ====================
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowDark = Color(0x3F000000);

  // ==================== Divider Colors ====================
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  // ==================== Disabled Colors ====================
  static const Color disabledLight = Color(0xFFBDBDBD);
  static const Color disabledDark = Color(0xFF616161);

  // ==================== Indicator Colors ====================
  static const Color pendingIndicatorLight = Color(0xFFD32F2F);
  static const Color pendingIndicatorDark = Color(0xFFEF5350);

  static const Color syncingIndicatorLight = Color(0xFF2196F3);
  static const Color syncingIndicatorDark = Color(0xFF42A5F5);

  // ==================== Card Colors ====================
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);

  // ==================== AppBar Colors ====================
  static const Color appBarLight = Color(0xFF4CAF50);
  static const Color appBarDark = Color(0xFF1B5E20);

  static const Color appBarForegroundLight = Color(0xFFFFFFFF);
  static const Color appBarForegroundDark = Color(0xFFFFFFFF);

  // ==================== Placeholder Colors ====================
  static const Color placeholderIconLight = Color(0xFFBDBDBD);
  static const Color placeholderIconDark = Color(0xFF757575);

  static const Color placeholderTextLight = Color(0xFF757575);
  static const Color placeholderTextDark = Color(0xFF9E9E9E);

  static const Color placeholderTitleLight = Color(0xFF616161);
  static const Color placeholderTitleDark = Color(0xFFBDBDBD);
}
