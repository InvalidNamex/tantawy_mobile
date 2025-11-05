import '../models/customer_model.dart';
import '../models/item_model.dart';
import '../models/price_list_detail_model.dart';
import '../providers/api_provider.dart';
import '../../utils/logger.dart';

class DataRepository {
  final ApiProvider _apiProvider = ApiProvider();

  Future<List<CustomerModel>> getActiveVisitPlan() async {
    logger.d('🚀 START: getActiveVisitPlan() called');
    try {
      logger.d('📡 Calling API endpoint...');
      final response = await _apiProvider.getActiveVisitPlan();
      logger.d('✅ API Response received');
      logger.d('📋 Response status: ${response.statusCode}');
      logger.d('📋 Response data type: ${response.data.runtimeType}');
      logger.d('📋 Response data: ${response.data}');
      
      final customers = response.data['data']['customers'] as List;
      logger.d('📊 API Response - Customers List Length: ${customers.length}');
      
      final customerModels = customers.map((json) => CustomerModel.fromJson(json)).toList();
      logger.i('✅ Converted to CustomerModel - List Length: ${customerModels.length}');
      
      return customerModels;
    } catch (e, stackTrace) {
      logger.e('❌ ERROR in getActiveVisitPlan: $e');
      logger.e('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<ItemModel>> getItems() async {
    final response = await _apiProvider.getItems();
    return (response.data as List).map((json) => ItemModel.fromJson(json)).toList();
  }

  Future<List<PriceListDetailModel>> getPriceListDetails(int priceListId) async {
    final response = await _apiProvider.getPriceListDetails(priceListId);
    return (response.data as List).map((json) => PriceListDetailModel.fromJson(json)).toList();
  }

  Future<void> syncData(int agentId) async {
    await _apiProvider.getSalesInvoices(agentId);
    await _apiProvider.getReturnSalesInvoices(agentId);
    await _apiProvider.getReceiveVouchers(agentId);
    await _apiProvider.getPaymentVouchers(agentId);
    await _apiProvider.getNegativeVisits(agentId);
  }
}
