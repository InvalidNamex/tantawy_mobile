import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors_extension.dart';

/// Reusable empty state widget to display when no data is available
/// Shows an icon, message, and optional action button
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  final Color? textColor;
  final double iconSize;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.message,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.textColor,
    this.iconSize = 64.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: iconColor ?? context.colors.placeholderIcon,
                ),
                SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    color: textColor ?? context.colors.placeholderText,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (actionText != null && onAction != null) ...[
                  SizedBox(height: 24),
                  ElevatedButton(onPressed: onAction, child: Text(actionText!)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
