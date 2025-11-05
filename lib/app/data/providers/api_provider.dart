import 'dart:convert';
import 'package:dio/dio.dart';
import '../../utils/constants.dart';
import '../../services/storage_service.dart';
import '../../utils/logger.dart';
import 'package:get/get.dart' as getx;

class ApiProvider {
  late Dio _dio;
  final StorageService _storage = getx.Get.find<StorageService>();

  ApiProvider() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseURL,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final agent = _storage.getAgent();
        if (agent != null) {
          final tokenPreview = agent.token.length > 10 
              ? '${agent.token.substring(0, 10)}...' 
              : '${agent.token}...';
          logger.d('🔑 Agent Details: ID=${agent.id}, Name=${agent.name}, Token=$tokenPreview, StoreID=${agent.storeID}');
          final credentials = base64Encode(utf8.encode('${agent.name}:${agent.token}'));
          options.headers['Authorization'] = 'Basic $credentials';
          logger.d('✅ Auth header added: Basic $credentials');
          logger.d('📤 Decoded: ${agent.name}:$tokenPreview');
        } else {
          logger.w('❌ WARNING: No agent found in storage! Request will be unauthorized');
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        logger.e('❌ API Error: ${error.message}');
        logger.e('❌ Response: ${error.response?.data}');
        return handler.next(error);
      },
    ));
  }

  Future<Response> login(String username, String password) async {
    return await _dio.post('/api/agents/login/', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Response> getActiveVisitPlan() async {
    return await _dio.get('/api/agents/visit-plans/active-with-customers/');
  }

  Future<Response> getItems() async {
    return await _dio.get('/api/items/');
  }

  Future<Response> getPriceListDetails(int priceListId) async {
    return await _dio.get('/api/price-list-details/pricelist/$priceListId/');
  }

  Future<Response> getSalesInvoices(int agentId, {String? dateFrom, String? dateTo, int? customerId}) async {
    final params = <String, dynamic>{'agent_id': agentId, 'invoice_type': 2};
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;
    if (customerId != null) params['customer_vendor'] = customerId;
    return await _dio.get('/api/agents/invoices/', queryParameters: params);
  }

  Future<Response> getReturnSalesInvoices(int agentId, {String? dateFrom, String? dateTo, int? customerId}) async {
    final params = <String, dynamic>{'agent_id': agentId, 'invoice_type': 4};
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;
    if (customerId != null) params['customer_vendor'] = customerId;
    return await _dio.get('/api/agents/invoices/', queryParameters: params);
  }

  Future<Response> getReceiveVouchers(int agentId, {String? dateFrom, String? dateTo}) async {
    final params = <String, dynamic>{'agent_id': agentId, 'transaction_type': 1};
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;
    return await _dio.get('/api/agents/transactions/', queryParameters: params);
  }

  Future<Response> getPaymentVouchers(int agentId, {String? dateFrom, String? dateTo}) async {
    final params = <String, dynamic>{'agent_id': agentId, 'transaction_type': 2};
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;
    return await _dio.get('/api/agents/transactions/', queryParameters: params);
  }

  Future<Response> getNegativeVisits(int agentId, {String? dateFrom, String? dateTo, int? customerId}) async {
    final params = <String, dynamic>{'agent_id': agentId};
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;
    if (customerId != null) params['customer_vendor'] = customerId;
    return await _dio.get('/api/visits/negative/', queryParameters: params);
  }

  Future<Response> batchCreateInvoices(List<Map<String, dynamic>> invoices) async {
    return await _dio.post('/api/invoices/batch-create/', data: {'invoices': invoices});
  }

  Future<Response> batchCreateVouchers(List<Map<String, dynamic>> vouchers) async {
    return await _dio.post('/api/vouchers/batch-create/', data: {'vouchers': vouchers});
  }

  Future<Response> batchCreateVisits(List<Map<String, dynamic>> visits) async {
    return await _dio.post('/api/visits/batch-create/', data: {'visits': visits});
  }
}
