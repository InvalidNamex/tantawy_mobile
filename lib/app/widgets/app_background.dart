import 'package:flutter/material.dart';

/// A reusable background widget with gradient background image
/// Automatically uses bg-light.png for light theme and bg.png for dark theme
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool useImage;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  const AppBackground({
    Key? key,
    required this.child,
    this.useImage = true,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine which background image to use based on theme brightness
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final backgroundImage = isDarkTheme 
        ? 'assets/images/bg.png'          // Dark theme background
        : 'assets/images/bg-light.png';   // Light theme background
    
    return Container(
      decoration: useImage
          ? BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: fit,
                alignment: alignment,
              ),
            )
          : null,
      child: child,
    );
  }
}
