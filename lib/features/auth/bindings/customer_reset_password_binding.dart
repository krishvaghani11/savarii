import 'package:get/get.dart';
import '../controllers/customer_reset_password_controller.dart';

class CustomerResetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerResetPasswordController>(() => CustomerResetPasswordController());
  }
}