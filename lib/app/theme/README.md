# Theme System Documentation

## Overview
This app uses a comprehensive theming system with support for both light and dark modes, following Material Design 3 best practices.

## File Structure
```
lib/app/theme/
├── app_colors.dart           # Color palette definitions
├── app_colors_extension.dart # BuildContext extension for easy access
└── app_theme.dart            # Theme configurations
```

## Usage

### 1. Using Theme-Aware Colors (Recommended)
Use the `context.colors` extension to automatically get the right color based on the current theme:

```dart
import 'package:flutter/material.dart';
import '../../../theme/app_colors_extension.dart';

Widget build(BuildContext context) {
  return Container(
    color: context.colors.primary,  // Automatically uses light or dark color
    child: Text(
      'Hello',
      style: TextStyle(color: context.colors.onPrimary),
    ),
  );
}
```

### 2. Using Direct Color Values
For specific cases where you need a fixed color regardless of theme:

```dart
import '../../../theme/app_colors.dart';

Container(
  color: AppColors.primaryLight,  // Always uses light green
)
```

### 3. Using Theme Colors
Access colors through the Material theme:

```dart
Container(
  color: Theme.of(context).colorScheme.primary,
)
```

## Available Colors

### Semantic Colors
- `primary` / `onPrimary` - Main brand color
- `secondary` / `onSecondary` - Secondary accent color
- `error` / `onError` - Error states
- `success` - Success states (green)
- `warning` - Warning states (orange)
- `info` - Information states (blue)

### Surface Colors
- `surface` / `onSurface` - Card and surface backgrounds
- `background` - Screen backgrounds
- `card` - Card backgrounds

### Navigation Colors
- `navBar` - Navigation bar background
- `navBarActive` - Active navigation item
- `navBarInactive` - Inactive navigation item

### UI Element Colors
- `outline` - Borders and dividers
- `divider` - Divider lines
- `disabled` - Disabled states
- `shadow` - Shadow colors

### Placeholder Colors
- `placeholderIcon` - Placeholder icons
- `placeholderText` - Placeholder text
- `placeholderTitle` - Placeholder titles

### Indicator Colors
- `pendingIndicator` - Pending data indicator (red)
- `syncingIndicator` - Syncing indicator (blue)

## Color Palette

### Light Mode
- Primary: `#4CAF50` (Green)
- Background: `#FAFAFA`
- Surface: `#FFFFFF`
- Error: `#D32F2F` (Red)

### Dark Mode
- Primary: `#66BB6A` (Lighter Green)
- Background: `#121212`
- Surface: `#1E1E1E`
- Error: `#EF5350` (Lighter Red)

## Best Practices

1. **Always use `context.colors`** for theme-aware colors
2. **Never hardcode colors** like `Colors.green` or `Color(0xFF...)` in widgets
3. **Use semantic names** (e.g., `error`, `success`) instead of color names (e.g., `red`, `green`)
4. **Test in both themes** to ensure proper contrast and visibility
5. **Use `AppColors` directly** only for constants that shouldn't change with theme

## Adding New Colors

1. Add the color to `app_colors.dart`:
```dart
static const Color customLight = Color(0xFF...);
static const Color customDark = Color(0xFF...);
```

2. Add getter to `app_colors_extension.dart`:
```dart
Color get custom => _isDark ? AppColors.customDark : AppColors.customLight;
```

3. Use in your widgets:
```dart
Container(color: context.colors.custom)
```

## Changing Theme Mode

The app currently uses light mode by default. To enable dark mode or system theme:

Edit `lib/main.dart`:
```dart
GetMaterialApp(
  themeMode: ThemeMode.system,  // or ThemeMode.dark
  // ...
)
```

Options:
- `ThemeMode.light` - Always light
- `ThemeMode.dark` - Always dark
- `ThemeMode.system` - Follow system settings
