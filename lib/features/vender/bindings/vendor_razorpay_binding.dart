import 'package:get/get.dart';
import '../controllers/vendor_razorpay_controller.dart';

class VendorRazorpayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorRazorpayController>(
      () => VendorRazorpayController(),
    );
  }
}
