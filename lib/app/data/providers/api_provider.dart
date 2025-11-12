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
      headers: {
        'ngrok-skip-browser-warning': 'true', // Skip ngrok browser warning
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Only add auth for endpoints that require it
        final requiresAuth = _requiresAuthentication(options.path);
        
        if (requiresAuth) {
          final agent = _storage.getAgent();
          if (agent != null) {
            logger.d('🔑 Auth required for ${options.path}');
            logger.d('🔑 Agent: ID=${agent.id}, Name=${agent.name}, Username=${agent.username}');
            
            // Create Basic Auth with username:password format (as per API docs)
            final credentials = base64Encode(utf8.encode('${agent.username}:${agent.password}'));
            options.headers['Authorization'] = 'Basic $credentials';
            
            logger.d('✅ Auth header added: Basic $credentials');
            logger.d('📤 Credentials: ${agent.username}:${agent.password}');
          } else {
            logger.w('❌ WARNING: Auth required but no agent found in storage!');
          }
        } else {
          logger.d('ℹ️ No auth required for ${options.path}');
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

  // Determine if endpoint requires authentication based on API docs
  bool _requiresAuthentication(String path) {
    // Endpoints that REQUIRE Basic Auth
    final authRequiredPaths = [
      '/api/agents/visit-plans/active-with-customers/',
      '/api/invoices/batch-create/',
      '/api/vouchers/batch-create/',
      '/api/visits/batch-create/',
    ];
    
    return authRequiredPaths.any((authPath) => path.contains(authPath));
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
