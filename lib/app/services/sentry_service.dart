import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../utils/logger.dart';

/// Service to manage Sentry configuration and error reporting
class SentryService {
  static const String _dsn =
      'https://bac3ecaaa743ff50043f25920af79309@o4510415561687040.ingest.de.sentry.io/4510415564243024';

  /// Initialize Sentry with proper configuration
  static Future<void> initialize(Future<void> Function() appRunner) async {
    await SentryFlutter.init((options) {
      options.dsn = _dsn;

      // Set sample rates based on environment
      options.tracesSampleRate = kDebugMode ? 1.0 : 0.2;
      options.profilesSampleRate = kDebugMode ? 1.0 : 0.1;

      // Configure environment
      options.environment = kDebugMode ? 'development' : 'production';

      // Enable/disable features
      options.enableAutoSessionTracking = true;
      options.enableAutoPerformanceTracing = true;
      options.enableUserInteractionTracing = true;
      options.enableUserInteractionBreadcrumbs = true;
      options.attachScreenshot = true;
      options.screenshotQuality = SentryScreenshotQuality.medium;
      options.attachViewHierarchy = true;

      // Configure breadcrumbs
      options.maxBreadcrumbs = 100;

      // Set release version
      options.release = 'tantawy@1.0.0+1';
      options.dist = '1';

      // Add custom tags
      options.beforeSend = (event, hint) async {
        // Filter out sensitive information
        if (kDebugMode) {
          logger.i('Sentry event: ${event.message}');
        }
        return event;
      };

      // Configure what to send
      options.sendDefaultPii = false; // Don't send personally identifiable info
      options.enableNativeCrashHandling = true;
      options.enableNdkScopeSync = true;

      if (kDebugMode) {
        options.debug = true;
      }
    }, appRunner: appRunner);

    logger.i('Sentry initialized successfully');
  }

  /// Set user context for better error tracking
  static Future<void> setUser({
    required String id,
    String? username,
    String? email,
    Map<String, dynamic>? extras,
  }) async {
    await Sentry.configureScope((scope) {
      scope.setUser(
        SentryUser(id: id, username: username, email: email, data: extras),
      );
    });
    logger.i('Sentry user context set: $id');
  }

  /// Clear user context (e.g., on logout)
  static Future<void> clearUser() async {
    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
    logger.i('Sentry user context cleared');
  }

  /// Add custom breadcrumb for tracking user actions
  static void addBreadcrumb({
    required String message,
    String? category,
    SentryLevel? level,
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        level: level ?? SentryLevel.info,
        data: data,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Capture an exception manually
  static Future<SentryId> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? hint,
    SentryLevel? level,
    Map<String, dynamic>? extras,
  }) async {
    logger.e(
      'Capturing exception: $exception',
      error: exception,
      stackTrace: stackTrace,
    );

    return await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: hint != null ? Hint.withMap({'hint': hint}) : null,
      withScope: (scope) {
        if (level != null) {
          scope.level = level;
        }
        if (extras != null) {
          extras.forEach((key, value) {
            scope.setExtra(key, value);
          });
        }
      },
    );
  }

  /// Capture a message manually
  static Future<SentryId> captureMessage(
    String message, {
    SentryLevel? level,
    Map<String, dynamic>? extras,
  }) async {
    logger.i('Capturing message: $message');

    return await Sentry.captureMessage(
      message,
      level: level ?? SentryLevel.info,
      withScope: (scope) {
        if (extras != null) {
          extras.forEach((key, value) {
            scope.setExtra(key, value);
          });
        }
      },
    );
  }

  /// Start a transaction for performance monitoring
  static ISentrySpan startTransaction({
    required String name,
    required String operation,
    String? description,
  }) {
    addBreadcrumb(
      message: 'Starting transaction: $name',
      category: 'transaction',
      level: SentryLevel.info,
    );

    return Sentry.startTransaction(
      name,
      operation,
      description: description,
      bindToScope: true,
    );
  }

  /// Set a custom tag
  static Future<void> setTag(String key, String value) async {
    await Sentry.configureScope((scope) {
      scope.setTag(key, value);
    });
  }

  /// Set custom context
  static Future<void> setContext(
    String key,
    Map<String, dynamic> context,
  ) async {
    await Sentry.configureScope((scope) {
      scope.setContexts(key, context);
    });
  }

  /// Close Sentry (call when app is closing)
  static Future<void> close() async {
    await Sentry.close();
    logger.i('Sentry closed');
  }
}
