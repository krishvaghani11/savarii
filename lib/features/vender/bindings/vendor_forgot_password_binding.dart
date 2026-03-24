import 'package:get/get.dart';
import '../controllers/vendor_forgot_password_controller.dart';

class VendorForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorForgotPasswordController>(() => VendorForgotPasswordController());
  }
}