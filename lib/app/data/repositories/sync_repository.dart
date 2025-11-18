import '../providers/api_provider.dart';
import '../../utils/logger.dart';
import '../../utils/auth_session_manager.dart';

class SyncRepository {
  final ApiProvider _apiProvider = ApiProvider();

  /// Syncs pending invoices in a single batch
  /// Throws exception if sync fails - caller should handle cleanup
  /// For authentication errors, handles logout and re-login automatically
  Future<void> syncPendingInvoices(List<Map<String, dynamic>> invoices) async {
    if (invoices.isEmpty) return;

    logger.i('🔄 Syncing ${invoices.length} invoices in batch...');
    try {
      final response = await _apiProvider.batchCreateInvoices(invoices);
      logger.i('✅ Batch invoice sync successful: ${response.statusCode}');
    } catch (e) {
      logger.e('❌ Batch invoice sync failed: $e');

      // Check for authentication errors and handle them
      if (AuthSessionManager.isAuthenticationError(e)) {
        logger.w(
          '🔐 Authentication failed during invoice sync - handling logout',
        );
        await AuthSessionManager.handleAuthenticationFailure(
          customMessage:
              'Session expired during sync. Please login again to continue syncing invoices.',
        );
        return; // Don't rethrow for auth errors
      }

      rethrow; // Let caller handle the error for non-auth errors
    }
  }

  /// Syncs pending vouchers in a single batch
  /// Throws exception if sync fails - caller should handle cleanup
  /// For authentication errors, handles logout and re-login automatically
  Future<void> syncPendingVouchers(List<Map<String, dynamic>> vouchers) async {
    if (vouchers.isEmpty) return;

    logger.i('🔄 Syncing ${vouchers.length} vouchers in batch...');
    try {
      final response = await _apiProvider.batchCreateVouchers(vouchers);
      logger.i('✅ Batch voucher sync successful: ${response.statusCode}');
    } catch (e) {
      logger.e('❌ Batch voucher sync failed: $e');

      // Check for authentication errors and handle them
      if (AuthSessionManager.isAuthenticationError(e)) {
        logger.w(
          '🔐 Authentication failed during voucher sync - handling logout',
        );
        await AuthSessionManager.handleAuthenticationFailure(
          customMessage:
              'Session expired during sync. Please login again to continue syncing vouchers.',
        );
        return; // Don't rethrow for auth errors
      }

      rethrow; // Let caller handle the error for non-auth errors
    }
  }

  /// Syncs pending visits in a single batch
  /// Throws exception if sync fails - caller should handle cleanup
  /// For authentication errors, handles logout and re-login automatically
  Future<void> syncPendingVisits(List<Map<String, dynamic>> visits) async {
    if (visits.isEmpty) return;

    logger.i('🔄 Syncing ${visits.length} visits in batch...');
    try {
      final response = await _apiProvider.batchCreateVisits(visits);
      logger.i('✅ Batch visit sync successful: ${response.statusCode}');
    } catch (e) {
      logger.e('❌ Batch visit sync failed: $e');

      // Check for authentication errors and handle them
      if (AuthSessionManager.isAuthenticationError(e)) {
        logger.w(
          '🔐 Authentication failed during visit sync - handling logout',
        );
        await AuthSessionManager.handleAuthenticationFailure(
          customMessage:
              'Session expired during sync. Please login again to continue syncing visits.',
        );
        return; // Don't rethrow for auth errors
      }

      rethrow; // Let caller handle the error for non-auth errors
    }
  }
}
