import 'package:intl/intl.dart';
import '../models/customer_model.dart';
import '../models/item_model.dart';
import '../models/price_list_detail_model.dart';
import '../models/invoice_model.dart';
import '../models/voucher_model.dart';
import '../models/visit_model.dart';
import '../models/stock_model.dart';
import '../models/cash_balance_model.dart';
import '../providers/api_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/logger.dart';
import 'package:get/get.dart';

class DataRepository {
  final ApiProvider _apiProvider = ApiProvider();
  final StorageService _storage = Get.find<StorageService>();

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

      final customerModels = customers
          .map((json) => CustomerModel.fromJson(json))
          .toList();
      logger.i(
        '✅ Converted to CustomerModel - List Length: ${customerModels.length}',
      );

      return customerModels;
    } catch (e, stackTrace) {
      logger.e('❌ ERROR in getActiveVisitPlan: $e');
      logger.e('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<ItemModel>> getItems() async {
    final response = await _apiProvider.getItems();
    return (response.data as List)
        .map((json) => ItemModel.fromJson(json))
        .toList();
  }

  Future<List<PriceListDetailModel>> getAllPriceListDetails() async {
    final response = await _apiProvider.getAllPriceListDetails();
    return (response.data as List)
        .map((json) => PriceListDetailModel.fromJson(json))
        .toList();
  }

  Future<List<InvoiceResponseModel>> fetchAndSaveAllInvoices(
    int agentId,
  ) async {
    try {
      logger.d('📡 Fetching ALL invoices for agent $agentId (no filters)');

      final response = await _apiProvider.getAllInvoices(agentId);

      logger.d('✅ API Response received: ${response.data}');

      // Handle nested response structure: response.data['invoices']
      List invoicesList;
      if (response.data is List) {
        invoicesList = response.data;
      } else {
        invoicesList = response.data['invoices'] ?? response.data['data'] ?? [];
      }

      logger.d('📊 Invoices list type: ${invoicesList.runtimeType}');
      logger.d('📊 Invoices list length: ${invoicesList.length}');

      final invoices = invoicesList
          .map((json) => InvoiceResponseModel.fromJson(json))
          .toList();

      logger.i('✅ Fetched and parsed ${invoices.length} invoices');

      // Save to local storage
      await _storage.saveInvoices(invoices);

      return invoices;
    } catch (e, stackTrace) {
      logger.e('❌ ERROR in fetchAndSaveAllInvoices: $e');
      logger.e('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<VoucherResponseModel>> fetchAndSaveAllVouchers(
    int agentId,
  ) async {
    try {
      logger.i('🔄 Fetching all vouchers for agent: $agentId');

      final response = await _apiProvider.getAllVouchers(agentId);
      logger.d('📦 Response data type: ${response.data.runtimeType}');

      // Handle nested response structure similar to invoices
      final dynamic vouchersList =
          response.data['transactions'] ??
          response.data['vouchers'] ??
          response.data['data'] ??
          response.data;

      logger.d('📊 Vouchers list type: ${vouchersList.runtimeType}');
      logger.d('📊 Vouchers list length: ${vouchersList.length}');

      final vouchers = (vouchersList as List)
          .map((json) => VoucherResponseModel.fromJson(json))
          .toList();

      logger.i('✅ Fetched and parsed ${vouchers.length} vouchers');

      // Save to local storage
      await _storage.saveVouchers(vouchers);

      return vouchers;
    } catch (e, stackTrace) {
      logger.e('❌ ERROR in fetchAndSaveAllVouchers: $e');
      logger.e('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<VisitResponseModel>> fetchAndSaveAllVisits(int agentId) async {
    try {
      logger.i('🔄 Fetching all negative visits for agent: $agentId');

      final response = await _apiProvider.getNegativeVisits(agentId);
      logger.d('📦 Response data type: ${response.data.runtimeType}');

      // Handle nested response structure similar to invoices/vouchers
      final dynamic visitsList =
          response.data['visits'] ?? response.data['data'] ?? response.data;

      logger.d('📊 Visits list type: ${visitsList.runtimeType}');
      logger.d('📊 Visits list length: ${visitsList.length}');

      final visits = (visitsList as List)
          .map((json) => VisitResponseModel.fromJson(json))
          .toList();

      logger.i('✅ Fetched and parsed ${visits.length} visits');

      // Save to local storage
      await _storage.saveVisits(visits);

      return visits;
    } catch (e, stackTrace) {
      logger.e('❌ ERROR in fetchAndSaveAllVisits: $e');
      logger.e('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<StockModel>> getAgentStock(int storeId) async {
    try {
      logger.i('📊 Fetching stock for store: $storeId');

      final response = await _apiProvider.getAgentStock(storeId);

      final data = response.data['data'] as List;
      logger.d('📦 Stock data list length: ${data.length}');

      final stocks = data.map((json) => StockModel.fromJson(json)).toList();

      logger.i('✅ Fetched ${stocks.length} stock items');

      return stocks;
    } catch (e, stackTrace) {
      logger.e('❌ ERROR in getAgentStock: $e');
      logger.e('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<CashBalanceModel> getCashBalance(
    int agentId, {
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      logger.i('📊 Fetching cash balance for agent: $agentId');

      final response = await _apiProvider.getCashBalance(
        agentId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      final data = response.data['data'];
      logger.d('📦 Cash balance data: $data');

      final balance = CashBalanceModel.fromJson(data);

      logger.i('✅ Fetched cash balance successfully');

      return balance;
    } catch (e, stackTrace) {
      logger.e('❌ ERROR in getCashBalance: $e');
      logger.e('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> syncData(int agentId, int storeId) async {
    // Fetch all invoices without filters
    await fetchAndSaveAllInvoices(agentId);

    // Fetch all vouchers without filters
    await fetchAndSaveAllVouchers(agentId);

    // Fetch all negative visits
    await fetchAndSaveAllVisits(agentId);

    // Fetch stock data
    try {
      final stocks = await getAgentStock(storeId);
      await _storage.saveStock(stocks);
      logger.i('✅ Stock data synced successfully');
    } catch (e) {
      logger.w('⚠️ Failed to sync stock data: $e');
      // Non-critical, don't throw
    }

    // Fetch cash balance data for last 7 days
    try {
      final dateFormat = DateFormat('dd/MM/yyyy');
      final toDate = DateTime.now();
      final fromDate = toDate.subtract(Duration(days: 7));

      final balance = await getCashBalance(
        agentId,
        dateFrom: dateFormat.format(fromDate),
        dateTo: dateFormat.format(toDate),
      );
      await _storage.saveCashBalance(balance);
      logger.i('✅ Cash balance synced successfully');
    } catch (e) {
      logger.w('⚠️ Failed to sync cash balance: $e');
      // Non-critical, don't throw
    }
  }
}
