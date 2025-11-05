import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/agent_model.dart';
import '../data/models/customer_model.dart';
import '../data/models/item_model.dart';
import '../data/models/price_list_detail_model.dart';
import '../utils/logger.dart';

class StorageService extends GetxService {
  late Box<AgentModel> _agentBox;
  late Box<CustomerModel> _customerBox;
  late Box<ItemModel> _itemBox;
  late Box<PriceListDetailModel> _priceListBox;
  late Box _pendingInvoicesBox;
  late Box _pendingVouchersBox;
  late Box _pendingVisitsBox;

  Future<StorageService> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(AgentModelAdapter());
    Hive.registerAdapter(CustomerModelAdapter());
    Hive.registerAdapter(PriceListInfoAdapter());
    Hive.registerAdapter(ItemModelAdapter());
    Hive.registerAdapter(PriceListDetailModelAdapter());
    Hive.registerAdapter(ItemInfoAdapter());
    Hive.registerAdapter(PriceListInfoDetailAdapter());
    
    _agentBox = await Hive.openBox<AgentModel>('agent');
    _customerBox = await Hive.openBox<CustomerModel>('customers');
    _itemBox = await Hive.openBox<ItemModel>('items');
    _priceListBox = await Hive.openBox<PriceListDetailModel>('price_lists');
    _pendingInvoicesBox = await Hive.openBox('pending_invoices');
    _pendingVouchersBox = await Hive.openBox('pending_vouchers');
    _pendingVisitsBox = await Hive.openBox('pending_visits');
    
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
}
