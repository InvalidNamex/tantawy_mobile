import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../services/sentry_service.dart';

/// Mixin to add Sentry error handling to controllers
mixin SentryErrorHandler {
  /// Wrap async operations with Sentry error handling
  Future<T?> executeWithSentry<T>({
    required Future<T> Function() operation,
    required String operationName,
    Map<String, dynamic>? extras,
    T? fallbackValue,
  }) async {
    final transaction = SentryService.startTransaction(
      name: operationName,
      operation: 'function',
    );

    try {
      SentryService.addBreadcrumb(
        message: 'Starting: $operationName',
        category: 'operation',
      );

      final result = await operation();

      transaction.status = const SpanStatus.ok();
      SentryService.addBreadcrumb(
        message: 'Completed: $operationName',
        category: 'operation',
        level: SentryLevel.info,
      );

      return result;
    } catch (e, stackTrace) {
      transaction.status = const SpanStatus.internalError();
      transaction.throwable = e;

      await SentryService.captureException(
        e,
        stackTrace: stackTrace,
        level: SentryLevel.error,
        extras: {'operation': operationName, ...?extras},
      );

      return fallbackValue;
    } finally {
      await transaction.finish();
    }
  }

  /// Handle errors in synchronous operations
  T? executeSync<T>({
    required T Function() operation,
    required String operationName,
    Map<String, dynamic>? extras,
    T? fallbackValue,
  }) {
    try {
      SentryService.addBreadcrumb(
        message: 'Executing: $operationName',
        category: 'operation',
      );

      return operation();
    } catch (e, stackTrace) {
      SentryService.captureException(
        e,
        stackTrace: stackTrace,
        level: SentryLevel.error,
        extras: {'operation': operationName, ...?extras},
      );

      return fallbackValue;
    }
  }
}

/// Custom error widget with Sentry integration
class SentryErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const SentryErrorWidget({Key? key, required this.errorDetails})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Report to Sentry
    SentryService.captureException(
      errorDetails.exception,
      stackTrace: errorDetails.stack,
      level: SentryLevel.error,
      extras: {
        'context': errorDetails.context?.toString(),
        'library': errorDetails.library,
      },
    );

    return Container(
      color: const Color(0xFFFFE0E0),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'An error occurred. Our team has been notified.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFD32F2F), fontSize: 16),
          ),
        ),
      ),
    );
  }
}

/// Zone error handler
void handleZoneError(Object error, StackTrace stackTrace) {
  SentryService.captureException(
    error,
    stackTrace: stackTrace,
    level: SentryLevel.fatal,
    extras: {'context': 'zone_error'},
  );
}

/// Navigation observer for Sentry breadcrumbs
class SentryNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('pop', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logNavigation('replace', newRoute, oldRoute);
    }
  }

  void _logNavigation(
    String action,
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    final routeName = route.settings.name ?? 'unknown';
    final previousRouteName = previousRoute?.settings.name ?? 'none';

    SentryService.addBreadcrumb(
      message: 'Navigation: $action to $routeName',
      category: 'navigation',
      level: SentryLevel.info,
      data: {'action': action, 'to': routeName, 'from': previousRouteName},
    );
  }
}
