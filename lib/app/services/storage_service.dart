import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/agent_model.dart';
import '../data/models/customer_model.dart';
import '../data/models/item_model.dart';
import '../data/models/price_list_detail_model.dart';
import '../data/models/invoice_model.dart';
import '../data/models/voucher_model.dart';
import '../data/models/visit_model.dart';
import '../data/models/stock_model.dart';
import '../data/models/cash_balance_model.dart';
import '../utils/logger.dart';

class StorageService extends GetxService {
  late Box<AgentModel> _agentBox;
  late Box<CustomerModel> _customerBox;
  late Box<ItemModel> _itemBox;
  late Box<PriceListDetailModel> _priceListBox;
  late Box<InvoiceResponseModel> _invoicesBox;
  late Box<VoucherResponseModel> _vouchersBox;
  late Box<VisitResponseModel> _visitsBox;
  late Box<StockModel> _stockBox;
  late Box<CashBalanceModel> _cashBalanceBox;
  late Box _pendingInvoicesBox;
  late Box _pendingVouchersBox;
  late Box _pendingVisitsBox;
  late Box _settingsBox;

  Future<StorageService> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(AgentModelAdapter());
    Hive.registerAdapter(CustomerModelAdapter());
    Hive.registerAdapter(PriceListInfoAdapter());
    Hive.registerAdapter(ItemModelAdapter());
    Hive.registerAdapter(PriceListDetailModelAdapter());
    Hive.registerAdapter(ItemInfoAdapter());
    Hive.registerAdapter(PriceListInfoDetailAdapter());
    Hive.registerAdapter(InvoiceResponseModelAdapter());
    Hive.registerAdapter(VoucherResponseModelAdapter());
    Hive.registerAdapter(VisitResponseModelAdapter());
    Hive.registerAdapter(StockModelAdapter());
    Hive.registerAdapter(CashBalanceModelAdapter());

    _agentBox = await Hive.openBox<AgentModel>('agent');
    _customerBox = await Hive.openBox<CustomerModel>('customers');
    _itemBox = await Hive.openBox<ItemModel>('items');
    _priceListBox = await Hive.openBox<PriceListDetailModel>('price_lists');
    _invoicesBox = await Hive.openBox<InvoiceResponseModel>('invoices');
    _vouchersBox = await Hive.openBox<VoucherResponseModel>('vouchers');
    _visitsBox = await Hive.openBox<VisitResponseModel>('visits');
    _stockBox = await Hive.openBox<StockModel>('stock');
    _cashBalanceBox = await Hive.openBox<CashBalanceModel>('cash_balance');
    _pendingInvoicesBox = await Hive.openBox('pending_invoices');
    _pendingVouchersBox = await Hive.openBox('pending_vouchers');
    _pendingVisitsBox = await Hive.openBox('pending_visits');
    _settingsBox = await Hive.openBox('settings');

