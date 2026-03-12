import 'package:get/get.dart';
import '../controllers/vendor_payment_confirmation_controller.dart';

class VendorPaymentConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorPaymentConfirmationController>(
      () => VendorPaymentConfirmationController(),
    );
  }
}
