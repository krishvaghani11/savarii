import 'package:get/get.dart';
import '../controllers/vendor_book_ticket_controller.dart';

class VendorBookTicketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorBookTicketController>(() => VendorBookTicketController());
  }
}
