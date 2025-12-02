import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/settings/controllers/settings_controller.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/home/controllers/visit_plan_controller.dart';
import '../services/shorebird_update_service.dart';
import '../theme/app_colors_extension.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final authController = Get.find<AuthController>();
    // Try to find VisitPlanController, if not found use a fallback
    VisitPlanController? visitPlanController;
    try {
      visitPlanController = Get.find<VisitPlanController>();
    } catch (e) {
      // Controller not found, it's ok
    }

    return Drawer(
      backgroundColor: context.colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, visitPlanController),

            Divider(height: 1, color: context.colors.divider),
            _buildDrawerItem(
              context: context,
              icon: Icons.payment,
              title: 'payment_voucher'.tr,
              onTap: () {
                Get.back(); // Close drawer
                Get.toNamed(
                  AppRoutes.voucher,
                  arguments: {'voucherType': AppConstants.voucherTypePayment},
                );
              },
            ),
            Divider(height: 1, color: context.colors.divider),
            _buildDrawerItem(
              context: context,
              icon: Icons.assessment,
              title: 'reports'.tr,
              onTap: () {
                Get.back(); // Close drawer
                Get.toNamed(AppRoutes.reports);
              },
            ),
            Divider(height: 1, color: context.colors.divider),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Sync Button
                  if (visitPlanController != null)
                    Obx(
                      () => _buildDrawerItem(
                        context: context,
                        icon: visitPlanController!.isSyncing.value
                            ? Icons.sync_disabled
                            : Icons.sync,
                        title: 'sync'.tr,
                        trailing: visitPlanController.isSyncing.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    context.colors.primary,
                                  ),
                                ),
                              )
                            : visitPlanController.hasPendingData
                            ? Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: context.colors.error,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                        onTap: visitPlanController.isSyncing.value
                            ? null
                            : visitPlanController.syncData,
                      ),
                    ),

                  SizedBox(height: 8),

                  // Theme Toggle
                  Obx(
                    () => _buildDrawerItem(
                      context: context,
                      icon: settingsController.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      title: 'theme'.tr,
                      trailing: Switch(
                        value: settingsController.isDarkMode,
                        onChanged: (_) => settingsController.toggleTheme(),
                        activeColor: context.colors.primary,
                      ),
                      onTap: settingsController.toggleTheme,
                    ),
                  ),

                  // Language Toggle
                  Obx(
                    () => _buildDrawerItem(
                      context: context,
                      icon: Icons.language,
                      title: 'language'.tr,
                      trailing: Text(
                        settingsController.isArabic ? 'العربية' : 'English',
                        style: TextStyle(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: settingsController.toggleLanguage,
                    ),
                  ),

                  SizedBox(height: 8),

                  // Check for Updates
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.system_update,
                    title: 'check_for_updates'.tr,
                    onTap: () {
                      Get.back(); // Close drawer
                      _checkForUpdates(context);
                    },
                  ),
                ],
              ),
            ),

            // Bottom Section
            Divider(height: 1, color: context.colors.divider),

            // Logout Button
            _buildDrawerItem(
              context: context,
              icon: Icons.logout,
              title: 'logout'.tr,
              iconColor: context.colors.error,
              titleColor: context.colors.error,
              onTap: () {
                Get.back(); // Close drawer
                _showLogoutDialog(context, authController);
              },
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VisitPlanController? controller) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: context.colors.primary.withOpacity(0.2),
            child: Icon(Icons.person, size: 48, color: context.colors.primary),
          ),
          SizedBox(height: 16),
          Text(
            controller?.agentName ?? '',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'app_name'.tr,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? context.colors.onSurface),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? context.colors.onSurface,
          fontSize: 16,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      enabled: onTap != null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  void _checkForUpdates(BuildContext context) {
    try {
      final shorebirdService = Get.find<ShorebirdUpdateService>();

      // Show checking message
      Get.snackbar(
        'checking_for_updates'.tr,
        'please_wait'.tr,
        backgroundColor: context.colors.primary.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        icon: Icon(Icons.sync, color: Colors.white),
      );

      // Check for updates
      shorebirdService.checkForUpdates(showNotification: true);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_check_updates'.tr,
        backgroundColor: context.colors.error.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('logout_confirmation'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: Text('logout'.tr),
          ),
        ],
      ),
    );
  }
}
