import 'package:flutter/material.dart';

/// Reusable loading button widget with circular progress indicator
/// Used for async operations like login, saving invoices, vouchers, and visits
/// Shows a circular progress indicator while loading and disables the button
class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String text;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final Color? progressColor;

  const LoadingButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.width,
    this.height = 50,
    this.textStyle,
    this.progressColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? CircularProgressIndicator(color: progressColor)
            : Text(text, style: textStyle),
      ),
    );
  }
}
