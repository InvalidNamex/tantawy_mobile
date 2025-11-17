import '../providers/api_provider.dart';
import '../../utils/logger.dart';

class SyncRepository {
  final ApiProvider _apiProvider = ApiProvider();

  /// Syncs pending invoices in a single batch
  /// Throws exception if sync fails - caller should handle cleanup
  Future<void> syncPendingInvoices(List<Map<String, dynamic>> invoices) async {
    if (invoices.isEmpty) return;

    logger.i('🔄 Syncing ${invoices.length} invoices in batch...');
    try {
      final response = await _apiProvider.batchCreateInvoices(invoices);
      logger.i('✅ Batch invoice sync successful: ${response.statusCode}');
    } catch (e) {
      logger.e('❌ Batch invoice sync failed: $e');
      rethrow; // Let caller handle the error
    }
  }

  /// Syncs pending vouchers in a single batch
  /// Throws exception if sync fails - caller should handle cleanup
  Future<void> syncPendingVouchers(List<Map<String, dynamic>> vouchers) async {
    if (vouchers.isEmpty) return;

    logger.i('🔄 Syncing ${vouchers.length} vouchers in batch...');
    try {
      final response = await _apiProvider.batchCreateVouchers(vouchers);
      logger.i('✅ Batch voucher sync successful: ${response.statusCode}');
    } catch (e) {
      logger.e('❌ Batch voucher sync failed: $e');
      rethrow; // Let caller handle the error
    }
  }

  /// Syncs pending visits in a single batch
  /// Throws exception if sync fails - caller should handle cleanup
  Future<void> syncPendingVisits(List<Map<String, dynamic>> visits) async {
    if (visits.isEmpty) return;

    logger.i('🔄 Syncing ${visits.length} visits in batch...');
    try {
      final response = await _apiProvider.batchCreateVisits(visits);
      logger.i('✅ Batch visit sync successful: ${response.statusCode}');
    } catch (e) {
      logger.e('❌ Batch visit sync failed: $e');
      rethrow; // Let caller handle the error
    }
  }
}
