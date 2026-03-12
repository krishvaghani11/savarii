import 'package:get/get.dart';
import '../controllers/vendor_otp_controller.dart';

class VendorOtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorOtpController>(() => VendorOtpController());
  }
}
