# Sentry Quick Reference Card

## 🚀 Common Operations

### 1. Capture an Exception
```dart
try {
  // risky code
} catch (e, stackTrace) {
  await SentryService.captureException(
    e,
    stackTrace: stackTrace,
    level: SentryLevel.error,
    extras: {'context': 'operation_name'},
  );
}
```

### 2. Capture a Message
```dart
await SentryService.captureMessage(
  'Important event occurred',
  level: SentryLevel.info,
);
```

### 3. Add Breadcrumb
```dart
SentryService.addBreadcrumb(
  message: 'User action description',
  category: 'user_interaction',
  level: SentryLevel.info,
);
```

### 4. Set User Context
```dart
await SentryService.setUser(
  id: userId,
  username: username,
  extras: {'key': 'value'},
);
```

### 5. Clear User Context
```dart
await SentryService.clearUser();
```

### 6. Start Transaction
```dart
final transaction = SentryService.startTransaction(
  name: 'operation_name',
  operation: 'task',
);

try {
  // operation
  transaction.status = const SpanStatus.ok();
} catch (e) {
  transaction.status = const SpanStatus.internalError();
  rethrow;
} finally {
  await transaction.finish();
}
```

### 7. Use Error Handler Mixin
```dart
class MyController extends GetxController with SentryErrorHandler {
  Future<void> fetchData() async {
    await executeWithSentry<Data>(
      operation: () async => await api.getData(),
      operationName: 'fetch_data',
      fallbackValue: null,
    );
  }
}
```

### 8. Set Custom Tags
```dart
await SentryService.setTag('feature', 'checkout');
```

### 9. Set Custom Context
```dart
await SentryService.setContext('order', {
  'order_id': '12345',
  'amount': 100.0,
});
```

## 📝 Sentry Levels

- `SentryLevel.fatal` - Critical errors
- `SentryLevel.error` - Errors
- `SentryLevel.warning` - Warnings
- `SentryLevel.info` - Information
- `SentryLevel.debug` - Debug info

## 📂 Key Files

- `lib/app/services/sentry_service.dart` - Main service
- `lib/app/utils/sentry_error_handler.dart` - Helper utilities
- `lib/main.dart` - Initialization
- `SENTRY_INTEGRATION.md` - Full documentation
- `lib/app/examples/example_sentry_controller.dart` - Examples

## 🔗 Links

- **Dashboard**: https://de.sentry.io/organizations/casatek/projects/flutter/
- **Docs**: https://docs.sentry.io/platforms/flutter/
