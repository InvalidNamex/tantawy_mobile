# Build Instructions

## Prerequisites
- Flutter SDK installed
- Android Studio or VS Code with Flutter extensions
- Android SDK configured

## Setup Steps

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Hive Adapters
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the App
```bash
flutter run
```

## Common Issues

### Hive Adapter Errors
If you see errors about missing `.g.dart` files, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Permission Errors on Android
Make sure AndroidManifest.xml has the required permissions (already added).

### iOS Location Permission
Add the following to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to record visit locations</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to record visit locations</string>
```

## Project Structure
- `lib/app/data/` - Models, providers, repositories
- `lib/app/modules/` - Feature modules (auth, home, invoice, voucher, visit)
- `lib/app/routes/` - Navigation routes
- `lib/app/services/` - Global services (storage, connectivity, location)
- `lib/app/theme/` - App theming
- `lib/app/utils/` - Constants and translations

## Testing
1. First login requires internet connection
2. After login, app works offline
3. Use sync button to upload pending transactions
4. Test with API at http://127.0.0.1:8000/

## Notes
- Default language is Arabic
- Supports light and dark mode
- All transactions are saved locally for offline access
- Pending transactions are marked with a red dot on sync button
