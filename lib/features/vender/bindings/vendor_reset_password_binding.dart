import 'package:get/get.dart';
import '../controllers/vendor_reset_password_controller.dart';

class VendorResetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorResetPasswordController>(() => VendorResetPasswordController());
  }
}