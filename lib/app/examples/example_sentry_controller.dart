import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../services/sentry_service.dart';
import '../utils/sentry_error_handler.dart';
import '../utils/logger.dart';

/// Example controller demonstrating Sentry integration
/// Use this as a reference for integrating Sentry into your controllers
class ExampleSentryController extends GetxController with SentryErrorHandler {
  final RxBool isLoading = false.obs;
  final RxList<String> items = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Add breadcrumb for controller initialization
    SentryService.addBreadcrumb(
      message: 'ExampleSentryController initialized',
      category: 'lifecycle',
      level: SentryLevel.info,
    );
  }

  /// Example 1: Using executeWithSentry for async operations
  Future<void> fetchDataWithSentry() async {
    isLoading.value = true;

    final result = await executeWithSentry<List<String>>(
      operation: () async {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));

        // Simulate potential error
        if (DateTime.now().second % 2 == 0) {
          throw Exception('Random error occurred');
        }

        return ['Item 1', 'Item 2', 'Item 3'];
      },
      operationName: 'fetch_example_data',
      extras: {
        'timestamp': DateTime.now().toIso8601String(),
        'source': 'example_controller',
      },
      fallbackValue: [], // Return empty list on error
    );

    if (result != null) {
      items.value = result;
    }

    isLoading.value = false;
  }

  /// Example 2: Manual exception capture
  Future<void> manualErrorCapture() async {
    try {
      // Some operation that might fail
      await _riskyOperation();
    } catch (e, stackTrace) {
      logger.e('Risky operation failed', error: e, stackTrace: stackTrace);

      // Manually capture the exception with context
      await SentryService.captureException(
        e,
        stackTrace: stackTrace,
        level: SentryLevel.error,
        extras: {
          'operation': 'risky_operation',
          'items_count': items.length,
          'user_action': 'button_click',
        },
      );

      // Show user-friendly error
      Get.snackbar('Error', 'Something went wrong. Please try again.');
    }
  }

  /// Example 3: Adding breadcrumbs for user actions
  void onUserAction(String action) {
    SentryService.addBreadcrumb(
      message: 'User performed action: $action',
      category: 'user_interaction',
      level: SentryLevel.info,
      data: {'action': action, 'timestamp': DateTime.now().toIso8601String()},
    );

    logger.i('User action tracked: $action');
  }

  /// Example 4: Performance monitoring with transactions
  Future<void> performanceMonitoredOperation() async {
    final transaction = SentryService.startTransaction(
      name: 'load_and_process_data',
      operation: 'task',
      description: 'Loading and processing example data',
    );

    try {
      // Step 1: Load data
      final span1 = transaction.startChild(
        'load_data',
        description: 'Loading data from source',
      );
      await Future.delayed(const Duration(seconds: 1));
      await span1.finish(status: const SpanStatus.ok());

      // Step 2: Process data
      final span2 = transaction.startChild(
        'process_data',
        description: 'Processing loaded data',
      );
      await Future.delayed(const Duration(milliseconds: 500));
      await span2.finish(status: const SpanStatus.ok());

      // Step 3: Save data
      final span3 = transaction.startChild(
        'save_data',
        description: 'Saving processed data',
      );
      await Future.delayed(const Duration(milliseconds: 300));
      await span3.finish(status: const SpanStatus.ok());

      transaction.status = const SpanStatus.ok();
      logger.i('Operation completed successfully');
    } catch (e) {
      transaction.status = const SpanStatus.internalError();
      transaction.throwable = e;
      logger.e('Operation failed', error: e);
      rethrow;
    } finally {
      await transaction.finish();
    }
  }

  /// Example 5: Capturing custom messages
  Future<void> captureCustomMessage(String message) async {
    await SentryService.captureMessage(
      message,
      level: SentryLevel.info,
      extras: {
        'items_count': items.length,
        'controller': 'ExampleSentryController',
      },
    );
  }

  /// Example 6: Setting custom tags
  Future<void> setCustomTags() async {
    await SentryService.setTag('feature', 'example');
    await SentryService.setTag('screen', 'example_screen');
  }

  /// Example 7: Setting custom context
  Future<void> setCustomContext() async {
    await SentryService.setContext('operation_context', {
      'items_loaded': items.length,
      'is_loading': isLoading.value,
      'last_action': DateTime.now().toIso8601String(),
    });
  }

  /// Example 8: Synchronous error handling
  void syncOperationWithErrorHandling() {
    final result = executeSync<String>(
      operation: () {
        // Some synchronous operation
        if (items.isEmpty) {
          throw Exception('No items available');
        }
        return items.first;
      },
      operationName: 'get_first_item',
      extras: {'items_count': items.length},
      fallbackValue: 'default_item',
    );

    logger.i('Result: $result');
  }

  // Simulated risky operation
  Future<void> _riskyOperation() async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('This is a simulated error for demonstration');
  }

  @override
  void onClose() {
    // Add breadcrumb for controller disposal
    SentryService.addBreadcrumb(
      message: 'ExampleSentryController disposed',
      category: 'lifecycle',
      level: SentryLevel.info,
    );
    super.onClose();
  }
}
