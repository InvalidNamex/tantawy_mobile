import '../providers/api_provider.dart';

class SyncRepository {
  final ApiProvider _apiProvider = ApiProvider();

  Future<void> syncPendingInvoices(List<Map<String, dynamic>> invoices) async {
    if (invoices.isEmpty) return;
    await _apiProvider.batchCreateInvoices(invoices);
  }

  Future<void> syncPendingVouchers(List<Map<String, dynamic>> vouchers) async {
    if (vouchers.isEmpty) return;
    await _apiProvider.batchCreateVouchers(vouchers);
  }

  Future<void> syncPendingVisits(List<Map<String, dynamic>> visits) async {
    if (visits.isEmpty) return;
    await _apiProvider.batchCreateVisits(visits);
  }
}
