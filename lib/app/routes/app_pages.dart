import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/splash_view.dart';
import '../modules/home/bindings/invoices_binding.dart';
import '../modules/home/bindings/orders_binding.dart';
import '../modules/home/bindings/visit_plan_binding.dart';
import '../modules/home/bindings/vouchers_binding.dart';
import '../modules/home/bindings/negative_visits_binding.dart';
import '../modules/home/views/invoices_view.dart';
import '../modules/home/views/orders_view.dart';
import '../modules/home/views/visit_plan_view.dart';
import '../modules/home/views/vouchers_view.dart';
import '../modules/home/views/negative_visits_view.dart';
import '../modules/invoice/bindings/invoice_binding.dart';
import '../modules/invoice/views/invoice_view.dart';
import '../modules/voucher/bindings/voucher_binding.dart';
import '../modules/voucher/views/voucher_view.dart';
import '../modules/visit/bindings/visit_binding.dart';
import '../modules/visit/views/visit_view.dart';
import '../modules/reports/bindings/reports_binding.dart';
import '../modules/reports/bindings/items_stock_binding.dart';
import '../modules/reports/bindings/cash_balance_binding.dart';
import '../modules/reports/views/reports_view.dart';
import '../modules/reports/views/items_stock_view.dart';
import '../modules/reports/views/cash_balance_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => SplashView()),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => VisitPlanView(),
      binding: VisitPlanBinding(),
    ),
    GetPage(
      name: AppRoutes.invoices,
      page: () => InvoicesView(),
      binding: InvoicesBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => OrdersView(),
      binding: OrdersBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.visitPlan,
      page: () => VisitPlanView(),
      binding: VisitPlanBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.vouchers,
      page: () => VouchersView(),
      binding: VouchersBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.negativeVisits,
      page: () => NegativeVisitsView(),
      binding: NegativeVisitsBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.invoice,
      page: () => InvoiceView(),
      binding: InvoiceBinding(),
    ),
    GetPage(
      name: AppRoutes.voucher,
      page: () => VoucherView(),
      binding: VoucherBinding(),
    ),
    GetPage(
      name: AppRoutes.visit,
      page: () => VisitView(),
      binding: VisitBinding(),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => ReportsView(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: AppRoutes.itemsStock,
      page: () => ItemsStockView(),
      binding: ItemsStockBinding(),
    ),
    GetPage(
      name: AppRoutes.cashBalance,
      page: () => CashBalanceView(),
      binding: CashBalanceBinding(),
    ),
  ];
}
