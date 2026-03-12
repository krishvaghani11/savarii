import 'package:get/get.dart';
import '../controllers/vendor_payment_details_controller.dart';

class VendorPaymentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorPaymentDetailsController>(
      () => VendorPaymentDetailsController(),
    );
  }
}
