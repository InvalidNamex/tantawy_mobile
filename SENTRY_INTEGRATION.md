# Sentry Integration Guide

This document explains the Sentry error tracking and performance monitoring implementation in the Tantawy Mobile app.

## Overview

Sentry is configured to provide comprehensive error tracking, performance monitoring, and user context for the application. The integration includes:

- **Automatic error capture** - Catches unhandled exceptions and errors
- **Performance monitoring** - Tracks app performance and slow operations
- **User context** - Associates errors with specific users
- **Breadcrumbs** - Tracks user actions leading to errors
- **Custom error reporting** - Manual error and message reporting

## Configuration

### Package Dependencies

```yaml
dependencies:
  sentry_flutter: ^9.8.0

dev_dependencies:
  sentry_dart_plugin: ^3.2.0
```

### Environment Variables

The DSN (Data Source Name) is configured in `lib/app/services/sentry_service.dart`:

```dart
static const String _dsn = 'https://bac3ecaaa743ff50043f25920af79309@o4510415561687040.ingest.de.sentry.io/4510415564243024';
```

### Sentry Configuration

Located in `pubspec.yaml`:

```yaml
sentry:
  upload_debug_symbols: true
  upload_source_maps: true
  project: flutter
  org: casatek
```

## Features

### 1. Automatic Error Capture

All unhandled exceptions are automatically captured and sent to Sentry with full stack traces.

### 2. Performance Monitoring

- **Transaction tracking** - Monitor specific operations
- **Trace sampling** - 100% in development, 20% in production
- **Profile sampling** - 10% in production
- **User interaction tracking** - Automatically track user interactions

### 3. User Context

When users log in, their information is associated with error reports:

```dart
await SentryService.setUser(
  id: agent.id.toString(),
  username: agent.username,
  extras: {
    'agent_name': agent.name,
    'store_id': agent.storeID,
  },
);
```

### 4. Breadcrumbs

Track user actions to understand the context of errors:

```dart
SentryService.addBreadcrumb(
  message: 'User clicked submit button',
  category: 'ui',
  level: SentryLevel.info,
);
```

### 5. Screenshots & View Hierarchy

Automatically captures screenshots and view hierarchy when errors occur (configurable).

## Usage Examples

### Manual Exception Reporting

```dart
try {
  // risky operation
} catch (e, stackTrace) {
  await SentryService.captureException(
    e,
    stackTrace: stackTrace,
    level: SentryLevel.error,
    extras: {'context': 'specific_operation'},
  );
}
```

### Capturing Messages

```dart
await SentryService.captureMessage(
  'Important event occurred',
  level: SentryLevel.warning,
  extras: {'user_action': 'completed_checkout'},
);
```

### Transaction Monitoring

```dart
final transaction = SentryService.startTransaction(
  name: 'load_customer_data',
  operation: 'db.query',
  description: 'Loading customer list from database',
);

try {
  // Perform operation
  await loadCustomerData();
  transaction.status = const SpanStatus.ok();
} catch (e) {
  transaction.status = const SpanStatus.internalError();
  transaction.throwable = e;
  rethrow;
} finally {
  await transaction.finish();
}
```

### Using SentryErrorHandler Mixin

Controllers can use the `SentryErrorHandler` mixin for convenient error handling:

```dart
class MyController extends GetxController with SentryErrorHandler {
  Future<void> fetchData() async {
    await executeWithSentry(
      operation: () async {
        // Your async operation
        return await repository.getData();
      },
      operationName: 'fetch_data',
      extras: {'source': 'api'},
      fallbackValue: null,
    );
  }
}
```

## Platform-Specific Configuration

### Android

The Android integration is configured in `android/app/build.gradle.kts`:

```kotlin
plugins {
    id("io.sentry.android.gradle") version "4.17.0"
}

sentry {
    autoProguardConfig = true
    autoUploadProguardMapping = true
    includeSourceContext = true
    includeProguardMapping = true
}
```

### iOS

iOS configuration is handled automatically by the `sentry_flutter` package and the settings in `pubspec.yaml`.

## Best Practices

1. **Set User Context Early** - Set user information as soon as they log in
2. **Clear User Context on Logout** - Remove user data when they log out
3. **Add Breadcrumbs** - Track important user actions
4. **Use Appropriate Log Levels**:
   - `fatal` - Critical errors that require immediate attention
   - `error` - Errors that affect functionality
   - `warning` - Potential issues
   - `info` - General information
   - `debug` - Detailed debugging information

5. **Don't Send PII** - Avoid sending personally identifiable information
6. **Use Custom Tags** - Add relevant tags for filtering:
   ```dart
   await SentryService.setTag('feature', 'checkout');
   ```

7. **Set Custom Context** - Add structured data:
   ```dart
   await SentryService.setContext('order', {
     'order_id': '12345',
     'amount': 100.0,
   });
   ```

## Environment-Based Configuration

The integration automatically adjusts based on the build mode:

- **Debug Mode**:
  - 100% transaction sampling
  - 100% profile sampling
  - Debug logging enabled
  - Detailed error information

- **Production Mode**:
  - 20% transaction sampling
  - 10% profile sampling
  - Production environment tag
  - Optimized for performance

## File Structure

```
lib/app/
├── services/
│   └── sentry_service.dart        # Main Sentry service
├── utils/
│   └── sentry_error_handler.dart  # Error handling utilities and mixins
└── main.dart                       # Sentry initialization
```

## Testing

To test the Sentry integration:

1. **Test Error Capture**:
   ```dart
   await SentryService.captureException(
     Exception('Test exception'),
     hint: 'Testing Sentry integration',
   );
   ```

2. **Test Message Capture**:
   ```dart
   await SentryService.captureMessage(
     'Test message from Tantawy app',
     level: SentryLevel.info,
   );
   ```

3. **Check Sentry Dashboard** - Visit https://de.sentry.io/organizations/casatek/projects/flutter/

## Troubleshooting

### Build Issues

If you encounter build issues:

1. Run `flutter clean`
2. Run `flutter pub get`
3. Rebuild the project

### Missing Debug Symbols

For Android release builds:

```bash
flutter build apk --release
# Debug symbols are automatically uploaded via sentry_dart_plugin
```

### iOS Symbols

iOS debug symbols are automatically handled by the Flutter plugin during build.

## Additional Resources

- [Sentry Flutter Documentation](https://docs.sentry.io/platforms/flutter/)
- [Sentry Performance Monitoring](https://docs.sentry.io/platforms/flutter/performance/)
- [Sentry Dashboard](https://de.sentry.io/organizations/casatek/)

## Support

For issues or questions about the Sentry integration, contact the development team or refer to the Sentry documentation.
