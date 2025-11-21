import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../theme/app_colors_extension.dart';
import '../routes/app_routes.dart';

/// Shared bottom navigation bar widget used across all main app screens
/// Provides consistent navigation with curved design and icons
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onIndexChanged;

  const AppBottomNavigation({
    Key? key,
    required this.currentIndex,
    this.onIndexChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationItems = <Widget>[
      Image.asset('assets/images/invoice.png', width: 30, height: 30),
      Image.asset('assets/images/order.png', width: 30, height: 30),
      Image.asset('assets/images/map.png', width: 30, height: 30),
      Image.asset('assets/images/receipt.png', width: 30, height: 30),
      Image.asset('assets/images/fail.png', width: 30, height: 30),
    ];

    return CurvedNavigationBar(
      index: currentIndex,
      items: navigationItems,
      color: context.colors.navBar,
      buttonBackgroundColor: context.colors.primary,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 300),
      onTap: (index) {
        onIndexChanged?.call(index);
        _navigateToTab(index);
      },
      height: 60,
    );
  }

  void _navigateToTab(int index) {
    // Get current route to avoid redundant navigation
    final currentRoute = Get.currentRoute;

    switch (index) {
      case 0:
        if (currentRoute != AppRoutes.invoices) {
          Get.offNamed(AppRoutes.invoices);
        }
        break;
      case 1:
        if (currentRoute != AppRoutes.orders) {
          Get.offNamed(AppRoutes.orders);
        }
        break;
      case 2:
        if (currentRoute != AppRoutes.visitPlan) {
          Get.offNamed(AppRoutes.visitPlan);
        }
        break;
      case 3:
        if (currentRoute != AppRoutes.vouchers) {
          Get.offNamed(AppRoutes.vouchers);
        }
        break;
      case 4:
        if (currentRoute != AppRoutes.negativeVisits) {
          Get.offNamed(AppRoutes.negativeVisits);
        }
        break;
    }
  }
}
