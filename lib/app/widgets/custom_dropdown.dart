import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors_extension.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final Widget? hint;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: hint,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.white.withOpacity(0.9),
              ),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
              dropdownColor: context.colors.surface,
              selectedItemBuilder: (BuildContext context) {
                return items.map<Widget>((DropdownMenuItem<T> item) {
                  return Container(
                    alignment: Alignment.center,
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                      child: item.child,
                    ),
                  );
                }).toList();
              },
              onChanged: onChanged,
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item.value,
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: context.colors.onSurface,
                      fontSize: 16,
                    ),
                    child: item.child,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
