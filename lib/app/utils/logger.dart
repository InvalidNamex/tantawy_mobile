import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../services/sentry_service.dart';

/// Custom logger that automatically sends errors to Sentry
class SentryLogger extends Logger {
  SentryLogger({super.printer, super.filter, super.output, super.level});

  // Flag to prevent infinite loops when Sentry itself logs errors
  static bool _isSendingToSentry = false;

  @override
  void e(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Log to console first
    super.e(message, time: time, error: error, stackTrace: stackTrace);

    // Send to Sentry if there's an error and we're not already in a Sentry operation
    if (error != null && !_isSendingToSentry) {
      _isSendingToSentry = true;
      SentryService.captureException(
        error,
        stackTrace: stackTrace,
        level: SentryLevel.error,
        extras: {
          'message': message.toString(),
          'timestamp': (time ?? DateTime.now()).toIso8601String(),
        },
      ).whenComplete(() {
        _isSendingToSentry = false;
      });
    }
  }

  @override
  void w(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Log to console first
    super.w(message, time: time, error: error, stackTrace: stackTrace);

    // Send warnings with errors to Sentry
    if (error != null && !_isSendingToSentry) {
      _isSendingToSentry = true;
      SentryService.captureException(
        error,
        stackTrace: stackTrace,
        level: SentryLevel.warning,
        extras: {
          'message': message.toString(),
          'timestamp': (time ?? DateTime.now()).toIso8601String(),
        },
      ).whenComplete(() {
        _isSendingToSentry = false;
      });
    }
  }

  @override
  void f(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Log to console first
    super.f(message, time: time, error: error, stackTrace: stackTrace);

    // Send fatal errors to Sentry
    if (error != null && !_isSendingToSentry) {
      _isSendingToSentry = true;
      SentryService.captureException(
        error,
        stackTrace: stackTrace,
        level: SentryLevel.fatal,
        extras: {
          'message': message.toString(),
          'timestamp': (time ?? DateTime.now()).toIso8601String(),
        },
      ).whenComplete(() {
        _isSendingToSentry = false;
      });
    }
  }
}

final logger = SentryLogger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
  ),
);