    return this;
  }

  // Agent
  Future<void> saveAgent(AgentModel agent) async {
    await _agentBox.put('current', agent);
    logger.d('✅ STORAGE: Agent saved - ${agent.name}');
  }

  AgentModel? getAgent() {
    var agent = _agentBox.get('current');
    if (agent != null) {
      logger.d('✅ STORAGE: Agent found - ${agent.name}');
    } else {
      logger.w('❌ STORAGE: No agent found');
    }
    return agent;
  }

  bool get isLoggedIn => _agentBox.get('current') != null;

  Future<void> clearAgent() async {
    await _agentBox.clear();
    logger.d('🗑️ STORAGE: Agent data cleared');
  }

  // Customers
  Future<void> saveCustomers(List<CustomerModel> customers) async {
    await _customerBox.clear();
    for (var customer in customers) {
      await _customerBox.put(customer.id, customer);
    }
  }

  List<CustomerModel> getCustomers() => _customerBox.values.toList();

  // Items
  Future<void> saveItems(List<ItemModel> items) async {
    await _itemBox.clear();
    for (var item in items) {
      await _itemBox.put(item.id, item);
    }
  }

  List<ItemModel> getItems() => _itemBox.values.toList();

  // Price Lists
  Future<void> savePriceListDetails(List<PriceListDetailModel> details) async {
    for (var detail in details) {
      await _priceListBox.put(detail.id, detail);
    }
  }

  List<PriceListDetailModel> getPriceListDetails(int priceListId) {
    return _priceListBox.values
        .where((detail) => detail.priceList.id == priceListId)
        .toList();
  }

  // Invoices (fetched from server)
  Future<void> saveInvoices(List<InvoiceResponseModel> invoices) async {
    await _invoicesBox.clear();
    for (var invoice in invoices) {
      await _invoicesBox.put(invoice.id, invoice);
    }
    logger.d('✅ STORAGE: ${invoices.length} invoices saved');
  }

  List<InvoiceResponseModel> getInvoices() {
    return _invoicesBox.values.toList();
  }

  List<InvoiceResponseModel> getInvoicesByType(int invoiceType) {
    return _invoicesBox.values
        .where((invoice) => invoice.invoiceType == invoiceType)
        .toList();
  }

  List<InvoiceResponseModel> getFilteredInvoices({
    int? invoiceType,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    var invoices = _invoicesBox.values.toList();

    if (invoiceType != null) {
      invoices = invoices
          .where((inv) => inv.invoiceType == invoiceType)
          .toList();
    }

    if (fromDate != null) {
      invoices = invoices.where((inv) {
        return inv.invoiceDate.isAfter(fromDate.subtract(Duration(days: 1)));
      }).toList();
    }

    if (toDate != null) {
      invoices = invoices.where((inv) {
        return inv.invoiceDate.isBefore(toDate.add(Duration(days: 1)));
      }).toList();
    }

    return invoices;
  }

  // Vouchers
  Future<void> saveVouchers(List<VoucherResponseModel> vouchers) async {
    await _vouchersBox.clear();
    await _vouchersBox.addAll(vouchers);
  }

  List<VoucherResponseModel> getVouchers() {
    return _vouchersBox.values.toList();
  }

  List<VoucherResponseModel> getVouchersByType(int type) {
    return _vouchersBox.values.where((v) => v.type == type).toList();
  }

  List<VoucherResponseModel> getFilteredVouchers({
    int? type,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    List<VoucherResponseModel> vouchers = _vouchersBox.values.toList();

    if (type != null) {
      vouchers = vouchers.where((v) => v.type == type).toList();
    }

    if (fromDate != null) {
      vouchers = vouchers.where((v) {
        return v.voucherDate.isAfter(fromDate.subtract(Duration(days: 1)));
      }).toList();
    }

    if (toDate != null) {
      vouchers = vouchers.where((v) {
        return v.voucherDate.isBefore(toDate.add(Duration(days: 1)));
      }).toList();
    }

    return vouchers;
  }

  // Pending Invoices
  Future<void> addPendingInvoice(Map<String, dynamic> invoice) async {
    await _pendingInvoicesBox.add(invoice);
  }

  List<Map<String, dynamic>> getPendingInvoices() {
    return _pendingInvoicesBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> clearPendingInvoices() async {
    await _pendingInvoicesBox.clear();
  }

  // Pending Vouchers
  Future<void> addPendingVoucher(Map<String, dynamic> voucher) async {
    await _pendingVouchersBox.add(voucher);
  }

  List<Map<String, dynamic>> getPendingVouchers() {
    return _pendingVouchersBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> clearPendingVouchers() async {
    await _pendingVouchersBox.clear();
  }

  // Pending Visits
  Future<void> addPendingVisit(Map<String, dynamic> visit) async {
    await _pendingVisitsBox.add(visit);
  }

  List<Map<String, dynamic>> getPendingVisits() {
    return _pendingVisitsBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> clearPendingVisits() async {
    await _pendingVisitsBox.clear();
  }

  bool get hasPendingData =>
      _pendingInvoicesBox.isNotEmpty ||
      _pendingVouchersBox.isNotEmpty ||
      _pendingVisitsBox.isNotEmpty;

  // Get counts for sync dialog
  int get pendingInvoicesCount => _pendingInvoicesBox.length;
  int get pendingVouchersCount => _pendingVouchersBox.length;
  int get pendingVisitsCount => _pendingVisitsBox.length;

  // Remove specific items by index (for granular sync control)
  Future<void> removePendingInvoiceAt(int index) async {
    final key = _pendingInvoicesBox.keys.elementAt(index);
    await _pendingInvoicesBox.delete(key);
  }

  Future<void> removePendingVoucherAt(int index) async {
    final key = _pendingVouchersBox.keys.elementAt(index);
    await _pendingVouchersBox.delete(key);
  }

  Future<void> removePendingVisitAt(int index) async {
    final key = _pendingVisitsBox.keys.elementAt(index);
    await _pendingVisitsBox.delete(key);
  }

  // Visits (Negative Visits)
  Future<void> saveVisits(List<VisitResponseModel> visits) async {
    await _visitsBox.clear();
    await _visitsBox.addAll(visits);
    logger.d('✅ STORAGE: ${visits.length} visits saved');
  }

  List<VisitResponseModel> getVisits() {
    return _visitsBox.values.toList();
  }

  List<VisitResponseModel> getFilteredVisits({
    DateTime? fromDate,
    DateTime? toDate,
    int? customerId,
  }) {
    List<VisitResponseModel> visits = _visitsBox.values.toList();

    if (customerId != null) {
      visits = visits.where((v) => v.customerVendorId == customerId).toList();
    }

    if (fromDate != null) {
      visits = visits.where((v) {
        return v.date.isAfter(fromDate.subtract(Duration(days: 1)));
      }).toList();
    }

    if (toDate != null) {
      visits = visits.where((v) {
        return v.date.isBefore(toDate.add(Duration(days: 1)));
      }).toList();
    }

    return visits;
  }

  // Stock
  Future<void> saveStock(List<StockModel> stock) async {
    await _stockBox.clear();
    for (var item in stock) {
      await _stockBox.put(item.itemId, item);
    }
    logger.d('✅ STORAGE: ${stock.length} stock items saved');
  }

  List<StockModel> getStock() {
    return _stockBox.values.toList();
  }

  // Cash Balance
  Future<void> saveCashBalance(CashBalanceModel balance) async {
    await _cashBalanceBox.clear();
    await _cashBalanceBox.put('latest', balance);
    logger.d('✅ STORAGE: Cash balance saved');
  }

  CashBalanceModel? getCashBalance() {
    return _cashBalanceBox.get('latest');
  }

  // Settings - Theme and Language
  Future<void> saveThemeMode(String themeMode) async {
    await _settingsBox.put('themeMode', themeMode);
    logger.d('✅ STORAGE: Theme mode saved - $themeMode');
  }

  String getThemeMode() {
    return _settingsBox.get('themeMode', defaultValue: 'light');
  }

  Future<void> saveLanguage(String language) async {
    await _settingsBox.put('language', language);
    logger.d('✅ STORAGE: Language saved - $language');
  }

  String getLanguage() {
    return _settingsBox.get('language', defaultValue: 'ar');
  }
}
