import 'package:get/get.dart';
import '../controllers/invoice_controller.dart';

class InvoiceBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [
      Bind.lazyPut<InvoiceController>(() => InvoiceController()),
    ];
  }
}
