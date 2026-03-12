import 'package:get/get.dart';
import '../controllers/vendor_view_tickets_controller.dart';

class VendorViewTicketsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorViewTicketsController>(
      () => VendorViewTicketsController(),
    );
  }
}
